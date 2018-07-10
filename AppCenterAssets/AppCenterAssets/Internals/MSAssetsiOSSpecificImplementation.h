#import <Foundation/Foundation.h>
#import "MSAssetsInstallMode.h"
#import "MSAssetsLocalPackage.h"
#import "MSAssetsRestartManager.h"
@protocol MSAssetsPlatformSpecificImplementation <NSObject>

/**
 * Performs all work needed to be done on native side to support install modes but `MSAssetsInstallModeOnNextRestart`.
 */
- (void) handleInstallModesForUpdateInstall:(MSAssetsInstallMode)installMode;

/**
 * Loads application.
 *
 * @param assetsRestartListener listener to notify that the app is loaded.
 */
- (void) loadApp:(MSAssetsRestartListener)assetsRestartListener;

/**
 * Clears debug cache files.
 *
 * @param error error occurred during read/write operations.
 */
- (void) clearDebugCacheWithError:(NSError *__autoreleasing *)error;

/**
 * Checks whether the specified package is latest.
 *
 * @param packageMetadata   info about the package to be checked.
 * @param appVersion version of the currently installed application.
 * @return `true` if package is latest.
 */
- (BOOL) isPackageLatest:(MSAssetsLocalPackage *)packageMetadata appVersion:(NSString *)appVersion;

/**
 * Gets binary version apk build time.
 *
 * @return time in `NSTimeInterval`.
 */
- (NSTimeInterval) getBinaryResourcesModifiedTime;
@end

@interface MSAssetsiOSSpecificImplementation : NSObject<MSAssetsPlatformSpecificImplementation>
@end
