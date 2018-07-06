#import <Foundation/Foundation.h>
#import "MSAssetsDeploymentInstance.h"

@interface MSAssetsiOSSpecificImplementation : NSObject<MSAssetsPlatformSpecificImplementation>
- (void) handleInstallModesForUpdateInstall:(MSAssetsInstallMode)installMode;
- (void) loadApp:(MSAssetsRestartListener)assetsRestartListener;
- (void) clearDebugCacheWithError:(NSError *__autoreleasing *)error;
- (BOOL) isPackageLatest:(MSLocalPackage *)packageMetadata appVersion:(NSString *)appVersion;
- (NSTimeInterval) getBinaryResourcesModifiedTime;
@end
