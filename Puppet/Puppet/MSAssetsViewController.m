/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import "MSAssetsViewController.h"
#import "AppCenterAssets.h"
#import "MSLogger.h"
#import "MSUtility+File.h"
#import "MSAlertController.h"

#define kDeploymentKey "X0s3Jrpp7TBLmMe5x_UG0b8hf-a8SknGZWL7Q"
#define kDeploymentKey2 "ZeJoy__Sai95nlorTIUaIELCya0eSy-VwNsQ7"


@interface MSAssetsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *updatePathView;
@property (weak, nonatomic) IBOutlet UILabel *updatePathView2;
@property (weak, nonatomic) IBOutlet UILabel *syncStatus;
@property (weak, nonatomic) IBOutlet UISwitch *enabled;
@property (weak, nonatomic) IBOutlet UILabel *result;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellCheckForUpdate;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellCheckForUpdate2;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDownloadStatus;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSync;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSync2;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSyncStatus;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellUpdatePath;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellUpdatePath2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;


@property (nonatomic) MSAssetsDeploymentInstance *assetsDeployment;
@property (nonatomic) MSAssetsDeploymentInstance *assetsDeployment2;


@end

@implementation MSAssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enabled.on = [MSAssets isEnabled];
    
    NSError *error = nil;
    _assetsDeployment = [MSAssets makeDeploymentInstanceWithBuilder:^(MSAssetsBuilder *builder) {
    } error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    } else {
        [_assetsDeployment setDelegate:self];
    }

    _assetsDeployment2 = [MSAssets makeDeploymentInstanceWithBuilder:^(MSAssetsBuilder *builder) {
    } error:&error];

    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    } else {
        [_assetsDeployment2 setDelegate:self];
    }

    [self updatePath];
    [self updateCells];
    [self updateImage];
}

- (void)updateCells {
    [self.cellCheckForUpdate setUserInteractionEnabled:[MSAssets isEnabled]];
    [self.cellCheckForUpdate2 setUserInteractionEnabled:[MSAssets isEnabled]];
    [self.cellDownloadStatus setUserInteractionEnabled:[MSAssets isEnabled]];
    [self.cellSync setUserInteractionEnabled:[MSAssets isEnabled]];
    [self.cellSync2 setUserInteractionEnabled:[MSAssets isEnabled]];
    [self.cellSyncStatus setUserInteractionEnabled:[MSAssets isEnabled]];
    [self.cellUpdatePath setUserInteractionEnabled:[MSAssets isEnabled]];
    [self.cellUpdatePath2 setUserInteractionEnabled:[MSAssets isEnabled]];
}

- (IBAction)enabledSwitchUpdated:(UISwitch *)sender {
    [MSAssets setEnabled:sender.on];
    sender.on = [MSAssets isEnabled];
    [self updateCells];
}

-(void)sync {
    MSAssetsSyncOptions *syncOptions = [MSAssetsSyncOptions new];
    [syncOptions setDeploymentKey:@kDeploymentKey];
    [syncOptions setUpdateDialog:[MSAssetsUpdateDialog new]];
    [_assetsDeployment sync:syncOptions];
}

-(void)sync2 {
    MSAssetsSyncOptions *syncOptions = [MSAssetsSyncOptions new];
    [syncOptions setDeploymentKey:@kDeploymentKey2];
    [syncOptions setUpdateDialog:[MSAssetsUpdateDialog new]];
    [_assetsDeployment2 sync:syncOptions];
}

-(void)updatePath {
    self.updatePathView.text = [_assetsDeployment getCurrentUpdateEntryPoint];
    self.updatePathView2.text = [_assetsDeployment2 getCurrentUpdateEntryPoint];;
}

- (void)updateImage {
    MSLogInfo([MSAssets logTag], @"Puppet: update image");
    NSString *path = [[_assetsDeployment getCurrentUpdateEntryPoint] stringByAppendingPathComponent:@"cp_assets/square.png"];
    if (path) {
        MSLogInfo([MSAssets logTag], @"%@", path);
        NSData *data = [MSUtility loadDataForPathComponent:path];
        if (data) {
            MSLogInfo([MSAssets logTag], @"File exists");
        } else {
            MSLogInfo([MSAssets logTag], @"File not found");
        }
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) [self.imageView setImage:image];
        });
    }


    NSString *path2 = [[_assetsDeployment2 getCurrentUpdateEntryPoint] stringByAppendingPathComponent:@"cp_assets2/square.png"];
    if (path2) {
        MSLogInfo([MSAssets logTag], @"%@", path2);
        NSData *data = [MSUtility loadDataForPathComponent:path2];
        if (data) {
            MSLogInfo([MSAssets logTag], @"File exists");
        } else {
            MSLogInfo([MSAssets logTag], @"File not found");
        }
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) [self.imageView2 setImage:image];
        });
    }
}

- (void)checkForUpdate {
    [_assetsDeployment checkForUpdate:@kDeploymentKey];
}

- (void)checkForUpdate2 {
    [_assetsDeployment2 checkForUpdate:@kDeploymentKey2];
}

- (void)didReceiveRemotePackageOnCheckForUpdate:(MSAssetsRemotePackage *)package {
    if (!package) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.syncStatus.text = @"No update available";
        });
    } else {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[package serializeToDictionary] options: NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"{" withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"}" withString:@""];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            MSAlertController *alert = [MSAlertController alertControllerWithTitle:@"Check for update results" message:jsonString preferredStyle:UIAlertControllerStyleAlert];
            [alert.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:defaultAction];
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
                case 1: {
                    [self sync];
                    break;
                }
                case 2: {
                    [self checkForUpdate2];
                    break;
                }
                case 3: {
                    [self sync2];
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)syncStatusChanged:(MSAssetsSyncStatus __unused)syncStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
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
                [self updateImage];
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
    });

}

- (void)didFailToQueryRemotePackageOnCheckForUpdate:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.result.text = error.description;
    });
}

- (void)handleBinaryVersionMismatchCallback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MSAlertController *alert = [MSAlertController alertControllerWithTitle:@"Check for update results" message:@"Binary mismatch" preferredStyle:UIAlertControllerStyleAlert];
        [alert.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:defaultAction];
        [alert show];
    });
}

@end
