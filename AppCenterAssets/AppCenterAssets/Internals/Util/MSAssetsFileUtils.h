#import <Foundation/Foundation.h>

@interface MSAssetsFileUtils : NSObject

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination;

@end
