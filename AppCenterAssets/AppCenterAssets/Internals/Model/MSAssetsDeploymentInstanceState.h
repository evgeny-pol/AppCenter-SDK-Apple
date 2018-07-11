#import <Foundation/Foundation.h>
#import "MSAssetsInstallMode.h"

@interface MSAssetsDeploymentInstanceState : NSObject

/**
 * Indicates whether a new update running for the first time.
 */
@property(nonatomic) BOOL didUpdate;

/**
 * Indicates whether there is a need to send rollback report.
 */
@property(nonatomic) BOOL needToReportRollback;

/**
 * Indicates whether is running binary version of app.
 */
@property(nonatomic) BOOL isRunningBinaryVersion;

/**
 * Indicates whether sync already in progress.
 */
@property(nonatomic) BOOL syncInProgress;

/**
 * Minimum background duration value.
 */
@property(nonatomic) int minimumBackgroundDuration;

/**
 * Indicates current install mode.
 */
@property(nonatomic) MSAssetsInstallMode currentInstallMode;

@end
