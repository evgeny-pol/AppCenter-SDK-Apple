#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"
#import "MSAssetsPackage.h"

@interface MSAssetsUpdateRequest : NSObject <MSSerializableObject>

/**
 * Specifies the deployment key you want to query for an update against.
 */
@property(nonatomic, copy) NSString * _Nonnull deploymentKey;

/**
 * Specifies the current app version.
 */
@property(nonatomic, copy) NSString * _Nonnull appVersion;

/**
 * Specifies the current local package hash.
 */
@property(nonatomic, copy) NSString *packageHash;

/**
 * Whether to ignore the application version.
 */
@property(nonatomic) BOOL isCompanion;

/**
 * Specifies the current package label.
 */
@property(nonatomic, copy) NSString *label;

/**
 * Device id.
 */
@property(nonatomic, copy) NSString *clientUniqueId;

/**
 * @param assetsPackage  basic package containing the information.
 * @return instance of the {@link AssetsRemotePackage}.
 */
+ (MSAssetsUpdateRequest *)createUpdateRequest:(NSString *)deploymentKey
                                 assetsPackage:(MSAssetsPackage *)assetsPackage
                                clientUniqueId:(NSString *)clientUniqueId;

@end
