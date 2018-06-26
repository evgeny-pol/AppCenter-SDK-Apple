#import <Foundation/Foundation.h>
#import "MSLocalPackage.h"

static NSString *const kMSIsPending = @"isPending";
static NSString *const kMSEntryPoint = @"entryPoint";
static NSString *const kMSIsFirstRun = @"isFirstRun";
static NSString *const kMSIsDebugOnly = @"_isDebugOnly";
static NSString *const kMSBinaryModifiedTime = @"binaryModifiedTime";

@implementation MSLocalPackage

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary) {
        return nil;
    }
    if ((self = [super initWithDictionary:dictionary])) {
        if (dictionary[kMSEntryPoint]) {
            self.entryPoint = dictionary[kMSEntryPoint];
        }
        if (dictionary[kMSBinaryModifiedTime]) {
            self.binaryModifiedTime = dictionary[kMSBinaryModifiedTime];
        }
        if (dictionary[kMSIsPending]) {
            self.isPending = [dictionary[kMSIsPending] isEqual:@YES] ? YES : NO;
        }
        if (dictionary[kMSIsFirstRun]) {
            self.isFirstRun = [dictionary[kMSIsFirstRun] isEqual:@YES] ? YES : NO;
        }
        if (dictionary[kMSIsDebugOnly]) {
            self.isDebugOnly = [dictionary[kMSIsDebugOnly] isEqual:@YES] ? YES : NO;
        }
    }
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [super serializeToDictionary];
    
    dict[kMSIsPending] = @(self.isPending);
    
    if (self.entryPoint) {
        dict[kMSEntryPoint] = self.entryPoint;
    }
    dict[kMSIsFirstRun] = @(self.isFirstRun);
    dict[kMSIsDebugOnly] = @(self.isDebugOnly);
    
    if (self.binaryModifiedTime) {
        dict[kMSBinaryModifiedTime] = self.binaryModifiedTime;
    }
    return dict;
}

+ (MSLocalPackage *)createLocalPackageWithPackage:(MSAssetsPackage *)assetsPackage
                                    failedInstall:(BOOL)failedInstall
                                       isFirstRun:(BOOL)isFirstRun
                                        isPending:(BOOL)isPending
                                      isDebugOnly:(BOOL)isDebugOnly
                                       entryPoint:(NSString *)entryPoint {
    MSLocalPackage *localPackage = [[MSLocalPackage alloc] init];
    [localPackage setAppVersion:[assetsPackage appVersion]];
    [localPackage setDeploymentKey:[assetsPackage deploymentKey]];
    [localPackage setUpdateDescription:[assetsPackage updateDescription]];
    [localPackage setIsMandatory:[assetsPackage isMandatory]];
    [localPackage setLabel:[assetsPackage label]];
    [localPackage setPackageHash:[assetsPackage packageHash]];
    [localPackage setFailedInstall:failedInstall];
    [localPackage setIsPending:isPending];
    [localPackage setIsFirstRun:isFirstRun];
    [localPackage setIsDebugOnly:isDebugOnly];
    [localPackage setEntryPoint:entryPoint];
    return localPackage;
}

+ (MSLocalPackage *)createLocalPackageWithAppVersion:(NSString *)appVersion {
    MSLocalPackage *localPackage = [[MSLocalPackage alloc] init];
    [localPackage setAppVersion:appVersion];
    [localPackage setDeploymentKey:@""];
    [localPackage setUpdateDescription:@""];
    [localPackage setIsMandatory:NO];
    [localPackage setLabel:@""];
    [localPackage setPackageHash:@""];
    [localPackage setFailedInstall:NO];
    [localPackage setIsPending:NO];
    [localPackage setIsFirstRun:NO];
    [localPackage setIsDebugOnly:NO];
    [localPackage setEntryPoint:@""];
    return localPackage;
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _isPending = [coder decodeBoolForKey:kMSIsPending];
        _entryPoint = [coder decodeObjectForKey:kMSEntryPoint];
        _isFirstRun = [coder decodeBoolForKey:kMSIsFirstRun];
        _isDebugOnly = [coder decodeBoolForKey:kMSIsDebugOnly];
        _binaryModifiedTime = [coder decodeObjectForKey:kMSBinaryModifiedTime];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeBool:self.isPending forKey:kMSIsPending];
    [coder encodeObject:self.entryPoint forKey:kMSEntryPoint];
    [coder encodeBool:self.isFirstRun forKey:kMSIsFirstRun];
    [coder encodeBool:self.isDebugOnly forKey:kMSIsDebugOnly];
    [coder encodeObject:self.binaryModifiedTime forKey:kMSBinaryModifiedTime];
}

@end
