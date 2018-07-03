#import "MSLocalPackage.h"
#import "MSAssetsUpdateUtilities.h"
#import "MSAssetsFileUtils.h"

/**
 * Manager responsible for update read/write actions.
 */
@interface MSAssetsUpdateManager : NSObject

@property (nonatomic, readonly, nullable) MSAssetsUpdateUtilities *updateUtilities;
@property (nonatomic, readonly, nullable) MSAssetsFileUtils *fileUtils;


/**
 * Initializes the manager with the necessary set of utils.
 *
 * @param updateUtilities instance of `MSAssetsUpdateUtilities`.
 * @param fileUtils instance of `MSAssetsFileUtils`.
 * @return manager instance.
 */
- (instancetype)initWithUpdateUtils:(MSAssetsUpdateUtilities *)updateUtilities
                       andFileUtils:(MSAssetsFileUtils *)fileUtils;

/**
 * Gets current package json object.
 *
 * @return current package json object.
*/
- (MSLocalPackage *)getCurrentPackage:(NSError **)error;

/**
 * Gets previous package json object.
 *
 * @return previous package json object.
*/
- (MSLocalPackage *)getPreviousPackage:(NSError **)error;

- (NSString *)getCurrentPackageHash:(NSError **)error;

/**
 * Gets package object by its hash.
 *
 * @param packageHash package identifier (hash).
 *
 * @return previous package json object.
*/
- (MSLocalPackage *)getPackage:(NSString *)packageHash
                          error:(NSError **)error;

/**
 * Gets folder for the package by the package hash.
 *
 * @param packageHash current package identifier (hash).
 * @return path to package folder.
 */
- (NSString *)getPackageFolderPath:(NSString *)packageHash;


/**
 * Gets the path for the download file.
 *
 * @return path for the download.
 */
- (NSString *)getDownloadFilePath;

/**
 * Unzips the following package file.
 *
 * @param filePath package file.
 * @param error an error if occurred during unzipping.
 */
- (void)unzipPackage:(NSString *)filePath
               error:(NSError * __autoreleasing *)error;

/**
 * Merges contents with the current update based on the manifest.
 *
 * @param newUpdateFolderPath        directory for new update.
 * @param newUpdateMetadataPath      path to update metadata file for new update.
 * @param newUpdateHash              hash of the new update package.
 * @param publicKeyString            public key used to verify signature.
 *                                   Can be `null` if code signing is not enabled.
 * @param expectedEntryPointFileName file name of the update entry point.
 * @param error error occurred during merging process (can be verification error, file error etc.).
 * @return actual new update entry point.
 */
- (NSString *)mergeDiffWithNewUpdateFolder:(NSString *)newUpdateFolderPath
                     newUpdateMetadataPath:(NSString *)newUpdateMetadataPath
                             newUpdateHash:(NSString *)newUpdateHash
                           publicKeyString:(NSString *)publicKeyString
                expectedEntryPointFileName:(NSString *)expectedEntryPointFileName
                                     error:(NSError * __autoreleasing *)error;

/**
 * Verifies package signature if code signing is enabled.
 *
 * @param newUpdateFolderPath path to the current update.
 * @param publicKey public key used to verify signature.
 *                        Can be `null` if code signing is not enabled.
 * @param newUpdateHash   hash of the update package.
 * @param isDiffUpdate    `true` if this is a diff update, `false` if this is a full update.
 * @param error signature verification error (in case signature is invalid or the update didn't pass the verification in any other way).
 */
- (void)verifySignatureForPath:(NSString *)newUpdateFolderPath
                 withPublicKey:(NSString *)publicKey
                 newUpdateHash:(NSString *)newUpdateHash
                    diffUpdate:(BOOL)isDiffUpdate
                         error:(NSError * __autoreleasing *)error;

@end
