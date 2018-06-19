/**
 * @ingroup enums
 * Indicates the current status of a sync operation.
 */
typedef NS_ENUM(NSUInteger, AssetsSyncStatus) {
    /**
     * The app is up-to-date with the Assets server.
     */
    UP_TO_DATE = 0,
    
    /**
     * An available update has been installed and will be run either immediately after the
     * <code>syncStatusChangedCallback</code> function returns or the next time the app resumes/restarts,
     * depending on the {@link AssetsInstallMode} specified in AssetsSyncOptions.
     */
    UPDATE_INSTALLED = 1,
    
    /**
     * The app had an optional update which the end user chose to ignore.
     * (This is only applicable when the updateDialog is used).
     */
    UPDATE_IGNORED = 2,
    
    /**
     * The sync operation encountered an unknown error.
     */
    UNKNOWN_ERROR = 3,
    
    /**
     * There is an ongoing sync operation running which prevents the current call from being executed.
     */
    SYNC_IN_PROGRESS = 4,
    
    /**
     * The Assets server is being queried for an update.
     */
    CHECKING_FOR_UPDATE = 5,
    
    /**
     * An update is available, and a confirmation dialog was shown
     * to the end user. (This is only applicable when the <code>updateDialog</code> is used).
     */
    AWAITING_USER_ACTION = 6,
    
    /**
     * An available update is being downloaded from the Assets server.
     */
    DOWNLOADING_PACKAGE = 7,
    
    /**
     * An available update was downloaded and is about to be installed.
     */
    INSTALLING_UPDATE = 8
};
