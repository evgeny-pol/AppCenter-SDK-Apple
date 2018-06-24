#import "MSAssets.h"
#import "MSAssetsUpdateState.h"

@implementation MSAssetsAPI

- (NSDictionary *)checkForUpdate:(NSString *)deploymentKey {

    if (deploymentKey){
        [self setDeploymentKey:deploymentKey];
    }

    NSMutableDictionary *localPackage = [[[MSAssetsAPI class] getCurrentPackage] mutableCopy];

    if (localPackage){
        NSLog(@"Got local package");
    }

    NSLog(@"Check for update called");
    return @{@"fake": @"fake"};
}

#pragma mark - Private API methods

+ (NSDictionary *)getUpdateMetadataForState:(MSAssetsUpdateState)updateState
                 currentPackageGettingError:(NSError * __autoreleasing *)error
{
    if (updateState) return @{@"fake": @"fake"};
    if (error) return @{@"fake": @"fake"};
    return @{@"fake": @"fake"};

}

+ (NSDictionary *)getCurrentPackage
{
    NSError *error;
    NSDictionary *currentPackage = [[MSAssetsAPI class] getUpdateMetadataForState:MSAssetsUpdateStateLatest currentPackageGettingError:&error];
    if (error){
        NSLog(@"An error occured: %@", [error localizedDescription]);
        return nil;
    }
    return currentPackage;
}

@end
