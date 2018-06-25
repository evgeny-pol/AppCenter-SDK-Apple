#import <Foundation/Foundation.h>
#import "MSAssetsQueryUpdateException.h"

static NSString *const kMSQueryUpdateException = @"Error occurred during querying the update.";

@implementation MSAssetsQueryUpdateException

- (instancetype)init:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@.", kMSQueryUpdateException, reason];
    self = [super initWithName:@"MSAssetsQueryUpdateException" reason:newReason userInfo: nil];
    return self;
}

- (instancetype)initWithPackageHash:(NSString *)packageHash reason:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ Package hash is %@. %@", kMSQueryUpdateException, packageHash, reason];
    self = [super initWithName:@"MSAssetsQueryUpdateException" reason:newReason userInfo: nil];
    return self;
}

@end
