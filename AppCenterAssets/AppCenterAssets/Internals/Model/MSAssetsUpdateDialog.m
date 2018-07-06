#import <Foundation/Foundation.h>
#import "MSAssetsUpdateDialog.h"

static NSString *const kMSDescriptionPrefix = @"descriptionPrefix";
static NSString *const kMSMandatoryContinueButtonLabel = @"mandatoryContinueButtonLabel";
static NSString *const kMSAppendReleaseDescription = @"appendReleaseDescription";
static NSString *const kMSMandatoryUpdateMessage = @"mandatoryUpdateMessage";
static NSString *const kMSOptionalIgnoreButtonLabel = @"optionalIgnoreButtonLabel";
static NSString *const kMSOptionalInstallButtonLabel = @"optionalInstallButtonLabel";
static NSString *const kMSOptionalUpdateMessage = @"optionalUpdateMessage";
static NSString *const kMSTitle = @"title";

@implementation MSAssetsUpdateDialog

- (instancetype)init {
    self = [super init];
    _descriptionPrefix = @"Description: ";
    _mandatoryContinueButtonLabel = @"Continue";
    _mandatoryUpdateMessage = @"An update is available that must be installed.";
    _optionalIgnoreButtonLabel = @"Ignore";
    _optionalInstallButtonLabel = @"Install";
    _optionalUpdateMessage = @"An update is available. Would you like to install it?";
    _title = @"Update available";
    _appendReleaseDescription = NO;
    return self;
}

- (NSMutableDictionary *)serializeToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    if (self.descriptionPrefix) {
        dict[kMSDescriptionPrefix] = self.descriptionPrefix;
    }
    dict[kMSAppendReleaseDescription] = @(self.appendReleaseDescription);
    if (self.mandatoryContinueButtonLabel) {
        dict[kMSMandatoryContinueButtonLabel] = self.mandatoryContinueButtonLabel;
    }
    if (self.mandatoryUpdateMessage) {
        dict[kMSMandatoryUpdateMessage] = self.mandatoryUpdateMessage;
    }
    if (self.optionalUpdateMessage) {
        dict[kMSOptionalUpdateMessage] = self.optionalUpdateMessage;
    }
    if (self.optionalIgnoreButtonLabel) {
        dict[kMSOptionalIgnoreButtonLabel] = self.optionalIgnoreButtonLabel;
    }
    if (self.optionalInstallButtonLabel) {
        dict[kMSOptionalInstallButtonLabel] = self.optionalInstallButtonLabel;
    }
    if (self.title) {
        dict[kMSTitle] = self.title;
    }
    return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _descriptionPrefix = [coder decodeObjectForKey:kMSDescriptionPrefix];
        _mandatoryUpdateMessage = [coder decodeObjectForKey:kMSMandatoryUpdateMessage];
        _mandatoryContinueButtonLabel = [coder decodeObjectForKey:kMSMandatoryContinueButtonLabel];
        _optionalUpdateMessage = [coder decodeObjectForKey:kMSOptionalUpdateMessage];
        _optionalInstallButtonLabel = [coder decodeObjectForKey:kMSOptionalInstallButtonLabel];
        _optionalIgnoreButtonLabel = [coder decodeObjectForKey:kMSOptionalIgnoreButtonLabel];
        _title = [coder decodeObjectForKey:kMSTitle];
        _appendReleaseDescription = [coder decodeBoolForKey:kMSAppendReleaseDescription];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.descriptionPrefix forKey:kMSDescriptionPrefix];
    [coder encodeObject:self.mandatoryUpdateMessage forKey:kMSMandatoryUpdateMessage];
    [coder encodeObject:self.mandatoryContinueButtonLabel forKey:kMSMandatoryContinueButtonLabel];
    [coder encodeObject:self.optionalInstallButtonLabel forKey:kMSOptionalInstallButtonLabel];
    [coder encodeObject:self.optionalUpdateMessage forKey:kMSOptionalUpdateMessage];
    [coder encodeObject:self.optionalIgnoreButtonLabel forKey:kMSOptionalIgnoreButtonLabel];
    [coder encodeObject:self.title forKey:kMSTitle];
    [coder encodeBool:self.appendReleaseDescription forKey:kMSAppendReleaseDescription];
}

@end
