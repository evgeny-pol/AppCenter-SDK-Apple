#import "MSAppCenter.h"
#import "MSAppCenterInternal.h"
#import "MSAssetsCheckForUpdate.h"
#import "MSHttpSenderPrivate.h"
#import "MSLoggerInternal.h"

@implementation MSAssetsCheckForUpdate

- (id)initWithBaseUrl:(NSString *)baseUrl queryStrings:(NSDictionary *)queryStrings{
    self = [super initWithBaseUrl:baseUrl
                               apiPath:@""
                               headers:nil
                          queryStrings:queryStrings
                          reachability:[MS_Reachability reachabilityForInternetConnection]
                   retryIntervals:@[]];
    return self;
}

- (NSURLRequest *)createRequest:(NSObject *)data {
    (void)data;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.sendURL];
    request.HTTPMethod = @"GET";
    [request setHTTPShouldHandleCookies:NO];    
    return request;
}

@end
