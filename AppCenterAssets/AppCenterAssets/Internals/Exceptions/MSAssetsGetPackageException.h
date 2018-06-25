#import <Foundation/Foundation.h>
/*
* An exception occurred during getting the package.
*/
@interface MSAssetsGetPackageException : NSException

- (instancetype)init:(NSString *)reason;

@end
