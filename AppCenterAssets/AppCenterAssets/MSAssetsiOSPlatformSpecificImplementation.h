#import <Foundation/Foundation.h>
#import "MSAssetsDeploymentInstance.h"


@interface MSAssetsiOSPlatformSpecificImplementation : NSObject<MSAssetsPlatformSpecificImplementation>
- (void) handleInstallModesForUpdateInstall:(MSAssetsInstallMode)installMode;

@end
