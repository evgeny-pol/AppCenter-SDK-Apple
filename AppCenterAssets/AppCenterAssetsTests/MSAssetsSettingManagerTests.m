#import <XCTest/XCTest.h>
#import "MSAssets.h"
#import "MSAppCenter.h"
#import "MSTestFrameworks.h"
#import "MSAssetsPackageInfo.h"
#import "MSAssetsUpdateResponse.h"
#import "MSMockUserDefaults.h"
#import "MSAssetsSettingManager.h"

@interface MSAssetsSettingManagerTests : XCTestCase

@property (nonatomic) MSAssetsSettingManager *sut;
@property (nonatomic) MSMockUserDefaults *settingsMock;

@end

@implementation MSAssetsSettingManagerTests

- (void)setUp {
    [super setUp];
    self.sut = [[MSAssetsSettingManager alloc] init];
    self.settingsMock = [MSMockUserDefaults new];
}

- (void)tearDown {
    [super tearDown];
    [self.settingsMock stopMocking];
}

- (void)testFailedPackages {
    unsigned long packagesCount = 3;
    NSString *fakeHash = @"HASH";
    
    //If
    for(unsigned long i=0; i<packagesCount; i++) {
        MSAssetsPackage *assetsPackage = [MSAssetsPackage new];
        NSString *label = [[NSString alloc] initWithFormat:@"%lu",i];
        NSString *packageHash = [[NSString alloc] initWithFormat:@"%@%lu", fakeHash, i];
        [assetsPackage setLabel:label];
        [assetsPackage setPackageHash:packageHash];
        [self.sut saveFailedUpdate:assetsPackage];
    }
    
    //When
    NSArray<MSAssetsPackage *> *returnedPackages = [self.sut getFailedUpdates];
    
    //Then
    XCTAssertFalse([self.sut existsFailedUpdate:@"FAKE-HASH"]);
    XCTAssertEqual([returnedPackages count], packagesCount);
    for(unsigned long i=0; i<packagesCount; i++) {
        NSString *label = [[NSString alloc] initWithFormat:@"%lu", i];
        NSString *packageHash = [[NSString alloc] initWithFormat:@"%@%lu", fakeHash, i];
        XCTAssertEqualObjects(label, [[returnedPackages objectAtIndex:i] label]);
        XCTAssertTrue([self.sut existsFailedUpdate:packageHash]);
    }
    
    //If
    [self.sut removeFailedUpdates];
    
    //When
    returnedPackages = [self.sut getFailedUpdates];
    
    //Then
    XCTAssertEqual([returnedPackages count], 0UL);
    NSString *previousHash = [[NSString alloc] initWithFormat:@"%@%lu", fakeHash, 0UL];
    XCTAssertFalse([self.sut existsFailedUpdate:previousHash]);
}

- (void)testPendingUpdates {
    NSString *fakeHash = @"HASH";
    
    //If
    MSAssetsPendingUpdate *pendingUpdate = [MSAssetsPendingUpdate new];
    [pendingUpdate setIsLoading:NO];
    [pendingUpdate setPendingUpdateHash:fakeHash];
    [self.sut savePendingUpdate:pendingUpdate];
    
    //When
    MSAssetsPendingUpdate *savedPendingUpdate = [self.sut getPendingUpdate];
    
    //Then
    XCTAssertEqualObjects([savedPendingUpdate pendingUpdateHash], [pendingUpdate pendingUpdateHash]);
    XCTAssertTrue([self.sut isPendingUpdate:fakeHash]);
    XCTAssertTrue([self.sut isPendingUpdate:nil]);
    XCTAssertFalse([self.sut isPendingUpdate:@"FAKE-HASH"]);
    
    //If
    [pendingUpdate setIsLoading:YES];
    
    //When
    [self.sut savePendingUpdate:pendingUpdate];
    
    //Then
    XCTAssertFalse([self.sut isPendingUpdate:fakeHash]);
    XCTAssertFalse([self.sut isPendingUpdate:nil]);
    
    //If
    [self.sut removePendingUpdate];
    
    //When
    savedPendingUpdate = [self.sut getPendingUpdate];
    
    //Then
    XCTAssertNil(savedPendingUpdate);
    XCTAssertFalse([self.sut isPendingUpdate:fakeHash]);
    XCTAssertFalse([self.sut isPendingUpdate:nil]);
}

- (void)testReportIdentifier {
    NSString *identifier = @"1.0:DEP-KEY";
    
    //If
    MSAssetsStatusReportIdentifier *reportIdentifier = [MSAssetsStatusReportIdentifier reportIdentifierFromString:identifier];
    [self.sut saveIdentifierOfReportedStatus:reportIdentifier];
    
    //When
    MSAssetsStatusReportIdentifier *savedIdentifier = [self.sut getPreviousStatusReportIdentifier];
    
    //Then
    XCTAssertEqualObjects([savedIdentifier toString], identifier);
    
    //When
    [self.sut removePreviousStatusReportIdentifier];
    
    //Then
    XCTAssertNil([self.sut getPreviousStatusReportIdentifier]);
    //TODO: test ReportIdentifier sertialization somewhere.
}

- (void)testBinaryHashes {
    unsigned long hashesCount = 3;
    NSString *fakeHash = @"HASH";
    NSMutableDictionary *binaryHashDictionary = [NSMutableDictionary dictionary];
    
    //If
    for(unsigned long i=0; i<hashesCount; i++) {
        NSDate *modifiedDate = [NSDate dateWithTimeIntervalSince1970:(i + 1) * 1000];
        NSString *modificationDate = [NSString stringWithFormat:@"%f", [modifiedDate timeIntervalSince1970]];
        NSString *packageHash = [[NSString alloc] initWithFormat:@"%@%lu", fakeHash, i];
        [binaryHashDictionary setObject:packageHash forKey:modificationDate];
    }
    [self.sut saveBinaryHash:binaryHashDictionary];
    
    //When
    NSMutableDictionary *savedDictionary = [self.sut getBinaryHash];
    
    //Then
    XCTAssertEqual([savedDictionary count], [binaryHashDictionary count]);
    for(unsigned long i=0; i<hashesCount; i++) {
        NSDate *modifiedDate = [NSDate dateWithTimeIntervalSince1970:(i + 1) * 1000];
        NSString *modificationDate = [NSString stringWithFormat:@"%f", [modifiedDate timeIntervalSince1970]];
        NSString *packageHash = [[NSString alloc] initWithFormat:@"%@%lu", fakeHash, i];
        XCTAssertEqualObjects([savedDictionary objectForKey:modificationDate], packageHash);
    }
    
    //If
    [self.sut removeBinaryHash];
    
    //When
    savedDictionary = [self.sut getBinaryHash];
    
    //Then
    XCTAssertEqual([savedDictionary count], 0UL);
}

@end
