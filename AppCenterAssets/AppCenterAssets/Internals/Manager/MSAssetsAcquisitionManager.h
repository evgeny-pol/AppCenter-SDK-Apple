#import "MSAssetsCheckForUpdate.h"
#import "MSRemotePackage.h"
#import "MSAssetsConfiguration.h"
#import "MSLocalPackage.h"


/**
 Callback to pass the result of check for update request.

 @param remotePackage result of the request.
 @param error error if happened.
 */
typedef void (^MSCheckForUpdateCompletionHandler)(MSRemotePackage * _Nullable remotePackage, NSError * _Nullable error);


/**
 Manager for making requests to CodePush server.
 */
@interface MSAssetsAcquisitionManager : NSObject

/**
 Instance of sender to make requests.
 */
@property(nonatomic, nullable) MSAssetsCheckForUpdate *updateChecker;

/**
 Sends a request to server for updates of the current package.

 @param configuration  current application configuration.
 @param localPackage instance of MSLocalPackage.
 @param handler callback to pass the results.
*/
- (void)queryUpdateWithCurrentPackage:(nullable MSAssetsConfiguration *)configuration
                                      localPackage:(nullable MSLocalPackage *)localPackage
                    completionHandler:(nullable MSCheckForUpdateCompletionHandler)handler;

@end

