#import <Foundation/Foundation.h>
#import <Lookback/LookbackSettingsViewController.h>
#import <Lookback/LookbackRecordingViewController.h>

/*! @header Lookback Public API
    Public interface for Lookback, the UX testing tool that records your screen
    and camera and uploads it to http://lookback.io for further study.
*/

/*! @class Lookback

    Lookback should be +[Lookback @link setupWithAppToken: @/link] before being used. After
    that, you can set its [Lookback @link enabled @/link] property to start and stop recording
    at any time. You can use @link LookbackSettingsViewController @/link to provide a user
    interface to do so.
    
    Rather than doing so manually, you can set -[Lookback @link shakeToRecord @/link] to
    display this UI whenever you shake your device.
*/
@interface Lookback : NSObject

#pragma mark Setup

/*! In your applicationDidFinishLaunching: or similar, call this method to prepare
    Lookback for use, using the App Token from your integration guide at lookback.io.
    @param appToken A string identifying your app, received from your app settings at http://lookback.io
*/
+ (void)setupWithAppToken:(NSString*)appToken;

/*! Shared instance of Lookback to use from your code. You must call
    +[Lookback @link setupWithAppToken:@/link] before calling this method.
 */
+ (Lookback*)sharedLookback;

/*! Deprecated: use @link sharedLookback @/link instead. This is because Swift
	disallows the use of a static method with the same name as the class that isn't
	a constructor.
 */
+ (Lookback*)lookback;

#pragma mark Recording

/*! Whether Lookback is set to recording. You can either set this programmatically,
    or use @link LookbackSettingsViewController @/link to let the user activate it.
 */
@property(nonatomic) BOOL enabled;

/*! If enabled, displays UI to start recording when you shake the device. Default NO.
    
    @discussion This is just a convenience method. It's roughly equivalent to implementing
    -[motionEnded:withEvent:] in your first responder, and modally displaying a
    LookbackSettingsViewController on the window's root view controller.
*/
@property(nonatomic) BOOL shakeToRecord;

/*! Is Lookback paused? Lookback will pause automatically when app is inactive.
    The value of this property is undefined if recording is not enabled (as there
    is nothing to pause).
 */
@property(nonatomic,getter=isPaused) BOOL paused;

/*! Lookback automatically sets a screen recording framerate that is suitable for your
	device. However, if your app is very performance intense, you might want to decrease
	the framerate at which Lookback records to free up some CPU time for your app. This
	multiplier lets you adapt the framerate that Lookback chooses for you to something
	more suitable for your app.
	
	Default value: 1.0
	Range: 0.1 to 1.0
	
	@see LookbackScreenRecorderFramerateLimitKey
*/
@property(nonatomic) float framerateMultiplier;

#pragma mark Metadata

/*! Identifier for the user who's currently using the app. You can filter on
    this property at lookback.io later. If your service has log in user names,
    you can use that here. Optional.
    @seealso http://lookback.io/docs/log-username
*/
@property(nonatomic,copy) NSString *userIdentifier;

/*! Track user navigation manually, if automatic tracking has been disabled.
    @see LookbackAutomaticallyLogViewAppearance
    @param viewIdentifier Unique human readable identifier for a specific view
*/
- (void)enteredView:(NSString*)viewIdentifier;

/*! Track user navigation manually, if automatic tracking has been disabled.
    @see LookbackAutomaticallyLogViewAppearance
    @param viewIdentifier Unique human readable identifier for a specific view
*/
- (void)exitedView:(NSString*)viewIdentifier;

/*!	You might want to track events beyond user navigation; such as errors,
    user interaction milestones, network events, etc. Call this method whenever
	such an event is happening, and if a recording is taking place, the event
	will be attached to the timeline of that recording.
	
	@example <pre>
		[[Lookback_Weak lookback]
			logEvent:@"Playback Error"
			eventInfo:[NSString stringWithFormat:@"%d: %@",
				error.errorCode, error.localizedDescription]
		];
	
	@param event     The name of the event: this is the string that will show up
					 on the timeline.
	@param eventInfo Additional information about the event, for example error
	                 code, interaction variation, etc.
*/
- (void)logEvent:(NSString*)event eventInfo:(NSString*)eventInfo;


// For debugging
@property(nonatomic,readonly) NSString *appToken;

@end

/*! If you only want to use Lookback in builds sent to testers (e g by using the
    CocoaPods :configurations=> feature), you need to avoid both linking with
    Lookback.framework and calling any Lookback code (since that would create
    a linker error). By making all your calls to Lookback_Weak instead of
    Lookback, your calls will be disabled when not linking with Lookback, and
    you thus avoid linker errors.
 
    @example <pre>
        [Lookback_Weak setupWithAppToken:@"<MYAPPTOKEN>"];
        [Lookback_Weak lookback].shakeToRecord = YES;
        
        [[Lookback_Weak lookback] enteredView:@"Settings"];
        </pre>
*/
#define Lookback_Weak (NSClassFromString(@"Lookback"))


#pragma mark UIKit extensions

/*!
 *  Lookback-specific extenions to UIView.
 */
@interface UIView (LookbackConcealing)

/*! @discussion If set to YES, the receiver will be covered by a red rectangle in recordings
	you make with Lookback. This is useful for hiding sensitive user
    data. Secure text fields are automatically concealed when focused.
	
	@example <pre>
		- (void)viewDidLoad {
			if([Lookback_Weak lookback]) { // don't set lookback properties if lookback isn't available
				self.userEmailLabel.lookback_shouldBeConcealedInRecordings = YES;
			}
			...
		}
		</pre>
 */
@property(nonatomic) BOOL lookback_shouldBeConcealedInRecordings;

@end


#pragma mark Settings

/*! @group Settings
    These settings can be set using [NSUserDefaults standardUserDefaults] to modify
    the behavior of Lookback. Some of these settings can be modified by the user
    from LookbackSettingsViewController.
*/

/*! If you implement the method `+(NSString*)lookBackIdentifier` in your view controller, that view will automatically be logged under that name (and later filter on it at lookback.io). Otherwise, your view controller's class name will be used instead, with prefix ("UI") and suffix ("ViewController") removed. You can disable this behavior by setting the NSUserDefaults key `LookbackAutomaticallyLogViewAppearance` to NO, and calling `-[LookBack enteredView:]` and `-[Lookback exitedView:]` methods manually.*/
static NSString *const LookbackAutomaticallyLogViewAppearance = @"GFio.lookback.autologViews";

/*! LookbackCameraEnabledSettingsKey controls whether the front-facing camera will record, in addition to recording the screen. */
static NSString *const LookbackCameraEnabledSettingsKey = @"com.thirdcog.lookback.camera.enabled";

/*! The BOOL NSUserDefaults key LookbackAudioEnabledSettingsKey controls whether audio will be recorded together with the front-facing camera. Does nothing if LookbackCameraEnabledSettingsKey is NO. */
static NSString *const LookbackAudioEnabledSettingsKey = @"com.thirdcog.lookback.audio.enabled";

/*! The BOOL NSUserDefaults key LookbackShowPreviewSettingsKey controls whether the user should be shown a preview image of their face at the bottom-right of the screen while recording, to make sure that they are holding their iPhone correctly and are well-framed. */
static NSString *const LookbackShowPreviewSettingsKey = @"com.thirdcog.lookback.preview.enabled";

/*! The integer NSUserDefaults key LookbackScreenRecorderFramerateLimitKey lets you set a specific framerate to limit screen
	recording to. Note that Lookback adapts framerate to something suitable for the current device: setting the framerate
	manually will override this.
	
	Decreasing the framerate is the best way to fix performance problems with Lookback. However, instead of hard-coding
	a specific framerate, consider setting -[Lookback framerateMultiplier] instead, as this will let Lookback adapt the
	framerate to something suitable for your device.
	
	Default value: Depends on hardware
	Range: 1 to 60
*/
static NSString *const LookbackScreenRecorderFramerateLimitKey = @"com.thirdcog.lookback.screenrecorder.fpsLimit";

/*! Standard timeout options for LookbackRecordingTimeoutSettingsKey. */
typedef NS_ENUM(NSInteger, LookbackTimeoutOption) {
	LookbackTimeoutImmediately = 0,
	LookbackTimeoutAfter1Minutes = 60,
	LookbackTimeoutAfter3Minutes = 180,
	LookbackTimeoutAfter5Minutes = 300,
	LookbackTimeoutAfter15Minutes = 900,
	LookbackTimeoutAfter30Minutes = 1800,
	LookbackTimeoutNever = NSIntegerMax,
};

/*! The NSTimeInterval/double key LookbackRecordingTimeoutOptionSettingsKey controls the timeout option when
	the app becomes inactive. Using 0 will stop a recording as soon as the app becomes inactive.
	Using DBL_MAX will never terminate a recording when the app becomes inactive. Any value in between will
	timeout and end the recording after the specified duration.
 */
static NSString *const LookbackRecordingTimeoutSettingsKey = @"io.lookback.recording.timeoutDuration";

typedef NS_ENUM(NSInteger, LookbackAfterTimeoutOption) {
	LookbackAfterTimeoutReview = 0,
	LookbackAfterTimeoutUpload,
	LookbackAfterTimeoutUploadAndStartNewRecording,
};

/*! The LookbackAfterTimeoutOption key LookbackRecordingAfterTimeoutOptionSettingsKey controls the behavior of
	Lookback when it times out after the app has become inactive. LookbackAfterTimeoutReview will let the user
	manually review and decide the next the app is open. LookbackAfterTimeoutUpload will proceed with uploading.
	LookbackAfterTimeoutUploadAndStartNewRecording will proceed with uploading and also start a new recording the
	next time the app is brought to the foreground.
 */
static NSString *const LookbackRecordingAfterTimeoutOptionSettingsKey = @"io.lookback.recording.afterTimeoutOption";

#pragma mark Notifications
/*! @group Notifications
    These notifications can be observed from [NSNotificationCenter defaultCenter].
*/

/*! When an experience upload starts, its URL is determined. You can then attach this URL to a bug report or similar.

    @example <pre>
        // Automatically put an experience's URL on the user's pasteboard when recording ends and upload starts.
        [[NSNotificationCenter defaultCenter] addObserverForName:LookbackStartedUploadingNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSDate *when = [note userInfo][LookbackExperienceStartedAtUserInfoKey];
            if(fabs([when timeIntervalSinceNow]) < 60) { // Only if it's for an experience we just recorded
                NSURL *url = [note userInfo][LookbackExperienceDestinationURLUserInfoKey];
                [UIPasteboard generalPasteboard].URL = url;
            }
        }];</pre>
*/
static NSString *const LookbackStartedUploadingNotificationName = @"com.thirdcog.lookback.notification.startedUploading";

/*! UserInfo key in a @link LookbackStartedUploadingNotificationName @/link notification. The value is an NSURL that the user can visit
    on a computer to view the experience he/she just recorded. */
static NSString *const LookbackExperienceDestinationURLUserInfoKey = @"com.thirdcog.lookback.notification.startedUploading.destinationURL";

/*! UserInfo key in a @link LookbackStartedUploadingNotificationName @/link notification. The value is an NSDate of when the given experience
    was recorded (so you can correlate the upload with the recording). */
static NSString *const LookbackExperienceStartedAtUserInfoKey = @"com.thirdcog.lookback.notification.startedUploading.sessionStartedAt";


#pragma mark Compatibility macros
/*!
	@group Compatibility macros
	For compatibility with old code using Lookback under the miscapitalized or misprefixed names.
 */
#define LookBack Lookback
#define GFAutomaticallyLogViewAppearance LookbackAutomaticallyLogViewAppearance
#define GFCameraEnabledSettingsKey LookbackCameraEnabledSettingsKey
#define GFAudioEnabledSettingsKey LookbackAudioEnabledSettingsKey
#define GFShowPreviewSettingsKey LookbackShowPreviewSettingsKey
#define GFStartedUploadingNotificationName LookbackStartedUploadingNotificationName
#define GFExperienceDestinationURLUserInfoKey LookbackExperienceDestinationURLUserInfoKey
#define GFExperienceStartedAtUserInfoKey LookbackExperienceStartedAtUserInfoKey

