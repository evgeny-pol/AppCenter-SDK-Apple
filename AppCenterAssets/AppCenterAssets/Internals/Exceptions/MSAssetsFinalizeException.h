#import <Foundation/Foundation.h>
#import "MSOperationType.h"

/**
 * Exception class for handling resource finalize exceptions.
 */
@interface MSAssetsFinalizeException : NSException

- (instancetype)init:(MSOperationType)type reason:(NSString *)reason;
- (instancetype)init:(NSString *)reason;

@end
