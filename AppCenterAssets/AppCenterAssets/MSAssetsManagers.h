#import "MSAssetsUpdateManager.h"
#import "MSAssetsAcquisitionManager.h"
#import "MSAssetsSettingManager.h"

@interface MSAssetsManagers : NSObject

@property (nonatomic, copy, readonly) MSAssetsUpdateManager *updateManager;

@property (nonatomic, copy, readonly) MSAssetsAcquisitionManager *acquisitionManager;

@end
