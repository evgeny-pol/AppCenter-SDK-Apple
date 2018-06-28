#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Domain

extern NSString *const kMSACErrorDomain;
    
#pragma mark - Connection
    
// Error codes
NS_ENUM(NSInteger){kMSACQueryUpdateErrorCode = 100, kMSACQueryUpdateParseErrorCode = 101, kMSACDownloadPackageErrorCode = 102};
        
// Error descriptions
extern NSString const *kMSACQueryUpdateErrorDesc;
extern NSString const *kMSACQueryUpdateParseErrorDesc;
extern NSString *kMSACDownloadPackageErrorDesc(NSString *downloadUrl);
extern NSString *kMSACDownloadPackageStatusCodeErrorDesc(NSString *downloadUrl, long statusCode);
        
// Error user info keys
extern NSString const *kMSACConnectionHttpCodeErrorKey;
extern NSString const *kMSACConnectionParseErrorKey;
NS_ASSUME_NONNULL_END
