#import <Foundation/Foundation.h>

/**
 * Exception class for handling {@link AssetsBaseCore} creating exceptions.
 */
@interface MSAssetsInitializeException : NSException

- (instancetype)init:(NSString *)reason;

@end
