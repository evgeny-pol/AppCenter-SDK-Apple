#import <Foundation/Foundation.h>
#import "JWT.h"
#import "MSLogger.h"
#import "MSAssetsErrorUtils.h"
#import "MSUtility+File.h"
#import "MSAssets.h"
#import "MSAssetsUpdateUtilities+JWT.h"

NSString *const BundleJWTFile = @".codepushrelease";
@implementation MSAssetsUpdateUtilities (JWT)

- (NSDictionary *) verifyAndDecodeJWT:(NSString *)jwt
                        withPublicKey:(NSString *)publicKey
                                error:(NSError * __autoreleasing *)error {
    id <JWTAlgorithmDataHolderProtocol> verifyDataHolder = [JWTAlgorithmRSFamilyDataHolder new].keyExtractorType([JWTCryptoKeyExtractor publicKeyWithPEMBase64].type).algorithmName(@"RS256").secret(publicKey);
    
    JWTCodingBuilder *verifyBuilder = [JWTDecodingBuilder decodeMessage:jwt].addHolder(verifyDataHolder);
    JWTCodingResultType *verifyResult = verifyBuilder.result;
    if (verifyResult.successResult) {
        return verifyResult.successResult.payload;
    }
    else {
        *error = verifyResult.errorResult.error;
        return nil;
    }
}

- (NSString *)getKeyValueFromPublicKeyString:(NSString *)publicKeyString {
    publicKeyString = [publicKeyString stringByReplacingOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----\n"
                                                                 withString:@""];
    publicKeyString = [publicKeyString stringByReplacingOccurrencesOfString:@"-----END PUBLIC KEY-----"
                                                                 withString:@""];
    publicKeyString = [publicKeyString stringByReplacingOccurrencesOfString:@"\n"
                                                                 withString:@""];
    
    return publicKeyString;
}

- (BOOL)verifyUpdateSignatureFor:(NSString *)folderPath
                    expectedHash:(NSString *)newUpdateHash
                   withPublicKey:(NSString *)publicKeyString
                           error:(NSError * __autoreleasing *)error {
    MSLogInfo([MSAssets logTag], @"Verifying signature for folder path: %@", folderPath);
    
    NSString *publicKey = [self getKeyValueFromPublicKeyString: publicKeyString];
    
    NSError *signatureVerificationError;
    NSString *signature = [self getSignatureFor: folderPath
                                          error: &signatureVerificationError];
    if (signatureVerificationError) {
        MSLogError([MSAssets logTag], @"The update could not be verified because no signature was found. %@", signatureVerificationError);
        *error = signatureVerificationError;
        return NO;
    }
    
    NSError *payloadDecodingError;
    NSDictionary *envelopedPayload = [self verifyAndDecodeJWT:signature withPublicKey:publicKey error:&payloadDecodingError];
    if(payloadDecodingError){
        MSLogError([MSAssets logTag], @"The update could not be verified because it was not signed by a trusted party. %@", payloadDecodingError);
        *error = payloadDecodingError;
        return NO;
    }
    
    MSLogInfo([MSAssets logTag], @"JWT signature verification succeeded, payload content:  %@", envelopedPayload);
    
    if(![envelopedPayload objectForKey:@"contentHash"]){
        *error = [MSAssetsErrorUtils getNoContentHashError];
        return NO;
    }
    
    NSString *contentHash = envelopedPayload[@"contentHash"];
    
    return [contentHash isEqualToString:newUpdateHash];
}

- (NSString *)getSignatureFilePath:(NSString *)updateFolderPath {
    NSString *jwtPath = [NSString stringWithFormat:@"%@/%@", updateFolderPath, BundleJWTFile];
    if ([MSUtility fileExistsForPathComponent:jwtPath]) {
        return jwtPath;
    } else {
        NSArray<NSURL *> *contents = [MSUtility contentsOfDirectory:updateFolderPath propertiesForKeys:nil];
        for (NSURL *content in contents) {
            if ([content hasDirectoryPath]) {
                NSString *fileName = [content lastPathComponent];
                NSString *path = [self getSignatureFilePath:[updateFolderPath stringByAppendingPathComponent:fileName]];
                if (path != nil) {
                    return path;
                }
            }
        }
    }
    return nil;
}

- (NSString *)getSignatureFor:(NSString *)folderPath
                        error:(NSError * __autoreleasing *)error {
    NSString *signatureFilePath = [self getSignatureFilePath:folderPath];
    if ([MSUtility fileExistsForPathComponent:signatureFilePath]) {
        return [[NSString alloc] initWithData:[MSUtility loadDataForPathComponent:signatureFilePath] encoding:NSUTF8StringEncoding];
    } else {
        *error = [MSAssetsErrorUtils getNoSignatureError:[folderPath stringByAppendingPathComponent:BundleJWTFile]];
        return nil;
    }
}
@end
