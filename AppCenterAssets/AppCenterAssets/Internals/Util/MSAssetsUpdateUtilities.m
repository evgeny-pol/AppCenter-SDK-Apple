#import <Foundation/Foundation.h>
#import "MSAssetsUpdateUtilities.h"
#import "MSAssetsUpdateUtilities+JWT.h"
#import "MSUtility+File.h"
#import "MSUtility+StringFormatting.h"
#import "MSAssets.h"
#import "MSLogger.h"
#import "MSAssetsErrorUtils.h"
#import "MSAssetsSettingManager.h"
#include <CommonCrypto/CommonDigest.h>

NSString *const ManifestFolderPrefix = @"CodePush";
NSString *const AssetsFolderName = @"assets";

@implementation MSAssetsUpdateUtilities

- (id)initWithSettingManager: (MSAssetsSettingManager*)settingManager{
    self = [super init];
    if (self) {
        self.settingManager = settingManager;
    }
    return self;
}

- (BOOL)addContentsOfFolderToManifest:(NSMutableArray<NSString *> *)manifest
                          folderPath:(NSString *)folderPath
                          pathPrefix:(NSString *)pathPrefix
                                error:(NSError *  __autoreleasing *)error {
    NSArray<NSURL *> * contents = [MSUtility contentsOfDirectory:folderPath propertiesForKeys:nil];
    
    if (contents == nil) {
        *error = [MSAssetsErrorUtils getNoDirError:folderPath];
        return NO;
    }
    for (NSURL *content in contents) {
        NSString *fileName = [[[content absoluteString] lastPathComponent] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        NSString *fullFilePath = [folderPath stringByAppendingPathComponent:fileName];
        NSString *relativePath = pathPrefix.length == 0 ? fileName : [pathPrefix stringByAppendingPathComponent:fileName];
        if ([self isHashIgnoredFor:relativePath]) {
            continue;
        }
        if ([content hasDirectoryPath]) {
            BOOL result = [self addContentsOfFolderToManifest:manifest folderPath: fullFilePath pathPrefix: relativePath error: error];
            if (!result) {
                return NO;
            }
        } else {
            NSData *fileData = [MSUtility loadDataForPathComponent: fullFilePath];
            if (fileData != nil) {
                [manifest addObject: [[relativePath stringByAppendingString:@":"] stringByAppendingString:[self computeHashFor: fileData]]];
            }
        }
    }
    return YES;
}

- (BOOL)isHashIgnoredFor:(NSString *)relativeFilePath {
    
    /* Note: The hashing logic here must mirror the hashing logic in other native SDK's, as well
     * as in the CLI. Ensure that any changes here are propagated to these other locations. */
    NSString *__MACOSX = @"__MACOSX/";
    NSString * DS_STORE = @".DS_Store";
    NSString *ASSETS_METADATA = @".codepushrelease";
    return [relativeFilePath hasPrefix:__MACOSX]
    || [relativeFilePath isEqualToString:DS_STORE]
    || [relativeFilePath hasSuffix:DS_STORE]
    || [relativeFilePath isEqualToString:ASSETS_METADATA]
    || [relativeFilePath hasSuffix:ASSETS_METADATA];
}

-(NSString *)computeHashFor:(NSData *)data {
//    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    if (data != nil) {
        return [MSUtility sha256WithData:data];
    }
    return @"";
}

- (BOOL) verifyFolderHash: (NSString *)expectedHash
               folderPath:(NSString *)folderPath
                    error:(NSError *  __autoreleasing *)error {
    MSLogInfo([MSAssets logTag], @"Verifying hash for folder path: %@", folderPath);
    NSMutableArray<NSString *> *updateContentsManifest = [NSMutableArray<NSString* > array];
    BOOL result = [self addContentsOfFolderToManifest:updateContentsManifest folderPath:folderPath pathPrefix:@"" error: error];
    if (!result) {
        return NO;
    }
    NSString *updateContentsManifestHash = [self computeFinalHashFromManifest:updateContentsManifest error:error];
    if (!updateContentsManifestHash) {
        return NO;
    }
    
    MSLogInfo([MSAssets logTag], @"Expected hash: %@, actual hash: %@", expectedHash, updateContentsManifestHash);
    return [expectedHash isEqualToString:updateContentsManifestHash];
}

- (NSString *)computeFinalHashFromManifest:(NSMutableArray *)manifest
                                     error:(NSError *__autoreleasing *)error {
    NSArray *sortedManifest = [manifest sortedArrayUsingSelector:@selector(compare:)];
    NSData *manifestData = [NSJSONSerialization dataWithJSONObject:sortedManifest
                                                           options:kNilOptions
                                                             error:error];
    if (!manifestData) {
        return nil;
    }
    
    NSString *manifestString = [[NSString alloc] initWithData:manifestData
                                                     encoding:NSUTF8StringEncoding];
    // The JSON serialization turns path separators into "\/", e.g. "CodePush\/assets\/image.png"
    manifestString = [manifestString stringByReplacingOccurrencesOfString:@"\\/"
                                                               withString:@"/"];
    return [self computeHashFor:[NSData dataWithBytes:manifestString.UTF8String length:manifestString.length]];
}


- (void)copyNecessaryFilesFromCurrentPackage: (NSString *)currentPackageFolderPath
                            diffManifestPath:(NSString *)diffManifestPath
                              newPackagePath:(NSString *)newPackagePath
                                       error:(NSError * __autoreleasing *)error {
    [MSUtility copyDirectoryContentsFromPathComponent:currentPackageFolderPath toPathComponent:newPackagePath];
    NSData *data = [MSUtility loadDataForPathComponent:diffManifestPath];
    if (data != nil) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
        NSArray<NSString *> *deletedFiles = [dictionary objectForKey:@"deletedFiles"];
        for (NSString *deletedFile in deletedFiles) {
            NSString *fileToDelete = [newPackagePath stringByAppendingPathComponent:deletedFile];
            if ([MSUtility fileExistsForPathComponent:fileToDelete]) {
                if (![MSUtility deleteItemForPathComponent:fileToDelete]) {
                    *error = [MSAssetsErrorUtils getFileDeleteError:fileToDelete];
                }
            }
        }
    }
}


- (NSString *)getHashForBinaryContents:(NSURL *)binaryBundleUrl
                      bundleAssetsPath:(NSString *)assetsPath
                                 error:(NSError * __autoreleasing *)error {
    // Get the cached hash from user preferences if it exists.
    NSString *binaryModifiedDate = [self modifiedDateStringOfFileAtURL:binaryBundleUrl];
    NSMutableDictionary *binaryHashDictionary = [[self settingManager] getBinaryHash];
    NSString *binaryHash = nil;
    if (binaryHashDictionary != nil) {
        binaryHash = [binaryHashDictionary objectForKey:binaryModifiedDate];
        if (binaryHash == nil) {
            [[self settingManager] removeBinaryHash];
        } else {
            return binaryHash;
        }
    }
    
    binaryHashDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *manifest = [NSMutableArray array];
    
    // If the app is using assets, then add
    // them to the generated content manifest.
    if ([MSUtility fileExistsForPathComponent:assetsPath]) {
        BOOL result = [self addContentsOfFolderToManifest:manifest folderPath: assetsPath
                                 pathPrefix:[NSString stringWithFormat:@"%@/%@", ManifestFolderPrefix, AssetsFolderName]
                                      error: error];
        if (!result) {
            return nil;
        }
    }
    
    [self addFileToManifest:binaryBundleUrl manifest:manifest];
    [self addFileToManifest:[binaryBundleUrl URLByAppendingPathExtension:@"meta"] manifest:manifest];
    
    binaryHash = [self computeFinalHashFromManifest:manifest error:error];
    
    // Cache the hash in user preferences. This assumes that the modified date for the
    // JS bundle changes every time a new bundle is generated by the packager.
    [binaryHashDictionary setObject:binaryHash forKey:binaryModifiedDate];
    [[self settingManager] saveBinaryHash:binaryHashDictionary];
    return binaryHash;
}

- (NSString *)modifiedDateStringOfFileAtURL:(NSURL *)fileURL {
    if (fileURL != nil) {
        NSString *filePath = [fileURL path];
        if (filePath != nil) {
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            NSDate *modifiedDate = [fileAttributes objectForKey:NSFileModificationDate];
            return [NSString stringWithFormat:@"%f", [modifiedDate timeIntervalSince1970]];
        }
    }
    return nil;
}

- (void)addFileToManifest:(NSURL *)fileURL
                 manifest:(NSMutableArray<NSString *> *)manifest {
    if ([MSUtility fileExistsForPathComponent:[fileURL path]]) {
        NSData *fileContents = [MSUtility loadDataForPathComponent:[fileURL path]];
        NSString *fileContentsHash = [self computeHashFor:fileContents];
        [manifest addObject:[NSString stringWithFormat:@"%@/%@:%@", ManifestFolderPrefix, [fileURL lastPathComponent], fileContentsHash]];
    }
}

- (NSString *)findEntryPointInFolder:(NSString *)folderPath
                    expectedFileName:(NSString *)expectedFileName {
    NSArray<NSURL *>* folderFiles = [MSUtility contentsOfDirectory:folderPath propertiesForKeys:nil];
    if (!folderFiles) {
        return nil;
    }
    
    for (NSURL *file in folderFiles) {
        NSString *fileName = [[file absoluteString] lastPathComponent];
        NSString *fullFilePath = [folderPath stringByAppendingPathComponent:fileName];
        BOOL isDir;
        NSString *fullPath;
        if ((fullPath = [file path]) && [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) {
            NSString *mainBundlePathInFolder = [self findEntryPointInFolder:fullFilePath expectedFileName:expectedFileName];
            if (mainBundlePathInFolder) {
                return [fileName stringByAppendingPathComponent:mainBundlePathInFolder];
            }
        } else if ([fileName isEqualToString:expectedFileName]) {
            return fileName;
        }
    }
    
    return nil;
}
@end
