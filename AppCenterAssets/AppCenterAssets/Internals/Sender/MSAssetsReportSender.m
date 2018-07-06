#import "MSAppCenter.h"
#import "MSAppCenterInternal.h"
#import "MSAssetsReportSender.h"
#import "MSHttpSenderPrivate.h"
#import "MSLoggerInternal.h"
#import "MSAssetsDeploymentStatusReport.h"
#import "MSAssetsDownloadStatusReport.h"
#import "MSAssetsReportType.h"

@implementation MSAssetsReportSender {
    MsAssetsReportType _reportType;
}

- (id)initWithBaseUrl:(NSString *)baseUrl reportType:(MsAssetsReportType)reportType{
    self = [super initWithBaseUrl:baseUrl
                          apiPath:@""
                          headers:@{kMSHeaderContentTypeKey : kMSContentType}
                     queryStrings:nil
                     reachability:[MS_Reachability reachabilityForInternetConnection]
                   retryIntervals:@[ @(10), @(5 * 60), @(20 * 60)]];
    _reportType = reportType;
    return self;
}

- (NSURLRequest *)createRequest:(NSObject *)data {
    NSObject <MSSerializableObject> *container = _reportType == MsAssetsReportTypeDownload ? (MSAssetsDownloadStatusReport *)data : (MSAssetsDeploymentStatusReport *)data;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.sendURL];
    
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = self.httpHeaders;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[container serializeToDictionary] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    request.HTTPBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    return request;
}

@end
