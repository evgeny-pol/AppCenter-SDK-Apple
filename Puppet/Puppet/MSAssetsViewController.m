/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import "MSAssetsViewController.h"
#import "AppCenterAssets.h"

@interface MSAssetsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *enabled;
@property (weak, nonatomic) IBOutlet UILabel *result;
@property (nonatomic) MSAssetsDeploymentInstance *assetsDeployment;

@end

@implementation MSAssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enabled.on = [MSAssets isEnabled];

    _assetsDeployment = [MSAssets makeDeploymentInstanceWithBuilder:^(MSAssetsBuilder *builder) {
        [builder setServerUrl:@"https://codepush.azurewebsites.net/"];
    }];

    [_assetsDeployment setDelegate:self];
}

- (IBAction)enabledSwitchUpdated:(UISwitch *)sender {
    [MSAssets setEnabled:sender.on];
    sender.on = [MSAssets isEnabled];
}

- (IBAction)checkForUpdate {
    [_assetsDeployment checkForUpdate:@"EAk0sEsG9uZii-_T4TCJYS1go6JfByhZUk-bX"];
}

- (void)didReceiveRemotePackageOnUpdateCheck:(MSRemotePackage *)package {
    if (!package) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.result.text = @"No update available";
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
            self.result.text = info;
        });
    }
}

- (void)didFailToQueryRemotePackageOnCheckForUpdate:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.result.text = error.description;
    });
}


@end
