#import <Foundation/Foundation.h>

/**
 * Listener for restart events.
 */
typedef void (^MSAssetsRestartListener)();

/**
* Handler of restarts.
*
* @param onlyIfUpdateIsPending `true` if restart only if update is pending.
* @param restartListener listener to notify when restart has finished.
*/
typedef void (^MSAssetsRestartHandler)(BOOL onlyIfUpdateIsPending, MSAssetsRestartListener restartListener);

/**
 * Manager responsible for restarting the application.
 */
@interface MSAssetsRestartManager : NSObject

/**
 * Creates an instance of `MSAssetsRestartManager`.
 *
 * @param restartHandler handler of restarts.
 */
- (instancetype)initWithRestartHandler:(MSAssetsRestartHandler)restartHandler;

/**
 * Allows the manager to perform restarts and performs them if there are pending.
 */
- (void)allowRestarts;

/**
 * Disallows the manager to perform restarts.
 */
- (void)disallowRestarts;

/**
 * Clears the list of pending restarts.
 */
- (void)clearPendingRestarts;

/**
 * Performs the application restart.
 *
 * @param ifUpdateIsPending if `true`, performs restart only if there is a pending update.
 * @return `true` if application has restarted successfully.
 */
- (BOOL)restartAppOnlyIfUpdateIsPending:(BOOL)ifUpdateIsPending;

@end
