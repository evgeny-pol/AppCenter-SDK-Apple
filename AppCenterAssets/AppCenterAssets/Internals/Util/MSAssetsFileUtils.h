#import <Foundation/Foundation.h>

@interface MSAssetsFileUtils : NSObject

/**
 * Appends file path with one more component.
 *
 * @param path      base path.
 * @param component path component to be appended to the base path.
 * @return new path.
 */
+ (NSString *)appendComponent:(NSString *)component toPath:(NSString *)path;

/**
 * Gets files from archive.
 *
 * @param path path to zip-archive.
 * @param destination path for the unzipped files to be saved.
 * @return A flag indicating success or fail.
 */
+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination;


/**
 * Copies the contents of one directory to another. Copies all the contents recursively.
 *
 * @param sourceDir path to the directory to copy files from.
 * @param destDir   path to the directory to copy files to.
 * @return A flag indicating success or fail.
 */
+ (BOOL)copyDirectoryContents:(NSString *)sourceDir toDestination:(NSString *)destDir;


/**
 * Moves file from one folder to another.
 *
 * @param fileToMove  path to the file to be moved.
 * @param newFolder   path to be moved to.
 * @param newFileName new name for the file to be moved.
 * @return YES if success, NO if failed.
 */
+ (BOOL)moveFile:(NSString *)fileToMove toFolder:(NSString *)newFolder withNewName:(NSString*)newFileName;

@end
