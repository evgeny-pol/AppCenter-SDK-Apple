/**
 * Indicates the state that an update is currently in.
 */
typedef NS_ENUM(NSUInteger, MSAssetsUpdateState) {
    /**
     * Indicates that an update represents the
     * version of the app that is currently running.
     */
    MSAssetsUpdateStateRunning = 0,
    
    /**
     * Indicates than an update has been installed, but the
     * app hasn't been restarted yet in order to apply it.
     */
    MSAssetsUpdateStatePending = 1,
    
    /**
     * Indicates than an update represents the latest available
     * release, and can be either currently running or pending.
     */
    MSAssetsUpdateStateLatest = 2
};
