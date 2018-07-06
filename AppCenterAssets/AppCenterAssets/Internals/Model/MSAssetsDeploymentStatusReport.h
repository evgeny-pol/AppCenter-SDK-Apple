#import <Foundation/Foundation.h>
#import "MSAssetsPackage.h"
#import "MSAssetsDeploymentStatus.h"
#import "MSSerializableObject.h"
#import "MSAssetsDownloadStatusReport.h"

/**
 * Represents a report about the deployment.
 */
@interface MSAssetsDeploymentStatusReport : MSAssetsDownloadStatusReport

/**
 * The version of the app that was deployed (for a native app upgrade).
 */
@property(nonatomic, copy, nonnull) NSString *appVersion;

/**
 * Deployment key used when deploying the previous package.
 */
@property(nonatomic, copy, nonnull) NSString *previousDeploymentKey;

/**
 * The label (v#) of the package that was upgraded from.
 */
@property(nonatomic, copy, null_unspecified) NSString *previousLabelOrAppVersion;

/**
 * Whether the deployment succeeded or failed.
 */
@property(nonatomic) MSAssetsDeploymentStatus status;

/**
 * Stores information about installed/failed package.
 */
@property(nonatomic, nullable) MSAssetsPackage *assetsPackage;

- (null_unspecified instancetype)initWithDictionary:(null_unspecified NSDictionary *)dictionary;

@end
