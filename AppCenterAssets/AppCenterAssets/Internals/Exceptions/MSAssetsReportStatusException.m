#import <Foundation/Foundation.h>
#import "MSAssetsReportStatusException.h"
#import "MSAssetsReportType.h"

@implementation MSAssetsReportStatusException

- (instancetype)initWithReportType:(MsAssetsReportType)reportType reason:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@", [self getReportTypeMessage: reportType], reason];
    self = [super initWithName:@"MSAssetsReportStatusException" reason: newReason userInfo: nil];
    return self;
}

- (NSString *)getReportTypeMessage:(MsAssetsReportType)type {
    switch (type) {
        case MsAssetsReportTypeDeploy:
            return @"Error occurred during delivering download status report.";
        case MsAssetsReportTypeDownload:
            return @"Error occurred during delivering deploy status report.";
        default:
            return @"Error occurred during delivering status report.";
    }
}
@end
