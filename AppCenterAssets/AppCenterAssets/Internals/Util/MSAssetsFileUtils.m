#import "MSAssetsFileUtils.h"
#import "SSZipArchive.h"
#import "MSLogger.h"
#import "MSAssets.h"

@implementation MSAssetsFileUtils


+ (NSString *)appendComponent:(NSString *)component toPath:(NSString *)path
{
    NSString *result = [path copy];
    if (![result hasSuffix:@"/"])
        result = [result stringByAppendingString:@"/"];
    result = [result stringByAppendingString:component];
    return result;
}


+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination {
    return [SSZipArchive unzipFileAtPath:path
                           toDestination:destination];
}


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
    NSString *newFilePath = [self appendComponent:newFolder toPath:newFileName];
    if (![fileManager moveItemAtPath:fileToMove toPath:newFilePath error:&error]) {
        MSLogInfo([MSAssets logTag], @"Can't move file from %@ to %@", fileToMove, newFilePath);
        return NO;
    }
    return YES;
}


@end
