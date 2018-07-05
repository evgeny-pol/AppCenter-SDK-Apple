#import "MSAssets.h"
#import "MSChannelGroupProtocol.h"
#import "MSChannelUnitConfiguration.h"
#import "MSChannelUnitProtocol.h"
#import "MSConstants+Internal.h"
#import "MSServiceAbstractProtected.h"
#import "AppCenter+Internal.h"
#import "MSAssetsDeploymentInstance.h"
#import "MSAssetsiOSPlatformSpecificImplementation.h"

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

#pragma mark - Public methods

+ (MSAssetsDeploymentInstance *)makeDeploymentInstanceWithBuilder:(void (^)(MSAssetsBuilder *))updateBlock {
    MSAssetsBuilder *builder = [MSAssetsBuilder new];
    updateBlock(builder);
    
    MSAssetsDeploymentInstance *assetsDeploymentInstance = [[MSAssetsDeploymentInstance alloc] initWithEntryPoint:builder.updateSubFolder
                                                                                                        publicKey:@""
                                                                                                 platformInstance: [MSAssetsiOSPlatformSpecificImplementation new]];
    [assetsDeploymentInstance setServerUrl:builder.serverUrl];
    [assetsDeploymentInstance setDeploymentKey:builder.deploymentKey];
    [assetsDeploymentInstance setUpdateSubFolder:builder.updateSubFolder];
    
    return assetsDeploymentInstance;
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
