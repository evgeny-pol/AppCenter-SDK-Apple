#import "MSAssetsCheckForUpdate.h"
#import "MSRemotePackage.h"
#import "MSAssetsConfiguration.h"
#import "MSLocalPackage.h"
#import "MSDownloadStatusReport.h"
#import "MSDeploymentStatusReport.h"
#import "MSAssetsReportSender.h"

/**
* Callback to pass the result of check for update request.
*
* @param remotePackage result of the request.
* @param error error if happened.
*/
typedef void (^MSCheckForUpdateCompletionHandler)(MSRemotePackage * _Nullable remotePackage, NSError * _Nullable error);

/**
* Manager for making requests to CodePush server.
*/
@interface MSAssetsAcquisitionManager : NSObject

/**
* Sends a request to server for updates of the current package.
*
* @param configuration  current application configuration.
* @param localPackage instance of MSLocalPackage.
* @param handler callback to pass the results.
*/
- (void)queryUpdateWithCurrentPackage:(MSLocalPackage *)localPackage
                    withConfiguration:(MSAssetsConfiguration *)configuration
                 andCompletionHandler:(MSCheckForUpdateCompletionHandler)handler;

/**
 * Sends download status to server.
 *
 * @param report instance of `MSDownloadStatusReport` to be sent.
 * @param configuration     current application configuration.
 */
- (void)reportDownloadStatus:(nullable MSDownloadStatusReport *)report
           withConfiguration:(nullable MSAssetsConfiguration *)configuration;

/**
 * Sends deployment status to server.
 *
 * @param report instance of `MSDeploymentStatusReport` to be sent.
 * @param configuration     current application configuration.
 */
- (void)reportDeploymentStatus:(nullable MSDeploymentStatusReport *)report
             withConfiguration:(nullable MSAssetsConfiguration *)configuration;
@end

