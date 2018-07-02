#import <Foundation/Foundation.h>

@interface MSAssetsUpdateUtilities : NSObject

- (void)addContentsOfFolderToManifest:(NSMutableArray<NSString *> *)manifest
                           folderPath:(NSString *)folderPath
                           pathPrefix:(NSString *)pathPrefix;

- (BOOL)isHashIgnoredFor:(NSString *)relativeFilePath;

- (NSString *)computeHashFor:(NSData *)data;

- (BOOL)verifyFolderHash: (NSString *)expectedHash
               folderPath:(NSString *)folderPath
                    error:(NSError *  __autoreleasing *)error;

- (void)copyNecessaryFilesFromCurrentPackage: (NSString *)currentPackageFolderPath
                            diffManifestPath:(NSString *)diffManifestPath
                              newPackagePath:(NSString *)newPackagePath
                                       error:(NSError * __autoreleasing *)error;

- (NSString *)getHashForBinaryContents:(NSURL *)binaryBundleUrl
                      bundleAssetsPath:(NSString *)assetsPath
                                 error:(NSError * __autoreleasing *)error;

- (NSDictionary *) verifyAndDecodeJWT:(NSString *)jwt
                        withPublicKey:(NSString *)publicKey
                                error:(NSError **)error;

- (NSString *)getKeyValueFromPublicKeyString:(NSString *)publicKeyString;

- (BOOL)verifyUpdateSignatureFor:(NSString *)folderPath
                    expectedHash:(NSString *)newUpdateHash
                   withPublicKey:(NSString *)publicKeyString
                           error:(NSError **)error;

- (NSString *)findEntryPointInFolder:(NSString *)folderPath
                    expectedFileName:(NSString *)expectedFileName
                               error:(NSError **)error;

- (NSString *)getSignatureFilePath:(NSString *)updateFolderPath;

- (NSString *)getSignatureFor:(NSString *)folderPath
                        error:(NSError **)error;

@end
