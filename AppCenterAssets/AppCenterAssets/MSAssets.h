#import "MSServiceAbstract.h"
#import "MSAssetsBuilder.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSAssetsAPI : NSObject

- (NSDictionary *)checkForUpdate:(NSString *)deploymentKey;

@property (nonatomic, copy) NSString *deploymentKey;
@property (nonatomic, copy) NSString *serverUrl;
@property (nonatomic, copy) NSString *updateSubFolder;

@end


/**
 * App Center Assets service.
 */
@interface MSAssets : MSServiceAbstract

+ (MSAssetsAPI *)initAPIWithBuilder:(MSAssetsBuilder *)builder;

+ (MSAssetsAPI *)makeAPIWithBuilder:(void (^)(MSAssetsBuilder *))builder;;

@end

NS_ASSUME_NONNULL_END
