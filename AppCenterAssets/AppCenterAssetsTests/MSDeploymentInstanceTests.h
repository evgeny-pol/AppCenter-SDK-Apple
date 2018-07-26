#import "MSTestFrameworks.h"
#import "MSAssetsDeploymentInstance.h"

static NSString *const kMSDeploymentKey = @"11111111-0000-1111-0000-111111111111";
static NSString *const kMSPackageHash = @"00000000-1111-0000-1111-000000000000";

// Make private method available for mocking.
@interface MSAssetsDeploymentInstance (Test)

- (void)checkForUpdate:(NSString *)deploymentKey withCompletionHandler:(MSCheckForUpdateCompletionHandler)handler;
- (MSAssetsLocalPackage *)getCurrentPackage;
- (void) doDownloadAndInstall:(MSAssetsRemotePackage *)remotePackage
                    syncOptions:(MSAssetsSyncOptions *)syncOptions
                  configuration:(MSAssetsConfiguration *)configuration
                        handler:(MSAssetsDownloadInstallHandler)handler;
- (void) notifyAboutSyncStatusChange:(MSAssetsSyncStatus)syncStatus instanceState:(MSAssetsDeploymentInstanceState *)instanceState;
@end

@interface MSDeploymentInstanceTests : XCTestCase

- (void)checkForUpdateCallWithDeploymentKey: (NSString *)deploymentKey
                            andLocalPackage: (MSAssetsLocalPackage *) localPackage
                                  andConfig: (MSAssetsConfiguration *)configuration
                           andRemotePackage: (MSAssetsRemotePackage *)rmPackage
                             andRemoteError: (NSError *)remoteError
                                andDelegate: (id<MSAssetsDelegate>)delegate
                      andCallbackCompletion: (MSCheckForUpdateCompletionHandler)handler;

@property (nonatomic) MSAssetsDeploymentInstance *sut;

@end
