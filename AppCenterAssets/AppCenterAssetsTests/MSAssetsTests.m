#import <XCTest/XCTest.h>
#import "MSAssets.h"
#import "MSAppCenter.h"
#import "MSTestFrameworks.h"
#import "MSAssetsPackageInfo.h"
#import "MSAssetsUpdateResponse.h"

static NSString *const kMSAssetsServiceName = @"Assets";

@interface MSAssetsTests : XCTestCase <MSAssetsDelegate>

@property (nonatomic) MSAssetsDeploymentInstance *assetsDeployment;

@end

@implementation MSAssetsTests


- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    [MSAppCenter start:@"7dfb022a-17b5-4d4a-9c75-12bc3ef5e6b7"
          withServices:@[ [MSAssets class] ]];

    NSError *error = nil;
    self.assetsDeployment = [MSAssets makeDeploymentInstanceWithBuilder:^(MSAssetsBuilder *builder) {
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
    XCTAssertNotNil(self.assetsDeployment);
}

- (void)testSettingDelegateWorks {
//    id<MSAssetsDelegate> delegateMock = OCMProtocolMock(@protocol(MSAssetsDelegate));

    [self.assetsDeployment setDelegate:self];
    XCTAssertNotNil(self.assetsDeployment.delegate);
    XCTAssertEqual(self.assetsDeployment.delegate, self);
}

- (void)testMSAssetsPackageSerialization {
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:@"1.0", @"appVersion", @"X0s3Jrpp7TBLmMe5x_UG0b8hf-a8SknGZWL7Q", @"deploymentKey",  @"descriptionText", @"description", @NO, @"failedInstall",  @NO, @"isMandatory",  @"labelText", @"label", @"packageHashData", @"packageHash", nil];
    MSAssetsPackage *package = [[MSAssetsPackage alloc] initWithDictionary:dictIn];
    NSDictionary *dictOut = [package serializeToDictionary];
    XCTAssertEqual(dictIn[@"appVersion"], dictOut[@"appVersion"]);
    XCTAssertEqual(dictIn[@"deploymentKey"], dictOut[@"deploymentKey"]);
    XCTAssertEqual(dictIn[@"description"], dictOut[@"description"]);
    XCTAssertEqual(dictIn[@"failedInstall"], dictOut[@"failedInstall"]);
    XCTAssertEqual(dictIn[@"isMandatory"], dictOut[@"isMandatory"]);
    XCTAssertEqual(dictIn[@"label"], dictOut[@"label"]);
    XCTAssertEqual(dictIn[@"packageHash"], dictOut[@"packageHash"]);
}

- (void)testMSAssetsPackageInfoSerialization {
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:@"currentPackageInfo", @"currentPackage", @"previousPackageInfo", @"previousPackage", nil];
    MSAssetsPackageInfo *packageInfo = [[MSAssetsPackageInfo alloc] initWithDictionary:dictIn];
    NSDictionary *dictOut = [packageInfo serializeToDictionary];
    XCTAssertEqual(dictIn[@"currentPackage"], dictOut[@"currentPackage"]);
    XCTAssertEqual(dictIn[@"previousPackage"], dictOut[@"previousPackage"]);
}

- (void)testMSAssetsPendingUpdateSerialization {
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:@YES, @"isLoading", @"hashInfo", @"hash", nil];
    MSAssetsPendingUpdate *pendingUpdate = [[MSAssetsPendingUpdate alloc] initWithDictionary:dictIn];
    NSDictionary *dictOut = [pendingUpdate serializeToDictionary];
    XCTAssertEqual(dictIn[@"isLoading"], dictOut[@"isLoading"]);
    XCTAssertEqual(dictIn[@"hash"], dictOut[@"hash"]);
}


- (void)testMSAssetsDeploymentStatusReportSerialization {
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:@"1.0", @"appVersion", @"previousDeploymentKeyData", @"previousDeploymentKey", @"previousLabelOrAppVersionData", @"previousLabelOrAppVersion", @"statusData", @"status", @"packageData", @"package", nil];
    MSAssetsDeploymentStatusReport *deploymentStatusReport = [[MSAssetsDeploymentStatusReport alloc] initWithDictionary:dictIn];
    NSDictionary *dictOut = [deploymentStatusReport serializeToDictionary];
    XCTAssertEqual(dictIn[@"appVersion"], dictOut[@"appVersion"]);
    XCTAssertEqual(dictIn[@"previousDeploymentKey"], dictOut[@"previousDeploymentKey"]);
    XCTAssertEqual(dictIn[@"previousLabelOrAppVersion"], dictOut[@"previousLabelOrAppVersion"]);
    XCTAssertEqual(dictIn[@"status"], dictOut[@"status"]);
    XCTAssertEqual(dictIn[@"package"], dictOut[@"package"]);
}

- (void)testMSAssetsDownloadStatusReportSerialization {
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:@"clientUniqueIdData", @"clientUniqueId", @"deploymentKeyData", @"deploymentKey", @"labelData", @"label", nil];
    MSAssetsDownloadStatusReport *downloadStatusReport = [[MSAssetsDownloadStatusReport alloc] initWithDictionary:dictIn];
    NSDictionary *dictOut = [downloadStatusReport serializeToDictionary];
    XCTAssertEqual(dictIn[@"clientUniqueId"], dictOut[@"clientUniqueId"]);
    XCTAssertEqual(dictIn[@"deploymentKey"], dictOut[@"deploymentKey"]);
    XCTAssertEqual(dictIn[@"label"], dictOut[@"label"]);
}


- (void)testMSAssetsLocalPackageSerialization {
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:@NO, @"isPending", @"entryPointData", @"entryPoint", @NO, @"isFirstRun", @NO, @"_isDebugOnly", @"binaryModifiedTimeData", @"binaryModifiedTime", nil];
    MSAssetsLocalPackage *localPackage = [[MSAssetsLocalPackage alloc] initWithDictionary:dictIn];
    NSDictionary *dictOut = [localPackage serializeToDictionary];
    XCTAssertEqual(dictIn[@"isPending"], dictOut[@"isPending"]);
    XCTAssertEqual(dictIn[@"isFirstRun"], dictOut[@"isFirstRun"]);
    XCTAssertEqual(dictIn[@"_isDebugOnly"], dictOut[@"_isDebugOnly"]);
    XCTAssertEqual(dictIn[@"binaryModifiedTime"], dictOut[@"binaryModifiedTime"]);
}

- (void)testMSAssetsUpdateResponseSerialization {
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:@"updateInfoData", @"updateInfo", nil];
    MSAssetsUpdateResponse *updateResponse = [[MSAssetsUpdateResponse alloc] initWithDictionary:dictIn];
    NSDictionary *dictOut = [updateResponse serializeToDictionary];
    XCTAssertEqual(dictIn[@"updateInfo"], dictOut[@"updateInfo"]);
}

- (void)testMSAssetsUpdateResponseUpdateInfoSerialization {
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:@"downloadURLData", @"downloadURL", @"descriptionData", @"description", @NO, @"isAvailable", @NO, @"isMandatory", @"appVersionData", @"appVersion", @"labelData", @"label", @"packageHashData", @"packageHash", 1024, @"packageSize", @"updateAppVersionData", @"updateAppVersion", @YES, @"shouldRunBinaryVersion", nil];
    MSAssetsUpdateResponseUpdateInfo *updateResponseUpdateInfo = [[MSAssetsUpdateResponseUpdateInfo alloc] initWithDictionary:dictIn];
    NSDictionary *dictOut = [updateResponseUpdateInfo serializeToDictionary];
    XCTAssertEqual(dictIn[@"downloadURL"], dictOut[@"downloadURL"]);
    XCTAssertEqual(dictIn[@"description"], dictOut[@"description"]);
    XCTAssertEqual(dictIn[@"isAvailable"], dictOut[@"isAvailable"]);
    XCTAssertEqual(dictIn[@"isMandatory"], dictOut[@"isMandatory"]);
    XCTAssertEqual(dictIn[@"appVersion"], dictOut[@"appVersion"]);
    XCTAssertEqual(dictIn[@"label"], dictOut[@"label"]);
    XCTAssertEqual(dictIn[@"packageHash"], dictOut[@"packageHash"]);
    XCTAssertEqual(dictIn[@"packageSize"], dictOut[@"packageSize"]);
    XCTAssertEqual(dictIn[@"updateAppVersion"], dictOut[@"updateAppVersion"]);
    XCTAssertEqual(dictIn[@"shouldRunBinaryVersion"], dictOut[@"shouldRunBinaryVersion"]);
}



@end
