#import "MSAssets.h"
#import "MSAssetsUpdateState.h"
#import "MSLocalPackage.h"
#import "MSAssetsErrors.h"
#import <UIKit/UIKit.h>

@implementation MSAssetsDeploymentInstance

@synthesize delegate = _delegate;

- (instancetype)init {
    if ((self = [super init])) {
        _managers = [[MSAssetsManagers alloc] init];
    }
    return self;
}

- (void)checkForUpdate:(NSString *)deploymentKey {

    if (deploymentKey){
        [self setDeploymentKey:deploymentKey];
    }

    // TODO: get correct configuration
    MSAssetsConfiguration *config = [self getConfiguration];

    MSLocalPackage *localPackage = [[self getCurrentPackage] mutableCopy];

    MSLocalPackage *queryPackage;
    if (localPackage){
        NSLog(@"Got local package");
        queryPackage = localPackage;
    }
    else{
        queryPackage = [MSLocalPackage createLocalPackageWithAppVersion:config.appVersion];
    }

    [[[self managers] acquisitionManager] queryUpdateWithCurrentPackage:config localPackage:queryPackage completionHandler:^( MSRemotePackage *package,  NSError * _Nullable error){
        if (error) {
            NSLog(@"#Error: %@", error.localizedDescription);
        };
        MSRemotePackage *update = [package mutableCopy];

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
            // TODO: set correct value with isFailedHash verification
            update.failedInstall = NO;
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
    configuration.packageHash = @"fake";

    return configuration;
}

- (MSLocalPackage *)getUpdateMetadataForState:(MSAssetsUpdateState)updateState
                 currentPackageGettingError:(NSError * __autoreleasing *)error
{
    NSError *__autoreleasing internalError;

    MSLocalPackage *package = [[[[self managers] updateManager] getCurrentPackage:&internalError] mutableCopy];

    if (internalError){
        error = &internalError;
        return nil;
    }

    if (updateState) return nil;
    if (error) return nil;
    return package;

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
