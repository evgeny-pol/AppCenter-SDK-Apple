#import "MSAssets.h"
#import "MSChannelGroupProtocol.h"
#import "MSChannelUnitConfiguration.h"
#import "MSChannelUnitProtocol.h"
#import "MSConstants+Internal.h"
#import "MSServiceAbstractProtected.h"
#import "AppCenter+Internal.h"
#import "MSAssetsDeploymentInstance.h"
#import "MSAssetsiOSSpecificImplementation.h"

// Service name for initialization.
static NSString *const kMSServiceName = @"Assets";

// The group Id for storage.
static NSString *const kMSGroupId = @"Assets";

// Singleton
static MSAssets *sharedInstance = nil;
static dispatch_once_t onceToken;
static id<MSAssetsPlatformSpecificImplementation> platformImpl;

@implementation MSAssets {
    
}

#pragma mark - Service initialization

- (instancetype)init {
  if ((self = [super init])) {
      platformImpl = [[MSAssetsiOSSpecificImplementation alloc] init];
  }
  return self;
}

#pragma mark - Public methods

+ (MSAssetsDeploymentInstance *)makeDeploymentInstanceWithBuilder:(void (^)(MSAssetsBuilder *))updateBlock error:(NSError * __autoreleasing*)error {
    MSAssetsBuilder *builder = [MSAssetsBuilder new];
    updateBlock(builder);
    MSAssetsDeploymentInstance *assetsDeploymentInstance = [[MSAssetsDeploymentInstance alloc] initWithEntryPoint:builder.updateSubFolder
                                                                                                        publicKey:builder.publicKey
                                                                                                    deploymentKey:builder.deploymentKey
                                                                                                      inDebugMode:NO
                                                                                                        serverUrl:builder.serverUrl
                                                                                                 platformInstance:platformImpl
                                                                                                        withError:error];
    if (*error) {
        return nil;
    }
    return assetsDeploymentInstance;
}

+ (void) setPlatformImplementation:(id<MSAssetsPlatformSpecificImplementation>)impl {
    platformImpl = impl;
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
