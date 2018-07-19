#import <Foundation/Foundation.h>

@interface MSAssetsBuilder : NSObject

@property (nonatomic, copy) NSString *deploymentKey;
@property (nonatomic, copy) NSString *serverUrl;
@property (nonatomic, copy) NSString *updateSubFolder;
@property (nonatomic, copy) NSString *publicKey;
@property (nonatomic, copy) NSString *baseDir;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *appVersion;

@end
