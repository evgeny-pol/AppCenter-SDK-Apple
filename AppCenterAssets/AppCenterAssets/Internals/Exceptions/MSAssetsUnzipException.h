#import <Foundation/Foundation.h>

/**
 * An exception occurred when unzipping the package.
 */
@interface MSAssetsUnzipException : NSException

- (instancetype)init:(NSString *)reason;

@end
