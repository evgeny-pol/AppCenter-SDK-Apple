@class MSRemotePackage;

@protocol MSAssetsDelegate <NSObject>

@optional

/**
 * Callback method that will be called by CheckForUpdate
 *
 * @param package The instance of MSRemotePackage.
 */
- (void)packageForUpdate:(MSRemotePackage *)package;

@end

