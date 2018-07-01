#import "MSAssetsManagers.h"

@implementation MSAssetsManagers

@synthesize updateManager = _updateManager;
@synthesize acquisitionManager = _acquisitionManager;
//@synthesize settingManager = _settingManager;

- (instancetype)init {
    if ((self = [super init])) {
        _updateManager = [[MSAssetsUpdateManager alloc] init];
        _acquisitionManager = [[MSAssetsAcquisitionManager alloc] init];
//        _settingManager = [[MSAssetsSettingManager alloc] init];
    }
    return self;
}


@end
