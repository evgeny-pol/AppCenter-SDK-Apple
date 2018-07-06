#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"
#import "MSLocalPackage.h"

/**
 * A request class for querying for updates.
 */
@interface MSAssetsUpdateRequest : NSObject <MSSerializableObject>

/**
 * Specifies the deployment key you want to query for an update against.
 */
@property(nonatomic, copy, nonnull) NSString *deploymentKey;

/**
 * Specifies the current app version.
 */
@property(nonatomic, copy, nonnull) NSString *appVersion;

/**
 * Specifies the current local package hash.
 */
@property(nonatomic, copy, null_unspecified) NSString *packageHash;

/**
 * Whether to ignore the application version.
 */
@property(nonatomic) BOOL isCompanion;

/**
 * Specifies the current package label.
 */
@property(nonatomic, copy, null_unspecified) NSString *label;

/**
 * Device id.
 */
@property(nonatomic, copy, null_unspecified) NSString *clientUniqueId;

/**
 * Creates an update request based on the current `MSAssetsPackage`.
 * @param deploymentKey the deployment key you want to query for an update against.
 * @param assetsPackage  currently installed package containing the information.
 * @param clientUniqueId id of the device.
 * @return instance of the `MSRemotePackage`.
 */
+ (null_unspecified MSAssetsUpdateRequest *)createUpdateRequestWithDeploymentKey:(nonnull NSString *)deploymentKey
                                 assetsPackage:(nonnull MSLocalPackage *)assetsPackage
                                andDeviceId:(nonnull NSString *)clientUniqueId;

@end
