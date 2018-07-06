#import "MSAssetsCheckForUpdate.h"
#import "MSAssetsRemotePackage.h"
#import "MSAssetsConfiguration.h"
#import "MSAssetsLocalPackage.h"
#import "MSAssetsDownloadStatusReport.h"
#import "MSAssetsDeploymentStatusReport.h"
#import "MSAssetsReportSender.h"

/**
* Callback to pass the result of check for update request.
*
* @param remotePackage result of the request.
* @param error error if happened.
*/
typedef void (^MSCheckForUpdateCompletionHandler)(MSAssetsRemotePackage * _Nullable remotePackage, NSError * _Nullable error);

/**
* Manager for making requests to CodePush server.
*/
@interface MSAssetsAcquisitionManager : NSObject

/**
* Sends a request to server for updates of the current package.
*
* @param configuration  current application configuration.
* @param localPackage instance of MSAssetsLocalPackage.
* @param handler callback to pass the results.
*/
- (void)queryUpdateWithCurrentPackage:(MSAssetsLocalPackage *)localPackage
                    withConfiguration:(MSAssetsConfiguration *)configuration
                 andCompletionHandler:(MSCheckForUpdateCompletionHandler)handler;

/**
 * Sends download status to server.
 *
 * @param report instance of `MSAssetsDownloadStatusReport` to be sent.
 * @param configuration     current application configuration.
 */
- (void)reportDownloadStatus:(nullable MSAssetsDownloadStatusReport *)report
           withConfiguration:(nullable MSAssetsConfiguration *)configuration;

/**
 * Sends deployment status to server.
 *
 * @param report instance of `MSAssetsDeploymentStatusReport` to be sent.
 * @param configuration     current application configuration.
 */
- (void)reportDeploymentStatus:(nullable MSAssetsDeploymentStatusReport *)report
             withConfiguration:(nullable MSAssetsConfiguration *)configuration;
@end

