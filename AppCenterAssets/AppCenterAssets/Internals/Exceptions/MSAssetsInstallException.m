#import <Foundation/Foundation.h>
#import "MSAssetsInstallException.h"

static NSString *const kMSInstallException = @"Error occurred during installing a package.";

@implementation MSAssetsInstallException

- (instancetype)init:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@.", kMSInstallException, reason];
    self = [super initWithName:@"MSAssetsInstallException" reason:newReason userInfo:nil];
    return self;
}
@end
