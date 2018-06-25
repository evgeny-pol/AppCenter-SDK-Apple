#import <Foundation/Foundation.h>
#import "MSAssetsGetPackageException.h"

static NSString *const kMSGetPackageException = @"Error occurred during obtaining a package.";

@implementation MSAssetsGetPackageException

- (instancetype)init:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@.", kMSGetPackageException, reason];
    self = [super initWithName:@"MSAssetsGetPackageException" reason:newReason userInfo:nil];
    return self;
}
@end
