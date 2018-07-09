#import "MSAssetsDownloadPackageResult.h"


/**
* Callback to be invoked when execution finished (successfully or not).
*
* @param downloadResult result of the download (`nil` in case of error).
* @param error error if occurred (`nil` if download successful).
*/
typedef void (^MSDownloadCompletionHandler)(MSAssetsDownloadPackageResult *downloadResult, NSError *error);


/**
 Callback to be invoked on download progress.

 @param received bytes received.
 @param total total bytes to be received.
 */
typedef void (^MSDownloadProgressHandler)(long long received, long long total);

@interface MSAssetsDownloadHandler : NSObject <NSURLSessionDataDelegate, NSStreamDelegate>

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
* @param operationQueue queue to be executed on.
* @return instance of `MSAssetsDownloadHandler`.
*/
- (id)initWithOperationQueue:(dispatch_queue_t)operationQueue;

/**
* Downloads the file.
*
* @param url url to download from.
* @param downloadFilePath path for the file to be saved to.
* @param progressCallback callback for download progress.
* @param completionHandler callback to be invoked when execution finished (successfully or not).
*/
- (void)downloadWithUrl:(NSString *)url
                 toPath:(NSString *)downloadFilePath
   withProgressCallback:(MSDownloadProgressHandler)progressCallback
   andCompletionHandler:(MSDownloadCompletionHandler)completionHandler;

@end
