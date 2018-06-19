/**
 * @ingroup enums
 * Indicates when you would like to check for (and install) updates from the Assets server.
 */
typedef NS_ENUM(NSUInteger, AssetsCheckFrequency) {
    /**
     * When the app is fully initialized (or more specifically, when the root component is mounted).
     */
    ON_APP_START = 0,
    
    /**
     * When the app re-enters the foreground.
     */
    ON_APP_RESUME = 1,
    
    /**
     * Don't automatically check for updates, but only do it when <code>Assets.sync()</code> is manually called inside app code.
     */
    MANUAL = 2
};
