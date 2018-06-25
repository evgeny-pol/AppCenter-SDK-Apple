#import <Foundation/Foundation.h>

/**
 * An exception occurred during installing the package.
 */
@interface MSAssetsInstallException : NSException

- (instancetype)init:(NSString *)reason;

@end
