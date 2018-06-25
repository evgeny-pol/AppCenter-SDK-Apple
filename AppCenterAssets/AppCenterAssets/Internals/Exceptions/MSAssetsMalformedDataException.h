#import <Foundation/Foundation.h>

/**
 * Exception class for throwing malformed Assets data exceptions.
 * Malformed data could be json blob of Assets update manifest and other json blobs
 * saved locally, received from server and etc.
 */
@interface MSAssetsMalformedDataException : NSException

- (instancetype)init:(NSString *)reason;

@end
