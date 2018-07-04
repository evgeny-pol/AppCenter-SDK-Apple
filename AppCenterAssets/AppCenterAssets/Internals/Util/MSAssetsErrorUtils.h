#import <Foundation/Foundation.h>

@interface MSAssetsErrorUtils : NSObject

+ (NSError *)getNoDirError:(NSString *)folderPath;
+ (NSError *)getFileDeleteError:(NSString *)filePath;
+ (NSError *)getFileCreateError:(NSString *)filePath;
+ (NSError *)getFileCopyError:(NSString *)src destination:(NSString *)dest;
+ (NSError *)getFileMoveError:(NSString *)src destination:(NSString *)dest;
+ (NSError *)getFileUnzipError:(NSString *)filePath destination:(NSString *)dest;
+ (NSError *)getNoSignatureError:(NSString *)signaturePath;
+ (NSError *)getNoSignatureError;
+ (NSError *)getDownloadPackageError:(NSString *)downloadUrl statusCode:(NSInteger)statusCode;
+ (NSError *)getDownloadPackageError:(NSString *)downloadUrl;
+ (NSError *)getNoContentHashError;
+ (NSError *)getUpdateParseError;
+ (NSError *)getUpdateError:(NSString *)errorString;
+ (NSError *)getUpdateNotTargetingBinaryError;
+ (NSError *)getUpdateMetadataFailToCreateError;
+ (NSError *)getIntegrityCheckError;
+ (NSError *)getCodeSigningCheckError;
+ (NSError *)getNoPackageHashToInstallError;
+ (NSError *)getUpdatePackageInfoError;
@end
