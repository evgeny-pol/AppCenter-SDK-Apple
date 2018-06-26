#import <Foundation/Foundation.h>

#import "MSHttpSender.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSAssetsCheckForUpdate : MSHttpSender

/**
 * Initialize the Sender.
 *
 * @param baseUrl Base url.
 *
 * @return A sender instance.
 */
- (id)initWithBaseUrl:(nullable NSString *)baseUrl queryStrings:(NSDictionary *)queryStrings;

@end

NS_ASSUME_NONNULL_END
