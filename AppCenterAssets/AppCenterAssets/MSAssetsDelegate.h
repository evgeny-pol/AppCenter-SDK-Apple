@class MSRemotePackage;

@protocol MSAssetsDelegate <NSObject>

@optional

/**
 * Callback method that will be called by CheckForUpdate
 *
 * @param package The instance of MSRemotePackage.
 */
- (void)packageForUpdate:(MSRemotePackage *)package;

/**
 * Callback method that will be called by CheckForUpdate in case of error
 *
 * @param error The error.
 */
- (void)didFailToQueryPackage:(NSError *)error;

@end

