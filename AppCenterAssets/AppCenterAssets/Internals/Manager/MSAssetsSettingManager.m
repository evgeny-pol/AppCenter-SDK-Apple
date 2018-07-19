#import <Foundation/Foundation.h>
#import "MSAssetsSettingManager.h"
#import "MSAssetsPackage.h"
#import "MSAssetsPendingUpdate.h"
#import "MSUserDefaults.h"
#import "MSUtility.h"

/**
 * Keys for storing information in `NSUserDefaults`.
 */
static NSString *const kMSFailedUpdates = @"MSAssetsFailedUpdates";
static NSString *const kMSPendingUpdate = @"MSAssetsPendingUpdate";
static NSString *const kMSReportIdentifier = @"MSAssetsReportIdentifier";
static NSString *const kMSBinaryHash = @"MSAssetsBinaryHash";

@implementation MSAssetsSettingManager {
    MSUserDefaults *_storage;
    NSString *_appName;
}

- (instancetype)init {
    self = [self initWithAppName:@"Assets"];
    return self;
}

- (instancetype)initWithAppName:(nonnull NSString *)appName {
    if ((self = [super init])) {
        _appName = appName;
        _storage = MS_USER_DEFAULTS;
    }
    return self;
}

- (NSString *)getAppSpecificKey:(NSString *)key {
    return [_appName stringByAppendingString:key];
}

- (NSMutableArray<MSAssetsPackage *> *)getFailedUpdates {
    NSMutableArray<MSAssetsPackage *> *failedPackages;
    NSData *data = [_storage objectForKey:[self getAppSpecificKey:kMSFailedUpdates]];
    if (data != nil) {
        failedPackages = (NSMutableArray *)[[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    }
    if (!failedPackages) {
        failedPackages = [NSMutableArray<MSAssetsPackage *> new];
    }
    return failedPackages;
}

- (MSAssetsPendingUpdate *)getPendingUpdate {
    NSData *data = [_storage objectForKey:[self getAppSpecificKey:kMSPendingUpdate]];
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
    [_storage removeObjectForKey:[self getAppSpecificKey:kMSFailedUpdates]];
}

- (void)removePendingUpdate {
    [_storage removeObjectForKey:[self getAppSpecificKey:kMSPendingUpdate]];
}

- (void)saveFailedUpdate:(MSAssetsPackage *_Nonnull)failedPackage {
    NSMutableArray<MSAssetsPackage *> *failedPackages = [self getFailedUpdates];
    [failedPackages addObject:failedPackage];
    [_storage setObject:[NSKeyedArchiver archivedDataWithRootObject:failedPackages]
                         forKey:[self getAppSpecificKey:kMSFailedUpdates]];
}

- (void)savePendingUpdate:(MSAssetsPendingUpdate *_Nonnull)pendingUpdate {
    [_storage setObject:[NSKeyedArchiver archivedDataWithRootObject:pendingUpdate] forKey:[self getAppSpecificKey:kMSPendingUpdate]];
}

- (void)saveIdentifierOfReportedStatus:(MSAssetsStatusReportIdentifier *)identifier {
    [_storage setObject:[identifier toString] forKey:[self getAppSpecificKey:kMSReportIdentifier]];
}

- (MSAssetsStatusReportIdentifier *)getPreviousStatusReportIdentifier {
    NSString *identifier = [_storage objectForKey:[self getAppSpecificKey:kMSReportIdentifier]];
    if (identifier != nil) {
        return [MSAssetsStatusReportIdentifier reportIdentifierFromString:identifier];
    }
    return nil;
}

- (void)removePreviousStatusReportIdentifier {
    [_storage removeObjectForKey:[self getAppSpecificKey:kMSReportIdentifier]];
}

- (void)saveBinaryHash:(NSMutableDictionary *)binaryHash {
    [_storage setObject:[NSKeyedArchiver archivedDataWithRootObject:binaryHash]
                         forKey:[self getAppSpecificKey:kMSBinaryHash]];
}

- (NSMutableDictionary *)getBinaryHash {
    NSMutableDictionary *binaryHashes;
    NSData *data = [_storage objectForKey:[self getAppSpecificKey:kMSBinaryHash]];
    if (data != nil) {
        binaryHashes = (NSMutableDictionary *)[[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    }
    if (!binaryHashes) {
        binaryHashes = [NSMutableDictionary new];
    }
    return binaryHashes;
}

- (void)removeBinaryHash {
    [_storage removeObjectForKey:[self getAppSpecificKey:kMSBinaryHash]];
}
@end
