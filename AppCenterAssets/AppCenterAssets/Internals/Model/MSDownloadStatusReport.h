#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"

@interface MSDownloadStatusReport : NSObject <MSSerializableObject>

/**
 * The id of the device.
 */
@property(nonatomic, copy, nonnull) NSString *clientUniqueId;

/**
 * The deployment key to use to query the CodePush server for an update.
 */
@property(nonatomic, copy, nonnull) NSString *deploymentKey;

/**
 * The internal label automatically given to the update by the CodePush server.
 * This value uniquely identifies the update within its deployment.
 */
@property(nonatomic, copy, nonnull) NSString *label;

/**
 * Creates a report using the provided information.
 *
 * @param clientUniqueId id of the device.
 * @param deploymentKey  deployment key to use to query the CodePush server for an update.
 * @param label          internal label automatically given to the update by the CodePush server.
 * @return instance of {@link MSDownloadStatusReport}.
 */
+ (nonnull MSDownloadStatusReport *)createReport:(nonnull NSString *)clientUniqueId
                       withDeploymentKey:(nonnull NSString *) deploymentKey
                                andLabel:(nonnull NSString *)label;

@end
