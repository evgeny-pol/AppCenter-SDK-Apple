#import "MSAssetsManagers.h"
#import "MSAssetsDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSAssetsDeploymentInstance : NSObject

- (void)checkForUpdate:(nonnull NSString *)deploymentKey;

@property (nonatomic) id<MSAssetsDelegate> delegate;


@property (nonatomic, copy, readonly, nullable) MSAssetsManagers *managers;

@property (nonatomic, copy, nonnull) NSString *deploymentKey;
@property (nonatomic, copy, nonnull) NSString *serverUrl;
@property (nonatomic, copy, nullable) NSString *updateSubFolder;

@end

NS_ASSUME_NONNULL_END
