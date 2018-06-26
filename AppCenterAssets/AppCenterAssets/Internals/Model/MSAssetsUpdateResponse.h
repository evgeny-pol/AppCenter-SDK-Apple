#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"
#import "MSAssetsUpdateResponseUpdateInfo.h"

@interface MSAssetsUpdateResponse : NSObject <MSSerializableObject>

/**
 * Information about the existing update.
 */
@property(nonatomic) MSUpdateResponseUpdateInfo *updateInfo;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
