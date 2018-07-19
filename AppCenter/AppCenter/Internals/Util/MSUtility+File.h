#import <Foundation/Foundation.h>

#import "MSUtility.h"

/*
 * Workaround for exporting symbols from category object files.
 */
extern NSString *MSUtilityFileCategory;

/**
 * Utility class that is used throughout the SDK.
 * File part.
 */
@interface MSUtility (File)

/**
 * Creates a file inside the app center sdk's file directory, intermediate directories are also create if nonexistent.
 *
 * @param filePathComponent A string representing the path of the file to create.
 * @param data The data to write to the file.
 * @param atomically Flag to indicate atomic write or not.
 * @param forceOverwrite Flag to make this method overwrite existing files.
 *
 * @return The URL of the file that was created. Necessary for e.g. crash buffer.
 *
 * @discussion SDK files should not be backed up in iCloud. Thus, iCloud backup is explicitely
 * deactivated on every folder created.
 */
+ (NSURL *)createFileAtPathComponent:(NSString *)filePathComponent
                            withData:(NSData *)data
                          atomically:(BOOL)atomically
                      forceOverwrite:(BOOL)forceOverwrite;

/**
 * Removes the file or directory specified inside the app center sdk directory.
 *
 * @param itemPathComponent A string representing the path of the file to delete.
 *
 * @return YES if the item was removed successfully or if URL was nil. Returns NO if an error occurred.
 */
+ (BOOL)deleteItemForPathComponent:(NSString *)itemPathComponent;

/**
 * Creates a directory inside the app center sdk's file directory, intermediate directories are also created if
 * nonexistent.
 *
 * @param directoryPathComponent A string representing the path of the directory to create.
 *
 * @return `YES` if the operation was successful or if the item already exists, otherwise `NO`.
 *
 * @discussion SDK files should not be backed up in iCloud. Thus, iCloud backup is explicitely
 * deactivated on every folder created.
 */
+ (NSURL *)createDirectoryForPathComponent:(NSString *)directoryPathComponent;

/**
 * Load a data at a filePathComponent, e.g. load data at "/Crashes/foo.bar".
 *
 * @param filePathComponent A string representing the pathComponent of the file to read.
 *
 * @return The data of the file or `nil` if the file does not exist.
 */
+ (NSData *)loadDataForPathComponent:(NSString *)filePathComponent;

/**
 * Returns the NSURLs of the contents of a directory.
 *
 * @param directory A string representing the path of the directory to look for content.
 *
 * @return An array of NSURL* of each file or directory in a directory.
 */
+ (NSArray<NSURL *> *)contentsOfDirectory:(NSString *)directory propertiesForKeys:(NSArray *)propertiesForKeys;

/**
 * Checks for existence of a path component.
 *
 * @param filePathComponent The path component to check.
 *
 * @return `YES` if a file or existence exists at the specified location. Otherwiese `NO`.
 */
+ (BOOL)fileExistsForPathComponent:(NSString *)filePathComponent;

/**
 * Removes a file at the given URL if it exists.
 *
 * @param fileURL The URL of the file to delete.
 *
 * @return A flag indicating success or fail.
 */
+ (BOOL)deleteFileAtURL:(NSURL *)fileURL;

/**
 * Get the full path for a component if it exists.
 *
 * @param filePathComponent A string representing the path component of the file or directory to check.
 *
 * @return The URL for the given path component or `nil`.
 */
+ (NSURL *)fullURLForPathComponent:(NSString *)filePathComponent;

/**
 * Moves file from one folder to another.
 *
 * @param fileToMove  path to the file to be moved.
 * @param newFolder   path to be moved to.
 * @param newFileName new name for the file to be moved.
 * @return a flag indicating success or fail.
 */
+ (BOOL)moveFile:(NSString *)fileToMove toFolder:(NSString *)newFolder withNewName:(NSString*)newFileName;

/**
 * Copies the contents of one directory to another. Copies all the contents recursively.
 *
 * @param sourceDir path to the directory to copy files from.
 * @param destDir   path to the directory to copy files to.
 * @return a flag indicating success or fail.
 */
+ (BOOL)copyDirectoryContentsFromPathComponent:(NSString *)sourceDir toPathComponent:(NSString *)destDir;

/**
 * Gets files from archive.
 *
 * @param pathComponent path to archive.
 * @param destination path for the unzipped files to be saved.
 * @return a flag indicating success or fail.
 */
+ (BOOL)unzipFileAtPathComponent:(NSString *)pathComponent toPathComponent:(NSString *)destination;

/**
 * Get App Center Directory
 *
 * @return App Center Directory URL.
 */
+ (NSURL *)appCenterDirectoryURL;

@end
