#import <Foundation/Foundation.h>
#import "MSAssetsGeneralException.h"

@implementation MSAssetsGeneralException

- (instancetype)init:(NSString *)reason {
    self = [super initWithName:@"MSAssetsGeneralException" reason: reason userInfo: nil];
    return self;
}
@end
