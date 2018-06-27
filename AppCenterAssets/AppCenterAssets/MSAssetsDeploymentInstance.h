#import <Foundation/Foundation.h>

@interface MSAssetsDeploymentInstance : NSObject

+ (NSString *)getApplicationSupportDirectory;
- (NSDictionary *)checkForUpdate:(NSString *)deploymentKey;

// The below methods are only used during tests.
+ (BOOL)isUsingTestConfiguration;


@property (nonatomic, copy) NSString *deploymentKey;
@property (nonatomic, copy) NSString *serverUrl;
@property (nonatomic, copy) NSString *updateSubFolder;

@end
