#import <Foundation/Foundation.h>
#import "MSSerializableObject.h"

/**
 * An "options" object used to determine whether a confirmation dialog should be displayed to the end user when an update is available,
 * and if so, what strings to use. Defaults to null, which has the effect of disabling the dialog completely. Setting this to any truthy
 * value will enable the dialog with the default strings, and passing an object to this parameter allows enabling the dialog as well as
 * overriding one or more of the default strings.
 */
@interface MSAssetsUpdateDialog : NSObject <MSSerializableObject>

/**
 * Indicates whether you would like to append the description of an available release to the
 * notification message which is displayed to the end user.
 * Defaults to `false`.
 */
@property(nonatomic) BOOL appendReleaseDescription;

/**
 * Indicates the string you would like to prefix the release description with, if any, when
 * displaying the update notification to the end user.
 * Defaults to `Description: `.
 */
@property(nonatomic, copy) NSString *descriptionPrefix;

/**
 * The text to use for the button the end user must press in order to install a mandatory update.
 * Defaults to `Continue`.
 */
@property(nonatomic, copy) NSString *mandatoryContinueButtonLabel;

/**
 * The text used as the body of an update notification, when the update is specified as mandatory.
 * Defaults to `An update is available that must be installed.`.
 */
@property(nonatomic, copy) NSString *mandatoryUpdateMessage;

/**
 * The text to use for the button the end user can press in order to ignore an optional update that is available.
 * Defaults to `Ignore`.
 */
@property(nonatomic, copy) NSString *optionalIgnoreButtonLabel;

/**
 * The text to use for the button the end user can press in order to install an optional update.
 * Defaults to `Install`.
 */
@property(nonatomic, copy) NSString *optionalInstallButtonLabel;

/**
 * The text used as the body of an update notification, when the update is optional.
 * Defaults to `An update is available. Would you like to install it?`.
 */
@property(nonatomic, copy) NSString *optionalUpdateMessage;

/**
 * The text used as the header of an update notification that is displayed to the end user.
 * Defaults to `Update available`.
 */
@property(nonatomic, copy) NSString *title;

@end
