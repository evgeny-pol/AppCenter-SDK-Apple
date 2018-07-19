#import <XCTest/XCTest.h>
#import "MSAssets.h"
#import "MSAppCenter.h"
#import "MSTestFrameworks.h"

static NSString *const kMSAssetsServiceName = @"Assets";

@interface MSAssetsTests : XCTestCase <MSAssetsDelegate>

@property (nonatomic) MSAssetsDeploymentInstance *sut;

@end

@implementation MSAssetsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    [MSAppCenter start:@"7dfb022a-17b5-4d4a-9c75-12bc3ef5e6b7"
          withServices:@[ [MSAssets class] ]];
    NSError *error = nil;
    self.sut = [MSAssets makeDeploymentInstanceWithBuilder:^(MSAssetsBuilder *__unused builder) {
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
    //id<MSAssetsDelegate> delegateMock = OCMProtocolMock(@protocol(MSAssetsDelegate));

    [self.sut setDelegate:self];
    XCTAssertNotNil(self.sut.delegate);
    XCTAssertEqual(self.sut.delegate, self);
}

@end
