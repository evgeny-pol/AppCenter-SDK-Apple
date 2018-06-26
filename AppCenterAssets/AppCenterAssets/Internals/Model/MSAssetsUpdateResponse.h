#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"
#import "MSAssetsUpdateResponseUpdateInfo.h"

/**
 * A response class containing info about the update.
 */
@interface MSAssetsUpdateResponse : NSObject <MSSerializableObject>

/**
 * Information about the existing update.
 */
@property(nonatomic) MSUpdateResponseUpdateInfo *updateInfo;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
