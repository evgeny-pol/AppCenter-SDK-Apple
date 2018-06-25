#import <Foundation/Foundation.h>
#import "MSAssetsPackageInfo.h"

static NSString *const kMSCurrentPackage = @"currentPackage";
static NSString *const kMSPreviousPackage = @"previousPackage";

@implementation MSAssetsPackageInfo

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary) {
        return nil;
    }
    if ((self = [super init])) {
        if (dictionary[kMSPreviousPackage]) {
            self.previousPackage = dictionary[kMSPreviousPackage];
        }
        if (dictionary[kMSCurrentPackage]) {
            self.currentPackage = dictionary[kMSCurrentPackage];
        }
    }
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (self.currentPackage) {
        dict[kMSCurrentPackage] = self.currentPackage;
    }
    if (self.previousPackage) {
        dict[kMSPreviousPackage] = self.previousPackage;
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _currentPackage = [coder decodeObjectForKey:kMSCurrentPackage];
        _previousPackage = [coder decodeObjectForKey:kMSPreviousPackage];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.currentPackage forKey:kMSCurrentPackage];
    [coder encodeObject:self.previousPackage forKey:kMSPreviousPackage];
}

@end
