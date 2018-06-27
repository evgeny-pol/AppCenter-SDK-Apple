#import "MSDownloadPackageResult.h"

typedef void (^MSDownloadCompletionHandler)(MSDownloadPackageResult *downloadResult, NSError *error);
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

- (id)init:(NSString *)downloadFilePath
operationQueue:(dispatch_queue_t)operationQueue
progressCallback:(MSDownloadProgressHandler)progressCallback
doneCallback:(MSDownloadCompletionHandler)completionHandler;

- (void)download:(NSString*)url;

@end
