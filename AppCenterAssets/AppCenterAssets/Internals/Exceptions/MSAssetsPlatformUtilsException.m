#import <Foundation/Foundation.h>
#import "MSAssetsPlatformUtilsException.h"

@implementation MSAssetsPlatformUtilsException

- (instancetype)init:(NSString *)reason {
    self = [super initWithName:@"MSAssetsPlatformUtilsException" reason:reason userInfo:nil];
    return self;
}
@end
