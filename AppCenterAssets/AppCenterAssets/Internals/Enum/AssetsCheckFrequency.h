/**
 * Indicates when you would like to check for (and install) updates from the Assets server.
 */
typedef NS_ENUM(NSUInteger, MSAssetsCheckFrequency) {
    /**
     * When the app is fully initialized (or more specifically, when the root component is mounted).
     */
    MSAssetsCheckFrequencyOnAppStart = 0,
    
    /**
     * When the app re-enters the foreground.
     */
    MSAssetsCheckFrequencyOnAppResume = 1,
    
    /**
     * Don't automatically check for updates, but only do it when Assets.sync() is manually called inside app code.
     */
    MSAssetsCheckFrequencyManual = 2
};
