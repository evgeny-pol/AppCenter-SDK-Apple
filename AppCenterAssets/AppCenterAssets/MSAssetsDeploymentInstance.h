#import "MSRemotePackage.h"
#import "MSAssetsManagers.h"

@interface MSAssetsDeploymentInstance : NSObject

- (MSRemotePackage *)checkForUpdate:(NSString *)deploymentKey;

@property (nonatomic, copy, readonly) MSAssetsManagers *managers;

@property (nonatomic, copy) NSString *deploymentKey;
@property (nonatomic, copy) NSString *serverUrl;
@property (nonatomic, copy) NSString *updateSubFolder;

@end
