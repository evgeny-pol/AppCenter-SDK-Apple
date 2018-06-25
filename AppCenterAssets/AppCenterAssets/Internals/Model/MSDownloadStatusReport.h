#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"

@interface MSDownloadStatusReport : NSObject <MSSerializableObject>

/**
 * The id of the device.
 */
@property(nonatomic, copy) NSString * _Nonnull clientUniqueId;

/**
 * The deployment key to use to query the CodePush server for an update.
 */
@property(nonatomic, copy) NSString * _Nonnull deploymentKey;

/**
 * The internal label automatically given to the update by the CodePush server.
 * This value uniquely identifies the update within its deployment.
 */
@property(nonatomic, copy) NSString * _Nonnull label;

/**
 * Creates a report using the provided information.
 *
 * @param clientUniqueId id of the device.
 * @param deploymentKey  deployment key to use to query the CodePush server for an update.
 * @param label          internal label automatically given to the update by the CodePush server.
 * @return instance of {@link MSDownloadStatusReport}.
 */
+ (MSDownloadStatusReport *)createReport:(NSString *)clientUniqueId
                       withDeploymentKey:(NSString *)deploymentKey
                                andLabel:(NSString *)label;

@end
