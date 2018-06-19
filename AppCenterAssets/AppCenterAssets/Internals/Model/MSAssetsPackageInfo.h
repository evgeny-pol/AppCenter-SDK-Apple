#import <Foundation/Foundation.h>

@interface MSAssetsPackageInfo

/**
 * Currently installed package hash.
 */
@property(nonatomic, copy) NSString *currentPackage;

/**
 * Package hash of the update installed before the current.
 */
@property(nonatomic, copy) NSString *previousPackage;

@end

