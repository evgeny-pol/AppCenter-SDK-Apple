#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"

/**
 * Contains information about packages available for user.
 */
@interface MSAssetsPackageInfo : NSObject <MSSerializableObject>

/**
 * Currently installed package hash.
 */
@property(nonatomic, copy) NSString *currentPackage;

/**
 * Package hash of the update installed before the current.
 */
@property(nonatomic, copy) NSString *previousPackage;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

