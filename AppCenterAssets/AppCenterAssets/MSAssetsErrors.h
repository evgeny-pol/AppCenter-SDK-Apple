#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Domain

extern NSString *const kMSACErrorDomain;
    
#pragma mark - Connection
    
// Error codes
NS_ENUM(NSInteger){
    kMSACQueryUpdateErrorCode = 100,
    kMSACDownloadPackageErrorCode = 102,
    kMSACSignatureVerificationErrorCode = 103,
    kMSACFileErrorCode = 104
};
        
// Error descriptions
extern NSString const *kMSACQueryUpdateErrorDesc;
extern NSString const *kMSACQueryUpdateParseErrorDesc;
extern NSString const *kMSACSignatureVerificationNoContentHashErrorDesc;
 
extern NSString const *kMSACUpdateAvailableButNotTargetingBinary;

extern NSString *kMSACDownloadPackageErrorDesc(NSString *downloadUrl);
extern NSString *kMSACDownloadPackageStatusCodeErrorDesc(NSString *downloadUrl, long statusCode);
extern NSString *kMSACSignatureVerificationNoSignatureErrorDesc(NSString *signatureFilePath);
extern NSString *kMSACDeleteFileErrorDesc(NSString *filePath);
extern NSString *kMSACNoDirFileErrorDesc(NSString *filePath);
        
// Error user info keys
extern NSString const *kMSACConnectionHttpCodeErrorKey;
extern NSString const *kMSACConnectionParseErrorKey;
extern NSString const *kMSACUpdateErrorKey;
extern NSString const *kMSACSignatureVerificationErrorKey;
extern NSString const *kMSACFileErrorKey;
NS_ASSUME_NONNULL_END
