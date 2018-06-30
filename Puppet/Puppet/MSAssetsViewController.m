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

        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *deploymentKey = [infoDictionary objectForKey:@"MSAssetsDeploymentKey"];
        [builder setDeploymentKey:deploymentKey];
        NSString *serverUrl = [infoDictionary objectForKey:@"MSAssetsServerUrl"];
        [builder setServerUrl:serverUrl];

    }];

    [_assetsDeployment setDelegate:self];
}

- (IBAction)enabledSwitchUpdated:(UISwitch *)sender {
  [MSAssets setEnabled:sender.on];
  sender.on = [MSAssets isEnabled];
}

- (IBAction)checkForUpdate {

    self.result.text = @"Request sent";
    [_assetsDeployment checkForUpdate:nil];
}

- (void)didReceiveRemotePackageOnUpdateCheck:(MSRemotePackage *)package
{
    NSLog(@"Callback from MSAssets.checkForUpdate");
    if (!package)
    {
        NSLog(@"No update available");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.result.text = @"No update available";
        });
    }
    else
    {
        NSLog(@"Update available");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.result.text = @"Update is available";
        });
    }
}

- (void)didFailToQueryRemotePackageOnCheckForUpdate:(NSError *)error
{
    NSLog(@"Callback with error from MSAssets.checkForUpdate");

    dispatch_async(dispatch_get_main_queue(), ^{
        self.result.text = error.description;
    });
}


@end
