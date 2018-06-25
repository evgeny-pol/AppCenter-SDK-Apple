#import <Foundation/Foundation.h>

/**
 * An exception occurred during making HTTP request to CodePush server.
 */
@interface MSApiHttpRequestException : NSException

- (instancetype)init:(NSString *)reason;

@end
