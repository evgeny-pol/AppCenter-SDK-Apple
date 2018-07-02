#import <Foundation/Foundation.h>
#import "MSAssetsErrorUtils.h"
#import "MSAssetsErrors.h"

@implementation MSAssetsErrorUtils

+ (NSError *)getNoDirError: (NSString *)folderPath {
    NSDictionary *userInfo = @{kMSACFileErrorKey : kMSACNoDirFileErrorDesc(folderPath)};
    return [NSError errorWithDomain:kMSACErrorDomain
                                            code:kMSACFileErrorCode
                                        userInfo:userInfo];
}

+ (NSError *)getFileDeleteError:(NSString *)filePath {
    NSDictionary *userInfo = @{kMSACFileErrorKey : kMSACDeleteFileErrorDesc(filePath)};
    return [NSError errorWithDomain:kMSACErrorDomain
                                            code:kMSACFileErrorCode
                                        userInfo:userInfo];
}

+ (NSError *)getNoSignatureError:(NSString *)signaturePath {
    NSDictionary *userInfo = @{kMSACSignatureVerificationErrorKey : kMSACSignatureVerificationNoSignatureErrorDesc(signaturePath)};
    return [NSError errorWithDomain:kMSACErrorDomain
                                            code:kMSACSignatureVerificationErrorCode
                                        userInfo:userInfo];
}

+ (NSError *)getDownloadPackageError:(NSString *)downloadUrl statusCode:(NSInteger)statusCode {
    NSDictionary *userInfo = @{kMSACConnectionHttpCodeErrorKey : kMSACDownloadPackageStatusCodeErrorDesc(downloadUrl, (long)statusCode)};
    return [NSError errorWithDomain:kMSACErrorDomain
                                            code:kMSACDownloadPackageErrorCode
                                        userInfo:userInfo];
}

+ (NSError *)getDownloadPackageError:(NSString *)downloadUrl {
    NSDictionary *userInfo = @{kMSACConnectionHttpCodeErrorKey : kMSACDownloadPackageErrorDesc(downloadUrl)};
    return [NSError errorWithDomain:kMSACErrorDomain
                                            code:kMSACDownloadPackageErrorCode
                                        userInfo:userInfo];
}

+ (NSError *)getNoContentHashError {
    NSDictionary *userInfo = @{kMSACSignatureVerificationErrorKey : kMSACSignatureVerificationNoContentHashErrorDesc};
    return [NSError errorWithDomain:kMSACErrorDomain
                                            code:kMSACSignatureVerificationErrorCode
                                        userInfo:userInfo];
}

+ (NSError *)getUpdateParseError {
    NSDictionary *userInfo = @{kMSACConnectionParseErrorKey : kMSACQueryUpdateParseErrorDesc};
    return [NSError errorWithDomain:kMSACErrorDomain
                                            code:kMSACQueryUpdateErrorCode
                                        userInfo:userInfo];
}

+ (NSError *)getUpdateError:(NSString *)errorString {
    NSDictionary *userInfo = @{kMSACConnectionHttpCodeErrorKey : errorString};
    return [NSError errorWithDomain:kMSACErrorDomain
                                            code:kMSACQueryUpdateErrorCode
                                        userInfo:userInfo];
}

+ (NSError *)getUpdateNotTargetingBinaryError {
    NSDictionary *userInfo = @{kMSACUpdateErrorKey : kMSACUpdateAvailableButNotTargetingBinary};
    return [NSError errorWithDomain:kMSACErrorDomain
                                            code:kMSACQueryUpdateErrorCode
                                        userInfo:userInfo];
}
@end
