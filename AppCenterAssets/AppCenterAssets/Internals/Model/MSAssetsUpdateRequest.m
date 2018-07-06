#import <Foundation/Foundation.h>
#import "MSAssetsUpdateRequest.h"
#import "MSLocalPackage.h"
#import "MSAssetsIllegalArgumentException.h"

static NSString *const kMSAppVersion = @"appVersion";
static NSString *const kMSDeploymentKey = @"deploymentKey";
static NSString *const kMSClientUniqueId = @"clientUniqueId";
static NSString *const kMSIsCompanion = @"isCompanion";
static NSString *const kMSLabel = @"label";
static NSString *const kMSPackageHash = @"packageHash";

@implementation MSAssetsUpdateRequest

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (self.appVersion) {
        dict[kMSAppVersion] = self.appVersion;
    }
    if (self.deploymentKey) {
        dict[kMSDeploymentKey] = self.deploymentKey;
    }
    if (self.clientUniqueId) {
        dict[kMSClientUniqueId] = self.clientUniqueId;
    }
    dict[kMSIsCompanion] = @(self.isCompanion);
    
    if (self.label) {
        dict[kMSLabel] = self.label;
    }
    if (self.packageHash) {
        dict[kMSPackageHash] = self.packageHash;
    }
    return dict;
}

+ (MSAssetsUpdateRequest *)createUpdateRequestWithDeploymentKey:(NSString *)deploymentKey
                                 assetsPackage:(MSLocalPackage *)assetsPackage
                                andDeviceId:(NSString *)clientUniqueId {
    MSAssetsUpdateRequest *request = [[MSAssetsUpdateRequest alloc] init];
    if (deploymentKey != nil) {
        [request setDeploymentKey:deploymentKey];
    } else {
        @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSAssetsUpdateRequest.class) argument:kMSDeploymentKey];
    }
    if ([assetsPackage appVersion] != nil) {
        [request setAppVersion:[assetsPackage appVersion]];
    } else {
        @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSAssetsUpdateRequest.class) argument:kMSAppVersion];
    }
    [request setClientUniqueId:clientUniqueId];
    [request setPackageHash:[assetsPackage packageHash]];
    [request setLabel: [assetsPackage label]];
    return request;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        NSString *appVersion = [coder decodeObjectForKey:kMSAppVersion];
        if (appVersion != nil) {
            _appVersion = appVersion;
        } else {
            @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSAssetsUpdateRequest.class) argument:kMSAppVersion];
        }
        NSString *deploymentKey = [coder decodeObjectForKey:kMSDeploymentKey];
        if (deploymentKey != nil) {
            _deploymentKey = deploymentKey;
        } else {
            @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSAssetsUpdateRequest.class) argument:kMSDeploymentKey];
        }
        _isCompanion = [coder decodeBoolForKey:kMSIsCompanion];
        _label = [coder decodeObjectForKey:kMSLabel];
        _packageHash = [coder decodeObjectForKey:kMSPackageHash];
        _clientUniqueId = [coder decodeObjectForKey:kMSClientUniqueId];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.appVersion forKey:kMSAppVersion];
    [coder encodeObject:self.deploymentKey forKey:kMSDeploymentKey];
    [coder encodeBool:self.isCompanion forKey:kMSIsCompanion];
    [coder encodeObject:self.label forKey:kMSLabel];
    [coder encodeObject:self.packageHash forKey:kMSPackageHash];
    [coder encodeObject:self.clientUniqueId forKey:kMSClientUniqueId];
}

@end
