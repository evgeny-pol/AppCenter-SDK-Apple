#import <XCTest/XCTest.h>
#import "MSAssets.h"
#import "MSAppCenter.h"
#import "MSTestFrameworks.h"
#import "MSAssetsReportSender.h"
#import "MSAssetsCheckForUpdate.h"
#import "MSAssetsAcquisitionManager.h"

#define kAppSecret @"7dfb022a-17b5-4d4a-9c75-12bc3ef5e6b7"
#define kDeploymentKeyHasUpdate "nznLJqzS2qnUQSbO0CjFigeBQYuXSy7pSmzVm"
#define kDeploymentKeyNoUpdate "OEMkJXZ-bFzyUoMk549hPHEYkqkKrJvgIQfEm"
#define kDeploymentKeyEmpty "ybaoY8gI2wHLK8pkpfokX5KLsFXTryZ-87GVX"


static NSString *const kMSAssetsServiceName = @"Assets";

@interface MSAssetsTests : XCTestCase

@property (nonatomic) MSAssetsDeploymentInstance *sut;

@end

@implementation MSAssetsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    [MSAppCenter start:kAppSecret
          withServices:@[ [MSAssets class] ]];
    NSError *error = nil;
    self.sut = [MSAssets makeDeploymentInstanceWithBuilder:^(MSAssetsBuilder *builder) {
        builder.deploymentKey = @kDeploymentKeyHasUpdate;
    } error:&error];

    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testApplyEnabledStateWorks {
    [MSAssets setEnabled:YES];
    XCTAssertTrue([MSAssets isEnabled]);

    [MSAssets setEnabled:NO];
    XCTAssertFalse([MSAssets isEnabled]);

    [MSAssets setEnabled:YES];
    XCTAssertTrue([MSAssets isEnabled]);
}

- (void)testServiceNameIsCorrect {
    XCTAssertEqual([MSAssets serviceName], kMSAssetsServiceName);
}

- (void)testAppSecretNotRequired {
    XCTAssertFalse([[MSAssets sharedInstance] isAppSecretRequired]);
}

- (void)testDeploymentWorks {
    XCTAssertNotNil(self.sut);
}

- (void)testSettingDelegateWorks {
    id<MSAssetsDelegate> delegateMock = OCMProtocolMock(@protocol(MSAssetsDelegate));
    [self.sut setDelegate:delegateMock];
    XCTAssertNotNil(self.sut.delegate);
    XCTAssertEqual(self.sut.delegate, delegateMock);
}

- (void)testStatusReportIdentifier {
    NSString *appVersion = @"1.0";
    NSString *deploymentKey = @"deploymentKeyData";
    MSAssetsStatusReportIdentifier *statusReportIdentifier = [[MSAssetsStatusReportIdentifier alloc] initWithAppVersion:appVersion];
    XCTAssertNotNil(statusReportIdentifier);
    XCTAssertEqualObjects(statusReportIdentifier.versionLabel, appVersion);
    XCTAssertEqualObjects([statusReportIdentifier versionLabelOrEmpty], appVersion);
    XCTAssertFalse(statusReportIdentifier.hasDeploymentKey);

    NSString *identifier = [statusReportIdentifier toString];
    MSAssetsStatusReportIdentifier *statusReportIdentifierFromString = [MSAssetsStatusReportIdentifier reportIdentifierFromString:identifier];
    XCTAssertEqualObjects(statusReportIdentifierFromString.versionLabel, appVersion);
    XCTAssertEqualObjects([statusReportIdentifierFromString versionLabelOrEmpty], appVersion);
    XCTAssertFalse(statusReportIdentifierFromString.hasDeploymentKey);

    MSAssetsStatusReportIdentifier *statusReportIdentifierWithDeploymentKey = [[MSAssetsStatusReportIdentifier alloc] initWithAppVersion:appVersion andDeploymentKey:deploymentKey];
    XCTAssertNotNil(statusReportIdentifierWithDeploymentKey);
    XCTAssertEqualObjects(statusReportIdentifierWithDeploymentKey.versionLabel, appVersion);
    XCTAssertEqualObjects([statusReportIdentifierWithDeploymentKey versionLabelOrEmpty], appVersion);
    XCTAssertTrue(statusReportIdentifierWithDeploymentKey.hasDeploymentKey);
    XCTAssertEqual(statusReportIdentifierWithDeploymentKey.deploymentKey, deploymentKey);

    NSString *identifierWithDeploymentKey = [statusReportIdentifierWithDeploymentKey toString];
    MSAssetsStatusReportIdentifier *statusReportIdentifierWithDeploymentKeyFromString = [MSAssetsStatusReportIdentifier reportIdentifierFromString:identifierWithDeploymentKey];

    XCTAssertEqualObjects(appVersion, statusReportIdentifierWithDeploymentKeyFromString.versionLabel);
    XCTAssertEqualObjects([statusReportIdentifierWithDeploymentKeyFromString versionLabelOrEmpty], appVersion);
    XCTAssertEqualObjects(statusReportIdentifierWithDeploymentKey.deploymentKey, statusReportIdentifierWithDeploymentKeyFromString.deploymentKey);
    XCTAssertTrue(statusReportIdentifierWithDeploymentKeyFromString.hasDeploymentKey);
}

- (void)testMSAssetsReportSender{
    MSAssetsReportSender *reportSender = [[MSAssetsReportSender alloc] initWithBaseUrl:@"https://codepush.azurewebsites.net/" reportType:MsAssetsReportTypeDownload];
    XCTAssertNotNil(reportSender);
}

- (void)testMSAssetsCheckForUpdate {
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys: @"data", @"key", nil];
    MSAssetsCheckForUpdate *checkForUpdate = [[MSAssetsCheckForUpdate alloc] initWithBaseUrl:@"https://codepush.azurewebsites.net/" queryStrings:dictIn];
    XCTAssertNotNil(checkForUpdate);

}

- (void)testMSAssetsUpdateUtilites {

    id mockSettingManager = OCMClassMock([MSAssetsSettingManager class]);
    MSAssetsUpdateUtilities *updateUtilities = [[MSAssetsUpdateUtilities alloc] initWithSettingManager:mockSettingManager];
    XCTAssertNotNil(updateUtilities);
    XCTAssertEqualObjects(updateUtilities.settingManager, mockSettingManager);

    NSString *sample = @"sample date";
    NSData* data = [sample dataUsingEncoding:NSUTF8StringEncoding];
    NSString *hash = [updateUtilities computeHashFor:data];
    XCTAssertEqualObjects(hash, @"3b1c1062b335527fd77f96d262d0d3fa28dcae9824236d5fa6a5303aa9e7e7e3");

    NSString *__MACOSX = @"__MACOSX/";
    NSString *DS_STORE = @".DS_Store";
    NSString *ASSETS_METADATA = @".codepushrelease";
    NSString *fileThatIsNotIgnored = @"file";
    XCTAssertTrue([updateUtilities isHashIgnoredFor:__MACOSX]);
    XCTAssertTrue([updateUtilities isHashIgnoredFor:DS_STORE]);
    XCTAssertTrue([updateUtilities isHashIgnoredFor:ASSETS_METADATA]);
    XCTAssertFalse([updateUtilities isHashIgnoredFor:fileThatIsNotIgnored]);
}

@end
