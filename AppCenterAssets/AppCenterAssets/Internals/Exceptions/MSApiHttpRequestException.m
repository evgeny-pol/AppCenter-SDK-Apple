#import <Foundation/Foundation.h>
#import "MSApiHttpRequestException.h"

@implementation MSApiHttpRequestException

- (instancetype)init:(NSString *)reason {
    self = [super initWithName:@"MSApiHttpRequestException" reason: reason userInfo: nil];
    return self;
}
@end
