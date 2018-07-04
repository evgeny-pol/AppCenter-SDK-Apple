#import "MSAssetsFileUtils.h"
#import "SSZipArchive.h"
#import "MSLogger.h"
#import "MSAssets.h"

@implementation MSAssetsFileUtils

/**
 * Gets files from archive.
 *
 * @param path path to zip-archive.
 * @param destination path for the unzipped files to be saved.
 * @return YES if success, NO if failed.
*/
+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination {
    return [SSZipArchive unzipFileAtPath:path
                    toDestination:destination];
}

/**
 * Copies the contents of one directory to another. Copies all the contents recursively.
 *
 * @param sourceDir path to the directory to copy files from.
 * @param destDir   path to the directory to copy files to.
 * @return YES if success, NO otherwise.
 */
+ (BOOL)copyDirectoryContents:(NSString *)sourceDir toDestination:(NSString *)destDir {
    BOOL isDir;
    NSError *error = nil;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!([fileManager fileExistsAtPath:destDir isDirectory:&isDir] && isDir)) {
        if (![fileManager createDirectoryAtPath:destDir withIntermediateDirectories:NO attributes:nil error:&error]) {
            MSLogInfo([MSAssets logTag], @"Can't copy, unable to create directory: %@", destDir);
            return NO;
        }
    }

    NSArray *sourceFiles = [fileManager contentsOfDirectoryAtPath:sourceDir error:&error];
    for (NSString *currentFile in sourceFiles) {
        if ([fileManager fileExistsAtPath:currentFile isDirectory:&isDir]) {
            if (!isDir) {
                if (![fileManager copyItemAtPath:[sourceDir stringByAppendingPathComponent:currentFile] toPath:[destDir stringByAppendingPathComponent:currentFile] error:&error]) {
                    MSLogInfo([MSAssets logTag], @"Unable to copy file: %@", [sourceDir stringByAppendingPathComponent:currentFile]);
                    return NO;
                }
            } else {
                return [self copyDirectoryContents:[sourceDir stringByAppendingPathComponent:currentFile] toDestination:[destDir stringByAppendingPathComponent:currentFile]];
            }
        }
    }

    return YES;
}

@end
