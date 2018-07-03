#import <Foundation/Foundation.h>

extern NSString *const ManifestFolderPrefix;
extern NSString *const BundleJWTFile;

/**
 * Utils class for Assets updates.
 */
@interface MSAssetsUpdateUtilities : NSObject

/**
 * Method recursively walks through the directory, computes hash for each file within it and adds
 * respective computed entries `path:pathHash` to manifest object.
 *
 * @param folderPath root directory for walking.
 * @param pathPrefix prefix for each path which will be added in manifest to avoid using absolute paths.
 * @param manifest   reference to manifest object.
 * @param error error that happened during adding.
 * @return `true` if successfully added all contents to manifest, `false` otherwise.
 */
- (BOOL)addContentsOfFolderToManifest:(NSMutableArray<NSString *> *)manifest
                           folderPath:(NSString *)folderPath
                           pathPrefix:(NSString *)pathPrefix
                                error:(NSError *  __autoreleasing *)error;

/**
 * Whether hashing file or directory should be ignored or not.
 *
 * @param relativeFilePath file path to check.
 * @return `true` if file path should be ignored during the hashing, `false` otherwise.
 */
- (BOOL)isHashIgnoredFor:(NSString *)relativeFilePath;

/**
 * Computes hash for string.
 *
 * @param data input data string.
 * @return computed hash.
 */
- (NSString *)computeHashFor:(NSData *)data;

/**
 * Computes hash of a directory and compares it with expected one.
 * If verification fails exception will be thrown.
 * Hashing algorithm:
 *
 * 1. Recursively generate a sorted array of format <relativeFilePath>: <sha256FileHash>
 * 2. JSON stringify the array
 * 3. SHA256-hash the result
 *
 * @param folderPath   path to directory.
 * @param expectedHash expected hash value.
 * @param error read/write error occurred while accessing the file system.
 * @return `true`, if verification succeeded, `false` otherwise.
 */
- (BOOL)verifyFolderHash: (NSString *)expectedHash
               folderPath:(NSString *)folderPath
                    error:(NSError *  __autoreleasing *)error;

/**
 * Fills new package directory with files following diff manifest rules:
 * - copy current installed package files to destination directory;
 * - delete files from destination directory specified in `deletedFiles` of diff manifest.
 *
 * @param diffManifestPath     path to diff manifest file.
 * @param currentPackageFolderPath path to current package directory.
 * @param newPackagePath     path to new package directory.
 * @param error read/write error if occurred.
 */
- (void)copyNecessaryFilesFromCurrentPackage: (NSString *)currentPackageFolderPath
                            diffManifestPath:(NSString *)diffManifestPath
                              newPackagePath:(NSString *)newPackagePath
                                       error:(NSError * __autoreleasing *)error;

/**
 * Locates hash computed on bundle file that was generated during the app build.
 *
 * @param binaryBundleUrl `NSURL` to binary bundle.
 * @param assetsPath path to bundle assets.
 * @param error read/write error if occurred.
 * @return hash value.
 */
- (NSString *)getHashForBinaryContents:(NSURL *)binaryBundleUrl
                      bundleAssetsPath:(NSString *)assetsPath
                                 error:(NSError * __autoreleasing *)error;

/**
 * Recursively searches for the specified entry point in update files.
 *
 * @param folderPath       path to folder containing update files (search location).
 * @param expectedFileName expected file name of the entry point.
 * @param error error occurred while scanning.
 * @return full path to entry point.
 */
- (NSString *)findEntryPointInFolder:(NSString *)folderPath
                    expectedFileName:(NSString *)expectedFileName
                               error:(NSError **)error;

@end
