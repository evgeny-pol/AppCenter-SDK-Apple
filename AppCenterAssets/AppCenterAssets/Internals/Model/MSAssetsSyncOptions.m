#import <Foundation/Foundation.h>
#import "MSAssetsSyncOptions.h"
#import "MSAssetsCheckFrequency.h"
#import "MSAssetsInstallMode.h"
#import "MSAssetsUpdateDialog.h"

static NSString *const kMSDeploymentKey = @"deploymentKey";
static NSString *const kMSInstallMode = @"installMode";
static NSString *const kMSMandatoryInstallMode = @"mandatoryInstallMode";
static NSString *const kMSMinumumBackgroundDuration = @"minimumBackgroundDuration";
static NSString *const kMSIgnoreFailedUpdates = @"ignoreFailedUpdates";
static NSString *const kMSUpdateDialog = @"updateDialog";
static NSString *const kMSCheckFrequency = @"checkFrequency";
static NSString *const kMSShouldRestart = @"shouldRestart";

@implementation MSAssetsSyncOptions

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (self.deploymentKey) {
        dict[kMSDeploymentKey] = self.deploymentKey;
    }
    dict[kMSInstallMode] = [NSNumber numberWithInt:self.installMode];
    dict[kMSMandatoryInstallMode] = [NSNumber numberWithInt:self.mandatoryInstallMode];
    dict[kMSCheckFrequency] = [NSNumber numberWithInt:self.checkFrequency];
    dict[kMSMinumumBackgroundDuration] = [NSNumber numberWithInt:self.minimumBackgroundDuration];
    if (self.updateDialog) {
        dict[kMSUpdateDialog] = [self.updateDialog serializeToDictionary];
    }
    dict[kMSIgnoreFailedUpdates] = @(self.ignoreFailedUpdates);
    dict[kMSShouldRestart] = @(self.shouldRestart);
    return dict;
}

- (instancetype)init:(NSString *)deploymentKey {
    if ((self = [self init])) {
        _deploymentKey = deploymentKey;
        _installMode = MSAssetsInstallModeOnNextRestart;
        _mandatoryInstallMode = MSAssetsInstallModeImmediate;
        _minimumBackgroundDuration = 0;
        _ignoreFailedUpdates = YES;
        _shouldRestart = YES;
        _checkFrequency = MSAssetsCheckFrequencyOnAppStart;
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _installMode = [coder decodeIntForKey:kMSInstallMode];
        _mandatoryInstallMode = [coder decodeIntForKey:kMSMandatoryInstallMode];
        _checkFrequency = [coder decodeIntForKey:kMSCheckFrequency];
        _minimumBackgroundDuration = [coder decodeIntForKey:kMSMinumumBackgroundDuration];
        _deploymentKey = [coder decodeObjectForKey:kMSDeploymentKey];
        _updateDialog = [coder decodeObjectForKey:kMSUpdateDialog];
        _shouldRestart = [coder decodeBoolForKey:kMSShouldRestart];
        _ignoreFailedUpdates = [coder decodeBoolForKey:kMSIgnoreFailedUpdates];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.updateDialog forKey:kMSUpdateDialog];
    [coder encodeObject:self.deploymentKey forKey:kMSDeploymentKey];
    [coder encodeBool:self.shouldRestart forKey:kMSShouldRestart];
    [coder encodeBool:self.ignoreFailedUpdates forKey:kMSIgnoreFailedUpdates];
    [coder encodeInt: self.minimumBackgroundDuration forKey:kMSMinumumBackgroundDuration];
    [coder encodeInt: self.checkFrequency forKey:kMSCheckFrequency];
    [coder encodeInt: self.installMode forKey:kMSInstallMode];
    [coder encodeInt: self.mandatoryInstallMode forKey:kMSMandatoryInstallMode];
}

@end
