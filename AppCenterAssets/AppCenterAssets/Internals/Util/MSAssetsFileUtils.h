#import <Foundation/Foundation.h>

@interface MSAssetsFileUtils : NSObject

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination;


/**
 * Copies the contents of one directory to another. Copies all the contents recursively.
 *
 * @param sourceDir path to the directory to copy files from.
 * @param destDir   path to the directory to copy files to.
 */
+ (BOOL)copyDirectoryContents:(NSString *)sourceDir toDestination:(NSString *)destDir;

@end
