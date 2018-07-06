#import "MSAssetsSyncStatus.h"

@class MSRemotePackage;

@protocol MSAssetsDelegate <NSObject>

@optional

/**
 * Callback method that will be called by CheckForUpdate
 *
 * @param package The instance of MSRemotePackage.
 */
- (void)didReceiveRemotePackageOnUpdateCheck:(MSRemotePackage *)package;

/**
 * Callback method that will be called by CheckForUpdate in case of error
 *
 * @param error The error.
 */
- (void)didFailToQueryRemotePackageOnCheckForUpdate:(NSError *)error;

/**
 * Callback method for receiving sync status changes.
 *
 * @param syncStatus new sync status.
 */
- (void)syncStatusChanged:(MSAssetsSyncStatus)syncStatus;

/**
 * Callback method for receiving package download progress.
 *
 * @param receivedBytes amount of bytes received.
 * @param totalBytes amount of bytes total.
 */
- (void)packageDownloadProgress:(long long)receivedBytes totalBytes:(long long)totalBytes;

@end

