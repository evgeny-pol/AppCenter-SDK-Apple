/**
 * @ingroup enums
 * Indicates the state that an update is currently in.
 */
typedef NS_ENUM(NSUInteger, AssetsUpdateState) {
    /**
     * Indicates that an update represents the
     * version of the app that is currently running.
     */
    RUNNING = 0,
    
    /**
     * Indicates than an update has been installed, but the
     * app hasn't been restarted yet in order to apply it.
     */
    PENDING = 1,
    
    /**
     * Indicates than an update represents the latest available
     * release, and can be either currently running or pending.
     */
    LATEST = 2;
};
