#import "MSAssetsManagers.h"

@implementation MSAssetsManagers

- (instancetype)init {
    if ((self = [super init])) {
        _updateManager = [[MSAssetsUpdateManager alloc] init];
        _acquisitionManager = [[MSAssetsAcquisitionManager alloc] init];
    }
    return self;
}


@end
