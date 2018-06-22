#import <Foundation/Foundation.h>
#import "MSDeploymentStatusReport.h"
#import "MSAssetsPackage.h"
#import "MSAssetsIllegalArgumentException.h"

static NSString *const kMSAppVersion = @"appVersion";
static NSString *const kMSPreviousDeploymentKey = @"previousKey";
static NSString *const kMSPreviousLabelOrAppVersion = @"previousLabel";
static NSString *const kMSStatus = @"status";
static NSString *const kMSAssetsPackage = @"package";

@implementation MSDeploymentStatusReport

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (self.appVersion) {
        dict[kMSAppVersion] = self.appVersion;
    }
    if (self.previousDeploymentKey) {
        dict[kMSPreviousDeploymentKey] = self.previousDeploymentKey;
    }
    if (self.previousLabelOrAppVersion) {
        dict[kMSPreviousLabelOrAppVersion] = self.previousLabelOrAppVersion;
    }
    dict[kMSStatus] = @""; //[self.status ];
    if (self.assetsPackage) {
        dict[kMSAssetsPackage] = @""; // [self.assetsPackage serializeToDictionary];
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self) {
        NSString *appVersion = [coder decodeObjectForKey:kMSAppVersion];
        if (appVersion != nil) {
            _appVersion = appVersion;
        } else {
            @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSDeploymentStatusReport.class) argument:kMSAppVersion];
        }
        NSString *previousKey = [coder decodeObjectForKey:kMSPreviousDeploymentKey];
        if (previousKey != nil) {
            _previousDeploymentKey = previousKey;
        } else {
            @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSDeploymentStatusReport.class) argument:kMSPreviousDeploymentKey];
        }
        _previousLabelOrAppVersion = [coder decodeObjectForKey:kMSPreviousLabelOrAppVersion];
        _status = (MSAssetsDeploymentStatus) [coder decodeIntForKey:kMSStatus];
        _assetsPackage = [coder decodeObjectForKey:kMSAssetsPackage];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.appVersion forKey:kMSAppVersion];
    [coder encodeObject:self.previousDeploymentKey forKey:kMSPreviousDeploymentKey];
    [coder encodeObject:self.previousLabelOrAppVersion forKey:kMSPreviousLabelOrAppVersion];
    [coder encodeObject:[NSNumber numberWithInt: self.status] forKey:kMSStatus]; //status
    [coder encodeObject:self.assetsPackage forKey:kMSAssetsPackage];
}

@end
