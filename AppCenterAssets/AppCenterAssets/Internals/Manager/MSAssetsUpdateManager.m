#import "MSAssetsUpdateManager.h"
#import "MSAssetsPackageInfo.h"
#import "MSUtility+File.h"
#import "MSAssetsErrorUtils.h"
#import "MSAssetsFileUtils.h"

@implementation MSAssetsUpdateManager 

static NSString *const DiffManifestFileName = @"hotcodepush.json";
static NSString *const DownloadFileName = @"download.zip";
static NSString *const RelativeBundlePathKey = @"bundlePath";
static NSString *const StatusFile = @"codepush.json";
static NSString *const UpdateBundleFileName = @"app.jsbundle";
static NSString *const UpdateMetadataFileName = @"app.json";
static NSString *const UnzippedFolderName = @"unzipped";

@synthesize updateUtilities = _updateUtilities;
@synthesize fileUtils = _fileUtils;

- (instancetype)initWithUpdateUtils:(MSAssetsUpdateUtilities *)updateUtilities
                       andFileUtils:(MSAssetsFileUtils *)fileUtils {
    if ((self = [super init])) {
        _updateUtilities = updateUtilities;
        _fileUtils = fileUtils;
    }
    return self;
}

- (MSLocalPackage *)getCurrentPackage:(NSError * __autoreleasing *)error {
    NSString *packageHash = [self getCurrentPackageHash:error];
    if (!packageHash) {
        return nil;
    }

    return [self getPackage:packageHash error:error];
}

- (NSString *)getCurrentPackageHash:(NSError * __autoreleasing *)error {
    MSAssetsPackageInfo *info = [self getCurrentPackageInfo:error];
    if (!info) {
        return nil;
    }

    return info.currentPackage;
}

- (MSAssetsPackageInfo *)getCurrentPackageInfo:(NSError * __autoreleasing *)error {
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
                          error:(NSError * __autoreleasing *)error {
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

- (NSString *)getPackageFolderPath:(NSString *)packageHash {
    return [[self getMSAssetsPath] stringByAppendingPathComponent:packageHash];
}

- (MSLocalPackage *)getPreviousPackage:(NSError * __autoreleasing *)error {
    NSString *packageHash = [self getPreviousPackageHash:error];
    if (!packageHash) {
        return nil;
    }

    return [self getPackage:packageHash error:error];
}

- (NSString *)getPreviousPackageHash:(NSError * __autoreleasing *)error {
    MSAssetsPackageInfo *info = [self getCurrentPackageInfo:error];
    if (!info) {
        return nil;
    }

    return info.previousPackage;
}

- (NSString *)getStatusFilePath {
    return [[self getMSAssetsPath] stringByAppendingPathComponent:StatusFile];
}

- (NSString *)getMSAssetsPath {
    NSString* assetsPath = [[self  getApplicationSupportDirectory] stringByAppendingPathComponent:@"Assets"];
    /*if ([MSAssetsDeploymentInstance isUsingTestConfiguration]) {
        assetsPath = [assetsPath stringByAppendingPathComponent:@"TestPackages"];
    }*/

    return assetsPath;
}

- (NSString *)getApplicationSupportDirectory {
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return applicationSupportDirectory;
}

- (NSString *)getDownloadFilePath {
    return [[self getMSAssetsPath] stringByAppendingPathComponent:DownloadFileName];
}

- (NSString *)getUnzippedFolderPath {
    return [[self getMSAssetsPath] stringByAppendingPathComponent:UnzippedFolderName];
}

- (void)unzipPackage:(NSString *)filePath
               error:(NSError * __autoreleasing *)error {
    NSString *unzippedFolderPath = [self getUnzippedFolderPath];
    [[self fileUtils] unzipFile:filePath unzippedFolderPath:unzippedFolderPath error:error];
    if (!*error) {
        BOOL result = [MSUtility deleteItemForPathComponent:filePath];
        if (!result) {
            *error = [MSAssetsErrorUtils getFileDeleteError:filePath];
        }
    }
}

- (NSString *)mergeDiffWithNewUpdateFolder:(NSString *)newUpdateFolderPath
                     newUpdateMetadataPath:(NSString *)newUpdateMetadataPath
                             newUpdateHash:(NSString *)newUpdateHash
                           publicKeyString:(NSString *)publicKeyString
                expectedEntryPointFileName:(NSString *)expectedEntryPointFileName
                                     error:(NSError * __autoreleasing *)error {
    
}

- (void)verifySignatureForPath:(NSString *)newUpdateFolderPath
                 withPublicKey:(NSString *)publicKey
                 newUpdateHash:(NSString *)newUpdateHash
                    diffUpdate:(BOOL)isDiffUpdate
                         error:(NSError * __autoreleasing *)error {
    
}

@end
