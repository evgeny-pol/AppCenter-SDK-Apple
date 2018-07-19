#import <Foundation/Foundation.h>
#import "MSAssetsPackage.h"
#import "MSAssetsPendingUpdate.h"
#import "MSAssetsStatusReportIdentifier.h"

/**
 * Manager responsible for storing configuration information on device.
 */
@interface MSAssetsSettingManager : NSObject

- (instancetype)initWithAppName:(nonnull NSString *)appName;

/**
 * Gets an array with containing failed updates info arranged by time of the failure ascending.
 * Each item represents an instance of `MSAssetsPackage` that has failed to update.
 *
 * @return an array of failed updates.
 */
- (NSMutableArray<MSAssetsPackage *> *)getFailedUpdates;

/**
 * Gets object with pending update info.
 *
 * @return object representing `MSAssetsPendingUpdate` with pending update info.
 */
- (MSAssetsPendingUpdate *)getPendingUpdate;

/**
 * Checks whether an update with the following hash has failed.
 *
 * @param packageHash hash to check.
 * @return `true` if there is a failed update with provided hash, `false` otherwise.
 */
- (BOOL)existsFailedUpdate:(NSString *_Nonnull )packageHash;

/**
 * Checks whether there is a pending update with the provided hash.
 * Pass `null` to check if there is any pending update.
 *
 * @param packageHash expected package hash of the pending update.
 * @return `true` if there is a pending update with the provided hash.
 */
- (BOOL)isPendingUpdate:(NSString *)packageHash;

/**
 * Removes information about failed updates.
 */
- (void)removeFailedUpdates;

/**
 * Removes information about the pending update.
 */
- (void)removePendingUpdate;

/**
 * Adds another failed update info to the list of failed updates.
 *
 * @param failedPackage instance of failed `MSAssetsPackage`.
 */
- (void)saveFailedUpdate:(MSAssetsPackage *_Nonnull) failedPackage;

/**
 * Saves information about the pending update.
 *
 * @param pendingUpdate instance of the `MSAssetsPendingUpdate`.
 */
- (void)savePendingUpdate:(MSAssetsPendingUpdate *_Nonnull) pendingUpdate;

/**
 * Saves identifier of already sent status report.
 *
 * @param identifier identifier of already sent status report.
 */
- (void)saveIdentifierOfReportedStatus:(MSAssetsStatusReportIdentifier *)identifier;

/**
 * Gets previously saved status report identifier.
 *
 * @return previously saved status report identifier.
 */
- (MSAssetsStatusReportIdentifier *)getPreviousStatusReportIdentifier;

/**
 * Removes information about previous status report.
 */
- (void)removePreviousStatusReportIdentifier;

/**
 * Saves a new dictionary of binary hashes.
 * Format is: <binary modification date>:<binary hash>.
 *
 * @param binaryHash dictionary with hashes.
 */
- (void)saveBinaryHash:(NSMutableDictionary *)binaryHash;

/**
 * Gets dictionary with binary hashes.
 *
 * @return dictionary with binary hashes.
 */
- (NSMutableDictionary *)getBinaryHash;

/**
 * Removes dictionary with binary hashes.
 */
- (void)removeBinaryHash;

@end
