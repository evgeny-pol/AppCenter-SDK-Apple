#import <Foundation/Foundation.h>
#import "MSAssetsErrorUtils.h"
#import "MSAssetsErrors.h"

@implementation MSAssetsErrorUtils

+ (NSError *)getNoDirError: (NSString *)folderPath {
    NSDictionary *userInfo = @{kMSACFileErrorKey : kMSACNoDirFileErrorDesc(folderPath)};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACFileErrorCode userInfo:userInfo];
}

+ (NSError *)getFileDeleteError:(NSString *)filePath {
    NSDictionary *userInfo = @{kMSACFileErrorKey : kMSACDeleteFileErrorDesc(filePath)};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACFileErrorCode userInfo:userInfo];
}

+ (NSError *)getFileCreateError:(NSString *)filePath {
    NSDictionary *userInfo = @{kMSACFileErrorKey : kMSACCreateFileErrorDesc(filePath)};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACFileErrorCode userInfo:userInfo];
}

+ (NSError *)getFileCopyError:(NSString *)src destination:(NSString *)dest {
    NSDictionary *userInfo = @{kMSACFileErrorKey : kMSACCopyFileErrorDesc(src, dest)};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACFileErrorCode userInfo:userInfo];
}

+ (NSError *)getFileMoveError:(NSString *)src destination:(NSString *)dest {
    NSDictionary *userInfo = @{kMSACFileErrorKey : kMSACMoveFileErrorDesc(src, dest)};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACFileErrorCode userInfo:userInfo];
}

+ (NSError *)getFileUnzipError:(NSString *)filePath destination:(NSString *)dest {
    NSDictionary *userInfo = @{kMSACFileErrorKey : kMSACUnzipFileErrorDesc(filePath, dest)};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACFileErrorCode userInfo:userInfo];
}

+ (NSError *)getNoSignatureError:(NSString *)signaturePath {
    NSDictionary *userInfo = @{kMSACSignatureVerificationErrorKey : kMSACSignatureVerificationNoSignatureErrorDesc(signaturePath)};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACSignatureVerificationErrorCode userInfo:userInfo];
}

+ (NSError *)getNoSignatureError {
    NSDictionary *userInfo = @{kMSACSignatureVerificationErrorKey : kMSACSignatureVerificationNoSignatureDefErrorDesc};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACSignatureVerificationErrorCode userInfo:userInfo];
}

+ (NSError *)getDownloadPackageError:(NSString *)downloadUrl statusCode:(NSInteger)statusCode {
    NSDictionary *userInfo = @{kMSACDownloadCodeErrorKey : kMSACDownloadPackageStatusCodeErrorDesc(downloadUrl, (long)statusCode)};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACDownloadPackageErrorCode userInfo:userInfo];
}

+ (NSError *)getDownloadPackageError:(NSString *)downloadUrl {
    NSDictionary *userInfo = @{kMSACDownloadCodeErrorKey : kMSACDownloadPackageErrorDesc(downloadUrl)};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACDownloadPackageErrorCode userInfo:userInfo];
}

+ (NSError *)getNoContentHashError {
    NSDictionary *userInfo = @{kMSACSignatureVerificationErrorKey : kMSACSignatureVerificationNoContentHashErrorDesc};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACSignatureVerificationErrorCode userInfo:userInfo];
}

+ (NSError *)getUpdateParseError {
    NSDictionary *userInfo = @{kMSACParseErrorKey : kMSACQueryUpdateParseErrorDesc};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACQueryUpdateErrorCode userInfo:userInfo];
}

+ (NSError *)getUpdateError:(NSString *)errorString {
    NSDictionary *userInfo = @{kMSACUpdateErrorKey : errorString};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACQueryUpdateErrorCode userInfo:userInfo];
}

+ (NSError *)getUpdateNotTargetingBinaryError {
    NSDictionary *userInfo = @{kMSACUpdateErrorKey : kMSACUpdateAvailableButNotTargetingBinary};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACQueryUpdateErrorCode userInfo:userInfo];
}

+ (NSError *)getUpdateMetadataFailToCreateError {
    NSDictionary *userInfo = @{kMSACUpdateErrorKey : kMSACUpdateFailedToCreateUpdateMetadataFileErrorDesc};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACQueryUpdateErrorCode userInfo:userInfo];
}

+ (NSError *)getIntegrityCheckError {
    NSDictionary *userInfo = @{kMSACSignatureVerificationErrorKey : kMSACSignatureVerificationIntegrityCheckErrorDesc};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACSignatureVerificationErrorCode userInfo:userInfo];
}

+ (NSError *)getCodeSigningCheckError {
    NSDictionary *userInfo = @{kMSACSignatureVerificationErrorKey : kMSACSignatureVerificationCodeSigningCheckErrorDesc};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACSignatureVerificationErrorCode userInfo:userInfo];
}

+ (NSError *)getNoPackageHashToInstallError {
    NSDictionary *userInfo = @{kMSACInstallErrorKey : kMSACInstallNoPackageHashErrorDesc};
    return [NSError errorWithDomain:kMSACErrorDomain code:kMSACInstallErrorCode userInfo:userInfo];    
}
@end
