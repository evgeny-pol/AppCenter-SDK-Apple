#import <Foundation/Foundation.h>

@interface MSAssetsPendingUpdate

/**
 * Whether the update is loading.
 */
@property(nonatomic, copy) BOOL isLoading;

/**
 * Pending update package hash.
 */
@property(nonatomic, copy) NSString *hash;

@end
