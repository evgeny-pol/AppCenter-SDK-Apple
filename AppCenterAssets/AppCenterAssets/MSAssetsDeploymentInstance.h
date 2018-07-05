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

typedef void(^MSAssetsSyncBlock)();
typedef void(^MSAssetsInstallCompleteBlock)();
typedef void(^MSAssetsDownloadSuccessBlock)(NSError*, NSDictionary*);
typedef void(^MSAssetsDownloadFailBlock)(NSError*);

NS_ASSUME_NONNULL_BEGIN

@protocol MSAssetsPlatformSpecificImplementation <NSObject>

- (void) handleInstallModesForUpdateInstall:(MSAssetsInstallMode)installMode;
- (void) loadApp:(MSAssetsRestartListener)assetsRestartListener;
- (void) clearDebugCacheWithError:(NSError *__autoreleasing *)error;
- (BOOL) isPackageLatest:(MSLocalPackage *)packageMetadata appVersion:(NSString *)appVersion;
- (NSTimeInterval) getBinaryResourcesModifiedTime;
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

/**
 * Creates instance of `MSAssetsDeploymentInstance`. Default constructor.
 *
 * @param deploymentKey      deployment key.
 * @param isDebugMode        indicates whether application is running in debug mode.
 * @param serverUrl          CodePush server url.
 * @param publicKey  public key string.
 * @param entryPoint path to update contents/bundles.
 * @param platformInstance  instance of a class conforming to `MSAssetsPlatformSpecificImplementation`
 * and containing platform-specific methods.
 * @see `MSAssetsiOSSpecificImplementation`.
 * @param error initialization error.
 */
- (instancetype)initWithEntryPoint:(NSString *)entryPoint
                         publicKey:(NSString *)publicKey
                     deploymentKey:(NSString *)deploymentKey
                       inDebugMode:(BOOL)isDebugMode
                         serverUrl:(NSString *)serverUrl
                  platformInstance:(id<MSAssetsPlatformSpecificImplementation>)platformInstance
                         withError:(NSError *__autoreleasing *)error;

- (void)checkForUpdate:(nullable NSString *)deploymentKey;

- (void)sync:(NSDictionary *)syncOptions withCallback:(MSAssetsSyncBlock)callback notifyClientAboutSyncStatus:(BOOL)notifySyncStatus notifyProgress:(BOOL)notifyProgress;

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
