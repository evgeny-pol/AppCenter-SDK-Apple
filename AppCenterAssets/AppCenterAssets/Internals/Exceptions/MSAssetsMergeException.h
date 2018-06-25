#import <Foundation/Foundation.h>

/**
 * An exception occurred during merging the contents of the package.
 */
@interface MSAssetsMergeException : NSException

- (instancetype)init:(NSString *)reason;

@end
