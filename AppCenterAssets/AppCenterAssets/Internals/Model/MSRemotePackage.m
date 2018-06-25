#import <Foundation/Foundation.h>
#import "MSRemotePackage.h"
#import "MSAssetsUpdateResponseUpdateInfo.h"

static NSString *const kMSDownloadUrl = @"downloadUrl";
static NSString *const kMSPackageSize = @"packageSize";
static NSString *const kMSUpdateAppVersion = @"updateAppVersion";

@implementation MSRemotePackage

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [super serializeToDictionary];
    
    if (self.downloadUrl) {
        dict[kMSDownloadUrl] = self.downloadUrl;
    }
    dict[kMSPackageSize] = [NSNumber numberWithLongLong:self.packageSize];
    dict[kMSUpdateAppVersion] = self.updateAppVersion ? @"YES" : @"NO";
    
    return dict;
}

+ (MSRemotePackage *)createRemotePackage:(BOOL)failedInstall
                             packageSize:(long)packageSize
                             downloadUrl:(NSString *)downloadUrl
                        updateAppVersion:(BOOL)updateAppVersion
                           assetsPackage:(MSAssetsPackage *)assetsPackage {
    MSRemotePackage *remotePackage = [[MSRemotePackage alloc] init];
    [remotePackage setAppVersion:[assetsPackage appVersion]];
    [remotePackage setDeploymentKey:[assetsPackage deploymentKey]];
    [remotePackage setUpdateDescription:[assetsPackage updateDescription]];
    [remotePackage setIsMandatory:[assetsPackage isMandatory]];
    [remotePackage setLabel:[assetsPackage label]];
    [remotePackage setPackageHash:[assetsPackage packageHash]];
    [remotePackage setFailedInstall:failedInstall];
    [remotePackage setDownloadUrl: downloadUrl];
    [remotePackage setUpdateAppVersion: updateAppVersion];
    [remotePackage setPackageSize: packageSize];
    return remotePackage;
}


+ (MSRemotePackage *)createRemotePackageFromUpdateInfo:(NSString *)deploymentKey
                                            updateInfo:(MSUpdateResponseUpdateInfo *)updateInfo {
    MSRemotePackage *remotePackage = [[MSRemotePackage alloc] init];
    [remotePackage setAppVersion:[updateInfo appVersion]];
    [remotePackage setDeploymentKey:deploymentKey];
    [remotePackage setUpdateDescription:[updateInfo updateDescription]];
    [remotePackage setIsMandatory:[updateInfo isMandatory]];
    [remotePackage setLabel:[updateInfo label]];
    [remotePackage setPackageHash:[updateInfo packageHash]];
    [remotePackage setFailedInstall:NO];
    [remotePackage setDownloadUrl: [updateInfo downloadUrl]];
    [remotePackage setUpdateAppVersion: [updateInfo updateAppVersion]];
    [remotePackage setPackageSize: [updateInfo packageSize]];
    return remotePackage;
}

+ (MSRemotePackage *)createDefaultRemotePackage:(NSString *)appVersion
                               updateAppVersion:(BOOL)updateAppVersion {
    MSRemotePackage *remotePackage = [[MSRemotePackage alloc] init];
    [remotePackage setAppVersion:appVersion];
    [remotePackage setUpdateAppVersion:updateAppVersion];
    return remotePackage;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _downloadUrl = [coder decodeObjectForKey:kMSDownloadUrl];
        _packageSize = [coder decodeInt64ForKey:kMSPackageSize];
        _updateAppVersion = [coder decodeBoolForKey:kMSUpdateAppVersion];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.downloadUrl forKey:kMSDownloadUrl];
    [coder encodeInt64: self.packageSize forKey: kMSPackageSize];
    [coder encodeBool:self.updateAppVersion forKey:kMSUpdateAppVersion];
}

@end
