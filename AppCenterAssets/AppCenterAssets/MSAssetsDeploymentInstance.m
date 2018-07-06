#import "MSAssets.h"
#import "MSAssetsDeploymentInstanceState.h"
#import "MSAssetsUpdateUtilities.h"
#import "MSLocalPackage.h"
#import "MSAssetsErrors.h"
#import "MSAssetsErrorUtils.h"
#import "MSLogger.h"
#import "MSUtility+File.h"
#import "MSAssetsDownloadHandler.h"
#import <UIKit/UIKit.h>
#import "MSAssetsSettingManager.h"
#import "MSAssetsFileUtils.h"
#import "MSAssetsInstallMode.h"
#import "MSAssetsUpdateState.h"
#import "MSAssetsSyncOptions.h"
#import "MSAssetsSyncStatus.h"

@implementation MSAssetsDeploymentInstance {
    BOOL _didUpdateProgress;
    NSString *_entryPoint;
    NSString *_publicKey;
    NSString *_deploymentKey;
    BOOL _isDebugMode;
    NSString *_serverUrl;
    NSString *_appVersion;
}

@synthesize delegate = _delegate;
static NSString *const DownloadFileName = @"download.zip";
static NSString *const UpdateMetadataFileName = @"app.json";


static BOOL isRunningBinaryVersion = NO;
//static BOOL needToReportRollback = NO;
//static BOOL testConfigurationFlag = NO;

- (instancetype)initWithEntryPoint:(NSString *)entryPoint
                         publicKey:(NSString *)publicKey
                     deploymentKey:(NSString *)deploymentKey
                       inDebugMode:(BOOL)isDebugMode
                         serverUrl:(NSString *)serverUrl
                  platformInstance:(id<MSAssetsPlatformSpecificImplementation>)platformInstance
                         withError:(NSError *__autoreleasing *)error {
    if ((self = [super init])) {
        _entryPoint = entryPoint;
        _publicKey = publicKey;
        _deploymentKey = deploymentKey;
        _isDebugMode = isDebugMode;
        if (serverUrl) {
            _serverUrl = serverUrl;
        } else {
            _serverUrl = @"https://codepush.azurewebsites.net/";
        }
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        if (appVersion) {
            _appVersion = appVersion;
        } else {
            *error = [MSAssetsErrorUtils getNoAppVersionError];
            return nil;
        }
        _downloadHandler = [[MSAssetsDownloadHandler alloc] initWithOperationQueue: dispatch_get_main_queue()];
        _updateUtilities = [[MSAssetsUpdateUtilities alloc] init];
        _updateManager = [[MSAssetsUpdateManager alloc] init];
        _acquisitionManager = [[MSAssetsAcquisitionManager alloc] init];
        _settingManager = [[MSAssetsSettingManager alloc] init];
        _telemetryManager = [[MSAssetsTelemetryManager alloc] init];
        _restartManager = [[MSAssetsRestartManager alloc] initWithRestartHandler:^(BOOL onlyIfUpdateIsPending, MSAssetsRestartListener restartListener) {
            [self restartInternal:restartListener onlyIfUpdateIsPending:onlyIfUpdateIsPending];
        }];
        _instanceState = [[MSAssetsDeploymentInstanceState alloc] init];
        _platformInstance = platformInstance;
        if (_isDebugMode && [_settingManager isPendingUpdate:nil]) {
            [_platformInstance clearDebugCacheWithError:error];
            if (error) {
                return nil;
            }
        }
        [self initializeUpdateAfterRestartWithError:error];
        if (error) {
 //           return nil;
        }
    }
    return self;
}

/**
 * Initializes update after app restart.
 *
 * @param error initialization error.
 */
- (void)initializeUpdateAfterRestartWithError:(NSError * __autoreleasing *)error {
    
    /* Reset the state which indicates that the app was just freshly updated. */
    [[self instanceState] setDidUpdate:NO];
    MSAssetsPendingUpdate *pendingUpdate = [[self settingManager] getPendingUpdate];
    if (pendingUpdate == nil) {
        return;
    }
    MSLocalPackage *packageMetadata = [[self updateManager] getCurrentPackage:error];
    if (error) {
        return;
    }
    if (packageMetadata == nil || ([[self platformInstance] isPackageLatest:packageMetadata appVersion:_appVersion]
                                   && ! [_appVersion isEqualToString:[packageMetadata appVersion]])) {
        MSLogInfo([MSAssets logTag], @"Skipping initializeUpdateAfterRestart(), binary version is newer.");
        return;
    }
    BOOL updateIsLoading = [pendingUpdate isLoading];
    if (updateIsLoading) {
        
        /* Pending update was initialized, but notifyApplicationReady was not called.
         * Therefore, deduce that it is a broken update and rollback. */
        MSLogInfo([MSAssets logTag], @"Update did not finish loading the last time, rolling back to a previous version.");
        [[self instanceState] setNeedToReportRollback:YES];
        [self rollbackPackage];
    } else {
        
        /* There is in fact a new update running for the first
         * time, so update the local state to ensure the client knows. */
        [[self instanceState] setDidUpdate:YES];
        
        /* Mark that we tried to initialize the new update, so that if it crashes,
         * we will know that we need to rollback when the app next starts. */
        [[self settingManager] savePendingUpdate:pendingUpdate];
    }
}

- (void) rollbackPackage {
    //TODO: Sync up with Patrick on rollbacks.
}

- (BOOL)restartInternal:(MSAssetsRestartListener)assetsRestartListener onlyIfUpdateIsPending:(BOOL)onlyIfUpdateIsPending {
    
    /* If this is an unconditional restart request, or there
     * is current pending update, then reload the app. */
    if (!onlyIfUpdateIsPending || [[self settingManager] isPendingUpdate:nil]) {
        [[self platformInstance] loadApp:assetsRestartListener];
        return YES;
    }
    return NO;
}

- (void)checkForUpdate:(nullable NSString *)deploymentKey {
    [self checkForUpdate:deploymentKey withCompletionHandler:^( MSRemotePackage *update,  NSError * _Nullable error){
        if (error) {
            if ([self.delegate respondsToSelector:@selector(didFailToQueryRemotePackageOnCheckForUpdate:)])
                [self.delegate didFailToQueryRemotePackageOnCheckForUpdate:error];
            return;
        } else {
            if ([self.delegate respondsToSelector:@selector(didReceiveRemotePackageOnUpdateCheck:)])
                [self.delegate didReceiveRemotePackageOnUpdateCheck:update];
        }

    }];
}

- (void)checkForUpdate:(NSString *)deploymentKey withCompletionHandler:(MSCheckForUpdateCompletionHandler)handler {
    if (deploymentKey){
        [self setDeploymentKey:deploymentKey];
    }
    NSError *configError = nil;
    MSAssetsConfiguration *config = [self getConfigurationWithError:&configError];
    if (configError) {
        handler(nil, configError);
        return;
    }
    if (deploymentKey)
        config.deploymentKey = deploymentKey;

    MSLocalPackage *localPackage = [[self getCurrentPackage] mutableCopy];

    MSLocalPackage *queryPackage;
    if (localPackage){
        MSLogInfo([MSAssets logTag], @"Got local package");
        queryPackage = localPackage;
    }
    else{
        queryPackage = [MSLocalPackage createLocalPackageWithAppVersion:config.appVersion];
    }
    [[self acquisitionManager] queryUpdateWithCurrentPackage:queryPackage withConfiguration:config andCompletionHandler:^( MSRemotePackage *update,  NSError * _Nullable error){
        if (error) {
            handler(nil, error);
            return;
        }
        if (!update) {
            handler(nil, nil);
            return;
        }
        if (!update || update.updateAppVersion ||
            (localPackage && ([update.packageHash isEqualToString:localPackage.packageHash])) ||
            ((!localPackage || localPackage.isDebugOnly) && [config.packageHash isEqualToString:update.packageHash] )){
            if (update && update.updateAppVersion){
                MSLogInfo([MSAssets logTag], @"An update is available but it is not targeting the binary version of your app.");
                handler(nil, nil);
                return;
            }
        } else {
            update.failedInstall = [[self settingManager] existsFailedUpdate:update.packageHash];
            if (deploymentKey){
                update.deploymentKey = deploymentKey;
            } else {
                update.deploymentKey = config.deploymentKey;
            }
        }
        handler(update, nil);
    }];
    MSLogInfo([MSAssets logTag], @"Check for update called");
}

- (void)sync:(MSAssetsSyncOptions *)syncOptions withCallback:(MSAssetsSyncBlock)callback notifyClientAboutSyncStatus:(BOOL)notifySyncStatus notifyProgress:(BOOL)notifyProgress {

    if (syncOptions) {};
    if (callback) {};
    if (notifySyncStatus) {};
    if (notifyProgress) {};

    if (self.instanceState.syncInProgress){
        MSLogInfo([MSAssets logTag], @"Sync already in progress.");
        [self syncStatusChanged:MSAssetsSyncStatusSyncInProgress];
        return;
    }

    if (!syncOptions)
        syncOptions = [[MSAssetsSyncOptions alloc] init];
    if (!syncOptions.deploymentKey)
        syncOptions.deploymentKey = self.deploymentKey;
    if (!syncOptions.installMode)
        syncOptions.installMode = MSAssetsInstallModeOnNextRestart;
    if (!syncOptions.mandatoryInstallMode)
        syncOptions.mandatoryInstallMode = MSAssetsInstallModeImmediate;
    if (!syncOptions.checkFrequency)
        syncOptions.checkFrequency = MSAssetsCheckFrequencyOnAppStart;

    NSError *configError = nil;
    MSAssetsConfiguration *config = [self getConfigurationWithError:&configError];

    if (syncOptions.deploymentKey)
        config.deploymentKey = syncOptions.deploymentKey;

    self.instanceState.syncInProgress = YES;

    [self syncStatusChanged:MSAssetsSyncStatusCheckingForUpdate];

}

- (MSAssetsConfiguration *)getConfigurationWithError:(NSError * __autoreleasing*)error {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    MSAssetsConfiguration *configuration = [MSAssetsConfiguration new];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (appVersion == nil) {
        *error = [MSAssetsErrorUtils getNoAppVersionError];
        return nil;
    }
    NSString *clientId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (clientId == nil) {
        clientId = @"";
    }
    configuration.appVersion = appVersion;
    configuration.clientUniqueId = clientId;
    configuration.deploymentKey = [self deploymentKey];
    configuration.serverUrl = [self serverUrl];
    configuration.packageHash = [[self updateManager] getCurrentPackageHash:error];
    return configuration;
}

- (void)syncStatusChanged:(MSAssetsSyncStatus)status {
    if (status) {};
}

- (MSLocalPackage *)getUpdateMetadataForState:(MSAssetsUpdateState)updateState
                 currentPackageGettingError:(NSError * __autoreleasing *)error {
    NSError *__autoreleasing internalError;
    MSLocalPackage *package = [[[self updateManager] getCurrentPackage:&internalError] mutableCopy];
    if (internalError){
        error = &internalError;
        return nil;
    }
    if (package == nil){
        
        // The app hasn't downloaded any CodePush updates yet,
        // so we simply return nil regardless if the user
        // wanted to retrieve the pending or running update.
        return nil;
    }

    // We have a CodePush update, so let's see if it's currently in a pending state.
    BOOL currentUpdateIsPending = [[self settingManager] isPendingUpdate:package.packageHash];

    if (updateState == MSAssetsUpdateStatePending && !currentUpdateIsPending) {
        
        // The caller wanted a pending update
        // but there isn't currently one.
        return nil;
    } else if (updateState == MSAssetsUpdateStateRunning && currentUpdateIsPending) {
        
        // The caller wants the running update, but the current
        // one is pending, so we need to grab the previous.
        package = [[self updateManager] getPreviousPackage:&internalError];
        if (internalError){
            error = &internalError;
            return nil;
        }
        else
            return package;
    } else {
        
        // The current package satisfies the request:
        // 1) Caller wanted a pending, and there is a pending update
        // 2) Caller wanted the running update, and there isn't a pending
        // 3) Caller wants the latest update, regardless if it's pending or not
        if (isRunningBinaryVersion) {
            
            // This only matters in Debug builds. Since we do not clear "outdated" updates,
            // we need to indicate to the JS side that somehow we have a current update on
            // disk that is not actually running.
            package.isDebugOnly = true;
        }
        
        // Enable differentiating pending vs. non-pending updates
        package.isPending = currentUpdateIsPending;
        return package;
    }

}

- (MSLocalPackage *)getCurrentPackage {
    NSError *error;
    MSLocalPackage *currentPackage = [self getUpdateMetadataForState:MSAssetsUpdateStateLatest currentPackageGettingError:&error];
    if (error){
        MSLogInfo([MSAssets logTag], @"An error occured: %@", [error localizedDescription]);
        return nil;
    }
    return currentPackage;
}

/**
 * Downloads update.
 *
 * @param updatePackage update to download.
 * @param completeHandler completion handler to deliver results/errors to.
 */
- (void)downloadUpdate:(MSRemotePackage *)updatePackage
       completeHandler:(MSDownloadHandler)completeHandler {
    NSString *packageHash = [updatePackage packageHash];
    NSString *newUpdateFolderPath = [[self updateManager] getPackageFolderPath:packageHash];
    NSString *newUpdateMetadataPath = [newUpdateFolderPath stringByAppendingPathComponent:UpdateMetadataFileName];
    if ([MSUtility fileExistsForPathComponent:newUpdateFolderPath]) {
        
        /* This removes any stale data in `newPackageFolderPath` that could have been left
         * uncleared due to a crash or error during the download or install process. */
        [MSUtility deleteItemForPathComponent:newUpdateFolderPath];
    }
    NSString *downloadFile = [[self updateManager] getDownloadFilePath];
    if (!downloadFile) {
        
        // Can not get or create a folder. The error will appear in the logs.
        completeHandler(nil, nil);
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[self downloadHandler] downloadWithUrl:[updatePackage downloadUrl]
                                     toPath:downloadFile
                       withProgressCallback:^(long long expectedContentLength, long long receivedContentLength) {
                           typeof(self) strongSelf = weakSelf;
                           if (!strongSelf) {
                               return;
                           }
                           if ([[strongSelf delegate] respondsToSelector:@selector(packageDownloadProgress:totalBytes:)]) {
                               [[strongSelf delegate] packageDownloadProgress:receivedContentLength totalBytes:expectedContentLength];
                           }
                       } andCompletionHandler:^(MSDownloadPackageResult *downloadResult, NSError *err) {
                           typeof(self) strongSelf = weakSelf;
                           if (!strongSelf) {
                               return;
                           }
                           if (err) {
                               if (completeHandler != nil) {
                                   completeHandler(nil, err);
                               }
                               return;
                           }
                           NSError *error = nil;
                           NSString *entryPoint = nil;
                           BOOL isZip = [downloadResult isZip];
                           if (isZip) {
                               [[strongSelf updateManager] unzipPackage:downloadFile
                                                                  error:&error];
                               if (error) {
                                   completeHandler(nil, error);
                                   return;
                               }
                               entryPoint = [[strongSelf updateManager] mergeDiffWithNewUpdateFolder:newUpdateFolderPath
                                                                         newUpdateMetadataPath:newUpdateMetadataPath
                                                                                 newUpdateHash:[updatePackage packageHash]
                                                                               publicKeyString: strongSelf->_publicKey
                                                                    expectedEntryPointFileName:strongSelf->_entryPoint
                                                                                               error:&error];
                               if (error) {
                                   completeHandler(nil, error);
                                   return;                                   
                               }
                           } else {
                               BOOL result = [MSAssetsFileUtils moveFile:downloadFile toFolder:newUpdateFolderPath withNewName:strongSelf->_entryPoint];
                               if (!result) {
                                   error = [MSAssetsErrorUtils getFileMoveError:downloadFile destination:newUpdateFolderPath];
                                   completeHandler(nil, error);
                                   return;
                               }
                           }
                           MSLocalPackage *localPackage = [MSLocalPackage createLocalPackageWithPackage:updatePackage
                                                                                          failedInstall:NO
                                                                                             isFirstRun: NO
                                                                                              isPending:YES
                                                                                            isDebugOnly:NO
                                                                                             entryPoint: entryPoint];                           
                           [localPackage setBinaryModifiedTime: [NSString stringWithFormat:@"%f", [[strongSelf platformInstance] getBinaryResourcesModifiedTime]]];
                           NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[localPackage serializeToDictionary] options:NSJSONWritingPrettyPrinted error:&error];
                           if (error) {
                               completeHandler(nil, error);
                               return;
                           }
                           NSURL *createdFile = [MSUtility createFileAtPathComponent:newUpdateMetadataPath withData:jsonData atomically:YES forceOverwrite:NO];
                           if (createdFile == nil) {
                               completeHandler(nil, [MSAssetsErrorUtils getUpdateMetadataFailToCreateError]);
                               return;
                           }
                           completeHandler(localPackage, nil);
                       }];
}

/**
 * Installs update.
 *
 * @param updatePackage             update to install.
 * @param installMode               installation mode.
 * @param minimumBackgroundDuration minimum background duration value
 * @see `MSAssetsSyncOptions->minimumBackgroundDuration`.
 * @return error installation error.
 */
- (NSError *)installUpdate:(MSLocalPackage*)updatePackage
          installMode:(MSAssetsInstallMode)installMode
minimumBackgroundDuration:(int)minimumBackgroundDuration {
    NSString *packageHash = [updatePackage packageHash];
    if (packageHash == nil) {
        return [MSAssetsErrorUtils getNoPackageHashToInstallError];
    }
    NSError *installError = [[self updateManager] installPackage:[updatePackage packageHash]
                                   removePendingUpdate:[[self settingManager] isPendingUpdate:[updatePackage packageHash]]];
    if (installError) {
        return installError;
    }
    MSAssetsPendingUpdate *pendingUpdate = [MSAssetsPendingUpdate new];
    [pendingUpdate setPendingUpdateHash:packageHash];
    [pendingUpdate setIsLoading:NO];
    [[self settingManager] savePendingUpdate:pendingUpdate];
    if (installMode == MSAssetsInstallModeOnNextResume ||
        
        /* We also add the resume listener if the installMode is IMMEDIATE, because
         * if the current activity is backgrounded, we want to reload the bundle when
         * it comes back into the foreground. */
        installMode == MSAssetsInstallModeImmediate ||
        installMode == MSAssetsInstallModeOnNextSuspend) {
        
        /* Store the minimum duration on the native module as an instance
         * variable instead of relying on a closure below, so that any
         * subsequent resume-based installs could override it. */
        [[self instanceState] setMinimumBackgroundDuration:minimumBackgroundDuration];
        [[self platformInstance] handleInstallModesForUpdateInstall:installMode];
    }
    return nil;
}

@end
