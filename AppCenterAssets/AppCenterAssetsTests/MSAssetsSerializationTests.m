#import <XCTest/XCTest.h>
#import "MSAssets.h"
#import "MSAppCenter.h"
#import "MSTestFrameworks.h"
#import "MSAssetsPackageInfo.h"
#import "MSAssetsUpdateResponse.h"

@interface MSAssetsSerializationTests : XCTestCase

@end

@implementation MSAssetsSerializationTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMSAssetsPackageSerialization {
    
    //If
    NSDictionary *dictIn = [self getAssetsPackageDictionary];
    MSAssetsPackage *package = [[MSAssetsPackage alloc] initWithDictionary:dictIn];
    
    //When
    NSDictionary *dictOut = [package serializeToDictionary];
    
    //Then
    XCTAssertEqualObjects(dictIn[@"appVersion"], dictOut[@"appVersion"]);
    XCTAssertEqualObjects(dictIn[@"deploymentKey"], dictOut[@"deploymentKey"]);
    XCTAssertEqualObjects(dictIn[@"description"], dictOut[@"description"]);
    XCTAssertEqualObjects(dictIn[@"failedInstall"], dictOut[@"failedInstall"]);
    XCTAssertEqualObjects(dictIn[@"isMandatory"], dictOut[@"isMandatory"]);
    XCTAssertEqualObjects(dictIn[@"label"], dictOut[@"label"]);
    XCTAssertEqualObjects(dictIn[@"packageHash"], dictOut[@"packageHash"]);
}

- (NSDictionary *)getAssetsPackageDictionary {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            @"1.0", @"appVersion",
            @"X0s3Jrpp7TBLmMe5x_UG0b8hf-a8SknGZWL7Q", @"deploymentKey",
            @"descriptionText", @"description",
            @NO, @"failedInstall",
            @NO, @"isMandatory",
            @"labelText", @"label",
            @"packageHashData", @"packageHash",
            nil];
}

- (void)testMSAssetsPackageInfoSerialization {
    
    //If
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"currentPackageInfo", @"currentPackage",
                            @"previousPackageInfo", @"previousPackage",
                            nil];
    MSAssetsPackageInfo *packageInfo = [[MSAssetsPackageInfo alloc] initWithDictionary:dictIn];
    
    //When
    NSDictionary *dictOut = [packageInfo serializeToDictionary];
    
    //Then
    XCTAssertEqualObjects(dictIn[@"currentPackage"], dictOut[@"currentPackage"]);
    XCTAssertEqualObjects(dictIn[@"previousPackage"], dictOut[@"previousPackage"]);
}

- (void)testMSAssetsPendingUpdateSerialization {
    
    //If
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @YES, @"isLoading",
                            @"hashInfo", @"hash",
                            nil];
    MSAssetsPendingUpdate *pendingUpdate = [[MSAssetsPendingUpdate alloc] initWithDictionary:dictIn];
    
    //When
    NSDictionary *dictOut = [pendingUpdate serializeToDictionary];
    
    //Then
    XCTAssertEqualObjects(dictIn[@"isLoading"], dictOut[@"isLoading"]);
    XCTAssertEqualObjects(dictIn[@"hash"], dictOut[@"hash"]);
}

- (void)testMSAssetsDeploymentStatusReportSerialization {
    
    //If
    NSDictionary *assetsPackage = [self getAssetsPackageDictionary];
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"clientUniqueIdData", @"clientUniqueId",
                            @"deploymentKeyData", @"deploymentKey",
                            @"labelData", @"label",
                            @"1.0", @"appVersion",
                            @"previousDeploymentKeyData", @"previousDeploymentKey",
                            @"previousLabelOrAppVersionData", @"previousLabelOrAppVersion",
                            @"DeploymentSucceeded", @"status",
                            assetsPackage, @"package",
                            nil];
    MSAssetsDeploymentStatusReport *deploymentStatusReport = [[MSAssetsDeploymentStatusReport alloc] initWithDictionary:dictIn];
    
    //When
    NSDictionary *dictOut = [deploymentStatusReport serializeToDictionary];
    
    //Then
    XCTAssertEqualObjects(dictIn[@"appVersion"], dictOut[@"appVersion"]);
    XCTAssertEqualObjects(dictIn[@"previousDeploymentKey"], dictOut[@"previousDeploymentKey"]);
    XCTAssertEqualObjects(dictIn[@"previousLabelOrAppVersion"], dictOut[@"previousLabelOrAppVersion"]);
    XCTAssertEqualObjects(dictIn[@"status"], dictOut[@"status"]);
    XCTAssertEqualObjects(dictIn[@"package"], dictOut[@"package"]);
}

- (void)testMSAssetsDownloadStatusReportSerialization {
    
    //If
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"clientUniqueIdData", @"clientUniqueId",
                            @"deploymentKeyData", @"deploymentKey",
                            @"labelData", @"label",
                            nil];
    MSAssetsDownloadStatusReport *downloadStatusReport = [[MSAssetsDownloadStatusReport alloc] initWithDictionary:dictIn];
    
    //When
    NSDictionary *dictOut = [downloadStatusReport serializeToDictionary];
    
    //Then
    XCTAssertEqualObjects(dictIn[@"clientUniqueId"], dictOut[@"clientUniqueId"]);
    XCTAssertEqualObjects(dictIn[@"deploymentKey"], dictOut[@"deploymentKey"]);
    XCTAssertEqualObjects(dictIn[@"label"], dictOut[@"label"]);
}


- (void)testMSAssetsLocalPackageSerialization {
    
    //If
    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @NO, @"isPending",
                            @"entryPointData", @"entryPoint",
                            @NO, @"isFirstRun",
                            @NO, @"_isDebugOnly",
                            @"binaryModifiedTimeData", @"binaryModifiedTime",
                            nil];
    MSAssetsLocalPackage *localPackage = [[MSAssetsLocalPackage alloc] initWithDictionary:dictIn];
    
    //When
    NSDictionary *dictOut = [localPackage serializeToDictionary];
    
    //Then
    XCTAssertEqualObjects(dictIn[@"isPending"], dictOut[@"isPending"]);
    XCTAssertEqualObjects(dictIn[@"isFirstRun"], dictOut[@"isFirstRun"]);
    XCTAssertEqualObjects(dictIn[@"_isDebugOnly"], dictOut[@"_isDebugOnly"]);
    XCTAssertEqualObjects(dictIn[@"binaryModifiedTime"], dictOut[@"binaryModifiedTime"]);
}

- (void)testMSAssetsUpdateResponseSerialization {
    
    //If
    NSDictionary *dictInUpdateInfo = [self getUpdateInfoDictionary];

    NSDictionary *dictIn = [[NSDictionary alloc] initWithObjectsAndKeys:
                            dictInUpdateInfo, @"updateInfo",
                            nil];
    MSAssetsUpdateResponse *updateResponse = [[MSAssetsUpdateResponse alloc] initWithDictionary:dictIn];
    
    //When
    NSDictionary *dictOut = [updateResponse serializeToDictionary];
    
    //When
    XCTAssertEqualObjects(dictIn[@"updateInfo"], dictOut[@"updateInfo"]);
}

- (NSDictionary *)getUpdateInfoDictionary {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            @"downloadURLData", @"downloadURL",
            @"descriptionData", @"description",
            @NO, @"isAvailable",
            @NO, @"isMandatory",
            @"appVersionData", @"appVersion",
            @"labelData", @"label",
            @"packageHashData", @"packageHash",
            [NSNumber numberWithLongLong:1024], @"packageSize",
            @YES, @"updateAppVersion",
            @YES, @"shouldRunBinaryVersion",
            nil];
}

- (void)testMSAssetsUpdateResponseUpdateInfoSerialization {
    
    //If
    NSDictionary *dictIn = [self getUpdateInfoDictionary];
    MSAssetsUpdateResponseUpdateInfo *updateResponseUpdateInfo = [[MSAssetsUpdateResponseUpdateInfo alloc] initWithDictionary:dictIn];
    
    //When
    NSDictionary *dictOut = [updateResponseUpdateInfo serializeToDictionary];
    
    //Then
    XCTAssertEqualObjects(dictIn[@"downloadURL"], dictOut[@"downloadURL"]);
    XCTAssertEqualObjects(dictIn[@"description"], dictOut[@"description"]);
    XCTAssertEqualObjects(dictIn[@"isAvailable"], dictOut[@"isAvailable"]);
    XCTAssertEqualObjects(dictIn[@"isMandatory"], dictOut[@"isMandatory"]);
    XCTAssertEqualObjects(dictIn[@"appVersion"], dictOut[@"appVersion"]);
    XCTAssertEqualObjects(dictIn[@"label"], dictOut[@"label"]);
    XCTAssertEqualObjects(dictIn[@"packageHash"], dictOut[@"packageHash"]);
    XCTAssertEqualObjects(dictIn[@"packageSize"], dictOut[@"packageSize"]);
    XCTAssertEqualObjects(dictIn[@"updateAppVersion"], dictOut[@"updateAppVersion"]);
    XCTAssertEqualObjects(dictIn[@"shouldRunBinaryVersion"], dictOut[@"shouldRunBinaryVersion"]);
}

- (void)testReportStatusIdentifier {
    
    //If
    NSString *fakeAppVersion = @"1.0";
    NSString *fakeDeploymentKey = @"DEP-KEY";
    NSString *stringForIdentifier = [[NSString alloc] initWithFormat: @"%@:%@", fakeAppVersion, fakeDeploymentKey];
    
    //When
    MSAssetsStatusReportIdentifier *identifier = [MSAssetsStatusReportIdentifier reportIdentifierFromString:stringForIdentifier];
    
    //Then
    XCTAssertEqualObjects(fakeAppVersion, [identifier versionLabelOrEmpty]);
    XCTAssertEqualObjects(fakeAppVersion, [identifier versionLabel]);
    XCTAssertEqualObjects(fakeDeploymentKey, [identifier deploymentKey]);
    
    //When
    NSString *identifierString = [identifier toString];
    
    //Then
    XCTAssertEqualObjects(identifierString, stringForIdentifier);
    
    //When
    identifier = [[MSAssetsStatusReportIdentifier alloc] initWithAppVersion: fakeAppVersion andDeploymentKey:fakeDeploymentKey];
    
    //Then
    XCTAssertTrue([identifier hasDeploymentKey]);
    XCTAssertEqualObjects(fakeAppVersion, [identifier versionLabelOrEmpty]);
    XCTAssertEqualObjects(fakeAppVersion, [identifier versionLabel]);
    XCTAssertEqualObjects(fakeDeploymentKey, [identifier deploymentKey]);
    
    //When
    identifierString = [identifier toString];
    
    //Then
    XCTAssertEqualObjects(stringForIdentifier, identifierString);
    
    //When
    identifier = [[MSAssetsStatusReportIdentifier alloc] initWithAppVersion:fakeAppVersion];
    
    //Then
    XCTAssertFalse([identifier hasDeploymentKey]);
    XCTAssertEqualObjects(fakeAppVersion, [identifier versionLabelOrEmpty]);
    
    //When
    NSString *onlyAppVersionIdentifier = [identifier toString];
    
    //Then
    XCTAssertEqualObjects(fakeAppVersion, onlyAppVersionIdentifier);
    
    //When
    identifier = [MSAssetsStatusReportIdentifier reportIdentifierFromString:fakeAppVersion];
    
    //Then
    XCTAssertFalse([identifier hasDeploymentKey]);
    XCTAssertEqualObjects(fakeAppVersion, [identifier versionLabel]);
    
    //When
    identifier = [MSAssetsStatusReportIdentifier new];
    
    //Then
    XCTAssertEqualObjects(@"", [identifier versionLabelOrEmpty]);
    
    //When
    identifierString = [identifier toString];
    
    //Then
    XCTAssertNil(identifierString);
    
    //When
    identifier = [MSAssetsStatusReportIdentifier reportIdentifierFromString:nil];
    
    //Then
    XCTAssertNil(identifier);
}
@end
