#import <Foundation/Foundation.h>

@class MSEventLog;
@class MSPageLog;
@class MSAssets;

@protocol MSAssetsDelegate <NSObject>

@optional

/**
 * Callback method that will be called before each event log is sent to the server.
 *
 * @param Assets The instance of MSAssets.
 * @param eventLog The event log that will be sent.
 */
- (void)Assets:(MSAssets *)Assets willSendEventLog:(MSEventLog *)eventLog;

/**
 * Callback method that will be called in case the SDK was able to send an event log to the server.
 * Use this method to provide custom behavior.
 *
 * @param Assets The instance of MSAssets.
 * @param eventLog The event log that App Center sent.
 */
- (void)Assets:(MSAssets *)Assets didSucceedSendingEventLog:(MSEventLog *)eventLog;

/**
 * Callback method that will be called in case the SDK was unable to send an event log to the server.
 *
 * @param Assets The instance of MSAssets.
 * @param eventLog The event log that App Center tried to send.
 * @param error The error that occurred.
 */
- (void)Assets:(MSAssets *)Assets didFailSendingEventLog:(MSEventLog *)eventLog withError:(NSError *)error;

/**
 * Callback method that will be called before each page log is sent to the server.
 *
 * @param Assets The instance of MSAssets.
 * @param pageLog The page log that will be sent.
 */
- (void)Assets:(MSAssets *)Assets willSendPageLog:(MSPageLog *)pageLog;

/**
 * Callback method that will be called in case the SDK was able to send a page log to the server.
 * Use this method to provide custom behavior.
 *
 * @param Assets The instance of MSAssets.
 * @param pageLog The page log that App Center sent.
 */
- (void)Assets:(MSAssets *)Assets didSucceedSendingPageLog:(MSPageLog *)pageLog;

/**
 * Callback method that will be called in case the SDK was unable to send a page log to the server.
 *
 * @param Assets The instance of MSAssets.
 * @param pageLog The page log that App Center tried to send.
 * @param error The error that occurred.
 */
- (void)Assets:(MSAssets *)Assets didFailSendingPageLog:(MSPageLog *)pageLog withError:(NSError *)error;

@end
