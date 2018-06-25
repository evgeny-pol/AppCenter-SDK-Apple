#import <Foundation/Foundation.h>

/**
 * An exception occurred during querying the update.
 */
@interface MSAssetsQueryUpdateException : NSException

- (instancetype)init:(NSString *)reason;
- (instancetype)initWithPackageHash:(NSString *)packageHash reason:(NSString *)reason;

@end
