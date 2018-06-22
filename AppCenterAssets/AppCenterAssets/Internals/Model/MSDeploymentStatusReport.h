#import <Foundation/Foundation.h>

@interface MSDeploymentStatusReports

/**
 * The version of the app that was deployed (for a native app upgrade).
 */
@property(nonatomic, copy) NSString *appVersion;

/**
 * Deployment key used when deploying the previous package.
 */
@property(nonatomic, copy) NSString *previousDeploymentKey;

/**
 * The label (v#) of the package that was upgraded from.
 */
@property(nonatomic, copy) NSString *previousLabelOrAppVersion;

/**
 * Whether the deployment succeeded or failed.
 */
@property(nonatomic, copy) MSDeploymentStatus *status;

/**
 * Stores information about installed/failed package.
 */
@property(nonatomic, copy) MSAssetsPackage *assetsPackage;

@end
