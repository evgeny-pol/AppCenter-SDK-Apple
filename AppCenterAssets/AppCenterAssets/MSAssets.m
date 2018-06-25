#import "MSAssets.h"
#import "MSChannelGroupProtocol.h"
#import "MSChannelUnitConfiguration.h"
#import "MSChannelUnitProtocol.h"
#import "MSConstants+Internal.h"
#import "MSServiceAbstractProtected.h"
#import "AppCenter+Internal.h"

// Service name for initialization.
static NSString *const kMSServiceName = @"Assets";

// The group Id for storage.
static NSString *const kMSGroupId = @"Assets";

// Singleton
static MSAssets *sharedInstance = nil;
static dispatch_once_t onceToken;

@implementation MSAssets

#pragma mark - Service initialization

- (instancetype)init {
  if ((self = [super init])) {
      
  }
  return self;
}

+ (MSAssetsAPI *)initAPIWithBuilder:(MSAssetsBuilder *)builder {
    MSAssetsAPI *publicAssetsApi = [[MSAssetsAPI alloc] init];
    [publicAssetsApi setServerUrl:builder.serverUrl];
    [publicAssetsApi setDeploymentKey:builder.deploymentKey];
    [publicAssetsApi setUpdateSubFolder:builder.updateSubFolder];
    return publicAssetsApi;
}

+ (MSAssetsAPI *)makeAPIWithBuilder:(void (^)(MSAssetsBuilder *))updateBlock {
    MSAssetsBuilder *builder = [MSAssetsBuilder new];
    updateBlock(builder);
    return [self initAPIWithBuilder:builder];
}

#pragma mark - MSServiceInternal

+ (instancetype)sharedInstance {
  dispatch_once(&onceToken, ^{
    if (sharedInstance == nil) {
      sharedInstance = [[self alloc] init];
    }
  });
  return sharedInstance;
}

+ (NSString *)serviceName {
  return kMSServiceName;
}

- (void)startWithChannelGroup:(id<MSChannelGroupProtocol>)channelGroup
                    appSecret:(nullable NSString *)appSecret
      transmissionTargetToken:(nullable NSString *)token {
    [super startWithChannelGroup:channelGroup appSecret:appSecret transmissionTargetToken:token];
    MSLogVerbose([MSAssets logTag], @"Started Assets service.");
}

+ (NSString *)logTag {
  return @"AppCenterAssets";
}

- (NSString *)groupId {
  return kMSGroupId;
}

#pragma mark - MSServiceAbstract

- (void)applyEnabledState:(BOOL)isEnabled {
    [super applyEnabledState:isEnabled];

    if (isEnabled) {
        MSLogInfo([MSAssets logTag], @"Asset service has been enabled.");
    } else {
        MSLogInfo([MSAssets logTag], @"Asset service has been disabled.");
    }
}

- (BOOL)isAppSecretRequired {
  return NO;
}


@end
