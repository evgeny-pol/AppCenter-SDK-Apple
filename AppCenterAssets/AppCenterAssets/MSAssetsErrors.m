#import "MSAssetsErrors.h"

#define MS_APP_CENTER_BASE_DOMAIN @"com.Microsoft.AppCenter."

#pragma mark - Domain

NSString *const kMSACErrorDomain = MS_APP_CENTER_BASE_DOMAIN @"ErrorDomain";

#pragma mark - Connection

// Error descriptions
NSString const *kMSACQueryUpdateErrorDesc = @"Error occurred during querying the update.";
NSString const *kMSACQueryUpdateParseErrorDesc = @"Error occurred during parsing update response.";
NSString const *kMSACUpdateAvailableButNotTargetingBinary = @"An update is available but it is not targeting the binary version of your app.";
NSString const *kMSACUpdateFailedToCreateUpdateMetadataFileErrorDesc = @"Failed to create update metadata file.";
NSString const *kMSACSignatureVerificationNoContentHashErrorDesc = @"The update could not be verified because the signature did not specify a content hash.";

NSString *kMSACDownloadPackageErrorDesc(NSString *downloadUrl) {
    return [[NSString alloc] initWithFormat: @"Error occurred during package downloading. Download url is %@", downloadUrl];
};
NSString *kMSACDownloadPackageStatusCodeErrorDesc(NSString *downloadUrl, long statusCode) {
    return [[NSString alloc] initWithFormat: @"Error occurred during package downloading. Received %ld response from %@", statusCode, downloadUrl];
};
NSString *kMSACSignatureVerificationNoSignatureErrorDesc(NSString *signatureFilePath) {
    return [[NSString alloc] initWithFormat: @"Cannot find signature at %@", signatureFilePath];
};
NSString *kMSACDeleteFileErrorDesc(NSString *filePath) {
    return [[NSString alloc] initWithFormat: @"Unable to delete file at %@", filePath];
};
NSString *kMSACNoDirFileErrorDesc(NSString *filePath) {
    return [[NSString alloc] initWithFormat: @"Pathname %@ does not denote a directory", filePath];
};

// Error user info keys
NSString const *kMSACConnectionHttpCodeErrorKey = MS_APP_CENTER_BASE_DOMAIN "HttpCodeKey";
NSString const *kMSACUpdateErrorKey = MS_APP_CENTER_BASE_DOMAIN "UpdateKey";
NSString const *kMSACConnectionParseErrorKey = MS_APP_CENTER_BASE_DOMAIN "ParseKey";
NSString const *kMSACSignatureVerificationErrorKey = MS_APP_CENTER_BASE_DOMAIN "SignatureKey";
NSString const *kMSACFileErrorKey = MS_APP_CENTER_BASE_DOMAIN "FileKey";
