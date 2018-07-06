#import <Foundation/Foundation.h>
#import "MSAssetsiOSSpecificImplementation.h"

@implementation MSAssetsiOSSpecificImplementation

- (void) handleInstallModesForUpdateInstall:(MSAssetsInstallMode __unused)installMode {
    
}

- (void) loadApp:(MSAssetsRestartListener)assetsRestartListener {
    if (assetsRestartListener != nil) {
        assetsRestartListener();
    }
}

- (void) clearDebugCacheWithError:(NSError *__autoreleasing __unused*)error {
    
}

- (BOOL) isPackageLatest:(MSAssetsLocalPackage *)packageMetadata
              appVersion:(NSString *)appVersion {
    NSTimeInterval binaryModifiedDateDuringPackageInstall = 0.0;
    NSString *binaryModifiedDateDuringPackageInstallString = [packageMetadata binaryModifiedTime];
    if (binaryModifiedDateDuringPackageInstallString != nil) {
        binaryModifiedDateDuringPackageInstall = [binaryModifiedDateDuringPackageInstallString doubleValue];
    }
    NSString *packageAppVersion = [packageMetadata appVersion];
    NSTimeInterval binaryResourcesModifiedTime = [self getBinaryResourcesModifiedTime];
    return binaryModifiedDateDuringPackageInstall == binaryResourcesModifiedTime
    && [appVersion isEqualToString:packageAppVersion];
}

- (NSTimeInterval) getBinaryResourcesModifiedTime {
    NSURL *binaryBundleURL = [[NSBundle mainBundle] bundleURL];
    if (binaryBundleURL != nil) {
        NSString *filePath = [binaryBundleURL path];
        if (filePath != nil) {
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            NSDate *modifiedDate = [fileAttributes objectForKey:NSFileModificationDate];
            return [modifiedDate timeIntervalSince1970];
        }
    }
    return 0;
}

@end
