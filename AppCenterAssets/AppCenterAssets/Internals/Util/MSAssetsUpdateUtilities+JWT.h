#import <Foundation/Foundation.h>
#import "MSAssetsUpdateUtilities.h"

@interface MSAssetsUpdateUtilities (JWT)

/**
 * Verifies and decodes JWT.
 *
 * @param jwt       JWT string.
 * @param publicKey public key for verification.
 * @param error error occurred during JWT decoding or verification.
 * @return "claims" value of decoded payload or null if error occurred.
 */
- (NSDictionary *)verifyAndDecodeJWT:(NSString *)jwt
                       withPublicKey:(NSString *)publicKey
                               error:(NSError **)error;

/**
 * Verifies signature of local update.
 *
 * @param folderPath      directory of local update.
 * @param newUpdateHash     remote package hash.
 * @param publicKeyString public key value.
 * @param error error during signature verification.
 * @return `true` if signature valid, `false` otherwise.
 */
- (BOOL)verifyUpdateSignatureFor:(NSString *)folderPath
                    expectedHash:(NSString *)newUpdateHash
                   withPublicKey:(NSString *)publicKeyString
                           error:(NSError **)error;

/**
 * Returns JWT file path of local update.
 *
 * @param updateFolderPath local update directory path.
 * @return JWT file path of update.
 */
- (NSString *)getSignatureFilePath:(NSString *)updateFolderPath;

/**
 * Returns JWT content of local update.
 *
 * @param folderPath local update directory path.
 * @param error error during signature verification.
 * @return JWT content of update.
 */
- (NSString *)getSignatureFor:(NSString *)folderPath
                        error:(NSError **)error;

/**
 * Parses public key from string.
 *
 * @param publicKeyString input public key value.
 * @return parsed value of public key.
 */
- (NSString *)getKeyValueFromPublicKeyString:(NSString *)publicKeyString;

@end
