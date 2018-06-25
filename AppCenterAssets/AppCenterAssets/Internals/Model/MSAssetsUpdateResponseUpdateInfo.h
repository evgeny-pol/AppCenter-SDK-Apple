#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"

@interface MSUpdateResponseUpdateInfo : NSObject <MSSerializableObject>

/**
 * Url to access package on server.
 */
@property(nonatomic, copy) NSString *downloadUrl;

/**
 * The description of the update.
 * This is the same value that you specified in the CLI when you released the update.
 */
@property(nonatomic, copy) NSString *updateDescription;

/**
 * Whether the package is available (<code>false</code> if it it disabled).
 */
@property(nonatomic) BOOL isAvailable;

/**
 * Indicates whether the update is considered mandatory.
 * This is the value that was specified in the CLI when the update was released.
 */
@property(nonatomic) BOOL isMandatory;

/**
 * The app binary version that this update is dependent on. This is the value that was
 * specified via the appStoreVersion parameter when calling the CLI's release command.
 */
@property(nonatomic, copy) NSString *appVersion;

/**
 * The SHA hash value of the update.
 */
@property(nonatomic, copy) NSString *packageHash;

/**
 * The internal label automatically given to the update by the CodePush server.
 * This value uniquely identifies the update within its deployment.
 */
@property(nonatomic, copy) NSString *label;

/**
 * Size of the package.
 */
@property(nonatomic) long long packageSize;

/**
 * Whether the client should trigger a store update.
 */
@property(nonatomic) BOOL updateAppVersion;

/**
 * Set to <code>true</code> if the update directs to use the binary version of the application.
 */
@property(nonatomic) BOOL shouldRunBinaryVersion;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
