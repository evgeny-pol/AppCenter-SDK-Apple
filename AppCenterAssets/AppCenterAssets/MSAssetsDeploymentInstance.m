#import "MSAssets.h"
#import "MSAssetsUpdateState.h"
#import "MSAssetsPackage.h"

@implementation MSAssetsDeploymentInstance

+ (NSString *)getApplicationSupportDirectory
{
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return applicationSupportDirectory;
}

- (NSDictionary *)checkForUpdate:(NSString *)deploymentKey {

    if (deploymentKey){
        [self setDeploymentKey:deploymentKey];
    }

    NSMutableDictionary *localPackage = [[[MSAssetsDeploymentInstance class] getCurrentPackage] mutableCopy];

    if (localPackage){
        NSLog(@"Got local package");
    }

    NSLog(@"Check for update called");
    return @{@"fake": @"fake"};
}

+ (NSDictionary *)getUpdateMetadataForState:(MSAssetsUpdateState)updateState
                 currentPackageGettingError:(NSError * __autoreleasing *)error
{
    NSError *__autoreleasing internalError;

    NSMutableDictionary *package = [[MSAssetsPackage getCurrentPackage:&internalError] mutableCopy];
    if (internalError){
        error = &internalError;
        return nil;
    }

    if (package) return @{@"fake": @"fake"};
    if (updateState) return @{@"fake": @"fake"};
    if (error) return @{@"fake": @"fake"};
    return @{@"fake": @"fake"};

}

+ (NSDictionary *)getCurrentPackage
{
    NSError *error;
    NSDictionary *currentPackage = [[MSAssetsDeploymentInstance class] getUpdateMetadataForState:MSAssetsUpdateStateLatest currentPackageGettingError:&error];
    if (error){
        NSLog(@"An error occured: %@", [error localizedDescription]);
        return nil;
    }
    return currentPackage;
}

+ (BOOL)isUsingTestConfiguration
{
    return NO;
}



@end
