#import <Foundation/Foundation.h>

/**
 * An exception occurred during rollback.
 */
@interface MSAssetsRollbackException : NSException

- (instancetype)init:(NSString *)reason;

@end
