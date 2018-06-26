#import <Foundation/Foundation.h>
#import "MSAssetsUpdateResponseUpdateInfo.h"

static NSString *const kMSDownloadUrl = @"downloadUrl";
static NSString *const kMSDescription = @"description";
static NSString *const kMSIsAvailable = @"isAvailable";
static NSString *const kMSisMandatory = @"isMandatory";
static NSString *const kMSAppVersion = @"appVersion";
static NSString *const kMSLabel = @"label";
static NSString *const kMSPackageHash = @"packageHash";
static NSString *const kMSPackageSize = @"packageSize";
static NSString *const kMSUpdateAppVersion = @"updateAppVersion";

@implementation MSUpdateResponseUpdateInfo

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary) {
        return nil;
    }
    if ((self = [super init])) {
        if (dictionary[kMSDownloadUrl]) {
            self.downloadUrl = dictionary[kMSDownloadUrl];
        }
        if (dictionary[kMSDescription]) {
            self.updateDescription = dictionary[kMSDescription];
        }
        if (dictionary[kMSIsAvailable]) {
            self.isAvailable = [dictionary[kMSIsAvailable] isEqual:@YES] ? YES : NO;
        }
        if (dictionary[kMSisMandatory]) {
            self.isMandatory = [dictionary[kMSisMandatory] isEqual:@YES] ? YES : NO;
        }
        if (dictionary[kMSUpdateAppVersion]) {
            self.updateAppVersion = [dictionary[kMSUpdateAppVersion] isEqual:@YES] ? YES : NO;
        }
        if (dictionary[kMSLabel]) {
            self.label = dictionary[kMSLabel];
        }
        if (dictionary[kMSPackageHash]) {
            self.packageHash = dictionary[kMSPackageHash];
        }
        if (dictionary[kMSAppVersion]) {
            self.appVersion = dictionary[kMSAppVersion];
        }
        if (dictionary[kMSPackageSize]) {
            self.packageSize = [dictionary[kMSPackageSize] longLongValue];
        }
    }
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (self.appVersion) {
        dict[kMSAppVersion] = self.appVersion;
    }
    if (self.downloadUrl) {
        dict[kMSDownloadUrl] = self.downloadUrl;
    }
    if (self.updateDescription) {
        dict[kMSDescription] = self.updateDescription;
    }
    dict[kMSIsAvailable] = @(self.isAvailable);
    dict[kMSisMandatory] = @(self.isMandatory);
    
    if (self.label) {
        dict[kMSLabel] = self.label;
    }
    if (self.packageHash) {
        dict[kMSPackageHash] = self.packageHash;
    }
    dict[kMSUpdateAppVersion] = @(self.updateAppVersion);
    dict[kMSPackageSize] = [NSNumber numberWithLongLong:self.packageSize];
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _appVersion = [coder decodeObjectForKey:kMSAppVersion];
        _downloadUrl = [coder decodeObjectForKey:kMSDownloadUrl];
        _isAvailable = [coder decodeBoolForKey:kMSIsAvailable];
        _isMandatory = [coder decodeBoolForKey:kMSisMandatory];
        _updateAppVersion = [coder decodeBoolForKey:kMSUpdateAppVersion];
        _packageSize = [coder decodeInt64ForKey:kMSPackageSize];
        _label = [coder decodeObjectForKey:kMSLabel];
        _packageHash = [coder decodeObjectForKey:kMSPackageHash];
        _updateDescription = [coder decodeObjectForKey:kMSDescription];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.appVersion forKey:kMSAppVersion];
    [coder encodeObject:self.downloadUrl forKey:kMSDownloadUrl];
    [coder encodeBool:self.isAvailable forKey:kMSIsAvailable];
    [coder encodeBool:self.isMandatory forKey:kMSisMandatory];
    [coder encodeBool:self.updateAppVersion forKey:kMSUpdateAppVersion];
    [coder encodeInt64:self.packageSize forKey:kMSPackageSize];
    [coder encodeObject:self.label forKey:kMSLabel];
    [coder encodeObject:self.packageHash forKey:kMSPackageHash];
    [coder encodeObject:self.updateDescription forKey:kMSDescription];
}

@end
