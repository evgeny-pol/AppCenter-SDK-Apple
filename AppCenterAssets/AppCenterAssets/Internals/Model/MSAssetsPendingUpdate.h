#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"

/**
 * Contains info about pending update.
 */
@interface MSAssetsPendingUpdate : NSObject <MSSerializableObject>

/**
 * Whether the update is loading.
 */
@property(nonatomic) BOOL isLoading;

/**
 * Pending update package hash.
 */
@property(nonatomic, copy) NSString *pendingUpdateHash;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
