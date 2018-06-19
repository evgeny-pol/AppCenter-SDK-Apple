/**
 * @ingroup enums
 * Indicates when you would like an installed update to actually be applied.
 */
typedef NS_ENUM(NSUInteger, AssetsInstallMode) {
    /**
     * Indicates that you want to install the update and restart the app immediately.
     */
    IMMEDIATE = 0,
    
    /**
     * Indicates that you want to install the update, but not forcibly restart the app.
     */
    ON_NEXT_RESTART = 1,
    
    /**
     * Indicates that you want to install the update, but don't want to restart the
     * app until the next time the end user resumes it from the background.
     */
    ON_NEXT_RESUME = 2,
    
    /**
     * Indicates that you want to install the update when the app is in the background,
     * but only after it has been in the background for "minimumBackgroundDuration" seconds (0 by default),
     * so that user context isn't lost unless the app suspension is long enough to not matter.
     */
    ON_NEXT_SUSPEND = 3
};
