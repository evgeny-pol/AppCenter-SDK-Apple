#import <Foundation/Foundation.h>
#import "MSDownloadStatusReport.h"
#import "MSAssetsIllegalArgumentException.h"

static NSString *const kMSClientUniqueId = @"clientUniqueId";
static NSString *const kMSDeploymentKey = @"deploymentKey";
static NSString *const kMSLabel = @"label";

@implementation MSDownloadStatusReport

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (self.clientUniqueId) {
        dict[kMSClientUniqueId] = self.clientUniqueId;
    }
    if (self.deploymentKey) {
        dict[kMSDeploymentKey] = self.deploymentKey;
    }
    if (self.label) {
        dict[kMSLabel] = self.label;
    }
    return dict;
}

+ (nonnull MSDownloadStatusReport *)createReportWithLabel:(nonnull NSString *)label
                                                 deviceId:(nonnull NSString *)clientUniqueId
                                         andDeploymentKey:(nonnull NSString *) deploymentKey {
    MSDownloadStatusReport *report = [[MSDownloadStatusReport alloc] init];
    if (clientUniqueId != nil) {
        [report setClientUniqueId:clientUniqueId];
    } else {
        @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSDownloadStatusReport.class) argument:kMSClientUniqueId];
    }
    if (deploymentKey != nil) {
        [report setDeploymentKey:deploymentKey];
    } else {
        @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSDownloadStatusReport.class) argument:kMSDeploymentKey];
    }
    if (label != nil) {
        [report setLabel:label];
    } else {
        @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSDownloadStatusReport.class) argument:kMSLabel];
    }
    return report;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        NSString *label = [coder decodeObjectForKey:kMSLabel];
        if (label != nil) {
            _label = label;
        } else {
            @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSDownloadStatusReport.class) argument:kMSLabel];
        }
        NSString *deploymentKey = [coder decodeObjectForKey:kMSDeploymentKey];
        if (deploymentKey != nil) {
            _deploymentKey = deploymentKey;
        } else {
            @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSDownloadStatusReport.class) argument:kMSDeploymentKey];
        }
        NSString *clientId = [coder decodeObjectForKey:kMSClientUniqueId];
        if (clientId != nil) {
            _clientUniqueId = clientId;
        } else {
            @throw [[MSAssetsIllegalArgumentException alloc] initWithClass:NSStringFromClass(MSDownloadStatusReport.class) argument:kMSClientUniqueId];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.clientUniqueId forKey:kMSClientUniqueId];
    [coder encodeObject:self.label forKey:kMSLabel];
    [coder encodeObject:self.deploymentKey forKey:kMSDeploymentKey];
}

@end


