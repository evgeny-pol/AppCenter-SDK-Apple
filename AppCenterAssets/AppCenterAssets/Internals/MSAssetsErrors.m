#import "MSAssetsErrors.h"

#define MS_APP_CENTER_BASE_DOMAIN @"com.Microsoft.AppCenter."

#pragma mark - Domain

NSString *const kMSACErrorDomain = MS_APP_CENTER_BASE_DOMAIN @"ErrorDomain";

#pragma mark - Update error descriptions

NSString const *kMSACQueryUpdateErrorDesc = @"Error occurred during querying the update.";
NSString const *kMSACQueryUpdateParseErrorDesc = @"Error occurred during parsing update response.";
NSString const *kMSACUpdateAvailableButNotTargetingBinary = @"An update is available but it is not targeting the binary version of your app.";
NSString const *kMSACUpdateFailedToCreateUpdateMetadataFileErrorDesc = @"Failed to create update metadata file.";
NSString const *kMSACUpdateFailedToUpdatePackageInfoErrorDesc = @"Error updating current package info.";

#pragma mark - Signature verification error descriptions

NSString const *kMSACSignatureVerificationNoContentHashErrorDesc = @"The update could not be verified because the signature did not specify a content hash.";
NSString const *kMSACSignatureVerificationNoSignatureDefErrorDesc = @"Error! Public key was provided but there is no JWT signature within app to verify. \
Possible reasons, why that might happen: \
1. You've released an update using version of CodePush CLI that does not support code signing.\
2. You've released an update without providing --privateKeyPath option.";
NSString const *kMSACSignatureVerificationIntegrityCheckErrorDesc = @"The update contents failed the data integrity check.";
NSString const *kMSACSignatureVerificationCodeSigningCheckErrorDesc = @"The update contents failed code signing check.";
NSString *kMSACSignatureVerificationNoSignatureErrorDesc(NSString *signatureFilePath) {
    return [[NSString alloc] initWithFormat: @"Cannot find signature at %@", signatureFilePath];
};

#pragma mark - Download error descriptions

NSString *kMSACDownloadPackageErrorDesc(NSString *downloadUrl) {
    return [[NSString alloc] initWithFormat: @"Error occurred during package downloading. Download url is %@", downloadUrl];
};
NSString *kMSACDownloadPackageStatusCodeErrorDesc(NSString *downloadUrl, long statusCode) {
    return [[NSString alloc] initWithFormat: @"Error occurred during package downloading. Received %ld response from %@", statusCode, downloadUrl];
};
NSString *kMSACDownloadPackageInvalidFileErrorDesc(NSString *filePath) {
    return [[NSString alloc] initWithFormat: @"Error occurred during package downloading. Wrong path: %@", filePath];
}

#pragma mark - File error descriptions

NSString *kMSACDeleteFileErrorDesc(NSString *filePath) {
    return [[NSString alloc] initWithFormat: @"Unable to delete file at %@", filePath];
};
NSString *kMSACCreateFileErrorDesc(NSString *filePath) {
    return [[NSString alloc] initWithFormat: @"Unable to create file at %@", filePath];
};
NSString *kMSACCopyFileErrorDesc(NSString *src, NSString *dest) {
    return [[NSString alloc] initWithFormat: @"Unable to copy file from %@ to %@", src, dest];
};
NSString *kMSACMoveFileErrorDesc(NSString *src, NSString *dest) {
    return [[NSString alloc] initWithFormat: @"Unable to move file from %@ to %@", src, dest];
};
NSString *kMSACUnzipFileErrorDesc(NSString *filePath, NSString *dest) {
    return [[NSString alloc] initWithFormat: @"Unable to unzip file at %@ to %@", filePath, dest];
};
NSString *kMSACNoDirFileErrorDesc(NSString *filePath) {
    return [[NSString alloc] initWithFormat: @"Pathname %@ does not denote a directory", filePath];
};

#pragma mark - Install error descriptions

NSString const *kMSACInstallNoPackageHashErrorDesc = @"Update package to be installed has no hash.";

NSString const *kMSACNoAppVersionErrorDesc = @"Unable to get package info for app.";

#pragma mark - Error keys

NSString const *kMSACDownloadCodeErrorKey = MS_APP_CENTER_BASE_DOMAIN "DownloadKey";
NSString const *kMSACUpdateErrorKey = MS_APP_CENTER_BASE_DOMAIN "UpdateKey";
NSString const *kMSACParseErrorKey = MS_APP_CENTER_BASE_DOMAIN "ParseKey";
NSString const *kMSACSignatureVerificationErrorKey = MS_APP_CENTER_BASE_DOMAIN "SignatureKey";
NSString const *kMSACInstallErrorKey = MS_APP_CENTER_BASE_DOMAIN "InstallKey";
NSString const *kMSACFileErrorKey = MS_APP_CENTER_BASE_DOMAIN "FileKey";
