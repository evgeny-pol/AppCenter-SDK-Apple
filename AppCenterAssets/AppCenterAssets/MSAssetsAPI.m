#import "MSAssets.h"

@implementation MSAssetsAPI

- (NSDictionary *)checkForUpdate:(NSString *)deploymentKey {
    if (deploymentKey){
        return @{@"fake": @"fake"};
    }
    NSLog(@"Check for update called");
    return @{@"fake": @"fake"};
}

@end
