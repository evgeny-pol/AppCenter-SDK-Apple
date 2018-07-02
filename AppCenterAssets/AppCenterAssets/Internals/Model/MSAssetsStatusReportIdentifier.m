#import "MSAssetsStatusReportIdentifier.h"

@implementation MSAssetsStatusReportIdentifier

- (instancetype)initWithAppVersion:(NSString *_Nonnull)versionLabel {
    self = [super init];
    if (self) {
        _versionLabel = versionLabel;
    }
    return self;
}

- (instancetype)initWithAppVersion:(NSString *_Nonnull)versionLabel andDeploymentKey:(NSString *)deploymentKey {
    self = [super init];
    if (self) {
        _versionLabel = versionLabel;
        _deploymentKey = deploymentKey;
    }
    return self;
}

+ (MSAssetsStatusReportIdentifier *)reportIdentifierFromString:(NSString *)stringIdentifier {
    NSArray<NSString *> *parsedIdentifier = [stringIdentifier componentsSeparatedByString:@":"];
    if ([parsedIdentifier count] == 1) {
        NSString *versionLabel = parsedIdentifier[0];
        return [[MSAssetsStatusReportIdentifier alloc] initWithAppVersion:versionLabel];
    } else if ([parsedIdentifier count] == 2) {
        NSString *versionLabel = parsedIdentifier[0];
        NSString *deploymentKey = parsedIdentifier[1];
        return [[MSAssetsStatusReportIdentifier alloc] initWithAppVersion:versionLabel andDeploymentKey: deploymentKey];
    } else {
        return nil;
    }
}

- (NSString *)toString {
    if ([self versionLabel] != nil) {
        if ([self deploymentKey] == nil) {
            return [self versionLabel];
        } else {
            return [[NSString alloc] initWithFormat:@"%@:%@", [self deploymentKey], [self versionLabel]];
        }
    } else {
        return nil;
    }
}

- (BOOL)hasDeploymentKey {
    return [self deploymentKey] != nil;
}

- (NSString *)versionLabelOrEmpty {
    return [self versionLabel] == nil ? @"" : [self versionLabel];
}

@end
