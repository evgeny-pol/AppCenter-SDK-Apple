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

#pragma mark - Private constants

static NSString *const DiffManifestFileName = @"hotcodepush.json";
static NSString *const DownloadFileName = @"download.zip";
static NSString *const RelativeBundlePathKey = @"bundlePath";
static NSString *const StatusFile = @"codepush.json";
static NSString *const UpdateBundleFileName = @"app.jsbundle";
static NSString *const UpdateMetadataFileName = @"app.json";
static NSString *const UnzippedFolderName = @"unzipped";

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

#pragma mark - Private API methods

+ (NSString *)getMSAssetsPath
{
    NSString* assetsPath = [[MSAssetsDeploymentInstance getApplicationSupportDirectory] stringByAppendingPathComponent:@"Assets"];
    if ([MSAssetsDeploymentInstance isUsingTestConfiguration]) {
        assetsPath = [assetsPath stringByAppendingPathComponent:@"TestPackages"];
    }

    return assetsPath;
}

#pragma mark - Public API methods

+ (MSAssetsPackage *)getCurrentPackage:(NSError * __autoreleasing *)error
{
    NSString *packageHash = [MSAssetsPackage getCurrentPackageHash:error];
    if (!packageHash) {
        return nil;
    }

    return [MSAssetsPackage getPackage:packageHash error:error];
}

+ (NSString *)getCurrentPackageHash:(NSError * __autoreleasing *)error
{
    MSAssetsPackageInfo *info = [self getCurrentPackageInfo:error];
    if (!info) {
        return nil;
    }

    return info.currentPackage;
}

+ (MSAssetsPackageInfo *)getCurrentPackageInfo:(NSError * __autoreleasing *)error
{
    NSString *statusFilePath = [self getStatusFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:statusFilePath]) {
        return [[MSAssetsPackageInfo alloc] init];
    }

    NSString *content = [NSString stringWithContentsOfFile:statusFilePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:error];
    if (!content) {
        return nil;
    }

    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:error];
    if (!json) {
        return nil;
    }

    return [[MSAssetsPackageInfo alloc] initWithDictionary:json];
}

+ (MSAssetsPackage *)getPackage:(NSString *)packageHash
                       error:(NSError * __autoreleasing *)error
{
    NSString *updateDirectoryPath = [self getPackageFolderPath:packageHash];
    NSString *updateMetadataFilePath = [updateDirectoryPath stringByAppendingPathComponent:UpdateMetadataFileName];

    if (![[NSFileManager defaultManager] fileExistsAtPath:updateMetadataFilePath]) {
        return nil;
    }

    NSString *updateMetadataString = [NSString stringWithContentsOfFile:updateMetadataFilePath
                                                               encoding:NSUTF8StringEncoding
                                                                  error:error];
    if (!updateMetadataString) {
        return nil;
    }

    NSData *updateMetadata = [updateMetadataString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:updateMetadata
                                                         options:kNilOptions
                                                           error:error];

    if (!json) {
        return nil;
    }

    return [[MSAssetsPackage alloc] initWithDictionary:json];
}

+ (NSString *)getPackageFolderPath:(NSString *)packageHash
{
    return [[self getMSAssetsPath] stringByAppendingPathComponent:packageHash];
}

+ (NSString *)getStatusFilePath
{
    return [[self getMSAssetsPath] stringByAppendingPathComponent:StatusFile];
}

@end
