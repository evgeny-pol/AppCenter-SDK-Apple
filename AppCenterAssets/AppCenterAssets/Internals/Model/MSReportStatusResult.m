#import <Foundation/Foundation.h>
#import "MSReportStatusResult.h"

static NSString *const kMSResult = @"result";

@implementation MSReportStatusResult

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (self.result) {
        dict[kMSResult] = self.result;
    }
    return dict;
}
+ (MSReportStatusResult *)createSuccessful:(NSString *)result {
    MSReportStatusResult *statusResult = [[MSReportStatusResult alloc] init];
    [statusResult setResult:result];
    return statusResult;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _result = [coder decodeObjectForKey:kMSResult];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.result forKey:kMSResult];
}

@end
