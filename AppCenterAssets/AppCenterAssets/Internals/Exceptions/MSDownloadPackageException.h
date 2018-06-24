#import <Foundation/Foundation.h>
#import "MSApiHttpRequestException"

/**
 * An exception occurred during downloading the package.
 */
@interface MSDownloadPackageException : MSApiHttpRequestException

- (instancetype)initWithBytes:(long)received total:(long)total;

- (instancetype)initWithUrl:(NSString *)downloadUrl reason:(NSString *)reason;
@end
