#import <Foundation/Foundation.h>

/**
 * Exception class for handling {@link AssetsPlatformUtils} exceptions.
 */
@interface MSAssetsPlatformUtilsException : NSException

- (instancetype)init:(NSString *)reason;

@end
