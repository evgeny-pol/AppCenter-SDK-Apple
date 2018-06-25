#import <Foundation/Foundation.h>
#import "MSAssetsSignatureVerificationException.h"
#import "MSSignatureExceptionType.h"

@implementation MSAssetsSignatureVerificationException

- (instancetype)initWithType:(MSSignatureExceptionType)type reason:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@", [self getSignatureExceptionMessage: type], reason];
    self = [super initWithName:@"MSAssetsFinalizeException" reason: newReason userInfo: nil];
    return self;
}

- (instancetype)initWithType:(MSSignatureExceptionType)type {
    self = [super initWithName:@"MSAssetsFinalizeException" reason: [self getSignatureExceptionMessage: type] userInfo: nil];
    return self;
}

- (instancetype)init:(NSString *)reason {
    NSString * newReason = [[NSString alloc] initWithFormat:@"%@ %@", [self getSignatureExceptionMessage: MSSignatureExceptionTypeDefault], reason];
    self = [super initWithName:@"MSAssetsSignatureVerificationException" reason: newReason userInfo: nil];
    return self;
}

- (NSString *)getSignatureExceptionMessage:(MSSignatureExceptionType)type {
    switch (type) {
        case MSSignatureExceptionTypeNoSignature:
            return @"Error! Public key was provided but there is no JWT signature within app to verify. \
            Possible reasons, why that might happen: \
            1. You've released an update using version of CodePush CLI that does not support code signing.\
            2. You've released an update without providing --privateKeyPath option.";
        case MSSignatureExceptionTypeNotSigned:
            return @"Signature was not signed by a trusted party.";
        case MSSignatureExceptionTypePublicKeyNotParsed:
            return @"Unable to parse public key.";
        case MSSignatureExceptionTypeReadSignatureFileError:
        case MSSignatureExceptionTypeNoContentHash:
            return @"Unable to read signature file.";
        case MSSignatureExceptionTypeDefault:
        default:
            return @"Error occurred during signature verification.";
    }
}
@end
