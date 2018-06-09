#import "MSAssetsTransmissionTargetInternal.h"
#import "MSAssetsInternal.h"

@implementation MSAssetsTransmissionTarget

- (instancetype)initWithTransmissionTargetToken:(NSString *)transmissionTargetToken {
  self = [super init];
  if (self) {
    self.transmissionTargetToken = transmissionTargetToken;
  }
  return self;
}

/**
 * Track an event.
 *
 * @param eventName  event name.
 */
- (void)trackEvent:(NSString *)eventName {
  [MSAssets trackEvent:eventName forTransmissionTarget:self];
}

/**
 * Track an event.
 *
 * @param eventName  event name.
 * @param properties dictionary of properties.
 */
- (void)trackEvent:(NSString *)eventName withProperties:(nullable NSDictionary<NSString *, NSString *> *)properties {
  [MSAssets trackEvent:eventName withProperties:properties forTransmissionTarget:self];
}

@end
