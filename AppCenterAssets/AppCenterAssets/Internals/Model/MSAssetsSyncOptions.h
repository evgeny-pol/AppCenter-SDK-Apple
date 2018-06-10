#import <Foundation/Foundation.h>

#import "MSAssetsUpdateDialog.h"

@interface MSAssetsSyncOptions

/**
 * Specifies the deployment key you want to query for an update against.
 * By default, this value is derived from the MainActivity.java file (Android),
 * but this option allows you to override it from the script-side if you need to
 * dynamically use a different deployment for a specific call to sync.
 */
@property(nonatomic, copy) NSString *deploymentKey;

/**
 * Specifies when you would like to install optional updates (i.e. those that aren't marked as mandatory).
 * Defaults to {@link AssetsInstallMode#ON_NEXT_RESTART}.
 */
@property(nonatomic, copy) MSAssetsInstallMode *installMode;

/**
 * Specifies when you would like to install updates which are marked as mandatory.
 * Defaults to {@link AssetsInstallMode#IMMEDIATE}.
 */
@property(nonatomic, copy) MSAssetsInstallMode *mandatoryInstallMode;

/**
 * Specifies the minimum number of seconds that the app needs to have been in the background before restarting the app.
 * This property only applies to updates which are installed using {@link AssetsInstallMode#ON_NEXT_RESUME},
 * and can be useful for getting your update in front of end users sooner, without being too obtrusive.
 * Defaults to `0`, which has the effect of applying the update immediately after a resume, regardless
 * how long it was in the background.
 */
@property(nonatomic, copy) int minimumBackgroundDuration;

/**
 * Specifies whether to ignore failed updates.
 * Defaults to <code>true</code>.
 */
@property(nonatomic, copy) BOOL ignoreFailedUpdates;

/**
 * An "options" object used to determine whether a confirmation dialog should be displayed to the end user when an update is available,
 * and if so, what strings to use. Defaults to null, which has the effect of disabling the dialog completely.
 * Setting this to any truthy value will enable the dialog with the default strings, and passing an object to this parameter allows
 * enabling the dialog as well as overriding one or more of the default strings.
 */
@property(nonatomic, copy) MSAssetsUpdateDialog *updateDialog;

/**
 * Specifies when you would like to synchronize updates with the CodePush server.
 * Defaults to {@link AssetsCheckFrequency#ON_APP_START}.
 */
@property(nonatomic, copy) MSAssetsCheckFrequency *checkFrequency;

/**
 * Whether sdk should restart the application after an update is made.
 * In case of assets replacement this flag is recommended to be set to <code>false</code>,
 * although in Android application, a restart is not going to be made anyway.
 */
@property(nonatomic, copy) BOOL shouldRestart;

@end


