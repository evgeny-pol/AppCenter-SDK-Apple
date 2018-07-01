#import "MSAssetsUpdateManager.h"
#import "MSAssetsAcquisitionManager.h"
#import "MSAssetsSettingManager.h"

@interface MSAssetsManagers : NSObject

@property (nonatomic, copy, readonly) MSAssetsUpdateManager *updateManager;

@property (nonatomic, copy, readonly) MSAssetsAcquisitionManager *acquisitionManager;

//@property (nonatomic, copy, readonly) MSAssetsSettingManager *settingManager;

@end
