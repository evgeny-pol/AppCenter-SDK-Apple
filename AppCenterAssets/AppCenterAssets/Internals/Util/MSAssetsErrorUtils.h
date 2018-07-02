#import <Foundation/Foundation.h>

@interface MSAssetsErrorUtils : NSObject

+ (NSError *)getNoDirError:(NSString *)folderPath;
+ (NSError *)getFileDeleteError:(NSString *)filePath;
+ (NSError *)getNoSignatureError:(NSString *)signaturePath;
+ (NSError *)getDownloadPackageError:(NSString *)downloadUrl statusCode:(NSInteger)statusCode;
+ (NSError *)getDownloadPackageError:(NSString *)downloadUrl;
+ (NSError *)getNoContentHashError;
+ (NSError *)getUpdateParseError;
+ (NSError *)getUpdateError:(NSString *)errorString;
@end
