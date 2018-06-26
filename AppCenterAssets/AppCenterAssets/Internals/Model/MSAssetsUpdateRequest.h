#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"
#import "MSAssetsPackage.h"

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
 * @param assetsPackage  basic package containing the information.
 * @return instance of the {@link AssetsRemotePackage}.
 */
+ (null_unspecified MSAssetsUpdateRequest *)createUpdateRequest:(nonnull NSString *)deploymentKey
                                 assetsPackage:(nonnull MSAssetsPackage *)assetsPackage
                                clientUniqueId:(nonnull NSString *)clientUniqueId;

@end
