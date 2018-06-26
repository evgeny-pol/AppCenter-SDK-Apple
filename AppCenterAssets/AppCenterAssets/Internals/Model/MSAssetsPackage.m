#import <Foundation/Foundation.h>
#import "MSAssetsPackage.h"
#import "MSAssetsIllegalArgumentException.h"
#import "MSAssetsPackageInfo.h"
#import "MSAssets.h"

static NSString *const kMSAppVersion = @"appVersion";
static NSString *const kMSDeploymentKey = @"deploymentKey";
static NSString *const kMSDescription = @"description";
static NSString *const kMSFailedInstall = @"failedInstall";
static NSString *const kMSIsMandatory = @"isMandatory";
static NSString *const kMSLabel = @"label";
static NSString *const kMSPackageHash = @"packageHash";

@implementation MSAssetsPackage

#pragma mark - Public methods

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary) {
        return nil;
    }
    if ((self = [super init])) {
        if (dictionary[kMSAppVersion]) {
            self.appVersion = dictionary[kMSAppVersion];
        }
        if (dictionary[kMSDeploymentKey]) {
            self.deploymentKey = dictionary[kMSDeploymentKey];
        }
        if (dictionary[kMSDescription]) {
            self.updateDescription = dictionary[kMSDescription];
        }
        if (dictionary[kMSFailedInstall]) {
            self.failedInstall = [dictionary[kMSFailedInstall] isEqual:@YES] ? YES : NO;
        }
        if (dictionary[kMSIsMandatory]) {
            self.isMandatory = [dictionary[kMSIsMandatory] isEqual:@YES] ? YES : NO;
        }
        if (dictionary[kMSLabel]) {
            self.label = dictionary[kMSLabel];
        }
        if (dictionary[kMSPackageHash]) {
            self.packageHash = dictionary[kMSPackageHash];
        }
    }
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
    if (self.updateDescription) {
        dict[kMSDescription] = self.updateDescription;
    }
    dict[kMSFailedInstall] = @(self.failedInstall);
    dict[kMSIsMandatory] = @(self.isMandatory);
    
    if (self.label) {
        dict[kMSLabel] = self.label;
    }
    if (self.packageHash) {
        dict[kMSPackageHash] = self.packageHash;
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _appVersion = [coder decodeObjectForKey:kMSAppVersion];
        _deploymentKey = [coder decodeObjectForKey:kMSDeploymentKey];
        _failedInstall = [coder decodeBoolForKey:kMSFailedInstall];
        _isMandatory = [coder decodeBoolForKey:kMSIsMandatory];
        _label = [coder decodeObjectForKey:kMSLabel];
        _packageHash = [coder decodeObjectForKey:kMSPackageHash];
        _updateDescription = [coder decodeObjectForKey:kMSDescription];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.appVersion forKey:kMSAppVersion];
    [coder encodeObject:self.deploymentKey forKey:kMSDeploymentKey];
    [coder encodeBool:self.failedInstall forKey:kMSFailedInstall];
    [coder encodeBool:self.isMandatory forKey:kMSIsMandatory];
    [coder encodeObject:self.label forKey:kMSLabel];
    [coder encodeObject:self.packageHash forKey:kMSPackageHash];
    [coder encodeObject:self.updateDescription forKey:kMSDescription];
}

@end
