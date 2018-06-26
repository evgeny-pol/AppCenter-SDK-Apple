#import <Foundation/Foundation.h>
#import "MSDownloadPackageResult.h"

static NSString *const kMSDownloadFile = @"downloadFile";
static NSString *const kMSisZip = @"isZip";

@implementation MSDownloadPackageResult

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    dict[kMSisZip] = @(self.isZip);
    if (self.downloadFile) {
        dict[kMSDownloadFile] = self.downloadFile;
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _downloadFile = [coder decodeObjectForKey:kMSDownloadFile];
        _isZip = [coder decodeBoolForKey:kMSisZip];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.downloadFile forKey:kMSDownloadFile];
    [coder encodeBool:self.isZip forKey:kMSisZip];
}

@end
