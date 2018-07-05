#import <Foundation/Foundation.h>
#import "MSAssetsIllegalArgumentException.h"

@implementation MSAssetsIllegalArgumentException

- (instancetype)initWithClass:(NSString *)className argument:(NSString *)argument {
    NSString * reason = [[NSString alloc] initWithFormat:@"%@.%@ can't be null.", argument, className];
    self = [super initWithName:@"MSAssetsIllegalArgumentException" reason: reason userInfo: nil];
    return self;
}
@end 
