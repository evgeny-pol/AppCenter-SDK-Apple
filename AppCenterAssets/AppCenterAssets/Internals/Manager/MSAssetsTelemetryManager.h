#import <Foundation/Foundation.h>
#import "MSLocalPackage.h"
#import "MSAssetsPackage.h"
#import "MSDeploymentStatusReport.h"
#import "MSAssetsSettingManager.h"

/**
 * Manager responsible for restarting the application.
 */
@interface MSAssetsTelemetryManager : NSObject

- (id)initWithSettingManager: (MSAssetsSettingManager
                               *)settingManager;

/**
 * Builds binary update report using current app version.
 *
 * @param appVersion current app version.
 * @return new binary update report.
 */
- (MSDeploymentStatusReport *)buildBinaryUpdateReportWithAppVersion:(NSString * _Nonnull)appVersion;

/**
 * Builds update report using current local package information.
 *
 * @param currentPackage instance of `MSLocalPackage` with package information.
 * @return new update report.
 */
- (MSDeploymentStatusReport *)buildUpdateReportWithPackage:(MSLocalPackage * _Nonnull)currentPackage;

/**
 * Builds rollback report using current local package information.
 *
 * @param failedPackage instance of `MSAssetsPackage` with package information.
 * @return new rollback report.
 */
- (MSDeploymentStatusReport *)buildRoolbackReportWithFailedPackage:(MSAssetsPackage * _Nonnull)failedPackage;


@end
