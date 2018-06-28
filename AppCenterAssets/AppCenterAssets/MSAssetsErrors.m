#import "MSAssetsErrors.h"

#define MS_APP_CENTER_BASE_DOMAIN @"com.Microsoft.AppCenter."

#pragma mark - Domain

NSString *const kMSACErrorDomain = MS_APP_CENTER_BASE_DOMAIN @"ErrorDomain";

#pragma mark - Connection

// Error descriptions
NSString const *kMSACQueryUpdateErrorDesc = @"Error occurred during querying the update.";
NSString const *kMSACQueryUpdateParseErrorDesc = @"Error occurred during parsing update response.";
NSString const *kMSACUpdateAvailableButNotTargetingBinary = @"An update is available but it is not targeting the binary version of your app.";

NSString *kMSACDownloadPackageErrorDesc(NSString *downloadUrl) {
    return [[NSString alloc] initWithFormat: @"Error occurred during package downloading. Download url is %@", downloadUrl];
};
NSString *kMSACDownloadPackageStatusCodeErrorDesc(NSString *downloadUrl, long statusCode) {
    return [[NSString alloc] initWithFormat: @"Error occurred during package downloading. Received %ld response from %@", statusCode, downloadUrl];
};


// Error user info keys
NSString const *kMSACConnectionHttpCodeErrorKey = MS_APP_CENTER_BASE_DOMAIN "HttpCodeKey";
NSString const *kMSACConnectionParseErrorKey = MS_APP_CENTER_BASE_DOMAIN "ParseKey";
