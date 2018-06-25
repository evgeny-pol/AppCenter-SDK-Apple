#import <Foundation/Foundation.h>
#import "MSAssetsInvalidPublicKeyException.h"

@implementation MSAssetsInvalidPublicKeyException

- (instancetype)init:(NSString *)reason {
    self = [super initWithName:@"MSAssetsInvalidPublicKeyException" reason:reason userInfo:nil];
    return self;
}
@end
