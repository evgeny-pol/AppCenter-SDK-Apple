#import "MSAssets.h"
#import "MSAssetsUpdateState.h"
#import "MSLocalPackage.h"
#import "MSAssetsErrors.h"
#import "MSAssetsSettingManager.h"
#import <UIKit/UIKit.h>

@implementation MSAssetsDeploymentInstance

@synthesize delegate = _delegate;
@synthesize updateManager = _updateManager;
@synthesize acquisitionManager = _acquisitionManager;

static BOOL isRunningBinaryVersion = NO;
//static BOOL needToReportRollback = NO;
//static BOOL testConfigurationFlag = NO;

- (instancetype)init {
    if ((self = [super init])) {
        _updateManager = [[MSAssetsUpdateManager alloc] init];
        _acquisitionManager = [[MSAssetsAcquisitionManager alloc] init];
    }
    return self;
}

- (void)checkForUpdate:(NSString *)deploymentKey {

    if (deploymentKey){
        [self setDeploymentKey:deploymentKey];
    }

    MSAssetsConfiguration *config = [self getConfiguration];
    if (deploymentKey)
        config.deploymentKey = deploymentKey;

    MSLocalPackage *localPackage = [[self getCurrentPackage] mutableCopy];

    MSLocalPackage *queryPackage;
    if (localPackage){
        NSLog(@"Got local package");
        queryPackage = localPackage;
    }
    else{
        queryPackage = [MSLocalPackage createLocalPackageWithAppVersion:config.appVersion];
    }

    [[self acquisitionManager] queryUpdateWithCurrentPackage:queryPackage withConfiguration:config andCompletionHandler:^( MSRemotePackage *update,  NSError * _Nullable error){
        if (error) {
            if ([[self delegate] respondsToSelector:@selector(didFailToQueryRemotePackageOnCheckForUpdate:)])
                [[self delegate] didFailToQueryRemotePackageOnCheckForUpdate:error];
            return;
        };
        
        if (!update)
        {
            if ([[self delegate] respondsToSelector:@selector(didReceiveRemotePackageOnUpdateCheck:)])
                [[self delegate] didReceiveRemotePackageOnUpdateCheck:nil];
            return;
        }

        if (!update || update.updateAppVersion ||
            (localPackage && ([update.packageHash isEqualToString:localPackage.packageHash])) ||
            ((!localPackage || localPackage.isDebugOnly) && [config.packageHash isEqualToString:update.packageHash] )){

            if (update && update.updateAppVersion){
                NSLog(@"An update is available but it is not targeting the binary version of your app.");

                if ([[self delegate] respondsToSelector:@selector(didFailToQueryRemotePackageOnCheckForUpdate:)])
                {
                    NSError *newError = [NSError errorWithDomain:kMSACErrorDomain
                                                            code:kMSACQueryUpdateParseErrorCode
                                                        userInfo:nil];
                    [[self delegate] didFailToQueryRemotePackageOnCheckForUpdate:newError];
                }

            }
        } else {
            update.failedInstall = [MSAssetsSettingManager existsFailedUpdate:update.packageHash];
            if (deploymentKey){
                update.deploymentKey = deploymentKey;
            } else {
                update.deploymentKey = config.deploymentKey;
            }
        }
        if ([[self delegate] respondsToSelector:@selector(didReceiveRemotePackageOnUpdateCheck:)])
            [[self delegate] didReceiveRemotePackageOnUpdateCheck:update];
    }];

    NSLog(@"Check for update called");
}

- (MSAssetsConfiguration *)getConfiguration
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    MSAssetsConfiguration *configuration = [MSAssetsConfiguration new];
    configuration.appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    configuration.clientUniqueId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    configuration.deploymentKey = [self deploymentKey];
    configuration.serverUrl = [self serverUrl];
    NSError *error;
    configuration.packageHash = [[self updateManager] getCurrentPackageHash:&error];

    return configuration;
}

- (MSLocalPackage *)getUpdateMetadataForState:(MSAssetsUpdateState)updateState
                 currentPackageGettingError:(NSError * __autoreleasing *)error
{
    NSError *__autoreleasing internalError;

    MSLocalPackage *package = [[[self updateManager] getCurrentPackage:&internalError] mutableCopy];
    if (internalError){
        error = &internalError;
        return nil;
    }

    if (package == nil){
        // The app hasn't downloaded any CodePush updates yet,
        // so we simply return nil regardless if the user
        // wanted to retrieve the pending or running update.
        return nil;
    }

    // We have a CodePush update, so let's see if it's currently in a pending state.

    BOOL currentUpdateIsPending = [MSAssetsSettingManager isPendingUpdate:package.packageHash];

    if (updateState == MSAssetsUpdateStatePending && !currentUpdateIsPending) {
        // The caller wanted a pending update
        // but there isn't currently one.
        return nil;
    } else if (updateState == MSAssetsUpdateStateRunning && currentUpdateIsPending) {
        // The caller wants the running update, but the current
        // one is pending, so we need to grab the previous.
        package = [[self updateManager] getPreviousPackage:&internalError];
        if (internalError){
            error = &internalError;
            return nil;
        }
        else
            return package;
    } else {
        // The current package satisfies the request:
        // 1) Caller wanted a pending, and there is a pending update
        // 2) Caller wanted the running update, and there isn't a pending
        // 3) Caller wants the latest update, regardless if it's pending or not
        if (isRunningBinaryVersion) {
            // This only matters in Debug builds. Since we do not clear "outdated" updates,
            // we need to indicate to the JS side that somehow we have a current update on
            // disk that is not actually running.
            package.isDebugOnly = true;
        }
        // Enable differentiating pending vs. non-pending updates
        package.isPending = currentUpdateIsPending;
        return package;
    }

}

- (MSLocalPackage *)getCurrentPackage
{
    NSError *error;
    MSLocalPackage *currentPackage = [self getUpdateMetadataForState:MSAssetsUpdateStateLatest currentPackageGettingError:&error];
    if (error){
        NSLog(@"An error occured: %@", [error localizedDescription]);
        return nil;
    }
    return currentPackage;
}




@end
