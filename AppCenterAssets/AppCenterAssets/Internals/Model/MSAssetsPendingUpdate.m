#import <Foundation/Foundation.h>
#import "MSAssetsPendingUpdate.h"

static NSString *const kMSIsLoading = @"isLoading";
static NSString *const kMSHash = @"pendingUpdateHash";

@implementation MSAssetsPendingUpdate

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    dict[kMSIsLoading] = self.isLoading ? @"YES" : @"NO";
    if (self.pendingUpdateHash) {
        dict[kMSHash] = self.pendingUpdateHash;
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _pendingUpdateHash = [coder decodeObjectForKey:kMSHash];
        _isLoading = [coder decodeBoolForKey:kMSIsLoading];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.pendingUpdateHash forKey:kMSHash];
    [coder encodeBool:self.isLoading forKey:kMSIsLoading];
}

@end
