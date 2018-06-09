#import <Foundation/Foundation.h>
#import "MSAssetsTransmissionTarget.h"

@interface MSAssetsTransmissionTarget ()

/**
 * The transmission target token corresponding to this transmission target.
 */
@property(nonatomic) NSString *transmissionTargetToken;

- (instancetype)initWithTransmissionTargetToken:(NSString *)token;

@end
