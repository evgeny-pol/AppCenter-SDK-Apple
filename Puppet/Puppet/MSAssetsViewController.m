/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 */

#import "MSAssetsViewController.h"
#import "AppCenterAssets.h"

@interface MSAssetsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *enabled;
@property (nonatomic) MSAssetsAPI *assets;

@end

@implementation MSAssetsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    self.enabled.on = [MSAssets isEnabled];
    
    _assets = [MSAssets makeAPIWithBuilder:^(MSAssetsBuilder *builder) {
        [builder setDeploymentKey:@"123"];
    }];
}

- (IBAction)enabledSwitchUpdated:(UISwitch *)sender {
  [MSAssets setEnabled:sender.on];
  sender.on = [MSAssets isEnabled];
}

- (IBAction)checkForUpdate {
    [_assets checkForUpdate:@"123"];
}


@end
