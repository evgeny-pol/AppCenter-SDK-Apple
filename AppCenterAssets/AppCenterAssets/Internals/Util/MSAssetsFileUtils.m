#import "MSAssetsFileUtils.h"
#import "SSZipArchive.h"

@implementation MSAssetsFileUtils

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination
{
    return [SSZipArchive unzipFileAtPath:path
                    toDestination:destination];
}

@end
