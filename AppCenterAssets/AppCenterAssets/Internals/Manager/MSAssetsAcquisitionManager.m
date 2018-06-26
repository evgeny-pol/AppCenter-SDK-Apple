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
#import "MSAssetsErrors.h"

@implementation MSAssetsAcquisitionManager

/**
 The API paths for latest release requests.
 */
static NSString *const kMSUpdateCheckEndpoint = @"%@updateCheck";

- (void)queryUpdateWithCurrentPackage:(MSAssetsConfiguration *)configuration
                                      localPackage:(MSLocalPackage *)localPackage
                    completionHandler:(MSCheckForUpdateCompletionHandler)handler {
    NSString * baseUrl = [[NSString alloc] initWithFormat:kMSUpdateCheckEndpoint, [configuration serverUrl]];
    
    NSString *deploymentKey = [configuration deploymentKey];
    NSString *clientUniqueId = [configuration clientUniqueId];
    MSAssetsUpdateRequest *updateRequest = [MSAssetsUpdateRequest createUpdateRequestWithDeploymentKey: deploymentKey
                                                                        assetsPackage:localPackage
                                                                       andDeviceId:clientUniqueId];
    NSMutableDictionary *queries = [updateRequest serializeToDictionary];
    
    self.updateChecker = [[MSAssetsCheckForUpdate alloc] initWithBaseUrl:baseUrl
                                                            queryStrings:queries];
    __weak typeof(self) weakSelf = self;
    [self.updateChecker
     sendAsync:nil
     completionHandler:^(__unused NSString *callId, NSUInteger statusCode, NSData *data, __unused NSError *error) {
         typeof(self) strongSelf = weakSelf;
         if (!strongSelf) {
             return;
         }
         
         // Release sender instance.
         strongSelf.updateChecker = nil;
         
         // Error instance for JSON parsing.
         NSError *jsonError = nil;
         
         // Success.
         if (statusCode == MSHTTPCodesNo200OK) {
             MSAssetsUpdateResponse *response = nil;
             if (data) {
                 id dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
                 if (jsonError) {
                     NSDictionary *userInfo = @{kMSACConnectionParseErrorKey : kMSACQueryUpdateParseErrorDesc};
                     NSError *newError = [NSError errorWithDomain:kMSACErrorDomain
                                                             code:kMSACQueryUpdateParseErrorCode
                                                         userInfo:userInfo];
                     handler(nil, newError);
                 }
                 response = [[MSAssetsUpdateResponse alloc] initWithDictionary:dictionary];
             }
             if (response) {
                 MSUpdateResponseUpdateInfo *updateInfo = [response updateInfo];
                 if ([updateInfo updateAppVersion]) {
                 handler([MSRemotePackage createDefaultRemotePackageWithAppVersion:[updateInfo appVersion]
                                                                  updateAppVersion:[updateInfo updateAppVersion]], nil);
                 } else if (![updateInfo isAvailable]) {
                     handler(nil, nil);
                 }
                 handler([MSRemotePackage createRemotePackageFromUpdateInfo:updateInfo
                                                           andDeploymentKey:[configuration deploymentKey]], nil);
             }
             handler(nil, nil);
         }
         
         // Failure.
         else {
             handler(nil, [strongSelf getErrorFromData:data]);
         }
     }];
}

- (NSError *)getErrorFromData:(NSData *)data {
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
    
    // Check the status code to clean up Distribute data for an unrecoverable error.
    
    if (!jsonString) {
        jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    NSDictionary *userInfo = @{kMSACConnectionHttpCodeErrorKey : kMSACQueryUpdateErrorDesc};
    NSError *error = [NSError errorWithDomain:kMSACErrorDomain
                                         code:kMSACQueryUpdateErrorCode
                                     userInfo:userInfo];
    return error;
}



@end
