#import "MSServiceAbstract.h"
#import "MSServiceInternal.h"
#import "MSAssetsBuilder.h"
#import "MSAssetsDeploymentInstance.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * App Center Assets service.
 */
@interface MSAssets : MSServiceAbstract <MSServiceInternal>

+ (NSString *)logTag;

+ (MSAssetsDeploymentInstance *)makeDeploymentInstanceWithBuilder:(void (^)(MSAssetsBuilder *))builder
                                                            error:(NSError *__autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
