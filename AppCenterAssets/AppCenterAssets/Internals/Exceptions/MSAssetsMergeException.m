#import <Foundation/Foundation.h>
#import "MSAssetsMergeException.h"

static NSString *const kMSMergeException = @"Error occurred during package contents merging.";

@implementation MSAssetsMergeException

- (instancetype)init:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@.", kMSMergeException, reason];
    self = [super initWithName:@"MSAssetsMergeException" reason:newReason userInfo:nil];
    return self;
}
@end
