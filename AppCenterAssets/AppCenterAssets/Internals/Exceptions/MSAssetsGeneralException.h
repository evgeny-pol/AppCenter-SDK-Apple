#import <Foundation/Foundation.h>
/**
 * General code push exception that has no specified sub type or occasion.
 */
@interface MSAssetsGeneralException : NSException

- (instancetype)init:(NSString *)reason;

@end
