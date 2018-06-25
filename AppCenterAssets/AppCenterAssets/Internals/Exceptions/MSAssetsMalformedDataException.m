#import <Foundation/Foundation.h>
#import "MSAssetsMalformedDataException.h"

@implementation MSAssetsMalformedDataException

- (instancetype)init:(NSString *)reason {
    self = [super initWithName:@"MSAssetsMalformedDataException" reason:reason userInfo:nil];
    return self;
}
@end
