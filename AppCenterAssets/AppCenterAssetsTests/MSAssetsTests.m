#import "MSAssets.h"
#import "MSAssetsInternal.h"
#import "MSAssetsPrivate.h"
#import "MSAssetsCategory.h"
#import "MSAppCenter.h"
#import "MSAppCenterInternal.h"
#import "MSChannelGroupDefault.h"
#import "MSChannelUnitDefault.h"
#import "MSConstants+Internal.h"
#import "MSEventLog.h"
#import "MSMockAssetsDelegate.h"
#import "MSServiceAbstract.h"
#import "MSServiceInternal.h"
#import "MSTestFrameworks.h"

static NSString *const kMSTypeEvent = @"event";
static NSString *const kMSTypePage = @"page";
static NSString *const kMSTestAppSecret = @"TestAppSecret";
static NSString *const kMSTestTransmissionToken = @"TestTransmissionToken";
static NSString *const kMSAssetsServiceName = @"Assets";

@class MSMockAssetsDelegate;

@interface MSAssetsTests : XCTestCase <MSAssetsDelegate>

@end

@interface MSAssets ()

@end

@interface MSServiceAbstract ()

- (BOOL)isEnabled;

- (void)setEnabled:(BOOL)enabled;

@end

/*
 * FIXME
 * Log manager mock is holding sessionTracker instance even after dealloc and this causes session tracker test failures.
 * There is a PR in OCMock that seems a related issue. https://github.com/erikdoe/ocmock/pull/348
 * Stopping session tracker after applyEnabledState calls for hack to avoid failures.
 */
@implementation MSAssetsTests

- (void)tearDown {
  [super tearDown];

  // Make sure sessionTracker removes all observers.
  [MSAssets sharedInstance].sessionTracker = nil;
  [MSAssets resetSharedInstance];
}

#pragma mark - Tests

- (void)testValidateEventName {
  const int maxEventNameLength = 256;

  // If
  NSString *validEventName = @"validEventName";
  NSString *shortEventName = @"e";
  NSString *eventName256 =
      [@"" stringByPaddingToLength:maxEventNameLength withString:@"eventName256" startingAtIndex:0];
  NSString *nullableEventName = nil;
  NSString *emptyEventName = @"";
  NSString *tooLongEventName =
      [@"" stringByPaddingToLength:(maxEventNameLength + 1) withString:@"tooLongEventName" startingAtIndex:0];
  // When
  NSString *valid = [[MSAssets sharedInstance] validateEventName:validEventName forLogType:kMSTypeEvent];
  NSString *validShortEventName =
      [[MSAssets sharedInstance] validateEventName:shortEventName forLogType:kMSTypeEvent];
  NSString *validEventName256 = [[MSAssets sharedInstance] validateEventName:eventName256 forLogType:kMSTypeEvent];
  NSString *validNullableEventName =
      [[MSAssets sharedInstance] validateEventName:nullableEventName forLogType:kMSTypeEvent];
  NSString *validEmptyEventName =
      [[MSAssets sharedInstance] validateEventName:emptyEventName forLogType:kMSTypeEvent];
  NSString *validTooLongEventName =
      [[MSAssets sharedInstance] validateEventName:tooLongEventName forLogType:kMSTypeEvent];

  // Then
  XCTAssertNotNil(valid);
  XCTAssertNotNil(validShortEventName);
  XCTAssertNotNil(validEventName256);
  XCTAssertNil(validNullableEventName);
  XCTAssertNil(validEmptyEventName);
  XCTAssertNotNil(validTooLongEventName);
  XCTAssertEqual([validTooLongEventName length], maxEventNameLength);
}

- (void)testApplyEnabledStateWorks {
  [[MSAssets sharedInstance] startWithChannelGroup:OCMProtocolMock(@protocol(MSChannelGroupProtocol))
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  MSServiceAbstract *service = [MSAssets sharedInstance];

  [service setEnabled:YES];
  XCTAssertTrue([service isEnabled]);

  [service setEnabled:NO];
  XCTAssertFalse([service isEnabled]);

  [service setEnabled:YES];
  XCTAssertTrue([service isEnabled]);

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];
}

- (void)testTrackPageCalledWhenAutoPageTrackingEnabled {

  // If
  id AssetsMock = OCMPartialMock([MSAssets sharedInstance]);
  id AssetsCategoryMock = OCMClassMock([MSAssetsCategory class]);
  NSString *testPageName = @"TestPage";
  OCMStub([AssetsCategoryMock missedPageViewName]).andReturn(testPageName);
  [MSAssets setAutoPageTrackingEnabled:YES];
  MSServiceAbstract *service = [MSAssets sharedInstance];
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];

  // When
  [[MSAssets sharedInstance] startWithChannelGroup:OCMProtocolMock(@protocol(MSChannelGroupProtocol))
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

  XCTestExpectation *expection =
      [self expectationWithDescription:@"Wait for block in applyEnabledState to be dispatched"];
  dispatch_async(dispatch_get_main_queue(), ^{
    [expection fulfill];
  });

  [self waitForExpectationsWithTimeout:1
                               handler:^(NSError *error) {
                                 if (error) {
                                   XCTFail(@"Expectation Failed with error: %@", error);
                                 }

                                 // Then
                                 XCTAssertTrue([service isEnabled]);
                                 OCMVerify([AssetsMock trackPage:testPageName withProperties:nil]);
                               }];
}

- (void)testSettingDelegateWorks {
  id<MSAssetsDelegate> delegateMock = OCMProtocolMock(@protocol(MSAssetsDelegate));
  [MSAssets setDelegate:delegateMock];
  XCTAssertNotNil([MSAssets sharedInstance].delegate);
  XCTAssertEqual([MSAssets sharedInstance].delegate, delegateMock);
}

- (void)testAssetsDelegateWithoutImplementations {

  // If
  MSEventLog *eventLog = OCMClassMock([MSEventLog class]);
  id delegateMock = OCMProtocolMock(@protocol(MSAssetsDelegate));
  OCMReject([delegateMock Assets:[MSAssets sharedInstance] willSendEventLog:eventLog]);
  OCMReject([delegateMock Assets:[MSAssets sharedInstance] didSucceedSendingEventLog:eventLog]);
  OCMReject([delegateMock Assets:[MSAssets sharedInstance] didFailSendingEventLog:eventLog withError:nil]);
  [MSAppCenter sharedInstance].sdkConfigured = NO;
  [MSAppCenter start:kMSTestAppSecret withServices:@[ [MSAssets class] ]];
  MSChannelUnitDefault *channelMock = [MSAssets sharedInstance].channelUnit =
      OCMPartialMock([MSAssets sharedInstance].channelUnit);
  OCMStub([channelMock enqueueItem:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
    id<MSLog> log = nil;
    [invocation getArgument:&log atIndex:2];
    for (id<MSChannelDelegate> delegate in channelMock.delegates) {

      // Call all channel delegate methods for testing.
      [delegate channel:channelMock willSendLog:log];
      [delegate channel:channelMock didSucceedSendingLog:log];
      [delegate channel:channelMock didFailSendingLog:log withError:nil];
    }
  });

  // When
  [[MSAssets sharedInstance].channelUnit enqueueItem:eventLog];

  // Then
  OCMVerifyAll(delegateMock);
}

- (void)testAssetsDelegateMethodsAreCalled {

  // If
  [MSAssets resetSharedInstance];
  id<MSAssetsDelegate> delegateMock = OCMProtocolMock(@protocol(MSAssetsDelegate));
  [MSAppCenter sharedInstance].sdkConfigured = NO;
  [MSAppCenter start:kMSTestAppSecret withServices:@[ [MSAssets class] ]];
  MSChannelUnitDefault *channelMock = [MSAssets sharedInstance].channelUnit =
      OCMPartialMock([MSAssets sharedInstance].channelUnit);
  OCMStub([channelMock enqueueItem:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
    id<MSLog> log = nil;
    [invocation getArgument:&log atIndex:2];
    for (id<MSChannelDelegate> delegate in channelMock.delegates) {

      // Call all channel delegate methods for testing.
      [delegate channel:channelMock willSendLog:log];
      [delegate channel:channelMock didSucceedSendingLog:log];
      [delegate channel:channelMock didFailSendingLog:log withError:nil];
    }
  });

  // When
  [[MSAssets sharedInstance] setDelegate:delegateMock];
  MSEventLog *eventLog = OCMClassMock([MSEventLog class]);
  [[MSAssets sharedInstance].channelUnit enqueueItem:eventLog];

  // Then
  OCMVerify([delegateMock Assets:[MSAssets sharedInstance] willSendEventLog:eventLog]);
  OCMVerify([delegateMock Assets:[MSAssets sharedInstance] didSucceedSendingEventLog:eventLog]);
  OCMVerify([delegateMock Assets:[MSAssets sharedInstance] didFailSendingEventLog:eventLog withError:nil]);
}

- (void)testTrackEventWithoutProperties {

  // If
  __block NSString *name;
  __block NSString *type;
  NSString *expectedName = @"gotACoffee";
  id<MSChannelUnitProtocol> channelUnitMock = OCMProtocolMock(@protocol(MSChannelUnitProtocol));
  id<MSChannelGroupProtocol> channelGroupMock = OCMProtocolMock(@protocol(MSChannelGroupProtocol));
  OCMStub([channelGroupMock addChannelUnitWithConfiguration:OCMOCK_ANY]).andReturn(channelUnitMock);
  OCMStub([channelUnitMock enqueueItem:[OCMArg isKindOfClass:[MSLogWithProperties class]]])
      .andDo(^(NSInvocation *invocation) {
        MSEventLog *log;
        [invocation getArgument:&log atIndex:2];
        type = log.type;
        name = log.name;
      });
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  [[MSAssets sharedInstance] startWithChannelGroup:channelGroupMock
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

  // When
  [MSAssets trackEvent:expectedName];

  // Then
  assertThat(type, is(kMSTypeEvent));
  assertThat(name, is(expectedName));
}

- (void)testTrackEventWhenAssetsDisabled {

  // If
  id AssetsMock = OCMPartialMock([MSAssets sharedInstance]);
  OCMStub([AssetsMock isEnabled]).andReturn(NO);
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  id channelUnitMock = OCMProtocolMock(@protocol(MSChannelUnitProtocol));
  id channelGroupMock = OCMProtocolMock(@protocol(MSChannelGroupProtocol));
  OCMStub([channelGroupMock addChannelUnitWithConfiguration:OCMOCK_ANY]).andReturn(channelUnitMock);
  [[MSAssets sharedInstance] startWithChannelGroup:channelGroupMock
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

  // When
  OCMReject([AssetsMock validateEventName:OCMOCK_ANY forLogType:OCMOCK_ANY]);
  OCMReject([AssetsMock validateProperties:OCMOCK_ANY forLogName:OCMOCK_ANY andType:OCMOCK_ANY]);
  OCMReject([channelUnitMock enqueueItem:OCMOCK_ANY]);
  [[MSAssets sharedInstance] trackEvent:@"Some event" withProperties:nil forTransmissionTarget:nil];
  // Then
  OCMVerifyAll(channelUnitMock);
  OCMVerifyAll(AssetsMock);
}

- (void)testTrackEventWithInvalidName {

  // If
  NSString *invalidEventName = nil;
  id AssetsMock = OCMPartialMock([MSAssets sharedInstance]);
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  id channelUnitMock = OCMProtocolMock(@protocol(MSChannelUnitProtocol));
  id channelGroupMock = OCMProtocolMock(@protocol(MSChannelGroupProtocol));
  OCMStub([channelGroupMock addChannelUnitWithConfiguration:OCMOCK_ANY]).andReturn(channelUnitMock);
  [[MSAssets sharedInstance] startWithChannelGroup:channelGroupMock
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

  // When
  OCMExpect([AssetsMock validateEventName:OCMOCK_ANY forLogType:OCMOCK_ANY]);
  OCMReject([channelUnitMock enqueueItem:OCMOCK_ANY]);
  OCMReject([AssetsMock validateProperties:OCMOCK_ANY forLogName:OCMOCK_ANY andType:OCMOCK_ANY]);
  [[MSAssets sharedInstance] trackEvent:invalidEventName withProperties:nil forTransmissionTarget:nil];

  // Then
  OCMVerifyAll(channelUnitMock);
  OCMVerifyAll(AssetsMock);
}

- (void)testTrackEventWithProperties {

  // If
  __block NSString *type;
  __block NSString *name;
  __block NSDictionary<NSString *, NSString *> *properties;
  NSString *expectedName = @"gotACoffee";
  NSDictionary *expectedProperties = @{ @"milk" : @"yes", @"cookie" : @"of course" };
  id channelUnitMock = OCMProtocolMock(@protocol(MSChannelUnitProtocol));
  id channelGroupMock = OCMProtocolMock(@protocol(MSChannelGroupProtocol));
  OCMStub([channelGroupMock addChannelUnitWithConfiguration:OCMOCK_ANY]).andReturn(channelUnitMock);
  OCMStub([channelUnitMock enqueueItem:[OCMArg isKindOfClass:[MSLogWithProperties class]]])
      .andDo(^(NSInvocation *invocation) {
        MSEventLog *log;
        [invocation getArgument:&log atIndex:2];
        type = log.type;
        name = log.name;
        properties = log.properties;
      });
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  [[MSAssets sharedInstance] startWithChannelGroup:channelGroupMock
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

  // When
  [MSAssets trackEvent:expectedName withProperties:expectedProperties];

  // Then
  assertThat(type, is(kMSTypeEvent));
  assertThat(name, is(expectedName));
  assertThat(properties, is(expectedProperties));
}

- (void)testTrackPageWithoutProperties {

  // If
  __block NSString *name;
  __block NSString *type;
  NSString *expectedName = @"HomeSweetHome";
  id<MSChannelUnitProtocol> channelUnitMock = OCMProtocolMock(@protocol(MSChannelUnitProtocol));
  id<MSChannelGroupProtocol> channelGroupMock = OCMProtocolMock(@protocol(MSChannelGroupProtocol));
  OCMStub([channelGroupMock addChannelUnitWithConfiguration:OCMOCK_ANY]).andReturn(channelUnitMock);
  OCMStub([channelUnitMock enqueueItem:[OCMArg isKindOfClass:[MSLogWithProperties class]]])
      .andDo(^(NSInvocation *invocation) {
        MSEventLog *log;
        [invocation getArgument:&log atIndex:2];
        type = log.type;
        name = log.name;
      });
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  [[MSAssets sharedInstance] startWithChannelGroup:channelGroupMock
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

  // When
  [MSAssets trackPage:expectedName];

  // Then
  assertThat(type, is(kMSTypePage));
  assertThat(name, is(expectedName));
}

- (void)testTrackPageWithProperties {

  // If
  __block NSString *type;
  __block NSString *name;
  __block NSDictionary<NSString *, NSString *> *properties;
  NSString *expectedName = @"HomeSweetHome";
  NSDictionary *expectedProperties = @{ @"Sofa" : @"yes", @"TV" : @"of course" };
  id<MSChannelUnitProtocol> channelUnitMock = OCMProtocolMock(@protocol(MSChannelUnitProtocol));
  id<MSChannelGroupProtocol> channelGroupMock = OCMProtocolMock(@protocol(MSChannelGroupProtocol));
  OCMStub([channelGroupMock addChannelUnitWithConfiguration:OCMOCK_ANY]).andReturn(channelUnitMock);
  OCMStub([channelUnitMock enqueueItem:[OCMArg isKindOfClass:[MSLogWithProperties class]]])
      .andDo(^(NSInvocation *invocation) {
        MSEventLog *log;
        [invocation getArgument:&log atIndex:2];
        type = log.type;
        name = log.name;
        properties = log.properties;
      });
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  [[MSAssets sharedInstance] startWithChannelGroup:channelGroupMock
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

  // When
  [MSAssets trackPage:expectedName withProperties:expectedProperties];

  // Then
  assertThat(type, is(kMSTypePage));
  assertThat(name, is(expectedName));
  assertThat(properties, is(expectedProperties));
}

- (void)testTrackPageWhenAssetsDisabled {

  // If
  id AssetsMock = OCMPartialMock([MSAssets sharedInstance]);
  OCMStub([AssetsMock isEnabled]).andReturn(NO);
  id channelUnitMock = OCMProtocolMock(@protocol(MSChannelUnitProtocol));
  id channelGroupMock = OCMProtocolMock(@protocol(MSChannelGroupProtocol));
  OCMStub([channelGroupMock addChannelUnitWithConfiguration:OCMOCK_ANY]).andReturn(channelUnitMock);

  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  [[MSAssets sharedInstance] startWithChannelGroup:channelGroupMock
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

  // When
  OCMReject([AssetsMock validateEventName:OCMOCK_ANY forLogType:OCMOCK_ANY]);
  OCMReject([AssetsMock validateProperties:OCMOCK_ANY forLogName:OCMOCK_ANY andType:OCMOCK_ANY]);
  OCMReject([channelUnitMock enqueueItem:OCMOCK_ANY]);
  [[MSAssets sharedInstance] trackPage:@"Some page" withProperties:nil];

  // Then
  OCMVerifyAll(channelUnitMock);
  OCMVerifyAll(AssetsMock);
}

- (void)testTrackPageWithInvalidName {

  // If
  NSString *invalidPageName = nil;
  id AssetsMock = OCMPartialMock([MSAssets sharedInstance]);
  id channelUnitMock = OCMProtocolMock(@protocol(MSChannelUnitProtocol));
  id channelGroupMock = OCMProtocolMock(@protocol(MSChannelGroupProtocol));
  OCMStub([channelGroupMock addChannelUnitWithConfiguration:OCMOCK_ANY]).andReturn(channelUnitMock);
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  [[MSAssets sharedInstance] startWithChannelGroup:channelGroupMock
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

  // When
  OCMExpect([AssetsMock validateEventName:OCMOCK_ANY forLogType:OCMOCK_ANY]);
  OCMReject([AssetsMock validateProperties:OCMOCK_ANY forLogName:OCMOCK_ANY andType:OCMOCK_ANY]);
  OCMReject([channelUnitMock enqueueItem:OCMOCK_ANY]);
  [[MSAssets sharedInstance] trackPage:invalidPageName withProperties:nil];

  // Then
  OCMVerifyAll(channelUnitMock);
  OCMVerifyAll(AssetsMock);
}

- (void)testAutoPageTracking {

  // For now auto page tracking is disabled by default
  XCTAssertFalse([MSAssets isAutoPageTrackingEnabled]);

  // When
  [MSAssets setAutoPageTrackingEnabled:YES];

  // Then
  XCTAssertTrue([MSAssets isAutoPageTrackingEnabled]);

  // When
  [MSAssets setAutoPageTrackingEnabled:NO];

  // Then
  XCTAssertFalse([MSAssets isAutoPageTrackingEnabled]);
}

- (void)testInitializationPriorityCorrect {
  XCTAssertTrue([[MSAssets sharedInstance] initializationPriority] == MSInitializationPriorityDefault);
}

- (void)testServiceNameIsCorrect {
  XCTAssertEqual([MSAssets serviceName], kMSAssetsServiceName);
}

- (void)testViewWillAppearSwizzlingWithAssetsAvailable {

  // If
  id AssetsMock = OCMPartialMock([MSAssets sharedInstance]);
  OCMStub([AssetsMock isAutoPageTrackingEnabled]).andReturn(YES);
  OCMStub([AssetsMock isAvailable]).andReturn(YES);
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  [[MSAssets sharedInstance] startWithChannelGroup:OCMProtocolMock(@protocol(MSChannelGroupProtocol))
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

// When
#if TARGET_OS_OSX
  NSViewController *viewController = [[NSViewController alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
  if ([viewController respondsToSelector:@selector(viewWillAppear)]) {
    [viewController viewWillAppear];
  }
#pragma clang diagnostic pop
#else
  UIViewController *viewController = [[UIViewController alloc] init];
  [viewController viewWillAppear:NO];
#endif

  // Then
  OCMVerify([AssetsMock isAutoPageTrackingEnabled]);
  XCTAssertNil([MSAssetsCategory missedPageViewName]);
}

- (void)testViewWillAppearSwizzlingWithAssetsNotAvailable {

  // If
  id AssetsMock = OCMPartialMock([MSAssets sharedInstance]);
  OCMStub([AssetsMock isAutoPageTrackingEnabled]).andReturn(YES);
  OCMStub([AssetsMock isAvailable]).andReturn(NO);
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  [[MSAssets sharedInstance] startWithChannelGroup:OCMProtocolMock(@protocol(MSChannelGroupProtocol))
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

// When
#if TARGET_OS_OSX
  NSViewController *viewController = [[NSViewController alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
  if ([viewController respondsToSelector:@selector(viewWillAppear)]) {
    [viewController viewWillAppear];
  }
#pragma clang diagnostic pop
#else
  UIViewController *viewController = [[UIViewController alloc] init];
  [viewController viewWillAppear:NO];
#endif

  // Then
  OCMVerify([AssetsMock isAutoPageTrackingEnabled]);
  XCTAssertNotNil([MSAssetsCategory missedPageViewName]);
}

- (void)testViewWillAppearSwizzlingWithShouldTrackPageDisabled {

  // If
  id AssetsMock = OCMPartialMock([MSAssets sharedInstance]);
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  [[MSAssets sharedInstance] startWithChannelGroup:OCMProtocolMock(@protocol(MSChannelGroupProtocol))
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:nil];

  // FIXME: logManager holds session tracker somehow and it causes other test failures. Stop it for hack.
  [[MSAssets sharedInstance].sessionTracker stop];

  // When
  OCMExpect([AssetsMock isAutoPageTrackingEnabled]).andReturn(YES);
  OCMReject([AssetsMock isAvailable]);
#if TARGET_OS_OSX
  NSPageController *containerController = [[NSPageController alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
  if ([containerController respondsToSelector:@selector(viewWillAppear)]) {
    [containerController viewWillAppear];
  }
#pragma clang diagnostic pop
#else
  UIPageViewController *containerController = [[UIPageViewController alloc] init];
  [containerController viewWillAppear:NO];
#endif

  // Then
  OCMVerifyAll(AssetsMock);
}

- (void)testStartWithTransmissionTargetAndAppSecretUsesTransmissionTarget {

  // If
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  id<MSChannelUnitProtocol> channelUnitMock = OCMProtocolMock(@protocol(MSChannelUnitProtocol));
  id<MSChannelGroupProtocol> channelGroupMock = OCMProtocolMock(@protocol(MSChannelGroupProtocol));
  __block MSEventLog *log;
  __block int invocations = 0;
  OCMStub([channelGroupMock addChannelUnitWithConfiguration:OCMOCK_ANY]).andReturn(channelUnitMock);
  OCMStub([channelUnitMock enqueueItem:[OCMArg isKindOfClass:[MSLogWithProperties class]]])
      .andDo(^(NSInvocation *invocation) {
        ++invocations;
        [invocation getArgument:&log atIndex:2];
      });
  [[MSAssets sharedInstance] startWithChannelGroup:channelGroupMock
                                            appSecret:kMSTestAppSecret
                              transmissionTargetToken:kMSTestTransmissionToken];

  // When
  [MSAssets trackEvent:@"eventName"];

  // Then
  OCMVerify([channelUnitMock enqueueItem:log]);
  XCTAssertTrue([[log transmissionTargetTokens] containsObject:kMSTestTransmissionToken]);
  XCTAssertEqual([[log transmissionTargetTokens] count], (unsigned long)1);
  XCTAssertEqual(invocations, 1);
}

- (void)testStartWithTransmissionTargetWithoutAppSecretUsesTransmissionTarget {

  // If
  [MSAppCenter configureWithAppSecret:kMSTestAppSecret];
  id<MSChannelUnitProtocol> channelUnitMock = OCMProtocolMock(@protocol(MSChannelUnitProtocol));
  id<MSChannelGroupProtocol> channelGroupMock = OCMProtocolMock(@protocol(MSChannelGroupProtocol));
  __block MSEventLog *log;
  __block int invocations = 0;
  OCMStub([channelGroupMock addChannelUnitWithConfiguration:OCMOCK_ANY]).andReturn(channelUnitMock);
  OCMStub([channelUnitMock enqueueItem:[OCMArg isKindOfClass:[MSLogWithProperties class]]])
      .andDo(^(NSInvocation *invocation) {
        ++invocations;
        [invocation getArgument:&log atIndex:2];
      });
  [[MSAssets sharedInstance] startWithChannelGroup:channelGroupMock
                                            appSecret:nil
                              transmissionTargetToken:kMSTestTransmissionToken];

  // When
  [MSAssets trackEvent:@"eventName"];

  // Then
  OCMVerify([channelUnitMock enqueueItem:log]);
  XCTAssertTrue([[log transmissionTargetTokens] containsObject:kMSTestTransmissionToken]);
  XCTAssertEqual([[log transmissionTargetTokens] count], (unsigned long)1);
  XCTAssertEqual(invocations, 1);
}

- (void)testGetTransmissionTargetCreatesTransmissionTargetOnce {

  // When
  MSAssetsTransmissionTarget *transmissionTarget1 =
      [MSAssets transmissionTargetForToken:kMSTestTransmissionToken];
  MSAssetsTransmissionTarget *transmissionTarget2 =
      [MSAssets transmissionTargetForToken:kMSTestTransmissionToken];

  // Then
  XCTAssertNotNil(transmissionTarget1);
  XCTAssertEqual(transmissionTarget1, transmissionTarget2);
}

- (void)testAppSecretNotRequired {
  XCTAssertFalse([[MSAssets sharedInstance] isAppSecretRequired]);
}

@end
