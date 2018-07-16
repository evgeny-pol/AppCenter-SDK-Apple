//
//  MSAssetsTests.m
//  
//
//  Created by Alexander Oreshko on 16/07/2018.
//

#import <XCTest/XCTest.h>
#import "MSAssets.h"
#import "MSAppCenter.h"

static NSString *const kMSAssetsServiceName = @"Analytics";

@interface MSAssetsTests : XCTestCase

@end

@implementation MSAssetsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    [MSAppCenter start:@"7dfb022a-17b5-4d4a-9c75-12bc3ef5e6b7"
          withServices:@[ [MSAssets class] ]];
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

@end
