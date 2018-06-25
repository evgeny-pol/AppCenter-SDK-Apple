#import <Foundation/Foundation.h>
#import "MSAssetsNativeApiCallException.h"

@implementation MSAssetsNativeApiCallException

- (instancetype)init:(NSString *)reason {
    self = [super initWithName:@"MSAssetsNativeApiCallException" reason:reason userInfo:nil];
    return self;
}
@end
