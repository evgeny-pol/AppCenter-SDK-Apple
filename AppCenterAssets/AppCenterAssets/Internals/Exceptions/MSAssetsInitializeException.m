#import <Foundation/Foundation.h>
#import "MSAssetsInitializeException.h"

@implementation MSAssetsInitializeException

- (instancetype)init:(NSString *)reason {
    self = [super initWithName:@"MSAssetsInitializeException" reason:reason userInfo:nil];
    return self;
}
@end
