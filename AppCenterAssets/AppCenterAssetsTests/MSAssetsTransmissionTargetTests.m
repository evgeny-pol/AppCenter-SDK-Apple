@import XCTest;

#import "MSAssetsInternal.h"
#import "MSAssetsTransmissionTargetInternal.h"
#import "MSTestFrameworks.h"

static NSString *const kMSTestTransmissionToken = @"TestTransmissionToken";

@interface MSAssetsTransmissionTargetTests : XCTestCase
@end

@implementation MSAssetsTransmissionTargetTests

#pragma mark - Tests

- (void)testInitialization {

  // When
  MSAssetsTransmissionTarget *transmissionTarget = [[MSAssetsTransmissionTarget alloc] initWithTransmissionTargetToken:kMSTestTransmissionToken];

  // Then
  XCTAssertNotNil(transmissionTarget);
  XCTAssertEqual(kMSTestTransmissionToken, [transmissionTarget transmissionTargetToken]);
}

- (void)testTrackEvent {

  // If
  OCMClassMock([MSAssets class]);
  MSAssetsTransmissionTarget *transmissionTarget = [[MSAssetsTransmissionTarget alloc] initWithTransmissionTargetToken:kMSTestTransmissionToken];
  NSString *eventName = @"event";

  // When
  [transmissionTarget trackEvent:eventName];

  // Then
  OCMVerify(ClassMethod([MSAssets trackEvent:eventName forTransmissionTarget:transmissionTarget]));
}

- (void)testTrackEventWithProperties {

  // If
  OCMClassMock([MSAssets class]);
  MSAssetsTransmissionTarget *transmissionTarget = [[MSAssetsTransmissionTarget alloc] initWithTransmissionTargetToken:kMSTestTransmissionToken];
  NSString *eventName = @"event";
  NSDictionary *properties = [NSDictionary new];

  // When
  [transmissionTarget trackEvent:eventName withProperties:properties];

  // Then
  OCMVerify(ClassMethod([MSAssets trackEvent:eventName withProperties:properties forTransmissionTarget:transmissionTarget]));
}

@end

