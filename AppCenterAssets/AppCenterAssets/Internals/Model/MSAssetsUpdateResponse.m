#import <Foundation/Foundation.h>
#import "MSAssetsUpdateResponse.h"
#import "MSAssetsUpdateResponseUpdateInfo.h"
#import "MSAssetsIllegalArgumentException.h"

static NSString *const kMSUpdateInfo = @"updateInfo";

@implementation MSAssetsUpdateResponse

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (self.updateInfo) {
        dict[kMSUpdateInfo] = [self.updateInfo serializeToDictionary];
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _updateInfo = [coder decodeObjectForKey:kMSUpdateInfo];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.updateInfo forKey:kMSUpdateInfo];
}

@end
