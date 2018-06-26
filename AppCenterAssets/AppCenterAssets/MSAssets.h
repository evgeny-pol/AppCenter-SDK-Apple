#import "MSServiceAbstract.h"
#import "MSAssetsBuilder.h"
#import "MSAssetsDeploymentInstance.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * App Center Assets service.
 */
@interface MSAssets : MSServiceAbstract

+ (MSAssetsDeploymentInstance *)makeDeploymentInstanceWithBuilder:(void (^)(MSAssetsBuilder *))builder;

@end

NS_ASSUME_NONNULL_END
