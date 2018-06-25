#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"

@interface MSAssetsPendingUpdate : NSObject <MSSerializableObject>

/**
 * Whether the update is loading.
 */
@property(nonatomic) BOOL isLoading;

/**
 * Pending update package hash.
 */
@property(nonatomic, copy) NSString *pendingUpdateHash;

@end
