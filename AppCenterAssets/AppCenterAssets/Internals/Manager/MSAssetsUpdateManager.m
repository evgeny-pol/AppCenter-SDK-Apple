#import "MSAssetsUpdateManager.h"
#import "MSAssetsPackageInfo.h"
#import "MSUtility+File.h"
#import "MSAssetsErrorUtils.h"
#import "MSAssetsFileUtils.h"
#import "MSAssetsConstants.h"
#import "MSLogger.h"
#import "MSAssets.h"
#import "MSAssetsUpdateUtilities+JWT.h"

@implementation MSAssetsUpdateManager 

static NSString *const DiffManifestFileName = @"hotcodepush.json";
static NSString *const DownloadFileName = @"download.zip";
static NSString *const RelativeBundlePathKey = @"bundlePath";
static NSString *const StatusFile = @"codepush.json";
static NSString *const UpdateBundleFileName = @"app.jsbundle";
static NSString *const UpdateMetadataFileName = @"app.json";
static NSString *const UnzippedFolderName = @"unzipped";

- (instancetype)initWithUpdateUtils:(MSAssetsUpdateUtilities *)updateUtilities {
    if ((self = [super init])) {
        _updateUtilities = updateUtilities;
    }
    return self;
}

- (MSLocalPackage *)getCurrentPackage:(NSError * __autoreleasing *)error {
    NSString *packageHash = [self getCurrentPackageHash:error];
    if (!packageHash) {
        return nil;
    }

    return [self getPackage:packageHash error:error];
}

- (NSString *)getCurrentPackageHash:(NSError * __autoreleasing *)error {
    MSAssetsPackageInfo *info = [self getCurrentPackageInfo:error];
    if (!info) {
        return nil;
    }

    return info.currentPackage;
}

- (MSAssetsPackageInfo *)getCurrentPackageInfo:(NSError * __autoreleasing *)error {
    NSString *statusFilePath = [self getStatusFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:statusFilePath]) {
        return [[MSAssetsPackageInfo alloc] init];
    }

    NSString *content = [NSString stringWithContentsOfFile:statusFilePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:error];
    if (!content) {
        return nil;
    }

    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:error];
    if (!json) {
        return nil;
    }

    return [[MSAssetsPackageInfo alloc] initWithDictionary:json];
}

- (MSLocalPackage *)getPackage:(NSString *)packageHash
                          error:(NSError * __autoreleasing *)error {
    NSString *updateDirectoryPath = [self getPackageFolderPath:packageHash];
    NSString *updateMetadataFilePath = [updateDirectoryPath stringByAppendingPathComponent:UpdateMetadataFileName];

    if (![[NSFileManager defaultManager] fileExistsAtPath:updateMetadataFilePath]) {
        return nil;
    }

    NSString *updateMetadataString = [NSString stringWithContentsOfFile:updateMetadataFilePath
                                                               encoding:NSUTF8StringEncoding
                                                                  error:error];
    if (!updateMetadataString) {
        return nil;
    }

    NSData *updateMetadata = [updateMetadataString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:updateMetadata
                                                         options:kNilOptions
                                                           error:error];

    if (!json) {
        return nil;
    }

    return [[MSLocalPackage alloc] initWithDictionary:json];
}

- (NSString *)getPackageFolderPath:(NSString *)packageHash {
    return [[self getMSAssetsPath] stringByAppendingPathComponent:packageHash];
}

- (MSLocalPackage *)getPreviousPackage:(NSError * __autoreleasing *)error {
    NSString *packageHash = [self getPreviousPackageHash:error];
    if (!packageHash) {
        return nil;
    }

    return [self getPackage:packageHash error:error];
}

- (NSString *)getPreviousPackageHash:(NSError * __autoreleasing *)error {
    MSAssetsPackageInfo *info = [self getCurrentPackageInfo:error];
    if (!info) {
        return nil;
    }

    return info.previousPackage;
}

- (NSString *)getStatusFilePath {
    return [[self getMSAssetsPath] stringByAppendingPathComponent:StatusFile];
}

- (NSString *)getMSAssetsPath {
    NSString* assetsPath = [[self  getApplicationSupportDirectory] stringByAppendingPathComponent:@"Assets"];
    if (![MSUtility fileExistsForPathComponent:assetsPath]) {
        NSURL *result = [MSUtility createDirectoryForPathComponent:assetsPath];
        if (!result) {
            MSLogError([MSAssets logTag], @"Can't create directory %@ for downloading file", assetsPath);
            return nil;
        }
        [result setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
    /*if ([MSAssetsDeploymentInstance isUsingTestConfiguration]) {
        assetsPath = [assetsPath stringByAppendingPathComponent:@"TestPackages"];
    }*/

    return assetsPath;
}

- (NSString *)getApplicationSupportDirectory {
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return applicationSupportDirectory;
}

- (NSString *)getDownloadFilePath {
    NSString *assetsPath = [self getMSAssetsPath];
    if (assetsPath) {
        return [[self getMSAssetsPath] stringByAppendingPathComponent:DownloadFileName];
    }
    return nil;
}

- (NSString *)getUnzippedFolderPath {
    return [[self getMSAssetsPath] stringByAppendingPathComponent:UnzippedFolderName];
}

- (NSString *)currentPackageFolderPathWithError:(NSError * __autoreleasing *)error {
    NSString *packageHash = [self getCurrentPackageHash:error];
    if (packageHash == nil) {
        return nil;
    }
    return [self getPackageFolderPath:packageHash];
}

- (void)unzipPackage:(NSString *)filePath
               error:(NSError * __autoreleasing *)error {
    NSString *unzippedFolderPath = [self getUnzippedFolderPath];
    BOOL result = [MSAssetsFileUtils unzipFileAtPath:filePath toDestination:unzippedFolderPath];
    if (result) {
        result = [MSUtility deleteItemForPathComponent:filePath];
        if (!result) {
            *error = [MSAssetsErrorUtils getFileDeleteError:filePath];
        }
    } else {
        *error = [MSAssetsErrorUtils getFileUnzipError:filePath destination:unzippedFolderPath];
    }
}

- (NSString *)mergeDiffWithNewUpdateFolder:(NSString *)newUpdateFolderPath
                     newUpdateMetadataPath:(NSString *)newUpdateMetadataPath
                             newUpdateHash:(NSString *)newUpdateHash
                           publicKeyString:(NSString *)publicKeyString
                expectedEntryPointFileName:(NSString *)expectedEntryPointFileName
                                     error:(NSError * __autoreleasing *)error {
    NSString *unzippedFolderPath = [self getUnzippedFolderPath];
    NSString *diffManifestPath = [unzippedFolderPath stringByAppendingPathComponent: DiffManifestFileName];
    BOOL isDiffUpdate = [MSUtility fileExistsForPathComponent:diffManifestPath];
    if (isDiffUpdate) {
        NSString *currentPackageFolderPath = [self currentPackageFolderPathWithError:error];
        if (error) {
            return nil;
        }
        if (currentPackageFolderPath != nil) {
            [[self updateUtilities] copyNecessaryFilesFromCurrentPackage:currentPackageFolderPath
                                                        diffManifestPath:diffManifestPath
                                                          newPackagePath:newUpdateFolderPath
                                                                   error:error];
            if (error) {
                return nil;
            }
        } else {
            //TODO: Check this scenario with old rn cp plugin.
        }
        BOOL deleted = [MSUtility deleteItemForPathComponent:diffManifestPath];
        if (!deleted) {
            *error = [MSAssetsErrorUtils getFileDeleteError:diffManifestPath];
            return nil;
        }
    }
    BOOL result = [MSAssetsFileUtils copyDirectoryContentsFrom:unzippedFolderPath to:newUpdateFolderPath];
    if (!result) {
        *error = [MSAssetsErrorUtils getFileCopyError:unzippedFolderPath destination:newUpdateFolderPath];
        return nil;
    }
    BOOL deleted = [MSUtility deleteItemForPathComponent:unzippedFolderPath];
    if (!deleted) {
        
        //Not a breaking error.
        MSLogInfo([MSAssets logTag], @"Error deleting downloaded file: %@", unzippedFolderPath);
    }
    NSString *entryPoint = [[self updateUtilities] findEntryPointInFolder:newUpdateFolderPath
                                                         expectedFileName:expectedEntryPointFileName
                                                                    error:error];
    if (error) {
        return nil;
    }
    if ([MSUtility fileExistsForPathComponent:newUpdateMetadataPath]) {
        deleted = [MSUtility deleteItemForPathComponent:newUpdateMetadataPath];
        if (!deleted) {
            *error = [MSAssetsErrorUtils getFileDeleteError:newUpdateMetadataPath];
            return nil;
        }
    }
    MSLogInfo([MSAssets logTag], isDiffUpdate ? @"Applying diff update" : @"Applying full update");
    NSError *signatureError = [self verifySignatureForPath:newUpdateFolderPath
                   withPublicKey:publicKeyString
                   newUpdateHash:newUpdateHash
                      diffUpdate:isDiffUpdate];
    if (signatureError) {
        *error = signatureError;
        return nil;
    }
    return entryPoint;
}

- (NSError *)verifySignatureForPath:(NSString *)newUpdateFolderPath
                 withPublicKey:(NSString *)publicKey
                 newUpdateHash:(NSString *)newUpdateHash
                    diffUpdate:(BOOL)isDiffUpdate {
    NSError *error = nil;
    BOOL isSignatureVerificationEnabled = (publicKey != nil);
    NSString *signaturePath = [[self updateUtilities] getSignatureFilePath:newUpdateFolderPath];
    BOOL isSignatureAppearedInApp = [MSUtility fileExistsForPathComponent:signaturePath];
    if (isSignatureVerificationEnabled) {
        if (isSignatureAppearedInApp) {
            BOOL verified = [[self updateUtilities] verifyFolderHash:newUpdateHash folderPath:newUpdateFolderPath error:&error];
            if (!error) {
                if (!verified) {
                    error = [MSAssetsErrorUtils getIntegrityCheckError];
                } else {
                    BOOL isSignatureValid = [[self updateUtilities] verifyUpdateSignatureFor:newUpdateFolderPath expectedHash:newUpdateHash withPublicKey:publicKey error:&error];
                    if (!error) {
                        if (!isSignatureValid) {
                            error = [MSAssetsErrorUtils getCodeSigningCheckError];
                        }
                    }
                }
            }
        } else {
            error = [MSAssetsErrorUtils getNoSignatureError];
        }
    } else {
        if (isSignatureAppearedInApp) {
            MSLogInfo([MSAssets logTag], @"Warning! JWT signature exists in codepush update but code integrity check couldn't be performed because there is no public key configured. \
                      Please ensure that public key is properly configured within your application.");
            [[self updateUtilities] verifyFolderHash:newUpdateHash folderPath:newUpdateFolderPath error:&error];
        } else {
            if (isDiffUpdate) {
                BOOL verified = [[self updateUtilities] verifyFolderHash:newUpdateHash folderPath:newUpdateFolderPath error:&error];
                if (!error) {
                    if (!verified) {
                        error = [MSAssetsErrorUtils getIntegrityCheckError];
                    }
                }
            }
        }
    }
    return error;
}

@end
