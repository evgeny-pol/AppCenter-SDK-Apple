#import "MSAssetsDelegate.h"
#import "MSAssetsUpdateManager.h"
#import "MSAssetsAcquisitionManager.h"
#import "MSAssetsSettingManager.h"
#import "MSAssetsTelemetryManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSAssetsDeploymentInstance : NSObject

- (void)checkForUpdate:(nullable NSString *)deploymentKey;

@property (nonatomic, copy, nonnull) NSString *deploymentKey;
@property (nonatomic, copy, nonnull) NSString *serverUrl;
@property (nonatomic, copy, nullable) NSString *updateSubFolder;

@property (nonatomic) id<MSAssetsDelegate> delegate;

@property (nonatomic, copy, readonly) MSAssetsTelemetryManager *telemetryManager;

@property (nonatomic, copy, readonly) MSAssetsUpdateManager *updateManager;

@property (nonatomic, copy, readonly) MSAssetsAcquisitionManager *acquisitionManager;

@property (nonatomic, copy, readonly) MSAssetsSettingManager *settingManager;



@end

NS_ASSUME_NONNULL_END
