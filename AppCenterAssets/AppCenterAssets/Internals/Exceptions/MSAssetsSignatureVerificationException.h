#import <Foundation/Foundation.h>
#import "MSSignatureExceptionType.h"

/**
 * Exception class for handling signature verification errors.
 */
@interface MSAssetsSignatureVerificationException : NSException

- (instancetype)initWithType:(MSSignatureExceptionType)type reason:(NSString *)reason;
- (instancetype)init:(NSString *)reason;
- (instancetype)initWithType:(MSSignatureExceptionType)type;

@end
