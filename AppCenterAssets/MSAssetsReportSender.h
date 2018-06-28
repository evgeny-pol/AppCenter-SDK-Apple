#import <Foundation/Foundation.h>

#import "MSHttpSender.h"
#import "MSAssetsReportType.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSAssetsReportSender : MSHttpSender

/**
 * Initialize the Sender.
 *
 * @param baseUrl Base url.
 * @param reportType type of the report to be sent.
 *
 * @return A sender instance.
 */
- (id)initWithBaseUrl:(nullable NSString *)baseUrl reportType:(MsAssetsReportType)reportType;

@end

NS_ASSUME_NONNULL_END
