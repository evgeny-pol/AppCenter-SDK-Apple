#import <Foundation/Foundation.h>
#import "MSOperationType.h"

/**
 * Exception class for handling resource finalize exceptions.
 */
@interface MSAssetsFinalizeException : NSException

- (instancetype)init:(MSOperationType)received total:(long)total;

@end
