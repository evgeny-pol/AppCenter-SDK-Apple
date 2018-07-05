#import <Foundation/Foundation.h>
#import "MSAssetsSettingManager.h"
#import "MSAssetsPackage.h"
#import "MSAssetsPendingUpdate.h"
#import "MSUtility.h"

/**
 * Keys for storing information in `NSUserDefaults`.
 */
static NSString *const kMSFailedUpdates = @"MSAssetsFailedUpdates";
static NSString *const kMSPendingUpdate = @"MSAssetsPendingUpdate";
static NSString *const kMSReportIdentifier = @"MSAssetsReportIdentifier";
static NSString *const kMSBinaryHash = @"MSAssetsBinaryHash";

@implementation MSAssetsSettingManager

- (NSMutableArray<MSAssetsPackage *> *)getFailedUpdates {
    NSMutableArray<MSAssetsPackage *> *failedPackages;
    NSData *data = [MS_USER_DEFAULTS objectForKey:kMSFailedUpdates];
    if (data != nil) {
        failedPackages = (NSMutableArray *)[[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    }
    if (!failedPackages) {
        failedPackages = [NSMutableArray<MSAssetsPackage *> new];
    }
    return failedPackages;
}

- (MSAssetsPendingUpdate *)getPendingUpdate {
    NSData *data = [MS_USER_DEFAULTS objectForKey:kMSPendingUpdate];
    if (data != nil) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (BOOL)existsFailedUpdate:(NSString *_Nonnull) packageHash {
    NSMutableArray<MSAssetsPackage *> *failedPackages = [self getFailedUpdates];
    for(MSAssetsPackage *assetsPackage in failedPackages) {
        if ([[assetsPackage packageHash] isEqualToString:packageHash]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isPendingUpdate:(NSString *)packageHash {
    MSAssetsPendingUpdate *pendingUpdate = [self getPendingUpdate];
    return pendingUpdate != nil && ![pendingUpdate isLoading] &&
    (packageHash == nil || [[pendingUpdate pendingUpdateHash] isEqualToString:packageHash]);
}

- (void)removeFailedUpdates {
    [MS_USER_DEFAULTS removeObjectForKey:kMSFailedUpdates];
}

- (void)removePendingUpdate {
    [MS_USER_DEFAULTS removeObjectForKey:kMSPendingUpdate];
}

- (void)saveFailedUpdate:(MSAssetsPackage *_Nonnull)failedPackage {
    NSMutableArray<MSAssetsPackage *> *failedPackages = [self getFailedUpdates];
    [failedPackages addObject:failedPackage];
    [MS_USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:failedPackages]
                         forKey:kMSFailedUpdates];
}

- (void)savePendingUpdate:(MSAssetsPendingUpdate *_Nonnull)pendingUpdate {
    [MS_USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:pendingUpdate] forKey:kMSPendingUpdate];
}

- (void)saveIdentifierOfReportedStatus:(MSAssetsStatusReportIdentifier *)identifier {
    [MS_USER_DEFAULTS setObject:[identifier toString] forKey:kMSReportIdentifier];
}

- (MSAssetsStatusReportIdentifier *)getPreviousStatusReportIdentifier {
    NSString *identifier = [MS_USER_DEFAULTS objectForKey:kMSReportIdentifier];
    if (identifier != nil) {
        return [MSAssetsStatusReportIdentifier reportIdentifierFromString:identifier];
    }
    return nil;
}

- (void)saveBinaryHash:(NSMutableDictionary *)binaryHash {
    [MS_USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:binaryHash]
                         forKey:kMSBinaryHash];
}

- (NSMutableDictionary *)getBinaryHash {
    NSMutableDictionary *binaryHashes;
    NSData *data = [MS_USER_DEFAULTS objectForKey:kMSBinaryHash];
    if (data != nil) {
        binaryHashes = (NSMutableDictionary *)[[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    }
    if (!binaryHashes) {
        binaryHashes = [NSMutableDictionary new];
    }
    return binaryHashes;
}

- (void)removeBinaryHash {
    [MS_USER_DEFAULTS removeObjectForKey:kMSBinaryHash];
}
@end
