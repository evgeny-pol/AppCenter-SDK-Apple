#import "MSAssetsUpdateUtilities.h"
#import "MSAssetsUpdateManager.h"
#import "MSAssetsDelegate.h"
#import "MSLocalPackage.h"
#import "MSAssetsDeploymentInstanceState.h"
#import "MSAssetsDownloadHandler.h"
#import "MSAssetsAcquisitionManager.h"
#import "MSAssetsSettingManager.h"
#import "MSAssetsTelemetryManager.h"
#import "MSAssetsInstallMode.h"
#import "MSAssetsRestartManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MSAssetsPlatformSpecificImplementation <NSObject>

- (void) handleInstallModesForUpdateInstall:(MSAssetsInstallMode)installMode;
- (void) loadApp:(MSAssetsRestartListener)assetsRestartListener;

@end

/**
 * A handler for delivering the download results.
 *
 * @param downloadedPackage an instance of downloaded `MSLocalPackage`.
 * Can be `nil` in case of download error.
 * @param error download error, if occurred.
 */
typedef void (^MSDownloadHandler)(MSLocalPackage * _Nullable downloadedPackage, NSError * _Nullable error);

@interface MSAssetsDeploymentInstance: NSObject

- (void)checkForUpdate:(nullable NSString *)deploymentKey;

- (instancetype)initWithEntryPoint:(NSString *)entryPoint
                         publicKey:(NSString *)publicKey
                  platformInstance:(id<MSAssetsPlatformSpecificImplementation>)platformInstance;

@property (nonatomic, copy, nonnull) NSString *deploymentKey;
@property (nonatomic, copy, nonnull) NSString *serverUrl;
@property (nonatomic, copy, nullable) NSString *updateSubFolder;
@property (nonatomic, nullable) MSAssetsDeploymentInstanceState *instanceState;

@property (nonatomic) id<MSAssetsDelegate> delegate;

@property (nonatomic, nonnull) id<MSAssetsPlatformSpecificImplementation> platformInstance;
@property (nonatomic, copy, readonly) MSAssetsTelemetryManager *telemetryManager;
@property (nonatomic, readonly, nullable) MSAssetsDownloadHandler *downloadHandler;
@property (nonatomic, readonly, nullable) MSAssetsUpdateUtilities *updateUtilities;
@property (nonatomic, readonly) MSAssetsUpdateManager *updateManager;
@property (nonatomic, readonly) MSAssetsAcquisitionManager *acquisitionManager;
@property (nonatomic, readonly) MSAssetsSettingManager *settingManager;
@property (nonatomic, readonly) MSAssetsRestartManager *restartManager;

@end

NS_ASSUME_NONNULL_END
