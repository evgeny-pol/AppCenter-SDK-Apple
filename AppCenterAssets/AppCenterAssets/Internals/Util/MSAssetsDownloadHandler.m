#import "MSAssetsDownloadHandler.h"
#import "MSAssetsDownloadPackageResult.h"
#import "MSAssetsErrorUtils.h"

@implementation MSAssetsDownloadHandler {
    // Header chars used to determine if the file is a zip.
    char _header[4];
}

- (id)initWithOperationQueue:(dispatch_queue_t)operationQueue {
    self.receivedContentLength = 0;
    self.operationQueue = operationQueue;
    return self;
}

- (void)downloadWithUrl:(NSString *)url
                  toPath:(NSString *)downloadFilePath
   withProgressCallback:(MSDownloadProgressHandler)progressCallback
   andCompletionHandler:(MSDownloadCompletionHandler)completionHandler {
    self.outputFileStream = [NSOutputStream outputStreamToFileAtPath:downloadFilePath
                                                              append:NO];
    self.downloadUrl = url;
    self.progressCallback = progressCallback;
    self.completionHandler = completionHandler;
    self.downloadFilePath = downloadFilePath;
    NSURL *requestUrl = [NSURL URLWithString:url];
    if (requestUrl != nil) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0];
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *queue = [NSOperationQueue new];
        if ([NSOperationQueue instancesRespondToSelector:@selector(setUnderlyingQueue:)]) {
            queue.underlyingQueue = self.operationQueue;
        }
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
        NSURLSessionDataTask* task = [session dataTaskWithRequest:request];
        [task resume];
    }
}

#pragma mark NSURLSession Delegate Methods

- (void)URLSession:(NSURLSession *) __unused session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition)) completionHandler {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode >= 400) {
            [self.outputFileStream close];
            [dataTask cancel];
            NSError *newError = [MSAssetsErrorUtils getDownloadPackageError:self.downloadUrl statusCode: statusCode];
            if (self.completionHandler != nil) {
                self.completionHandler(nil, newError);
            }
            return;
        }
    }
    
    self.expectedContentLength = response.expectedContentLength;
    [self.outputFileStream open];
    
    // Have to call this is order for the future callbacks to work:
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *) __unused session
          dataTask:(NSURLSessionDataTask *) dataTask
    didReceiveData:(NSData *)data {
    if (self.receivedContentLength < 4) {
        for (int i = 0; i < (int)[data length]; i++) {
            int headerOffset = (int)self.receivedContentLength + i;
            if (headerOffset >= 4) {
                break;
            }
            const char *bytes = [data bytes];
            _header[headerOffset] = bytes[i];
        }
    }
    
    self.receivedContentLength = self.receivedContentLength + [data length];
    
    NSInteger bytesLeft = [data length];
    
    do {
        NSInteger bytesWritten = [self.outputFileStream write:[data bytes]
                                                    maxLength:bytesLeft];
        if (bytesWritten == -1) {
            break;
        }
        bytesLeft -= bytesWritten;
    } while (bytesLeft > 0);
    
    if (self.progressCallback != nil) {
        self.progressCallback(self.expectedContentLength, self.receivedContentLength);
    }
    
    // bytesLeft should not be negative.
    assert(bytesLeft >= 0);
    
    if (bytesLeft) {
        [self.outputFileStream close];
        [dataTask cancel];
        if (self.completionHandler != nil) {
            self.completionHandler(nil, [self.outputFileStream streamError]);
        }
    }
}

- (void)URLSession:(NSURLSession *) __unused session
              task:(NSURLSessionTask *) __unused task
didCompleteWithError:(NSError *)error {
    [self.outputFileStream close];
    if (error != nil) {
        if (self.completionHandler != nil) {
            self.completionHandler(nil, error);
        }
    } else {
        if (self.receivedContentLength < 1) {
            NSError *newError = [MSAssetsErrorUtils getDownloadPackageError:self.downloadUrl];
            if (self.completionHandler != nil) {
                self.completionHandler(nil, newError);
            }
            return;
        }
        
        // expectedContentLength might be -1 when NSURLConnection don't know the length(e.g. response encode with gzip)
        if (self.expectedContentLength > 0) {
            
            // We should have received all of the bytes if this is called.
            assert(self.receivedContentLength == self.expectedContentLength);
        }
        
        BOOL isZip = _header[0] == 'P' && _header[1] == 'K' && _header[2] == 3 && _header[3] == 4;
        MSAssetsDownloadPackageResult *result = [MSAssetsDownloadPackageResult new];
        [result setIsZip:isZip];
        [result setDownloadFile:[self downloadFilePath]];
        if (self.completionHandler != nil) {
            self.completionHandler(result, nil);
        }
    }
}
@end
