#import "MSAssetsUpdateManager.h"
#import "MSAssetsPackageInfo.h"


@implementation MSAssetsUpdateManager

static NSString *const DiffManifestFileName = @"hotcodepush.json";
static NSString *const DownloadFileName = @"download.zip";
static NSString *const RelativeBundlePathKey = @"bundlePath";
static NSString *const StatusFile = @"codepush.json";
static NSString *const UpdateBundleFileName = @"app.jsbundle";
static NSString *const UpdateMetadataFileName = @"app.json";
static NSString *const UnzippedFolderName = @"unzipped";

- (MSLocalPackage *)getCurrentPackage:(NSError * __autoreleasing *)error
{
    NSString *packageHash = [self getCurrentPackageHash:error];
    if (!packageHash) {
        return nil;
    }

    return [self getPackage:packageHash error:error];
}

- (NSString *)getCurrentPackageHash:(NSError * __autoreleasing *)error
{
    MSAssetsPackageInfo *info = [self getCurrentPackageInfo:error];
    if (!info) {
        return nil;
    }

    return info.currentPackage;
}

- (MSAssetsPackageInfo *)getCurrentPackageInfo:(NSError * __autoreleasing *)error
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

- (MSLocalPackage *)getPackage:(NSString *)packageHash
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

    return [[MSLocalPackage alloc] initWithDictionary:json];
}

- (NSString *)getPackageFolderPath:(NSString *)packageHash
{
    return [[self getMSAssetsPath] stringByAppendingPathComponent:packageHash];
}

- (NSString *)getStatusFilePath
{
    return [[self getMSAssetsPath] stringByAppendingPathComponent:StatusFile];
}

- (NSString *)getMSAssetsPath
{
    NSString* assetsPath = [[self  getApplicationSupportDirectory] stringByAppendingPathComponent:@"Assets"];
    /*if ([MSAssetsDeploymentInstance isUsingTestConfiguration]) {
        assetsPath = [assetsPath stringByAppendingPathComponent:@"TestPackages"];
    }*/

    return assetsPath;
}

- (NSString *)getApplicationSupportDirectory
{
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return applicationSupportDirectory;
}

@end
