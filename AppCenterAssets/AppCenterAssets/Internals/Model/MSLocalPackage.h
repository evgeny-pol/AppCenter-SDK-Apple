#import <Foundation/Foundation.h>

#import "MSAssetsPackage.h"

@interface MSLocalPackage

/**
 * Indicates whether this update is in a "pending" state.
 * When <code>true</code>, that means the update has been downloaded and installed, but the app restart
 * needed to apply it hasn't occurred yet, and therefore, its changes aren't currently visible to the end-user.
 */
@property(nonatomic, copy) BOOL isPending;

/**
 * The path to the update entry point.
 */
@property(nonatomic, copy) NSString *entryPoint;

/**
 * Indicates whether this is the first time the update has been run after being installed.
 */
@property(nonatomic, copy) BOOL isFirstRun;

/**
 * Whether this package is intended for debug mode.
 */
@property(nonatomic, copy) BOOL isDebugOnly;

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
 * @return instance of the {@link AssetsLocalPackage}.
 */
+ (MSLocalPackage *)createLocalPackage:(BOOL)failedInstall
                            isFirstRun:(BOOL)isFirstRun
                             isPending:(BOOL)isPending
                           isDebugOnly:(BOOL)isDebugOnly
                            entryPoint:(NSString *)entryPoint
                         assetsPackage:(MSAssetsPackage *)assetsPackage;

+ (MSLocalPackage *)createLocalPackage:(NSString *)appVersion;

@end
