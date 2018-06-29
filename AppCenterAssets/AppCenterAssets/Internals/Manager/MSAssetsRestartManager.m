#import "MSAssetsRestartManager.h"
#import "MSLogger.h"
#import "MSAssets.h"

@implementation MSAssetsRestartManager {
    
    /**
     * Queue containing pending restart requests.
     */
    NSMutableArray *_restartQueue;
    
    /**
     * `true` if restart is allowed.
     */
    BOOL _restartAllowed;
    
    /**
     * `true` if application is in the process of restart.
     */
    BOOL _restartInProgress;
    
    /**
     * Handler for restart events.
     */
    MSAssetsRestartHandler _restartHandler;
}

- (void)initWithRestartHandler:(MSAssetsRestartHandler)restartHandler {
    _restartHandler = restartHandler;
}

- (void)allowRestarts {
    MSLogInfo([MSAssets logTag], @"Re-allowing restarts...");
    _restartAllowed = YES;
    if ([_restartQueue count] > 0) {
        MSLogInfo([MSAssets logTag], @"Executing pending restart...");
        BOOL onlyIfUpdateIsPending = (BOOL)[_restartQueue objectAtIndex:0];
        [_restartQueue removeObjectAtIndex:0];
        [self restartAppOnlyIfUpdateIsPending:onlyIfUpdateIsPending];
    }
}

- (void)disallowRestarts {
    MSLogInfo([MSAssets logTag], @"Disallowing restarts...");
    _restartAllowed = NO;
}

- (void)clearPendingRestarts {
    [_restartQueue removeAllObjects];
}

- (BOOL)restartAppOnlyIfUpdateIsPending:(BOOL)ifUpdateIsPending{
    if (_restartInProgress) {
        MSLogInfo([MSAssets logTag], @"Restart request queued until the current restart is completed.");
        [_restartQueue addObject:[NSNumber numberWithBool:ifUpdateIsPending]];
    } else if (!_restartAllowed) {
        MSLogInfo([MSAssets logTag], @"Restart request queued until restarts are re-allowed.");
        [_restartQueue addObject:[NSNumber numberWithBool:ifUpdateIsPending]];
    } else {
        _restartInProgress = YES;
        if (_restartHandler != nil) {
            __weak typeof(self) weakSelf = self;
            _restartHandler(ifUpdateIsPending, ^() {
                typeof(self) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                strongSelf->_restartInProgress = NO;
                if ([strongSelf->_restartQueue count] > 0) {
                    BOOL onlyIfUpdateIsPending = (BOOL)[strongSelf->_restartQueue objectAtIndex:0];
                    [strongSelf->_restartQueue removeObjectAtIndex:0];
                    [strongSelf restartAppOnlyIfUpdateIsPending:onlyIfUpdateIsPending];
                }
            });
        }
    };
    return NO;
}

@end
