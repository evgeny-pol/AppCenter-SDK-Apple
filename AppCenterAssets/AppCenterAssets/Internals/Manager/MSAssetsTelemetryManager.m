#import "MSAssetsTelemetryManager.h"
#import "MSLocalPackage.h"
#import "MSAssetsPackage.h"
#import "MSDeploymentStatusReport.h"
#import "MSAssetsStatusReportIdentifier.h"

@interface MSAssetsTelemetryManager ()

// Private Access
@property MSAssetsSettingManager *settingManager;

@end


@implementation MSAssetsTelemetryManager

- (id)initWithSettingManager: (MSAssetsSettingManager *)settingManager {
    self = [super init];
    if (self) {
        self.settingManager = settingManager;
    }
    return self;
}

- (MSDeploymentStatusReport *)buildBinaryUpdateReportWithAppVersion:(NSString * _Nonnull)appVersion {
    MSAssetsStatusReportIdentifier *previousStatusReportIdentifier = [[self settingManager] getPreviousStatusReportIdentifier];
    MSDeploymentStatusReport *report = nil;
    if (previousStatusReportIdentifier == nil) {
        
        /* There was no previous status report */
        report = [MSDeploymentStatusReport new];
        [report setAppVersion:appVersion];
        [report setLabel:@""];
        [report setStatus:MSAssetsDeploymentStatusSucceeded];
    } else {
        BOOL identifierHasDeploymentKey = [previousStatusReportIdentifier hasDeploymentKey];
        NSString *identifierLabel = [previousStatusReportIdentifier versionLabelOrEmpty];
        if (identifierHasDeploymentKey || ![identifierLabel isEqualToString:appVersion]) {
            report = [MSDeploymentStatusReport new];
            if (identifierHasDeploymentKey) {
                NSString *previousDeploymentKey = [previousStatusReportIdentifier deploymentKey];
                NSString *previousLabel = [previousStatusReportIdentifier versionLabel];
                report = [MSDeploymentStatusReport new];
                [report setAppVersion:appVersion];
                [report setPreviousDeploymentKey:previousDeploymentKey];
                [report setPreviousLabelOrAppVersion:previousLabel];
            } else {
                
                /* Previous status report was with a binary app version. */
                [report setAppVersion:appVersion];
                [report setPreviousLabelOrAppVersion:[previousStatusReportIdentifier versionLabel]];
            }
        }
    }
    return report;
}

- (MSDeploymentStatusReport *)buildUpdateReportWithPackage:(MSAssetsPackage * _Nonnull)currentPackage {
    MSAssetsStatusReportIdentifier *currentPackageIdentifier = [self  buildPackageStatusReportIdentifier:currentPackage];
    MSAssetsStatusReportIdentifier *previousStatusReportIdentifier = [[self settingManager] getPreviousStatusReportIdentifier];
    MSDeploymentStatusReport *report = nil;
    if (currentPackageIdentifier != nil) {
        if (previousStatusReportIdentifier == nil) {
            report = [MSDeploymentStatusReport new];
            [report setAssetsPackage:currentPackage];
            [report setStatus:MSAssetsDeploymentStatusSucceeded];
        } else {
            
            /* Compare identifiers as strings for simplicity */
            if (![[previousStatusReportIdentifier toString] isEqualToString:[currentPackageIdentifier toString]]) {
                report = [MSDeploymentStatusReport new];
                if ([previousStatusReportIdentifier hasDeploymentKey]) {
                    NSString *previousDeploymentKey = [previousStatusReportIdentifier deploymentKey];
                    NSString *previousLabel = [previousStatusReportIdentifier versionLabel];
                    [report setAssetsPackage:currentPackage];
                    [report setStatus:MSAssetsDeploymentStatusSucceeded];
                    [report setPreviousDeploymentKey:previousDeploymentKey];
                    [report setPreviousLabelOrAppVersion:previousLabel];
                } else {
                    
                    /* Previous status report was with a binary app version. */
                    [report setAssetsPackage:currentPackage];
                    [report setStatus:MSAssetsDeploymentStatusSucceeded];
                    [report setPreviousLabelOrAppVersion:[previousStatusReportIdentifier versionLabel]];
                }
            }
        }
    }

    return report;
}

- (MSAssetsStatusReportIdentifier *)buildPackageStatusReportIdentifier:(MSAssetsPackage *)updatePackage {
    
    /* Because deploymentKeys can be dynamically switched, we use a
     combination of the deploymentKey and label as the packageIdentifier. */
    NSString *deploymentKey = [updatePackage deploymentKey];
    NSString *label = [updatePackage label];
    if (deploymentKey != nil && label != nil) {
        return [[MSAssetsStatusReportIdentifier alloc] initWithAppVersion:label andDeploymentKey:deploymentKey];
    } else {
        return nil;
    }
}

- (MSDeploymentStatusReport *)buildRollbackReportWithFailedPackage:(MSAssetsPackage * _Nonnull)failedPackage {
    MSDeploymentStatusReport *report = [MSDeploymentStatusReport new];
    [report setAssetsPackage:failedPackage];
    [report setStatus:MSAssetsDeploymentStatusFailed];
    return report;
}

@end
