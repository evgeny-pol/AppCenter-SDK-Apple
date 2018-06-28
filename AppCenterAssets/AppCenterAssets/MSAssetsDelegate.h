@class MSRemotePackage;

@protocol MSAssetsDelegate <NSObject>

@optional

/**
 * Callback method that will be called by CheckForUpdate
 *
 * @param package The instance of MSRemotePackage.
 *
 * @see [MSDistribute notifyUpdateAction:]
 */
- (void)packageForUpdate:(MSRemotePackage *)package;

@end

