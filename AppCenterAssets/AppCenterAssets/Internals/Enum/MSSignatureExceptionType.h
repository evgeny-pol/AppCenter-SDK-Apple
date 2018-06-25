
typedef NS_ENUM(NSInteger, MSSignatureExceptionType) {
    MSSignatureExceptionTypeNoSignature = 0,
    MSSignatureExceptionTypeNotSigned = 1,
    MSSignatureExceptionTypePublicKeyNotParsed = 2,
    MSSignatureExceptionTypeReadSignatureFileError = 3,
    MSSignatureExceptionTypeNoContentHash = 4,
    MSSignatureExceptionTypeDefault = 5
};
