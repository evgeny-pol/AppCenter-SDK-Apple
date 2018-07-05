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
        [builder setDeploymentKey:@"EAk0sEsG9uZii-_T4TCJYS1go6JfByhZUk-bX"];
        [builder setServerUrl:@"https://codepush.azurewebsites.net/"];
    }];

    [_assetsDeployment setDelegate:self];
}

- (IBAction)enabledSwitchUpdated:(UISwitch *)sender {
  [MSAssets setEnabled:sender.on];
  sender.on = [MSAssets isEnabled];
}

- (IBAction)checkForUpdate {

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *deploymentKey = [infoDictionary objectForKey:@"MSAssetsDeploymentKey"];
    [_assetsDeployment checkForUpdate:deploymentKey];

    self.result.text = @"Request sent";
}

- (void)didReceiveRemotePackageOnUpdateCheck:(MSRemotePackage *)package
{
    NSLog(@"Callback from MSAssets.checkForUpdate");
    if (!package)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.result.text = @"No update available";
        });
    }
    else
    {
        NSString *info = @"Update info: ";
        NSMutableDictionary *dict = package.serializeToDictionary;
        for(NSString *key in dict)
        {
            info = [info stringByAppendingString:key];
            info = [info stringByAppendingString:@":"];
            if ([dict objectForKey:key])
                info = [info stringByAppendingString:[dict objectForKey:key]];
            else
                    info = [info stringByAppendingString:@"[no value]"];
            info = [info stringByAppendingString:@"\n"];
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            self.result.text = info;
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
