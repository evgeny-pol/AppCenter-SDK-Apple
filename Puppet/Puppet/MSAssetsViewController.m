/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import "MSAssetsViewController.h"
#import "AppCenterAssets.h"

@interface MSAssetsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *enabled;
@property (nonatomic) MSAssetsDeploymentInstance *assetsDeployment;

@end

@implementation MSAssetsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    self.enabled.on = [MSAssets isEnabled];
    
    _assetsDeployment = [MSAssets makeDeploymentInstanceWithBuilder:^(MSAssetsBuilder *builder) {
        [builder setDeploymentKey:@"123"];
    }];

    [_assetsDeployment setDelegate:self];
}

- (IBAction)enabledSwitchUpdated:(UISwitch *)sender {
  [MSAssets setEnabled:sender.on];
  sender.on = [MSAssets isEnabled];
}

- (IBAction)checkForUpdate {
    [_assetsDeployment checkForUpdate:@"123"];
}

- (void)didReceiveRemotePackageOnUpdateCheck:(MSRemotePackage *)package
{
    NSLog(@"Callback from MSAssets.checkForUpdate");
}

- (void)didFailToQueryPackage:(NSError *)error
{
    NSLog(@"Callback with error from MSAssets.checkForUpdate");
}



@end
