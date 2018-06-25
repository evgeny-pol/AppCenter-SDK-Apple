@interface MSAssetsDeploymentInstance : NSObject

- (NSDictionary *)checkForUpdate:(NSString *)deploymentKey;

@property (nonatomic, copy) NSString *deploymentKey;
@property (nonatomic, copy) NSString *serverUrl;
@property (nonatomic, copy) NSString *updateSubFolder;

@end
