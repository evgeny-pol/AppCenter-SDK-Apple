#import <Foundation/Foundation.h>
#import "MSAssetsPackage.h"
#import "MSAssetsUpdateResponseUpdateInfo.h"

/**
 * Represents information about a remote package (on server).
 */
@interface MSAssetsRemotePackage : MSAssetsPackage

/**
 * Url to access package on server.
 */
@property(nonatomic, copy) NSString *downloadUrl;

/**
 * Size of the package.
 */
@property(nonatomic) long long packageSize;

/**
 * Whether the client should trigger a store update.
 */
@property(nonatomic) BOOL updateAppVersion;

/**
 * Creates an instance of the class from the basic package.
 *
 * @param failedInstall    whether this update has been previously installed but was rolled back.
 * @param packageSize      the size of the package.
 * @param downloadUrl      url to access package on server.
 * @param updateAppVersion whether the client should trigger a store update.
 * @param assetsPackage  basic package containing the information.
 * @return instance of the `MSAssetsRemotePackage`.
 */
+ (MSAssetsRemotePackage *)createRemotePackageFromPackage:(MSAssetsPackage *)assetsPackage
                                      failedInstall:(BOOL)failedInstall
                                        packageSize:(long)packageSize
                                        downloadUrl:(NSString *)downloadUrl
                                   updateAppVersion:(BOOL)updateAppVersion;

/**
 * Creates instance of the class from the update response from server.
 *
 * @param deploymentKey the deployment key that was used to originally download this update.
 * @param updateInfo    update info response from server.
 * @return instance of the `MSAssetsRemotePackage`.
 */
+ (MSAssetsRemotePackage *)createRemotePackageFromUpdateInfo:(MSAssetsUpdateResponseUpdateInfo *)updateInfo
                                      andDeploymentKey:(NSString *)deploymentKey;

/**
 * Creates a default package from the app version.
 *
 * @param appVersion       current app version.
 * @param updateAppVersion whether the client should trigger a store update.
 * @return instance of the `MSAssetsRemotePackage`.
 */
+ (MSAssetsRemotePackage *)createDefaultRemotePackageWithAppVersion:(NSString *)appVersion
                               updateAppVersion:(BOOL)updateAppVersion;
@end

