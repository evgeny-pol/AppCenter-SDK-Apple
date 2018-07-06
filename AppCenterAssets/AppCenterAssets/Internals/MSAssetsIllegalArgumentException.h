#import <Foundation/Foundation.h>

/**
 * An exception occurred during making HTTP request to CodePush server.
 */
@interface MSAssetsIllegalArgumentException : NSException

- (instancetype)initWithClass:(NSString *)className argument:(NSString *)argument;

@end
