#import <Foundation/Foundation.h>

#import "MSAssetsPackage.h"
#import "MSDeploymentStatus.h"

@interface MSDeploymentStatusReports

/**
 * The id of the device.
 */
@property(nonatomic, copy) NSString *clientUniqueId;

/**
 * The deployment key to use to query the CodePush server for an update.
 */
@property(nonatomic, copy) NSString *deploymentKey;

/**
 * The internal label automatically given to the update by the CodePush server.
 * This value uniquely identifies the update within its deployment.
 */
@property(nonatomic, copy) NSString *label;

/**
 * Whether the deployment succeeded or failed.
 */
@property(nonatomic, copy) MSDeploymentStatus *status;

/**
 * Stores information about installed/failed package.
 */
@property(nonatomic, copy) MSAssetsPackage *assetsPackage;

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
