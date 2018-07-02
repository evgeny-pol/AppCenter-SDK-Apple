#import "MSLocalPackage.h"

/**
 * Manager responsible for update read/write actions.
 */
@interface MSAssetsUpdateManager : NSObject

/**
 - * Gets current package json object.
 - *
 - * @return current package json object.
 - */
- (MSLocalPackage *)getCurrentPackage:(NSError **)error;

/**
 - * Gets previous package json object.
 - *
 - * @return previous package json object.
 - */
- (MSLocalPackage *)getPreviousPackage:(NSError **)error;

- (NSString *)getCurrentPackageHash:(NSError **)error;

/**
 - * Gets package object by its hash.
 - *
 - * @param packageHash package identifier (hash).
 - *
 - * @return previous package json object.
 - */
- (MSLocalPackage *)getPackage:(NSString *)packageHash
                          error:(NSError **)error;

/**
 * Gets folder for the package by the package hash.
 *
 * @param packageHash current package identifier (hash).
 * @return path to package folder.
 */
- (NSString *)getPackageFolderPath:(NSString *)packageHash;

@end
