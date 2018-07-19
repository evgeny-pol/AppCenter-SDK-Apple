#import <Foundation/Foundation.h>

/**
 * Identifier for status report saved on users device.
 * Basically it is used in `MSAssetsTelemetryManager`
 * for identifying status reports saved on users device. Identifier consist of two parts: deployment key and version label.
 * If both are exist it means that update report was saved, if only version label exists it means that binary report was saved.
 * There shouldn't be a situation when version label doesn't exist.
 * Identifier can be serialized into string for saving on device and deserialized from it.
 */
@interface MSAssetsStatusReportIdentifier : NSObject

/**
* App version.
*/
@property(nonatomic, copy, nullable) NSString *versionLabel;

/**
 * CodePush deployment key.
 */
@property(nonatomic, copy, nullable) NSString *deploymentKey;

/**
 * Creates an instance of `MSAssetsStatusReportIdentifier`.
 *
 * @param versionLabel version label.
 */
- (instancetype)initWithAppVersion:(NSString *_Nonnull)versionLabel;

/**
 * Creates an instance of `MSAssetsStatusReportIdentifier`.
 *
 * @param deploymentKey deployment key.
 * @param versionLabel  version label.
 */
- (instancetype)initWithAppVersion:(NSString *_Nonnull)versionLabel andDeploymentKey:(NSString *)deploymentKey;

/**
 * Deserializes identifier from string.
 *
 * @param stringIdentifier input string.
 * @return `MSAssetsStatusReportIdentifier` instance if it could be parsed, `null` otherwise.
 */
+ (MSAssetsStatusReportIdentifier *)reportIdentifierFromString:(NSString *)stringIdentifier;

/**
 * Serializes identifier to string.
 *
 * @return serialized identifier.
 */
- (NSString *)toString;

/**
 * Indicates whether identifier has deployment key.
 *
 * @return `true` if identifier has deployment key, `false` otherwise.
 */
- (BOOL)hasDeploymentKey;

/**
 * Gets version label or empty string if it equals `nil`.
 *
 * @return version label or empty string if it equals `nil`.
 */
- (NSString *)versionLabelOrEmpty;

@end
