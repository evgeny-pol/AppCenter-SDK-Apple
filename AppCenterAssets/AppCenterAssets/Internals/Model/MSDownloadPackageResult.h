#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"

@interface MSDownloadPackageResult : NSObject <MSSerializableObject>

/**
 * Whether the file is zipped.Whether the file is zipped.
 */
@property(nonatomic, copy) NSString *downloadFile;

/**
 * Whether the file is zipped.
 */
@property(nonatomic) BOOL isZip;

@end
