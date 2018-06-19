#import <Foundation/Foundation.h>

@interface MSAssetsPackage

/**
 * The app binary version that this update is dependent on. This is the value that was
 * specified via the appStoreVersion parameter when calling the CLI's release command.
 */
@property(nonatomic, copy) NSString *appVersion;

/**
 * The deployment key that was used to originally download this update.
 */
@property(nonatomic, copy) NSString *deploymentKey;

/**
 * The description of the update. This is the same value that you specified in the CLI
 * when you released the update.
 */
@property(nonatomic, copy) NSString *description;

/**
 * Indicates whether this update has been previously installed but was rolled back.
 */
@property(nonatomic, copy) BOOL *failedInstall;

/**
 * Indicates whether the update is considered mandatory.
 * This is the value that was specified in the CLI when the update was released.
 */
@property(nonatomic, copy) BOOL *isMandatory;

/**
 * The internal label automatically given to the update by the CodePush server.
 * This value uniquely identifies the update within its deployment.
 */
@property(nonatomic, copy) NSString *label;

/**
 * The SHA hash value of the update.
 */
@property(nonatomic, copy) NSString *packageHash;

@end
