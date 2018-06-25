#import <Foundation/Foundation.h>
#import "MSAssetsUnzipException.h"

static NSString *const kMSUnzipException = @"Error occurred during package unzipping.";

@implementation MSAssetsUnzipException

- (instancetype)init:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@.", kMSUnzipException, reason];
    self = [super initWithName:@"MSAssetsUnzipException" reason:newReason userInfo:nil];
    return self;
}
@end
