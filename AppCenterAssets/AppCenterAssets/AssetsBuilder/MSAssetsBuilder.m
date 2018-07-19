#import "MSAssetsBuilder.h"

@implementation MSAssetsBuilder

- (instancetype)init {
    if ((self = [super init])) {
        _deploymentKey = nil;
        _serverUrl = nil;
        _updateSubFolder = nil;
        _publicKey = nil;
        _baseDir = nil;
        _appName = nil;
        _appVersion = nil;
    }
    return self;
}

@end
