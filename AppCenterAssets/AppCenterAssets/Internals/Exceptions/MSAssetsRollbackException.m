#import <Foundation/Foundation.h>
#import "MSAssetsRollbackException.h"

static NSString *const kMSRollbackException = @"Error occurred during the rollback.";

@implementation MSAssetsRollbackException

- (instancetype)init:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@.", kMSRollbackException, reason];
    self = [super initWithName:@"MSAssetsRollbackException" reason:newReason userInfo:nil];
    return self;
}
@end
