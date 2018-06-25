#import <Foundation/Foundation.h>
#import "MSApiHttpRequestException.h"

/**
 * An exception occurred during downloading the package.
 */
@interface MSDownloadPackageException : MSApiHttpRequestException

- (instancetype)initWithBytes:(long)received total:(long)total;
- (instancetype)init:(NSString *)reason;
- (instancetype)initWithUrl:(NSString *)downloadUrl reason:(NSString *)reason;
@end
