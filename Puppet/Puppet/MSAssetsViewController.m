/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import "MSAssetsViewController.h"
#import "AppCenterAssets.h"

@interface MSAssetsViewController ()

@property (weak, nonatomic) IBOutlet UITextView *updatePathView;
@property (weak, nonatomic) IBOutlet UILabel *syncStatus;
@property (weak, nonatomic) IBOutlet UISwitch *enabled;
@property (weak, nonatomic) IBOutlet UILabel *result;
@property (nonatomic) MSAssetsDeploymentInstance *assetsDeployment;

@end

@implementation MSAssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enabled.on = [MSAssets isEnabled];
    
    NSError *error = nil;
    _assetsDeployment = [MSAssets makeDeploymentInstanceWithBuilder:^(MSAssetsBuilder *builder) {
        [builder setServerUrl:@"https://codepush.azurewebsites.net/"];
    } error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    } else {
        [_assetsDeployment setDelegate:self];
    }
    [self updatePath];
}

- (IBAction)enabledSwitchUpdated:(UISwitch *)sender {
    [MSAssets setEnabled:sender.on];
    sender.on = [MSAssets isEnabled];
}

-(void)sync {
    MSAssetsSyncOptions *syncOptions = [MSAssetsSyncOptions new];
    [syncOptions setDeploymentKey:@"4VnyrkITHiZ6Qroh19nsQkebgfZLSyNJucKym"];
    [syncOptions setUpdateDialog:[MSAssetsUpdateDialog new]];
    [_assetsDeployment sync:syncOptions];
}

-(void)updatePath {
    NSString *path = [_assetsDeployment getCurrentUpdateEntryPoint];
    self.updatePathView.text = path;
}

- (void)checkForUpdate {
    [_assetsDeployment checkForUpdate:@"4VnyrkITHiZ6Qroh19nsQkebgfZLSyNJucKym"];
}

- (void)didReceiveRemotePackageOnCheckForUpdate:(MSAssetsRemotePackage *)package {
    if (!package) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.syncStatus.text = @"No update available";
        });
    } else {
        NSMutableString *info = @"";
        NSMutableDictionary *dict = package.serializeToDictionary;
        for(NSString *key in dict) {
            info = [info stringByAppendingString:key];
            info = [info stringByAppendingString:@":"];
            if ([dict objectForKey:key])
                info = [info stringByAppendingString:[[dict objectForKey:key] description]];
            else
                info = [info stringByAppendingString:@"[no value]"];
            info = [info stringByAppendingString:@"\n"];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check for update results"
                                                            message:info
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (void)didReceiveBytesForPackageDownloadProgress:(long long)receivedBytes totalBytes:(long long)totalBytes {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.result.hidden = false;
        int percentage = (int) (((receivedBytes * 1.0) / totalBytes) * 100);
        if (percentage == 100) {
            self.result.text = @"Package downloaded";
        } else {
            self.result.text = [[NSString alloc] initWithFormat:@"%d %%...", percentage];
        }
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([indexPath section]) {
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    [self checkForUpdate];
                    break;
                }
                case 2:
                    [self sync];
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)syncStatusChanged:(MSAssetsSyncStatus __unused)syncStatus {
    NSString *syncStatusString = @"";
    switch (syncStatus) {
        case MSAssetsSyncStatusUpToDate:
            syncStatusString = @"Up to date";
            break;
        case MSAssetsSyncStatusUnknownError:
            syncStatusString = @"Unknown error";
            break;
        case MSAssetsSyncStatusUpdateIgnored:
            syncStatusString = @"Update ignored";
            break;
        case MSAssetsSyncStatusSyncInProgress:
            syncStatusString = @"Sync in progress";
            break;
        case MSAssetsSyncStatusUpdateInstalled:
            syncStatusString = @"Update installed";
            [self updatePath];
            [_assetsDeployment notifyApplicationReady];
            break;
        case MSAssetsSyncStatusInstallingUpdate:
            syncStatusString = @"Installing update";
            break;
        case MSAssetsSyncStatusCheckingForUpdate:
            syncStatusString = @"Checking for update";
            break;
        case MSAssetsSyncStatusAwaitingUserAction:
            syncStatusString = @"Awaiting user action";
            break;
        case MSAssetsSyncStatusDownloadingPackage:
            syncStatusString = @"Downloading package";
            break;
        default:
            break;
    }
    self.syncStatus.text = syncStatusString;
}

- (void)didFailToQueryRemotePackageOnCheckForUpdate:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.result.text = error.description;
    });
}
@end
