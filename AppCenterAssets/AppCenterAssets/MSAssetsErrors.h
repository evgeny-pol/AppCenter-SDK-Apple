#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Domain
extern NSString *const kMSACErrorDomain;
    
#pragma mark - Error codes
NS_ENUM(NSInteger){
    kMSACQueryUpdateErrorCode = 100,
    kMSACDownloadPackageErrorCode = 102,
    kMSACSignatureVerificationErrorCode = 103,
    kMSACFileErrorCode = 104
};
        
#pragma mark - Error descriptions
extern NSString const *kMSACQueryUpdateErrorDesc;
extern NSString const *kMSACQueryUpdateParseErrorDesc;
extern NSString const *kMSACUpdateAvailableButNotTargetingBinary;
extern NSString const *kMSACUpdateFailedToCreateUpdateMetadataFileErrorDesc;
extern NSString const *kMSACSignatureVerificationNoContentHashErrorDesc;
extern NSString const *kMSACSignatureVerificationNoSignatureDefErrorDesc;
extern NSString const *kMSACSignatureVerificationIntegrityCheckErrorDesc;
extern NSString const *kMSACSignatureVerificationCodeSigningCheckErrorDesc;
extern NSString *kMSACSignatureVerificationNoSignatureErrorDesc(NSString *signatureFilePath);
extern NSString *kMSACDownloadPackageErrorDesc(NSString *downloadUrl);
extern NSString *kMSACDownloadPackageStatusCodeErrorDesc(NSString *downloadUrl, long statusCode);
extern NSString *kMSACDeleteFileErrorDesc(NSString *filePath);
extern NSString *kMSACCreateFileErrorDesc(NSString *filePath);
extern NSString *kMSACMoveFileErrorDesc(NSString *src, NSString *dest);
extern NSString *kMSACCopyFileErrorDesc(NSString *src, NSString *dest);
extern NSString *kMSACUnzipFileErrorDesc(NSString *filePath, NSString *dest);
extern NSString *kMSACNoDirFileErrorDesc(NSString *filePath);
        
#pragma mark - Error keys
extern NSString const *kMSACDownloadCodeErrorKey;
extern NSString const *kMSACParseErrorKey;
extern NSString const *kMSACUpdateErrorKey;
extern NSString const *kMSACSignatureVerificationErrorKey;
extern NSString const *kMSACFileErrorKey;
NS_ASSUME_NONNULL_END
