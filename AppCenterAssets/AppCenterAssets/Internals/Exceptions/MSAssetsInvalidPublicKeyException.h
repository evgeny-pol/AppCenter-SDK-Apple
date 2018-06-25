#import <Foundation/Foundation.h>

/**
 * Class to handle exception occurred when obtaining public key.
 */
@interface MSAssetsInvalidPublicKeyException : NSException

- (instancetype)init:(NSString *)reason;

@end
