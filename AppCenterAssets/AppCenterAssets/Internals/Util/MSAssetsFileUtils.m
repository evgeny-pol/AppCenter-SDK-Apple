#import "MSAssetsFileUtils.h"
#import "SSZipArchive.h"
#import "MSLogger.h"
#import "MSAssets.h"

@implementation MSAssetsFileUtils



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
+ (BOOL)copyDirectoryContentsFrom:(NSString *)sourceDir to:(NSString *)destDir {
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
                return [self copyDirectoryContentsFrom:[sourceDir stringByAppendingPathComponent:currentFile]
                                                    to:[destDir stringByAppendingPathComponent:currentFile]];
            }
        }
    }

    return YES;
}

+ (BOOL)moveFile:(NSString *)fileToMove toFolder:(NSString *)newFolder withNewName:(NSString*)newFileName {
    BOOL isDir;
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!([fileManager fileExistsAtPath:newFolder isDirectory:&isDir] && isDir)) {
        if (![fileManager createDirectoryAtPath:newFolder withIntermediateDirectories:NO attributes:nil error:&error]) {
            MSLogInfo([MSAssets logTag], @"Can't move file from, unable to create directory: %@", newFolder);
            return NO;
        }
    }

    NSString *newFilePath = [newFolder stringByAppendingPathComponent:newFileName];
    if (![fileManager moveItemAtPath:fileToMove toPath:newFilePath error:&error]) {
        MSLogInfo([MSAssets logTag], @"Can't move file from %@ to %@", fileToMove, newFilePath);
        return NO;
    }
    return YES;
}

+ (NSString *)readFileToString:(NSString *)filePath {
    BOOL isDir;
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && !isDir) {
        return [NSString stringWithContentsOfFile:filePath encoding:NSUnicodeStringEncoding error:&error];
    } else {
        MSLogInfo([MSAssets logTag], @"Can't read to string file %@", filePath);
        return nil;
    }
}

+ (BOOL)writeString:(NSString *)content ToFile:(NSString *)filePath
{
    NSError *error = nil;
    BOOL succeed = [content writeToFile:filePath
                              atomically:YES encoding:NSUnicodeStringEncoding error:&error];
    if (!succeed) {
        MSLogInfo([MSAssets logTag], @"Can't write string to file %@", filePath);
    }
    return succeed;
}

+ (BOOL)fileAtPathExists:(NSString *)filePath
{
    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && !isDir);
}



@end
