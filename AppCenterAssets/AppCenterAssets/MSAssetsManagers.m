#import "MSAssetsManagers.h"

@implementation MSAssetsManagers

@synthesize updateManager = _updateManager;
@synthesize acquisitionManager = _acquisitionManager;

- (instancetype)init {
    if ((self = [super init])) {
        _updateManager = [[MSAssetsUpdateManager alloc] init];
        _acquisitionManager = [[MSAssetsAcquisitionManager alloc] init];
    }
    return self;
}

@end
