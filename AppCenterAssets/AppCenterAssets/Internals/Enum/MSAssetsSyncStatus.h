/**
 * Indicates the current status of a sync operation.
 */
typedef NS_ENUM(NSUInteger, MSAssetsSyncStatus) {
    /**
     * The app is up-to-date with the Assets server.
     */
    MSAssetsSyncStatusUpToDate = 0,
    
    /**
     * An available update has been installed and will be run either immediately after the
     * syncStatusChangedCallback function returns or the next time the app resumes/restarts,
     * depending on the AssetsInstallMode specified in AssetsSyncOptions.
     */
    MSAssetsSyncStatusUpdateInstalled = 1,
    
    /**
     * The app had an optional update which the end user chose to ignore.
     * (This is only applicable when the updateDialog is used).
     */
    MSAssetsSyncStatusUpdateIgnored = 2,
    
    /**
     * The sync operation encountered an unknown error.
     */
    MSAssetsSyncStatusUnknownError = 3,
    
    /**
     * There is an ongoing sync operation running which prevents the current call from being executed.
     */
    MSAssetsSyncStatusSyncInProgress = 4,
    
    /**
     * The Assets server is being queried for an update.
     */
    MSAssetsSyncStatusCheckingForUpdate = 5,
    
    /**
     * An update is available, and a confirmation dialog was shown
     * to the end user. (This is only applicable when the updateDialog is used).
     */
    MSAssetsSyncStatusAwaitingUserAction = 6,
    
    /**
     * An available update is being downloaded from the Assets server.
     */
    MSAssetsSyncStatusDownloadingPackage = 7,
    
    /**
     * An available update was downloaded and is about to be installed.
     */
    MSAssetsSyncStatusInstallingUpdate = 8
};
