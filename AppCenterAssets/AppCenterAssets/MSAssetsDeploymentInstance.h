#import "MSAssetsDelegate.h"
#import "MSLocalPackage.h"
#import "MSAssetsDownloadHandler.h"
#import "MSAssetsUpdateUtilities.h"
#import "MSAssetsUpdateManager.h"
#import "MSAssetsAcquisitionManager.h"
#import "MSAssetsSettingManager.h"
#import "MSAssetsTelemetryManager.h"
#import "MSAssetsFileUtils.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MSAssetsPlatformSpecificImplementation
@end

/**
 * A handler for delivering the downlod results.
 *
 * @param downloadedPackage an instance of downloaded `MSLocalPackage`.
 * Can be `nil` in case of download error.
 * @param error download error, if occurred.
 */
typedef void (^MSDownloadHandler)(MSLocalPackage * _Nullable downloadedPackage, NSError * _Nullable error);

@interface MSAssetsDeploymentInstance : NSObject

- (void)checkForUpdate:(nullable NSString *)deploymentKey;

@property (nonatomic, copy, nonnull) NSString *deploymentKey;
@property (nonatomic, copy, nonnull) NSString *serverUrl;
@property (nonatomic, copy, nullable) NSString *updateSubFolder;

@property (nonatomic) id<MSAssetsDelegate> delegate;

@property (nonatomic, copy, readonly) MSAssetsTelemetryManager *telemetryManager;

@property (nonatomic, readonly, nullable) MSAssetsDownloadHandler *downloadHandler;
@property (nonatomic, readonly, nullable) MSAssetsUpdateUtilities *updateUtilities;
@property (nonatomic, readonly, nullable) MSAssetsFileUtils *fileUtils;
@property (nonatomic, copy, readonly) MSAssetsUpdateManager *updateManager;

@property (nonatomic, copy, readonly) MSAssetsAcquisitionManager *acquisitionManager;

@property (nonatomic, copy, readonly) MSAssetsSettingManager *settingManager;



@end

NS_ASSUME_NONNULL_END
