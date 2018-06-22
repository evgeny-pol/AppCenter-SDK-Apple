#import <Foundation/Foundation.h>
#import "MSAssetsPackage.h"
#import "MSAssetsDeploymentStatus.h"
#import "MSSerializableObject.h"

@interface MSDeploymentStatusReport : NSObject <MSSerializableObject>

/**
 * The version of the app that was deployed (for a native app upgrade).
 */
@property(nonatomic, copy) NSString * _Nonnull appVersion;

/**
 * Deployment key used when deploying the previous package.
 */
@property(nonatomic, copy) NSString * _Nonnull previousDeploymentKey;

/**
 * The label (v#) of the package that was upgraded from.
 */
@property(nonatomic, copy) NSString *previousLabelOrAppVersion;

/**
 * Whether the deployment succeeded or failed.
 */
@property(nonatomic) MSAssetsDeploymentStatus status;

/**
 * Stores information about installed/failed package.
 */
@property(nonatomic, copy) MSAssetsPackage *assetsPackage;



@end
