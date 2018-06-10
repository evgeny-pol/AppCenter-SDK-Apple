#import <Foundation/Foundation.h>

@interface MSDownloadPackageResult

/**
 * Whether the file is zipped.Whether the file is zipped.
 */
@property(nonatomic, copy) NSFileHandle *downloadFile;

/**
 * Whether the file is zipped.
 */
@property(nonatomic, copy) BOOL isZip;

@end
