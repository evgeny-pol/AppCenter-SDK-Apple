#import "MSAssets.h"
#import "MSAssetsDeploymentInstanceState.h"
#import "MSAssetsUpdateUtilities.h"
#import "MSAssetsLocalPackage.h"
#import "MSAssetsErrors.h"
#import "MSAssetsErrorUtils.h"
#import "MSLogger.h"
#import "MSUtility+File.h"
#import "MSAssetsDownloadHandler.h"
#import <UIKit/UIKit.h>
#import "MSAssetsSettingManager.h"
#import "MSUtility+File.h"
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
        _downloadHandler = nil;
        _settingManager = [[MSAssetsSettingManager alloc] init];
        _updateUtilities = [[MSAssetsUpdateUtilities alloc] initWithSettingManager:_settingManager];
        _updateManager = [[MSAssetsUpdateManager alloc] initWithUpdateUtils:_updateUtilities];
        _acquisitionManager = [[MSAssetsAcquisitionManager alloc] init];
        _telemetryManager = [[MSAssetsTelemetryManager alloc] initWithSettingManager:_settingManager];
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
    MSAssetsLocalPackage *packageMetadata = [[self updateManager] getCurrentPackage:error];
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
    [self checkForUpdate:deploymentKey withCompletionHandler:^( MSAssetsRemotePackage *update,  NSError * _Nullable error){
        if (error) {
            if ([self.delegate respondsToSelector:@selector(didFailToQueryRemotePackageOnCheckForUpdate:)])
                [self.delegate didFailToQueryRemotePackageOnCheckForUpdate:error];
            return;
        } else {
            if ([self.delegate respondsToSelector:@selector(didReceiveRemotePackageOnCheckForUpdate:)])
                [self.delegate didReceiveRemotePackageOnCheckForUpdate:update];
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

    MSAssetsLocalPackage *localPackage = [[self getCurrentPackage] mutableCopy];

    MSAssetsLocalPackage *queryPackage;
    if (localPackage){
        MSLogInfo([MSAssets logTag], @"Got local package");
        queryPackage = localPackage;
    }
    else{
        queryPackage = [MSAssetsLocalPackage createLocalPackageWithAppVersion:config.appVersion];
    }
    [[self acquisitionManager] queryUpdateWithCurrentPackage:queryPackage withConfiguration:config andCompletionHandler:^( MSAssetsRemotePackage *update,  NSError * _Nullable error){
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
        [self notifyAboutSyncStatusChange: MSAssetsSyncStatusSyncInProgress instanceState:[self instanceState]];
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
    
    [self notifyAboutSyncStatusChange: MSAssetsSyncStatusCheckingForUpdate instanceState:[self instanceState]];
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

- (MSAssetsLocalPackage *)getUpdateMetadataForState:(MSAssetsUpdateState)updateState
                 currentPackageGettingError:(NSError * __autoreleasing *)error {
    NSError *__autoreleasing internalError;
    MSAssetsLocalPackage *package = [[[self updateManager] getCurrentPackage:&internalError] mutableCopy];
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

- (MSAssetsLocalPackage *)getCurrentPackage {
    NSError *error;
    MSAssetsLocalPackage *currentPackage = [self getUpdateMetadataForState:MSAssetsUpdateStateLatest currentPackageGettingError:&error];
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
- (void)downloadUpdate:(MSAssetsRemotePackage *)updatePackage
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
    self.downloadHandler = [[MSAssetsDownloadHandler alloc] initWithOperationQueue: dispatch_get_main_queue()];
    __weak typeof(self) weakSelf = self;
    [[self downloadHandler] downloadWithUrl:[updatePackage downloadUrl]
                                     toPath:downloadFile
                       withProgressCallback:^(long long expectedContentLength, long long receivedContentLength) {
                           typeof(self) strongSelf = weakSelf;
                           if (!strongSelf) {
                               return;
                           }
                           if ([[strongSelf delegate] respondsToSelector:@selector(didReceiveBytesForPackageDownloadProgress:totalBytes:)]) {
                               [[strongSelf delegate] didReceiveBytesForPackageDownloadProgress:receivedContentLength totalBytes:expectedContentLength];
                           }
                       } andCompletionHandler:^(MSAssetsDownloadPackageResult *downloadResult, NSError *err) {
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
                               BOOL result = [MSUtility moveFile:downloadFile toFolder:newUpdateFolderPath withNewName:strongSelf->_entryPoint];
                               if (!result) {
                                   error = [MSAssetsErrorUtils getFileMoveError:downloadFile destination:newUpdateFolderPath];
                                   completeHandler(nil, error);
                                   return;
                               }
                           }
                           MSAssetsLocalPackage *localPackage = [MSAssetsLocalPackage createLocalPackageWithPackage:updatePackage
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
 * Downloads and installs update.
 *
 * @param remotePackage update to use.
 * @param syncOptions   sync options.
 * @param configuration configuration to use.
 * @param handler handler to deliver errors to.
 */
- (void) doDownloadAndInstall:(MSAssetsRemotePackage *)remotePackage
                  syncOptions:(MSAssetsSyncOptions *)syncOptions
                configuration:(MSAssetsConfiguration *)configuration
                      handler:(MSDownloadInstallHandler)handler {
    [self notifyAboutSyncStatusChange:MSAssetsSyncStatusDownloadingPackage instanceState:[self instanceState]];
    __weak typeof(self) weakSelf = self;
    [self downloadUpdate:remotePackage completeHandler:^(MSAssetsLocalPackage * _Nullable downloadedPackage, NSError * _Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        // Destroy the handler because each time a new handler should be created.
        strongSelf.downloadHandler = nil;
        if (error) {
            [[strongSelf settingManager] saveFailedUpdate:remotePackage];
            handler(error);
            return;
        }
        NSString *label = [downloadedPackage label];
        if (!label) {
            label = @"";
        }
        MSAssetsDownloadStatusReport *report = [[MSAssetsDownloadStatusReport alloc] initReportWithLabel:label
                                                                                    deviceId:[configuration clientUniqueId]
                                                                            andDeploymentKey:[configuration deploymentKey]];
        [[strongSelf acquisitionManager] reportDownloadStatus:report withConfiguration:configuration];
        MSAssetsInstallMode resolvedInstallMode = [downloadedPackage isMandatory] ? [syncOptions mandatoryInstallMode] : [syncOptions installMode];
        [[strongSelf instanceState] setCurrentInstallMode:resolvedInstallMode];
        [strongSelf notifyAboutSyncStatusChange:MSAssetsSyncStatusInstallingUpdate instanceState:[strongSelf instanceState]];
        NSError *installError = [strongSelf installUpdate:downloadedPackage installMode:resolvedInstallMode minimumBackgroundDuration:[syncOptions minimumBackgroundDuration]];
        if (installError) {
            handler(installError);
            return;
        }
        [strongSelf notifyAboutSyncStatusChange:MSAssetsSyncStatusUpdateInstalled instanceState:[strongSelf instanceState]];
        [[strongSelf instanceState] setSyncInProgress:NO];
        if (resolvedInstallMode == MSAssetsInstallModeImmediate && [syncOptions shouldRestart]) {
            [[strongSelf restartManager] restartAppOnlyIfUpdateIsPending:NO];
        } else {
            [[strongSelf restartManager] clearPendingRestarts];
        }
        handler(nil);
    }];
}

/**
 * Notifies listeners about changed sync status and log it.
 *
 * @param syncStatus sync status.
 */
- (void) notifyAboutSyncStatusChange:(MSAssetsSyncStatus)syncStatus instanceState:(MSAssetsDeploymentInstanceState *)instanceState{
    if ([[self delegate] respondsToSelector:@selector(syncStatusChanged:)]) {
        [[self delegate] syncStatusChanged:syncStatus];
    }
    switch (syncStatus) {
        case MSAssetsSyncStatusCheckingForUpdate:
            MSLogInfo([MSAssets logTag], @"Checking for update.");
            break;
        case MSAssetsSyncStatusAwaitingUserAction:
            MSLogInfo([MSAssets logTag], @"Awaiting user action.");
            break;
        case MSAssetsSyncStatusDownloadingPackage:
            MSLogInfo([MSAssets logTag], @"Downloading package.");
            break;
        case MSAssetsSyncStatusInstallingUpdate:
            MSLogInfo([MSAssets logTag], @"Installing update.");
            break;
        case MSAssetsSyncStatusUpToDate:
            MSLogInfo([MSAssets logTag], @"App is up to date.");
            break;
        case MSAssetsSyncStatusSyncInProgress:
            MSLogInfo([MSAssets logTag], @"Sync is in progress.");
            break;
        case MSAssetsSyncStatusUpdateIgnored:
            MSLogInfo([MSAssets logTag], @"User cancelled the update.");
            break;
        case MSAssetsSyncStatusUnknownError:
            MSLogInfo([MSAssets logTag], @"An unknown error occurred.");
            break;
        case MSAssetsSyncStatusUpdateInstalled:
            switch (instanceState.currentInstallMode) {
                case MSAssetsInstallModeImmediate:
                    MSLogInfo([MSAssets logTag], @"Update is installed and will be run right now.");
                    break;
                case MSAssetsInstallModeOnNextRestart:
                    MSLogInfo([MSAssets logTag], @"Update is installed and will be run on the next app restart.");
                    break;
                case MSAssetsInstallModeOnNextResume:
                    MSLogInfo([MSAssets logTag], @"Update is installed and will be run when the app next resumes.");
                    break;
                case MSAssetsInstallModeOnNextSuspend:
                    MSLogInfo([MSAssets logTag], @"Update is installed and will be run after the app has been in the background for at least %d seconds.", instanceState.minimumBackgroundDuration);
                    break;
            }
            break;
    }
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
- (NSError *)installUpdate:(MSAssetsLocalPackage*)updatePackage
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
