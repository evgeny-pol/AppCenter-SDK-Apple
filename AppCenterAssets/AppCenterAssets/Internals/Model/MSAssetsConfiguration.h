#import <Foundation/Foundation.h>

/**
 * Provides info regarding current app state and settings.
 */
@interface MSAssetsConfiguration : NSObject

/**
 * The version of the app that was deployed (for a native app upgrade).
 */
@property(nonatomic, copy, nullable) NSString *appVersion;

/**
 * iOS client unique id.
 */
@property(nonatomic, copy, nonnull) NSString *clientUniqueId;

/**
 * CodePush deployment key.
 */
@property(nonatomic, copy, nonnull) NSString *deploymentKey;

/**
 * CodePush acquisition server URL.
 */
@property(nonatomic, copy, nonnull) NSString *serverUrl;

/**
 * Package hash of currently running update.
 * @see MSAssetsUpdateState.
 */
@property(nonatomic, copy, null_unspecified) NSString *packageHash;

@end
