#import <Foundation/Foundation.h>
#import "MSAssetsFinalizeException.h"
#import "MSOperationType.h"

@implementation MSAssetsFinalizeException

- (instancetype)init:(MSOperationType)type reason:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@", [self getOperationMessage: type], reason];
    self = [super initWithName:@"MSAssetsFinalizeException" reason: newReason userInfo: nil];
    return self;
}

- (instancetype)init:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@", [self getOperationMessage: MsOperationTypeDefault], reason];
    self = [super initWithName:@"MSAssetsFinalizeException" reason: newReason userInfo: nil];
    return self;
}

- (NSString *)getOperationMessage:(MSOperationType)type {
    switch (type) {
        case MsOperationTypeRead:
            return @"Error closing IO resources when reading file.";
        case MsOperationTypeCopy:
            return @"Error closing IO resources when copying files.";
        case MsOperationTypeWrite:
            return @"Error closing IO resources when writing to a file.";
        case MsOperationTypeDefault:
        default:
            return @"Error closing IO resources.";
    }
}
@end
