#import <Foundation/Foundation.h>

#import "MSAppCenterInternal.h"
#import "MSLogger.h"
#import "MSUtility+File.h"
#import "SSZipArchive.h"

/*
 * Workaround for exporting symbols from category object files.
 */
NSString *MSUtilityFileCategory;

/**
 * Bundle identifier, used for storage directories.
 */
static NSString *const kMSAppCenterBundleIdentifier = @"com.microsoft.appcenter";

@implementation MSUtility (File)

+ (NSURL *)createFileAtPathComponent:(NSString *)filePathComponent
                            withData:(NSData *)data
                          atomically:(BOOL)atomically
                      forceOverwrite:(BOOL)forceOverwrite {
  @synchronized(self) {
    if (filePathComponent) {
      NSURL *fileURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:filePathComponent];

      // Check if item already exists.
      if (!forceOverwrite && [fileURL checkResourceIsReachableAndReturnError:nil]) {
        return fileURL;
      }

      // Create parent directories as needed.
      NSURL *directoryURL = [fileURL URLByDeletingLastPathComponent];
      if (![directoryURL checkResourceIsReachableAndReturnError:nil]) {
        [self createDirectoryAtURL:directoryURL];
      }

      // Create the file.
      NSData *theData = (data != nil) ? data : [NSData data];
      if ([theData writeToURL:fileURL atomically:atomically]) {
        return fileURL;
      } else {
        MSLogError([MSAppCenter logTag], @"Couldn't create new file at path %@", fileURL);
      }
    }
    return nil;
  }
}

+ (BOOL)deleteItemForPathComponent:(NSString *)itemPathComponent {
  @synchronized(self) {
    if (itemPathComponent) {
      NSURL *itemURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:itemPathComponent];
      NSError *error = nil;
      BOOL succeeded;
      succeeded = [[NSFileManager defaultManager] removeItemAtURL:itemURL error:&error];
      if (error) {
        MSLogError([MSAppCenter logTag], @"Couldn't remove item at %@: %@", itemURL, error.localizedDescription);
      }
      return succeeded;
    }
    return NO;
  }
}

// TODO: We should remove this and just expose the method taking a pathComponent.
+ (BOOL)deleteFileAtURL:(NSURL *)fileURL {
  @synchronized(self) {
    if (fileURL && [fileURL checkResourceIsReachableAndReturnError:nil]) {
      NSError *error = nil;
      BOOL succeeded;
      succeeded = [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
      if (error) {
        MSLogError([MSAppCenter logTag], @"Couldn't remove item at %@: %@", fileURL, error.localizedDescription);
      }
      return succeeded;
    }
    return NO;
  }
}

+ (NSURL *)createDirectoryForPathComponent:(NSString *)directoryPathComponent {
  @synchronized(self) {
    if (directoryPathComponent) {
      NSURL *subDirURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:directoryPathComponent];
      BOOL success = [self createDirectoryAtURL:subDirURL];
      return success ? subDirURL : nil;
    }
    return nil;
  }
}

+ (NSURL *)createDirectoryForPathComponent:(NSString *)directoryPathComponent inPath:(NSString *)path{
    @synchronized(self) {
        if (directoryPathComponent && path) {
            NSURL *pathURL = [NSURL URLWithString:path];
            NSURL *subDirURL = [pathURL URLByAppendingPathComponent:directoryPathComponent];
            BOOL success = [self createDirectoryAtURL:subDirURL];
            return success ? subDirURL : nil;
        }
        return nil;
    }
}

+ (NSData *)loadDataForPathComponent:(NSString *)filePathComponent {
  @synchronized(self) {
    if (filePathComponent) {
      NSURL *fileURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:filePathComponent];
      return [NSData dataWithContentsOfURL:fileURL];
    }
    return nil;
  }
}

/**
 * TODO candidate for refactoring. Should return pathComponents and not full URLs.
 * Has big impact on crashes logic.
 */
+ (NSArray<NSURL *> *)contentsOfDirectory:(NSString *)directory propertiesForKeys:(NSArray *)propertiesForKeys {
  @synchronized(self) {
    if (directory && directory.length > 0) {
      NSFileManager *fileManager = [NSFileManager new];
      NSError *error = nil;
      NSURL *dirURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:directory isDirectory:YES];
      NSArray *files = [fileManager contentsOfDirectoryAtURL:dirURL
                                  includingPropertiesForKeys:propertiesForKeys
                                                     options:(NSDirectoryEnumerationOptions)0
                                                       error:&error];
      if (!files) {
        MSLogError([MSAppCenter logTag], @"Couldn't get files in the directory \"%@\": %@", directory,
                   error.localizedDescription);
      }
      return files;
    }
    return nil;
  }
}

+ (BOOL)fileExistsForPathComponent:(NSString *)filePathComponent {
  {
    NSURL *fileURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:filePathComponent];
    return [fileURL checkResourceIsReachableAndReturnError:nil];
  }
}

+ (BOOL)fileExistsForPathComponent:(NSString *)filePathComponent inPath:(NSString *)path {
    {
        NSURL *pathURL = [NSURL URLWithString:path];
        NSURL *fileURL = [pathURL URLByAppendingPathComponent:filePathComponent];
        return [fileURL checkResourceIsReachableAndReturnError:nil];
    }
}

+ (NSURL *)fullURLForPathComponent:(NSString *)filePathComponent {
  {
    if (filePathComponent) {
      return [[self appCenterDirectoryURL] URLByAppendingPathComponent:filePathComponent];
    }
    return nil;
  }
}

+ (NSURL *)appCenterDirectoryURL {
  static NSURL *dirURL = nil;
  static dispatch_once_t predFilesDir;
  dispatch_once(&predFilesDir, ^{

#if TARGET_OS_TV
    NSSearchPathDirectory directory = NSCachesDirectory;
#else
    NSSearchPathDirectory directory = NSApplicationSupportDirectory;
#endif

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray<NSURL *> *urls = [fileManager URLsForDirectory:directory inDomains:NSUserDomainMask];
    NSURL *baseDirUrl = [urls objectAtIndex:0];

#if TARGET_OS_OSX

    // Use the application's bundle identifier for macOS to make sure to use separate directories for each app.
    NSString *bundleIdentifier = [NSString stringWithFormat:@"%@/", [MS_APP_MAIN_BUNDLE bundleIdentifier]];
    dirURL = [[baseDirUrl URLByAppendingPathComponent:bundleIdentifier]
        URLByAppendingPathComponent:kMSAppCenterBundleIdentifier];
#else
    dirURL = [baseDirUrl URLByAppendingPathComponent:kMSAppCenterBundleIdentifier];
#endif
    if (![dirURL checkResourceIsReachableAndReturnError:nil]) {
      [self createDirectoryAtURL:dirURL];
    }
  });

  return dirURL;
}

+ (BOOL)createDirectoryAtURL:(NSURL *)fullDirURL {
  if (fullDirURL) {
    if ([fullDirURL checkResourceIsReachableAndReturnError:nil]) {
      return YES;
    }

    // Create directory also create parent directories if they don't exist.
    NSError *error = nil;
    if ([[NSFileManager defaultManager] createDirectoryAtURL:fullDirURL
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:&error]) {
      [self disableBackupForDirectoryURL:fullDirURL];
      return YES;
    } else {
      MSLogError([MSAppCenter logTag], @"Couldn't create directory at %@: %@", fullDirURL, error.localizedDescription);
    }
  }
  return NO;
}

#pragma mark - Private methods.


+ (BOOL)disableBackupForDirectoryURL:(nonnull NSURL *)directoryURL {
  NSError *error = nil;

  // SDK files shouldn't be backed up in iCloud.
  if (!directoryURL || ![directoryURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error]) {
    MSLogError([MSAppCenter logTag], @"Error excluding %@ from iCloud backup %@", directoryURL,
               error.localizedDescription);
    return NO;
  } else {
    return YES;
  }
}

+ (BOOL)unzipFileAtPathComponent:(NSString *)pathComponent toPathComponent:(NSString *)destination {
    NSURL *sourceFileURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:pathComponent];
    if (!sourceFileURL) {
        return NO;
    }
    NSURL *destinationFileURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:destination];
    if (!destinationFileURL) {
        return NO;
    }
    return [SSZipArchive unzipFileAtPath:[sourceFileURL path]
                           toDestination:[destinationFileURL path]];
}

+ (BOOL)copyDirectoryContentsFromPathComponent:(NSString *)sourceDir toPathComponent:(NSString *)destDir {
    if (![MSUtility fileExistsForPathComponent:sourceDir]) {
        MSLogInfo([MSAppCenter logTag], @"Error copying item at path %@ to path %@. Source path does not exist.", sourceDir, destDir);
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    NSURL *fullUrl = [[self appCenterDirectoryURL] URLByAppendingPathComponent:destDir];
    NSString *fullPath;
    if (!(fullPath = [fullUrl path]) || !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir)) {
        if (![MSUtility createDirectoryAtURL:fullUrl]) {
            MSLogInfo([MSAppCenter logTag], @"Error copying item at path %@ to path %@. Error creating destination directory.", sourceDir, destDir);
            return NO;
        }
    }
    
    NSArray<NSURL *> *sourceFiles = [MSUtility contentsOfDirectory:sourceDir propertiesForKeys:nil];
    for (NSURL *currentFile in sourceFiles) {
        NSString *fileName = [currentFile lastPathComponent];
        if ([MSUtility fileExistsForPathComponent:[sourceDir stringByAppendingPathComponent:fileName]]) {
            if (![currentFile hasDirectoryPath]) {
                NSError *error;
                NSString *fromPath = [sourceDir stringByAppendingPathComponent:fileName];
                NSString *toPath = [destDir stringByAppendingPathComponent:fileName];
                NSURL *sourceFileURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:fromPath];
                NSURL *destFileURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:toPath];
                NSString *fullFromPath;
                NSString *fullDestPath;
                if (!sourceFileURL || !(fullFromPath = [sourceFileURL path]) || !destFileURL || !(fullDestPath = [destFileURL path])) {
                    MSLogInfo([MSAppCenter logTag], @"Error copying item at path %@ to path %@. %@", fromPath, toPath, [error localizedDescription]);
                    return NO;
                }
                if ([MSUtility fileExistsForPathComponent:toPath]) {
                    [MSUtility deleteItemForPathComponent:toPath];
                }
                if (![fileManager copyItemAtPath:fullFromPath toPath:fullDestPath error:&error]) {
                    MSLogInfo([MSAppCenter logTag], @"Error copying item at path %@ to path %@. %@", fromPath, toPath, [error localizedDescription]);
                    return NO;
                }
            }
            else {
                [MSUtility copyDirectoryContentsFromPathComponent:[sourceDir stringByAppendingPathComponent:fileName]
                                                    toPathComponent:[destDir stringByAppendingPathComponent:fileName]];
            }
        }
    }
    return YES;
}


+ (BOOL)moveFile:(NSString *)fileToMove toFolder:(NSString *)newFolder withNewName:(NSString*)newFileName {
    NSURL *fullUrl = [[self appCenterDirectoryURL] URLByAppendingPathComponent:newFolder];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!([MSUtility fileExistsForPathComponent:newFolder] && [fullUrl hasDirectoryPath])) {
        if (![MSUtility createDirectoryAtURL:fullUrl]) {
            MSLogInfo([MSAppCenter logTag], @"Error moving item at path %@ to path %@. Error creating destination directory.", fileToMove, newFolder);
            return NO;
        }
    }
    
    NSString *newFilePath = [newFolder stringByAppendingPathComponent:newFileName];
    NSError *error;
    NSURL *sourceFileURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:fileToMove];
    NSURL *destURL = [[self appCenterDirectoryURL] URLByAppendingPathComponent:newFilePath];
    NSString *fullSourceFilePath;
    NSString *fullDestPath;
    if (!sourceFileURL || !(fullSourceFilePath = [sourceFileURL path]) || !destURL || !(fullDestPath = [destURL path])) {
        MSLogInfo([MSAppCenter logTag], @"Error moving item at path %@ to path %@. %@", fileToMove, newFilePath, [error localizedDescription]);
        return NO;
    }
    if (![fileManager moveItemAtPath:fullSourceFilePath toPath:fullDestPath error:&error]) {
        MSLogInfo([MSAppCenter logTag], @"Error moving item at path %@ to path %@. %@", fileToMove, newFilePath, [error localizedDescription]);
        return NO;
    }
    return YES;
}

@end
