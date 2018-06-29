#import "MSAssetsTelemetryManager.h"
#import "MSLocalPackage.h"
#import "MSAssetsPackage.h"
#import "MSDeploymentStatusReport.h"
#import "MSAssetsSettingManager.h"

@implementation MSAssetsTelemetryManager

+ (MSDeploymentStatusReport *)buildBinaryUpdateReportWithAppVersion:(NSString * _Nonnull)appVersion {
    MSDeploymentStatusReport *report = [MSDeploymentStatusReport new];
    [report setAppVersion:appVersion];
    [report setLabel:@""];
    [report setStatus:MSAssetsDeploymentStatusSucceeded];
    return report;
}

+ (MSDeploymentStatusReport *)buildUpdateReportWithPackage:(MSAssetsPackage * _Nonnull)currentPackage {
    MSDeploymentStatusReport *report = [MSDeploymentStatusReport new];
    [report setAssetsPackage:currentPackage];
    [report setStatus:MSAssetsDeploymentStatusSucceeded];
    return report;
}

+ (MSDeploymentStatusReport *)buildRoolbackReportWithFailedPackage:(MSAssetsPackage * _Nonnull)failedPackage {
    MSDeploymentStatusReport *report = [MSDeploymentStatusReport new];
    [report setAssetsPackage:failedPackage];
    [report setStatus:MSAssetsDeploymentStatusFailed];
    return report;
}

@end
