#import <Foundation/Foundation.h>

@interface MSAssetsUpdateRequest

/**
 * Specifies the deployment key you want to query for an update against.
 */
@property(nonatomic, copy) NSString *deploymentKey;

/**
 * Specifies the current app version.
 */
@property(nonatomic, copy) NSString *appVersion;

/**
 * Specifies the current local package hash.
 */
@property(nonatomic, copy) NSString *packageHash;

/**
 * Whether to ignore the application version.
 */
@SerializedName("isCompanion")
private boolean isCompanion;
@property(nonatomic, copy) BOOL isCompanion;

/**
 * Specifies the current package label.
 */
@property(nonatomic, copy) NSString *label;

/**
 * Device id.
 */
@property(nonatomic, copy) NSString *clientUniqueId;

/**
 * Creates an instance of the class from the basic package.
 *
 * @param failedInstall    whether this update has been previously installed but was rolled back.
 * @param packageSize      the size of the package.
 * @param downloadUrl      url to access package on server.
 * @param updateAppVersion whether the client should trigger a store update.
 * @param assetsPackage  basic package containing the information.
 * @return instance of the {@link AssetsRemotePackage}.
 */
+ (MSAssetsUpdateRequest *)createUpdateRequest:(NSString *)deploymentKey
                                 assetsPackage:(MSAssetsPackage *)assetsPackage
                                clientUniqueId:(NSString *)clientUniqueId;

@end
