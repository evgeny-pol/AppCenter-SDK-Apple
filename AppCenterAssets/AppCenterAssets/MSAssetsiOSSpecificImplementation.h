#import <Foundation/Foundation.h>
#import "MSAssetsDeploymentInstance.h"

@interface MSAssetsiOSSpecificImplementation : NSObject<MSAssetsPlatformSpecificImplementation>
- (void) handleInstallModesForUpdateInstall:(MSAssetsInstallMode)installMode;
- (void) loadApp:(MSAssetsRestartListener)assetsRestartListener;
@end
