#import <Foundation/Foundation.h>
#import "MSDownloadPackageException.h"

static NSString *const kMSDownloadPackageException = @"Error occurred during package downloading.";

@implementation MSDownloadPackageException

- (instancetype)initWithBytes:(long)received total:(long)total {
    NSString * reason = [[NSString alloc] initWithFormat:@"%@ Received %ld bytes, expected %ld.", kMSDownloadPackageException, received, total];
    self = [super init: reason];
    return self;
}

- (instancetype)init:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@.", kMSDownloadPackageException, reason];
    self = [super init: newReason];
    return self;
}

- (instancetype)initWithUrl:(NSString *)downloadUrl reason:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ Download url is %@. %@", kMSDownloadPackageException, downloadUrl, reason];
    self = [super init: newReason];
    return self;
}
@end
