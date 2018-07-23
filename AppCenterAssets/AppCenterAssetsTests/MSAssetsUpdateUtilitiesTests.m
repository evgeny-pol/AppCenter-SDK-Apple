#import <XCTest/XCTest.h>
#import "MSAssetsUpdateUtilities.h"
#import "MSTestFrameworks.h"
#import "MSAssetsErrorUtils.h"
#import "MSUtility+File.h"
#import <Foundation/Foundation.h>

@interface MSAssetsUpdateUtilitiesTests : XCTestCase

@property (nonatomic) MSAssetsUpdateUtilities *sut;
@property id mockSettingManager;

@end

@implementation MSAssetsUpdateUtilitiesTests

- (void)setUp {
    [super setUp];

    _mockSettingManager = OCMClassMock([MSAssetsSettingManager class]);
    self.sut = [[MSAssetsUpdateUtilities alloc] initWithSettingManager:_mockSettingManager];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUpdateUtilsInitialization {
    XCTAssertNotNil(self.sut);
    XCTAssertEqualObjects(self.sut.settingManager, _mockSettingManager);
}

- (void)testComputeHashFor {
    NSString *sample = @"sample date";
    NSData* data = [sample dataUsingEncoding:NSUTF8StringEncoding];
    NSString *hash = [self.sut computeHashFor:data];
    XCTAssertEqualObjects(hash, @"3b1c1062b335527fd77f96d262d0d3fa28dcae9824236d5fa6a5303aa9e7e7e3");
}

- (void)testIsHashIgnoredFor {
    NSString *__MACOSX = @"__MACOSX/";
    NSString *DS_STORE = @".DS_Store";
    NSString *ASSETS_METADATA = @".codepushrelease";
    NSString *fileThatIsNotIgnored = @"file";
    XCTAssertTrue([self.sut isHashIgnoredFor:__MACOSX]);
    XCTAssertTrue([self.sut isHashIgnoredFor:DS_STORE]);
    XCTAssertTrue([self.sut isHashIgnoredFor:ASSETS_METADATA]);
    XCTAssertFalse([self.sut isHashIgnoredFor:fileThatIsNotIgnored]);
}

- (void)testAddContentsOfFolderToManifestFailsNoFolder {
    NSString *folderPath = @"noSuchFolder";
    NSError *error = nil;
    BOOL result = [self.sut addContentsOfFolderToManifest:nil folderPath:folderPath pathPrefix:@"" error:&error];
    XCTAssertFalse(result);
    NSError *expectedError = [MSAssetsErrorUtils getNoDirError:folderPath];
    XCTAssertEqualObjects(error, expectedError);
}

- (void)testVerifyFolderHash {
    NSString *folderPath = @"sampleFolder";
    NSURL *result = [MSUtility createDirectoryForPathComponent:folderPath];
    XCTAssertNotNil(result);
    NSString *fileName = @"SampleFile";
    NSString *fileText = @"SampleFileText";
    NSData* data = [fileText dataUsingEncoding:NSUTF8StringEncoding];
    NSURL* fileURL = [MSUtility createFileAtPathComponent:[folderPath stringByAppendingPathComponent:fileName] withData:data atomically:YES forceOverwrite:YES];
    XCTAssertNotNil(fileURL);

    NSString *subfolderPath = @"sampleFolder/sampleSubfolder";
    NSString *fileNameTier2 = @"SampleFileInSubfolder";
    NSString *fileTextTier2 = @"SampleFileInSubfolderText";
    NSData *dataTier2 = [fileTextTier2 dataUsingEncoding:NSUTF8StringEncoding];
    NSURL* fileURLTier2 = [MSUtility createFileAtPathComponent:[subfolderPath stringByAppendingPathComponent:fileNameTier2] withData:dataTier2 atomically:YES forceOverwrite:YES];
    XCTAssertNotNil(fileURLTier2);

    NSString *expectedHash = @"3e6f4387b4955bd1693c4344d1228272556666a9c49226734b3c54c62ec1bb01";
    NSError *error = nil;
    BOOL hashOk = [self.sut verifyFolderHash:expectedHash folderPath:folderPath error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(hashOk);
}

@end
