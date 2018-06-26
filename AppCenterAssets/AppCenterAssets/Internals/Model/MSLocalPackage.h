#import <Foundation/Foundation.h>
#import "MSAssetsPackage.h"

/**
 * Represents the downloaded package.
 */
@interface MSLocalPackage : MSAssetsPackage

/**
 * Indicates whether this update is in a `pending` state.
 * When `true`, that means the update has been downloaded and installed, but the app restart
 * needed to apply it hasn't occurred yet, and therefore, its changes aren't currently visible to the end-user.
 */
@property(nonatomic) BOOL isPending;

/**
 * The path to the update entry point.
 */
@property(nonatomic, copy) NSString *entryPoint;

/**
 * Indicates whether this is the first time the update has been run after being installed.
 */
@property(nonatomic) BOOL isFirstRun;

/**
 * Whether this package is intended for debug mode.
 */
@property(nonatomic) BOOL isDebugOnly;

/**
 * The time when binary of the update was modified (built).
 */
@property(nonatomic, copy) NSString *binaryModifiedTime;

/**
 * Creates an instance of the package from basic package.
 *
 * @param failedInstall   whether this update has been previously installed but was rolled back.
 * @param isFirstRun      whether this is the first time the update has been run after being installed.
 * @param isPending       whether this update is in a "pending" state.
 * @param isDebugOnly     whether this package is intended for debug mode.
 * @param entryPoint      the path to the application entry point.
 * @param assetsPackage   basic package containing the information.
 * @return instance of the `MSLocalPackage`.
 */
+ (MSLocalPackage *)createLocalPackageWithPackage:(MSAssetsPackage *)assetsPackage
                                    failedInstall:(BOOL)failedInstall
                                       isFirstRun:(BOOL)isFirstRun
                                        isPending:(BOOL)isPending
                                      isDebugOnly:(BOOL)isDebugOnly
                                       entryPoint:(NSString *)entryPoint;

/**
 * Creates adefault instance of the package (can be used to query the update).
 *
 * @param appVersion   version of the binary contents.
 * @return instance of the `MSLocalPackage`.
 */
+ (MSLocalPackage *)createLocalPackageWithAppVersion:(NSString *)appVersion;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
