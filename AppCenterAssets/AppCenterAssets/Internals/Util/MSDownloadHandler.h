#import "MSDownloadPackageResult.h"


/**
* Callback to be invoked when execution finished (successfully or not).
*
* @param downloadResult result of the download (`nil` in case of error).
* @param error error if occurred (`nil` if download successful).
*/
typedef void (^MSDownloadCompletionHandler)(MSDownloadPackageResult *downloadResult, NSError *error);


/**
 Callback to be invoked on download progress.

 @param received bytes received.
 @param total total bytes to be received.
 */
typedef void (^MSDownloadProgressHandler)(long long received, long long total);

@interface MSDownloadHandler : NSObject <NSURLSessionDataDelegate>

@property (strong) NSOutputStream *outputFileStream;
@property (copy) NSString *downloadFilePath;
@property long long expectedContentLength;
@property long long receivedContentLength;
@property dispatch_queue_t operationQueue;
@property (copy) MSDownloadCompletionHandler completionHandler;
@property (copy) MSDownloadProgressHandler progressCallback;
@property NSString *downloadUrl;

/**
* Initializes the download handler and saves all the necessary data for the work.
*
* @param downloadFilePath path for the file to be saved to.
* @param operationQueue queue to be executed on.
* @param progressCallback callback for download progress.
* @param completionHandler callback to be invoked when execution finished (successfully or not).
* @return instance of `MSDownloadHandler`.
*/
- (id)init:(NSString *)downloadFilePath
operationQueue:(dispatch_queue_t)operationQueue
progressCallback:(MSDownloadProgressHandler)progressCallback
doneCallback:(MSDownloadCompletionHandler)completionHandler;

/**
* Downloads the file.
*
* @param url url to download from.
*/
- (void)download:(NSString*)url;

@end
