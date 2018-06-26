#import "MSAssets.h"
#import "MSAssetsUpdateState.h"
#import "MSLocalPackage.h"

@implementation MSAssetsDeploymentInstance

- (instancetype)init {
    if ((self = [super init])) {
        _managers = [[MSAssetsManagers alloc] init];
    }
    return self;
}

- (MSRemotePackage *)checkForUpdate:(NSString *)deploymentKey {

    if (deploymentKey){
        [self setDeploymentKey:deploymentKey];
    }

    // TODO: get correct configuration
    MSAssetsConfiguration *config = [MSAssetsConfiguration new];

    MSLocalPackage *localPackage = [[self getCurrentPackage] mutableCopy];

    MSLocalPackage *queryPackage;
    if (localPackage){
        NSLog(@"Got local package");
        queryPackage = localPackage;
    }
    else{
        queryPackage = [MSLocalPackage new];
    }

    [[[self managers] acquisitionManager] queryUpdateWithCurrentPackage:config localPackage:queryPackage completionHandler:NULL];

    NSLog(@"Check for update called");
    return NULL;
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

    if (updateState) return NULL;
    if (error) return NULL;
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
