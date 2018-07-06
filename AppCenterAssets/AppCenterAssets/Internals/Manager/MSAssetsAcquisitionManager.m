#import "MSAppCenter.h"
#import "MSAppCenterInternal.h"
#import "MSAssetsCheckForUpdate.h"
#import "MSAssetsAcquisitionManager.h"
#import "MSAssetsUpdateResponse.h"
#import "MSAssetsUpdateRequest.h"
#import "MSAssetsUpdateResponseUpdateInfo.h"
#import "MSHttpSenderPrivate.h"
#import "MSLoggerInternal.h"
#import "MSAssets.h"
#import "MSAssetsErrorUtils.h"
#import "MSAssetsReportSender.h"
#import "MSLogger.h"

@implementation MSAssetsAcquisitionManager {
    MSAssetsCheckForUpdate *_updateChecker;
    MSAssetsReportSender *_reportSender;
}

/**
 The API paths for requests.
 */
static NSString *const kMSUpdateCheckEndpoint = @"%@updateCheck";
static NSString *const kMSReportDeploymentStatusEndpoint = @"%@reportStatus/deploy";
static NSString *const kMSReportDownloadStatusEndpoint = @"%@reportStatus/download";

- (void)queryUpdateWithCurrentPackage:(MSAssetsLocalPackage *)localPackage
                    withConfiguration:(MSAssetsConfiguration *)configuration
                    andCompletionHandler:(MSCheckForUpdateCompletionHandler)handler {
    NSString *serverUrl = [self fixServerUrl:[configuration serverUrl]];
    NSString *baseUrl = [[NSString alloc] initWithFormat:kMSUpdateCheckEndpoint, serverUrl];
    NSString *deploymentKey = [configuration deploymentKey];
    NSString *clientUniqueId = [configuration clientUniqueId];
    MSAssetsUpdateRequest *updateRequest = [MSAssetsUpdateRequest createUpdateRequestWithDeploymentKey: deploymentKey
                                                                        assetsPackage:localPackage
                                                                       andDeviceId:clientUniqueId];
    NSMutableDictionary *queries = [updateRequest serializeToDictionary];
    _updateChecker = [[MSAssetsCheckForUpdate alloc] initWithBaseUrl:baseUrl
                                                            queryStrings:queries];
    __weak typeof(self) weakSelf = self;
    [_updateChecker
     sendAsync:nil
     completionHandler:^(__unused NSString *callId, NSUInteger statusCode, NSData *data, NSError *error) {
         typeof(self) strongSelf = weakSelf;
         if (!strongSelf) {
             return;
         }
         if (error) {
             handler(nil, error);
             return;
         }
         strongSelf->_updateChecker = nil;
         NSError *jsonError = nil;
         if (statusCode == MSHTTPCodesNo200OK) {
             MSAssetsUpdateResponse *response = nil;
             if (data) {
                 id dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
                 if (jsonError) {
                     handler(nil, [MSAssetsErrorUtils getUpdateParseError]);
                     return;
                 }
                 response = [[MSAssetsUpdateResponse alloc] initWithDictionary:dictionary];
             }
             if (response) {
                 MSAssetsUpdateResponseUpdateInfo *updateInfo = [response updateInfo];
                 if ([updateInfo updateAppVersion]) {
                     handler([MSAssetsRemotePackage createDefaultRemotePackageWithAppVersion:[updateInfo appVersion]
                                                                  updateAppVersion:[updateInfo updateAppVersion]], nil);
                     return;
                 } else if (![updateInfo isAvailable]) {
                     handler(nil, nil);
                     return;
                 }
                 handler([MSAssetsRemotePackage createRemotePackageFromUpdateInfo:updateInfo
                                                           andDeploymentKey:[configuration deploymentKey]], nil);
                 return;
             }
             handler(nil, nil);
         } else {
             handler(nil, [MSAssetsErrorUtils getUpdateError:[self getErrorFromData:data]]);
         }
     }];
}

- (NSString *)fixServerUrl:(NSString *)serverUrl {
    if (![serverUrl hasSuffix:@"/"]) {
        serverUrl = [serverUrl stringByAppendingString:@"/"];
    }
    return serverUrl;
}

/**
* Gets error description from `NSData`.
*
* @param data instance of `NSData` to examine.
* @return `NSString` with error description.
*/
- (NSString *)getErrorFromData:(NSData *)data {
    NSString *jsonString = nil;
    NSError *jsonError = nil;
    id dictionary = nil;
    
    // Failure can deliver empty payload.
    if (data) {
        dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableContainers
                                                       error:&jsonError];
        
        // Failure can deliver non-JSON format of payload.
        if (!jsonError) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&jsonError];
            if (jsonData && !jsonError) {
                
                // NSJSONSerialization escapes paths by default so we replace them.
                jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]
                              stringByReplacingOccurrencesOfString:@"\\/"
                              withString:@"/"];
            }
        }
    }
    if (!jsonString) {
        jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return jsonError == nil ? jsonString : [jsonError localizedDescription];
}

- (void)reportDownloadStatus:(nullable MSAssetsDownloadStatusReport *)report
           withConfiguration:(nullable MSAssetsConfiguration *)configuration {
    NSString *serverUrl = [self fixServerUrl:[configuration serverUrl]];
    NSString *baseUrl = [[NSString alloc] initWithFormat:kMSReportDownloadStatusEndpoint, serverUrl];
    
    _reportSender = [[MSAssetsReportSender alloc] initWithBaseUrl:baseUrl reportType: MsAssetsReportTypeDownload];
    __weak typeof(self) weakSelf = self;
    [_reportSender
     sendAsync:report
     completionHandler:^(__unused NSString *callId, NSUInteger statusCode, NSData *data, NSError *error) {
         typeof(self) strongSelf = weakSelf;
         if (!strongSelf) {
             return;
         }
         if (error) {
             MSLogError([MSAssets logTag], @"Error reporting download status: %@", [error localizedDescription]);
             return;
         }
         strongSelf->_reportSender = nil;
         if (statusCode == MSHTTPCodesNo200OK) {
             if (data) {
                 MSLogInfo([MSAssets logTag], @"Report status download: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
             }
         } else {
             MSLogError([MSAssets logTag], @"Error reporting download status: %@", [strongSelf getErrorFromData:data]);
         }
     }];
}

- (void)reportDeploymentStatus:(nullable MSAssetsDeploymentStatusReport *) report
             withConfiguration:(nullable MSAssetsConfiguration *) configuration {
    NSString *serverUrl = [self fixServerUrl:[configuration serverUrl]];
    NSString *deploymentKey = [configuration deploymentKey];
    NSString *clientUniqueId = [configuration clientUniqueId];
    NSString *label = [report assetsPackage] != nil ? [[report assetsPackage] label] : [report label];
    NSString *appVersion = [report assetsPackage] != nil ? [[report assetsPackage] appVersion] : [configuration appVersion];
    NSString *baseUrl = [[NSString alloc] initWithFormat:kMSReportDeploymentStatusEndpoint, serverUrl];
    [report setClientUniqueId: clientUniqueId];
    [report setDeploymentKey:deploymentKey];
    [report setAppVersion:appVersion];
    [report setLabel:label];
    
    _reportSender = [[MSAssetsReportSender alloc] initWithBaseUrl:baseUrl reportType: MsAssetsReportTypeDeploy];
    __weak typeof(self) weakSelf = self;
    [_reportSender
     sendAsync:report
     completionHandler:^(__unused NSString *callId, NSUInteger statusCode, NSData *data, NSError *error) {
         typeof(self) strongSelf = weakSelf;
         if (!strongSelf) {
             return;
         }
         if (error) {
             MSLogError([MSAssets logTag], @"Error reporting deploy status: %@", [error localizedDescription]);
             return;
         }
         strongSelf->_reportSender = nil;
         if (statusCode == MSHTTPCodesNo200OK) {
             if (data) {
                 MSLogInfo([MSAssets logTag], @"Report status deploy: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
             }
         } else {
             MSLogError([MSAssets logTag], @"Error reporting deploy status: %@", [strongSelf getErrorFromData:data]);
         }
     }];
}

@end
