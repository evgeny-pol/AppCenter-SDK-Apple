#import <Foundation/Foundation.h>
#import "MSAssetsiOSPlatformSpecificImplementation.h"

@implementation MSAssetsiOSPlatformSpecificImplementation

- (void) handleInstallModesForUpdateInstall:(MSAssetsInstallMode __unused)installMode {
    
}

- (void) loadApp:(MSAssetsRestartListener)assetsRestartListener {
    if (assetsRestartListener != nil) {
        assetsRestartListener();
    }
}
@end
