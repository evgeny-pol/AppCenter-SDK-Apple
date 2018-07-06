#import <Foundation/Foundation.h>
#import "MSAssetsConstants.h"

// These constants represent valid deployment statuses
NSString *const kMSDeploymentFailed = @"DeploymentFailed";
NSString *const kMSDeploymentSucceeded = @"DeploymentSucceeded";

NSString *const kMSCodePushSyncStatusChangedNotification = @"CodePushSyncStatusChangedNotification";

// These keys are used to inspect the metadata
// that is associated with the package.
NSString *const kMSAppVersionKey = @"appVersion";
NSString *const kMSPackageHashKey = @"packageHash";
NSString *const kMSLabelKey = @"label";
NSString *const kMSPackageIsPendingKey = @"isPending";
NSString *const kMSFailedInstallKey = @"failedInstall";
NSString *const kMSIsFirstRunKey = @"isFirstRun";
NSString *const kMSIsDebugOnlyKey = @"_isDebugOnly";
NSString *const kMSUpdateInfoKey = @"updateInfo";
NSString *const kMSIsCompanionKey = @"isCompanion";
NSString *const kMSIsAvailableKey = @"isAvailable";
NSString *const kMSUpdateAppVersionKey = @"updateAppVersion";
NSString *const kMSDescriptionKey = @"description";
NSString *const kMSIsMandatoryKey = @"isMandatory";
NSString *const kMSPackageSizeKey = @"packageSize";
NSString *const kMSDownloadUrlKey = @"downloadURL";
NSString *const kMSDownloadUrRemotePackageKey = @"downloadUrl"; //there is a mismatch in this, so service require to send with lower case
NSString *const kMSSyncStatusKey = @"syncStatus";

// This keys for associated CodePush config values
NSString *const kMSAppVersionConfigKey = @"appVersion";
NSString *const kMSBuildVersionConfigKey = @"buildVersion";
NSString *const kMSServerURLConfigKey = @"serverUrl";
NSString *const kMSDeploymentKeyConfigKey = @"deploymentKey";
NSString *const kMSClientUniqueIDConfigKey = @"clientUniqueId";
NSString *const kMSIgonreAppVersionConfigKey = @"_ignoreAppVersion";

NSString *const kMSMinimumBackgroundDurationKey = @"minimumBackgroundDuration";
NSString *const kMSMandatoryInstallModeKey = @"mandatoryInstallMode";
NSString *const kMSIgnoreFailedUpdatesKey = @"ignoreFailedUpdates";
NSString *const kMSInstallModeKey = @"installMode";

NSString *const kMSBinaryBundleDateKey = @"binaryDate";
NSString *const kMSStatusKey = @"status";
NSString *const kMSPreviousDeploymentKey = @"previousDeploymentKey";
NSString *const kMSPreviousLabelOrAppVersionKey = @"previousLabelOrAppVersion";
