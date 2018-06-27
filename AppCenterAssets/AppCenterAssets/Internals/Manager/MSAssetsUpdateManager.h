#import "MSLocalPackage.h"

/**
 * Manager responsible for update read/write actions.
 */
@interface MSAssetsUpdateManager : NSObject


/**
 * Gets current package json object.
 *
 * @return current package json object.
 */
- (MSLocalPackage *)getCurrentPackage:(NSError **)error;

- (NSString *)getCurrentPackageHash:(NSError **)error;
- (MSLocalPackage *)getPackage:(NSString *)packageHash
                          error:(NSError **)error;
- (NSString *)getPackageFolderPath:(NSString *)packageHash;

@end
