#import <Foundation/Foundation.h>
#import "MSAssetsUpdateUtilities.h"
#import "MSUtility+File.h"
#import "MSUtility+StringFormatting.h"
#import "MSLogger.h"
#import "MSAssets.h"
#import "MSAssetsErrors.h"
#import "MSAssetsSettingManager.h"
#include <CommonCrypto/CommonDigest.h>
#import "JWT.h"

static NSString *const ManifestFolderPrefix = @"Assets";
@implementation MSAssetsUpdateUtilities

- (void)addContentsOfFolderToManifest:(NSMutableArray<NSString *> *)manifest
                          folderPath:(NSString *)folderPath
                          pathPrefix:(NSString *)pathPrefix {
    NSArray<NSURL *> *contents = [MSUtility contentsOfDirectory:folderPath propertiesForKeys:nil];
    
    if (contents == nil) {
        return;
    }
    for (NSURL *content in contents) {
        NSString *fileName = [[content absoluteString] lastPathComponent];
        NSString *fullFilePath = [folderPath stringByAppendingPathComponent:fileName];
        NSString *relativePath = [pathPrefix length] == 0 ? @"" : [pathPrefix stringByAppendingPathComponent:fileName];
        if ([self isHashIgnoredFor:relativePath]) {
            continue;
        }
        if ([content hasDirectoryPath]) {
            [self addContentsOfFolderToManifest:manifest folderPath: fullFilePath pathPrefix: relativePath];
        } else {
            NSData *fileData = [MSUtility loadDataForPathComponent: [content absoluteString]];
            [manifest addObject: [[relativePath stringByAppendingString:@":"] stringByAppendingString:[self computeHashFor: fileData]]];
        }
    }
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
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (dataString != nil) {
        return [MSUtility sha256:dataString];
    }
    return @"";
}

- (BOOL) verifyFolderHash: (NSString *)expectedHash
               folderPath:(NSString *)folderPath
                    error:(NSError *  __autoreleasing *)error {
    MSLogInfo([MSAssets logTag], @"Verifying hash for folder path: %@", folderPath);
    NSMutableArray<NSString *> *updateContentsManifest = [NSMutableArray<NSString* > array];
    [self addContentsOfFolderToManifest:updateContentsManifest folderPath:folderPath pathPrefix:@""];
    
    NSString *updateContentsManifestHash = [self computeFinalHashFromManifest:updateContentsManifest error:error];
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


- (void)copyNecessaryFilesFromCurrentPackage: (NSString * __unused)currentPackageFolderPath
                            diffManifestPath:(NSString *)diffManifestPath
                              newPackagePath:(NSString *)newPackagePath
                                       error:(NSError * __autoreleasing *)error {
    //[MSAssetsFieUtils copyEntriesInFolder:currentPackageFolderPath dest:newPackagePath];
    NSData *data = [NSData dataWithContentsOfFile:diffManifestPath];
    if (data != nil) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
        NSArray<NSString *> *deletedFiles = [dictionary objectForKey:@"deletedFiles"];
        for (NSString *deletedFile in deletedFiles) {
            NSString *fileToDelete = [newPackagePath stringByAppendingPathComponent:deletedFile];
            if ([MSUtility fileExistsForPathComponent:fileToDelete]) {
                if (![MSUtility deleteItemForPathComponent:fileToDelete]) {
                    NSDictionary *userInfo = @{kMSACFileErrorKey : kMSACDeleteFileErrorDesc(fileToDelete)};
                    NSError *newError = [NSError errorWithDomain:kMSACErrorDomain
                                                        code:kMSACFileErrorCode
                                                    userInfo:userInfo];
                    *error = newError;
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
    NSMutableDictionary *binaryHashDictionary = [MSAssetsSettingManager getBinaryHash];
    NSString *binaryHash = nil;
    if (binaryHashDictionary != nil) {
        binaryHash = [binaryHashDictionary objectForKey:binaryModifiedDate];
        if (binaryHash == nil) {
            [MSAssetsSettingManager removeBinaryHash];
        } else {
            return binaryHash;
        }
    }
    
    binaryHashDictionary = [NSMutableDictionary dictionary];
    NSMutableArray *manifest = [NSMutableArray array];
    
    // If the app is using assets, then add
    // them to the generated content manifest.
    if ([MSUtility fileExistsForPathComponent:assetsPath]) {
        [self addContentsOfFolderToManifest:manifest folderPath: assetsPath
                                               pathPrefix:[NSString stringWithFormat:@"%@/%@", ManifestFolderPrefix, @"assets"]];
    }
    
    [self addFileToManifest:binaryBundleUrl manifest:manifest];
    [self addFileToManifest:[binaryBundleUrl URLByAppendingPathExtension:@"meta"] manifest:manifest];
    
    binaryHash = [self computeFinalHashFromManifest:manifest error:error];
    
    // Cache the hash in user preferences. This assumes that the modified date for the
    // JS bundle changes every time a new bundle is generated by the packager.
    [binaryHashDictionary setObject:binaryHash forKey:binaryModifiedDate];
    [MSAssetsSettingManager saveBinaryHash:binaryHashDictionary];
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

- (NSDictionary *) verifyAndDecodeJWT:(NSString *)jwt
                        withPublicKey:(NSString *)publicKey
                                error:(NSError * __autoreleasing *)error {
    id <JWTAlgorithmDataHolderProtocol> verifyDataHolder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor publicKeyWithPEMBase64].type).algorithmName(@"RS256").secret(publicKey);
    
    JWTCodingBuilder *verifyBuilder = [JWTDecodingBuilder decodeMessage:jwt].addHolder(verifyDataHolder);
    JWTCodingResultType *verifyResult = verifyBuilder.result;
    if (verifyResult.successResult) {
        return verifyResult.successResult.payload;
    }
    else {
        *error = verifyResult.errorResult.error;
        return nil;
    }
}

- (NSString *)getKeyValueFromPublicKeyString:(NSString *)publicKeyString {
    publicKeyString = [publicKeyString stringByReplacingOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----\n"
                                                                 withString:@""];
    publicKeyString = [publicKeyString stringByReplacingOccurrencesOfString:@"-----END PUBLIC KEY-----"
                                                                 withString:@""];
    publicKeyString = [publicKeyString stringByReplacingOccurrencesOfString:@"\n"
                                                                 withString:@""];
    
    return publicKeyString;
}

- (BOOL)verifyUpdateSignatureFor:(NSString *)folderPath
                    expectedHash:(NSString *)newUpdateHash
                   withPublicKey:(NSString *)publicKeyString
                           error:(NSError * __autoreleasing *)error {
    MSLogInfo([MSAssets logTag], @"Verifying signature for folder path: %@", folderPath);
    
    NSString *publicKey = [self getKeyValueFromPublicKeyString: publicKeyString];
    
    NSError *signatureVerificationError;
    NSString *signature = [self getSignatureFor: folderPath
                                          error: &signatureVerificationError];
    if (signatureVerificationError) {
       MSLogError([MSAssets logTag], @"The update could not be verified because no signature was found. %@", signatureVerificationError);
        *error = signatureVerificationError;
        return false;
    }
    
    NSError *payloadDecodingError;
    NSDictionary *envelopedPayload = [self verifyAndDecodeJWT:signature withPublicKey:publicKey error:&payloadDecodingError];
    if(payloadDecodingError){
        MSLogError([MSAssets logTag], @"The update could not be verified because it was not signed by a trusted party. %@", payloadDecodingError);
        *error = payloadDecodingError;
        return false;
    }
    
    MSLogInfo([MSAssets logTag], @"JWT signature verification succeeded, payload content:  %@", envelopedPayload);
    
    if(![envelopedPayload objectForKey:@"contentHash"]){
        NSDictionary *userInfo = @{kMSACSignatureVerificationErrorKey : kMSACSignatureVerificationNoContentHashErrorDesc};
        NSError *newError = [NSError errorWithDomain:kMSACErrorDomain
                                                code:kMSACSignatureVerificationErrorCode
                                            userInfo:userInfo];
        *error = newError;
        return false;
    }
    
    NSString *contentHash = envelopedPayload[@"contentHash"];
    
    return [contentHash isEqualToString:newUpdateHash];
}

- (NSString *)findEntryPointInFolder:(NSString *)folderPath
                    expectedFileName:(NSString *)expectedFileName
                               error:(NSError * __autoreleasing *)error {
    NSArray<NSURL *>* folderFiles = [MSUtility contentsOfDirectory:folderPath propertiesForKeys:nil];
    if (!folderFiles) {
        return nil;
    }
    
    for (NSURL *file in folderFiles) {
        NSString *fileName = [[file absoluteString] lastPathComponent];
        NSString *fullFilePath = [folderPath stringByAppendingPathComponent:fileName];
        if ([file hasDirectoryPath]) {
            NSString *mainBundlePathInFolder = [self findEntryPointInFolder:fullFilePath
                                                           expectedFileName:expectedFileName
                                                                      error:error];
            if (mainBundlePathInFolder) {
                return [fileName stringByAppendingPathComponent:mainBundlePathInFolder];
            }
        } else if ([fileName isEqualToString:expectedFileName]) {
            return fileName;
        }
    }
    
    return nil;
}

- (NSString *)getSignatureFilePath:(NSString *)updateFolderPath {
    NSString *jwtPath = [NSString stringWithFormat:@"%@/%@/%@", updateFolderPath, ManifestFolderPrefix, /*BundleJWTFile*/ @""];
    if ([MSUtility fileExistsForPathComponent:jwtPath]) {
        return jwtPath;
    } else {
        NSArray<NSURL *> *contents = [MSUtility contentsOfDirectory:updateFolderPath propertiesForKeys:nil];
        for (NSURL *content in contents) {
            if ([content hasDirectoryPath]) {
                NSString *path = [self getSignatureFilePath:[content path]];
                if (path != nil) {
                    return path;
                }
            }
        }
    }
    return nil;
}

- (NSString *)getSignatureFor:(NSString *)folderPath
                        error:(NSError * __autoreleasing *)error {
    NSString *signatureFilePath = [self getSignatureFilePath:folderPath];
    if ([MSUtility fileExistsForPathComponent:signatureFilePath]) {
        return [NSString stringWithContentsOfFile:signatureFilePath encoding:NSUTF8StringEncoding error:error];
    } else {
        NSDictionary *userInfo = @{kMSACSignatureVerificationErrorKey : kMSACSignatureVerificationNoSignatureErrorDesc(signatureFilePath)};
        NSError *newError = [NSError errorWithDomain:kMSACErrorDomain
                                                code:kMSACSignatureVerificationErrorCode
                                            userInfo:userInfo];
        *error = newError;
        return nil;
    }
}
@end
