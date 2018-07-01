#import "MSLocalPackage.h"

/**
 * Manager responsible for update read/write actions.
 */
@interface MSAssetsUpdateManager : NSObject



- (MSLocalPackage *)getCurrentPackage:(NSError **)error;
- (MSLocalPackage *)getPreviousPackage:(NSError **)error;
- (NSString *)getCurrentPackageHash:(NSError **)error;
- (MSLocalPackage *)getPackage:(NSString *)packageHash
                          error:(NSError **)error;
- (NSString *)getPackageFolderPath:(NSString *)packageHash;

@end
