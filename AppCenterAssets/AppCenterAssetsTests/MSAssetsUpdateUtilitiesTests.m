#import <XCTest/XCTest.h>
#import "MSAssetsUpdateUtilities.h"
#import "MSTestFrameworks.h"
#import "MSAssetsErrorUtils.h"
#import "MSUtility+File.h"
#import <Foundation/Foundation.h>
#import "MSAssetsUpdateUtilities+JWT.h"

static NSString *const kSampleFolder = @"sampleFolder";
static NSString *const kSampleFile = @"SampleFile";
static NSString *const kSampleFileText = @"SampleFileText";
static NSString *const kSampleSubfolder = @"sampleSubfolder";
static NSString *const kSampleFileInSubfolder = @"SampleFileInSubfolder";
static NSString *const kSampleFileInSubfolderText = @"SampleFileInSubfolderText";
static NSString *const kFakeSignature = @"fakeSignature";
static NSString *const kNoFolder = @"noSuchFolder";
static NSString *const kFakePublicKey = @"-----BEGIN PUBLIC KEY-----\n[PUBLIC_KEY_DATA]\n-----END PUBLIC KEY-----\n";

@interface MSAssetsUpdateUtilitiesTests : XCTestCase

@property (nonatomic) MSAssetsUpdateUtilities *sut;
@property id mockSettingManager;

@end

@implementation MSAssetsUpdateUtilitiesTests

- (void)setUp {
    [super setUp];

    _mockSettingManager = OCMClassMock([MSAssetsSettingManager class]);
    self.sut = [[MSAssetsUpdateUtilities alloc] initWithSettingManager:_mockSettingManager];

    [self createFile:kSampleFile inPath:kSampleFolder withText:kSampleFileText];
    [self createFile:BundleJWTFile inPath:kSampleFolder withText:kFakeSignature];
    [self createFile:kSampleFileInSubfolder inPath:[kSampleFolder stringByAppendingPathComponent:kSampleSubfolder] withText:kSampleFileInSubfolderText];
}

- (void)tearDown {
    [super tearDown];
    [MSUtility deleteItemForPathComponent:kSampleFolder];
}

- (void)createFile:(NSString *)fileName inPath:(NSString *)path withText:(NSString *)text {
    [MSUtility createFileAtPathComponent:[path stringByAppendingPathComponent:fileName] withData:[text dataUsingEncoding:NSUTF8StringEncoding] atomically:YES forceOverwrite:YES];
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
    NSString *fileThatIsNotIgnored = @"file";
    XCTAssertTrue([self.sut isHashIgnoredFor:__MACOSX]);
    XCTAssertTrue([self.sut isHashIgnoredFor:DS_STORE]);
    XCTAssertTrue([self.sut isHashIgnoredFor:BundleJWTFile]);
    XCTAssertFalse([self.sut isHashIgnoredFor:fileThatIsNotIgnored]);
}

- (void)testVerifyFolderHash {
    NSString *expectedHash = @"3e6f4387b4955bd1693c4344d1228272556666a9c49226734b3c54c62ec1bb01";
    NSError *error = nil;
    BOOL hashOk = [self.sut verifyFolderHash:expectedHash folderPath:kSampleFolder error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(hashOk);
}

- (void)testFindEntryPointInFolderFailsNoFolder {
    NSString *entryPoint = [self.sut findEntryPointInFolder:kNoFolder expectedFileName:kSampleFile];
    XCTAssertNil(entryPoint);
}

- (void)testFindEntryPointInFolderFailsNoFile {
    NSString *entryPoint = [self.sut findEntryPointInFolder:kSampleFolder expectedFileName:@"noSuchFile"];
    XCTAssertNil(entryPoint);
}

- (void)testFindEntryPointInFolderSuccessFoundInFolder {
    NSString *entryPoint = [self.sut findEntryPointInFolder:kSampleFolder expectedFileName:kSampleFile];
    XCTAssertEqualObjects(entryPoint, kSampleFile);
}

- (void)testFindEntryPointInFolderSuccessFoundInSubаfolder {
    NSString *entryPoint = [self.sut findEntryPointInFolder:kSampleFolder expectedFileName:kSampleFileInSubfolder];
    XCTAssertEqualObjects(entryPoint, [kSampleSubfolder stringByAppendingPathComponent:kSampleFileInSubfolder]);
}

- (void)testAddContentsOfFolderToManifestFailsNoFolder {
    NSError *error = nil;
    NSString *folderPath = kNoFolder;
    NSMutableArray<NSString *> *manifest = [NSMutableArray<NSString* > array];
    BOOL result = [self.sut addContentsOfFolderToManifest:manifest folderPath:folderPath pathPrefix:@"prefix" error:&error];
    XCTAssertFalse(result);
    NSError *expectedError = [MSAssetsErrorUtils getNoDirError:folderPath];
    XCTAssertEqualObjects(error, expectedError);
}

- (void)testAddContentsOfFolderToManifestSuccess {
    NSError *error = nil;
    NSMutableArray<NSString *> *manifest = [NSMutableArray<NSString* > array];
    BOOL result = [self.sut addContentsOfFolderToManifest:manifest folderPath:kSampleFolder pathPrefix:@"prefix" error:&error];
    XCTAssertTrue(result);
    XCTAssertEqual(manifest.count, 2);
    XCTAssertEqualObjects(manifest[0],  @"prefix/sampleSubfolder/SampleFileInSubfolder:5816aa5a89468053aa19df26dd52f710743d02593c932be6c5881964c4226857");
    XCTAssertEqualObjects(manifest[1],  @"prefix/SampleFile:bd747ef223a7a702a3075c67ea330b286df0ba0a1d732b0708075d811cf95c7c");
}

- (void)testGetSignatureFilePathFailsNoFolder {
    NSString *signatureFilePath = [self.sut getSignatureFilePath:kNoFolder];
    XCTAssertNil(signatureFilePath);
}

- (void)testGetSignatureFilePathSuccess {
    NSString *signatureFilePath = [self.sut getSignatureFilePath:kSampleFolder];
    XCTAssertNotNil(signatureFilePath);
    XCTAssertEqualObjects(signatureFilePath, [kSampleFolder stringByAppendingPathComponent:BundleJWTFile]);
}

- (void)testGetSignatureFilePathFalsNoSignatureFile {
    NSString *signatureFilePath = [self.sut getSignatureFilePath:[kSampleFolder stringByAppendingPathComponent:kSampleSubfolder]];
    XCTAssertNil(signatureFilePath);
}

- (void)testSignatureFor {
    NSError *error = nil;
    NSString *result = [self.sut getSignatureFor:kSampleFolder error:&error];
    XCTAssertNotNil(result);
    XCTAssertEqualObjects(result, kFakeSignature);
}

- (void)testSignatureForFailsNoFolder {
    NSError *error = nil;
    NSString *result = [self.sut getSignatureFor:kNoFolder error:&error];
    XCTAssertNotNil(error);
    NSError *expectedError = [MSAssetsErrorUtils getNoSignatureError:[@"noSuchFolder" stringByAppendingPathComponent:BundleJWTFile]];
    XCTAssertEqualObjects(error, expectedError);
    XCTAssertNil(result);
}

- (void)testSignatureForFailsNoFile {
    NSError *error = nil;
    NSString *result = [self.sut getSignatureFor:[kSampleFolder stringByAppendingPathComponent:kSampleSubfolder] error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(result);
}

- (void)testGetKeyValueFromPublicKeyString {
    NSString *expectedResult = @"[PUBLIC_KEY_DATA]";
    NSString *key = [self.sut getKeyValueFromPublicKeyString:kFakePublicKey];
    XCTAssertEqualObjects(key, expectedResult);
}

- (void)testVerifyUpdateSignatureForFailsBadSignature {
    NSError *error = nil;
    BOOL result = [self.sut verifyUpdateSignatureFor:kSampleFolder expectedHash:@"fakeHash" withPublicKey:kFakePublicKey error:&error];
    XCTAssertFalse(result);
    XCTAssertNotNil(error);
}

- (void)testVerifyUpdateSignatureForFailsNoFolder {
    NSError *error = nil;
    BOOL result = [self.sut verifyUpdateSignatureFor:kNoFolder expectedHash:@"fakeHash" withPublicKey:kFakePublicKey error:&error];
    XCTAssertFalse(result);
    XCTAssertNotNil(error);
}

@end
