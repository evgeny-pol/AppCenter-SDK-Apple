#import <Foundation/Foundation.h>
#import "MSAssetsReportType.h"

/**
 * An exception occurred during reporting the status to server.
 */
@interface MSAssetsQueryUpdateException : NSException

- (instancetype)initWithReportType:(MSAssetsReportType)reportType reason(NSString *)reason;

@end
