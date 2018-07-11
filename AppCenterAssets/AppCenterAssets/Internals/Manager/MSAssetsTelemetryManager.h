#import <Foundation/Foundation.h>
#import "MSAssetsLocalPackage.h"
#import "MSAssetsPackage.h"
#import "MSAssetsDeploymentStatusReport.h"
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
- (MSAssetsDeploymentStatusReport *)buildBinaryUpdateReportWithAppVersion:(NSString * _Nonnull)appVersion;

/**
 * Builds update report using current local package information.
 *
 * @param currentPackage instance of `MSAssetsLocalPackage` with package information.
 * @return new update report.
 */
- (MSAssetsDeploymentStatusReport *)buildUpdateReportWithPackage:(MSAssetsLocalPackage * _Nonnull)currentPackage;

/**
 * Builds rollback report using current local package information.
 *
 * @param failedPackage instance of `MSAssetsPackage` with package information.
 * @return new rollback report.
 */
- (MSAssetsDeploymentStatusReport *)buildRollbackReportWithFailedPackage:(MSAssetsPackage * _Nonnull)failedPackage;

/**
 * Saves already sent status report.
 *
 * @param report report to save.
 */
- (void)saveReportedStatus:(MSAssetsDeploymentStatusReport *)report;

@end
