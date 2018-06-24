#import <Foundation/Foundation.h>

/**
 * Class for all exceptions that is coming from {@link AssetsBaseCore} public methods.
 */
@interface MSAssetsNativeApiCallException : NSException

- (instancetype)init:(NSString *)reason;

@end
