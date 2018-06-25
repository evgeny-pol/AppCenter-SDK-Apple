#import <Foundation/Foundation.h>
#import "MSAssetsReportType.h"

/**
 * An exception occurred during reporting the status to server.
 */
@interface MSAssetsReportStatusException : NSException

- (instancetype)initWithReportType:(MsAssetsReportType)reportType reason:(NSString *)reason;

@end
