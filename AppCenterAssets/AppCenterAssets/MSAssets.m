#import "MSAssets.h"
#import "MSChannelGroupProtocol.h"
#import "MSChannelUnitConfiguration.h"
#import "MSChannelUnitProtocol.h"
#import "MSConstants+Internal.h"
#import "MSServiceAbstractProtected.h"

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

+ (NSString *)logTag {
  return @"AppCenterAssets";
}

- (NSString *)groupId {
  return kMSGroupId;
}

#pragma mark - MSServiceAbstract

- (void)applyEnabledState:(BOOL)isEnabled {
    if (isEnabled){
        
    }
}

- (BOOL)isAppSecretRequired {
  return NO;
}

@end
