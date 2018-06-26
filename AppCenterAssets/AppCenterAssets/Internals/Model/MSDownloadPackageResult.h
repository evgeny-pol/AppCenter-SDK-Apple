#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"

/**
 * Class representing the downloaded update package.
 */
@interface MSDownloadPackageResult : NSObject <MSSerializableObject>

/**
 * Path to the file containing the update.
 */
@property(nonatomic, copy) NSString *downloadFile;

/**
 * Whether the file is zipped.
 */
@property(nonatomic) BOOL isZip;

@end
