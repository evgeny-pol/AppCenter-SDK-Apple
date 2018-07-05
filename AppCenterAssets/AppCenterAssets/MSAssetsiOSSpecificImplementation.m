#import <Foundation/Foundation.h>
#import "MSAssetsiOSSpecificImplementation.h"

@implementation MSAssetsiOSSpecificImplementation

- (void) handleInstallModesForUpdateInstall:(MSAssetsInstallMode __unused)installMode {
    
}

- (void) loadApp:(MSAssetsRestartListener)assetsRestartListener {
    if (assetsRestartListener != nil) {
        assetsRestartListener();
    }
}
@end
