
typedef NS_ENUM(NSString, MSSignatureExceptionType) {
    MSSignatureExceptionTypeNoSignature = @"Error! Public key was provided but there is no JWT signature within app to verify. \n" +
    "                                    Possible reasons, why that might happen: \n" +
    "                                    1. You've released an update using version of CodePush CLI that does not support code signing.\n" +
    "                                    2. You've released an update without providing --privateKeyPath option.",
    MSSignatureExceptionTypeNotSigned = @"Signature was not signed by a trusted party.",
    MSSignatureExceptionTypePublicKeyNotParsed = @"Unable to parse public key.",
    MSSignatureExceptionTypeReadSignatureFileError = @"Unable to read signature file.",
    MSSignatureExceptionTypeNoContentHash = @"Unable to read signature file.",
    MSSignatureExceptionTypeDefault = @"Error occurred during signature verification."
};
