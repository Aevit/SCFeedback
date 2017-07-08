//
//  SCFeedbackManager.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/5/3.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCScreenRecorder.h"
#import "SCAudioManager.h"
#import "SCDrawerViewController.h"
#import "SCEditInfoViewController.h"
#import "SCFbOverlayWindow.h"
#import "SCFeedbackDelegate.h"


#pragma mark - properties and apis
@interface SCFeedbackManager : NSObject

#pragma mark - ---- simple api
/**
 shared instance
 
 @return shared instance
 */
+ (SCFeedbackManager*)sharedManager;

/**
 enable to show a alert after shaking.
 default is "YES".
 if you want to keep the state "YES", just save the state (such as in NSUserDefault), and call this api whenever you want.
 
 @param enable YES: will show a alert after shaking; NO: do nothing after shaking.
 */
- (void)enableShake:(BOOL)enable;

/**
 when press the send butotn at "SCEditInfoViewController", do something what you want.
 you can set the "block" to "nil" to clean the callback.
 
 @param block block
 */
- (void)setupSendInfoBlock:(sc_sendInfo_block)block;

/**
 go to the SCEditInfoViewController to edit the feedback content and medias such as image and video.
 
 @param theNewInfo the new mediaInfo, can be nil.
 */
- (void)gotoEditWithMediaInfo:(SCFbMediaInfo *)theNewInfo;













// you can simply use with the apis above, if you want to do more thing, you can use the properties or apis below.



#pragma mark - ----- custom info
// you can custom these info with the property: "customInfo"
extern NSString *const scInfo_drawer_title; // SCEditInfoViewController's title

extern NSString *const scInfo_editInfo_title; // SCEditInfoViewController's title
extern NSString *const scInfo_editInfo_placeholder; // SCEditInfoViewController, placeholder of textview
extern NSString *const scInfo_editInfo_beyondNumTitle; // SCEditInfoViewController, title of alert when the number of attachments is out of 4
extern NSString *const scInfo_editInfo_beyondNumMsg; // SCEditInfoViewController, message of alert when the number of attachments is out of 4
extern NSString *const scInfo_editInfo_beyondNumCancel; // SCEditInfoViewController, cancel button text of alert when the number of attachments is out of 4

extern NSString *const scInfo_shake_title; // title of alert after shaking
extern NSString *const scInfo_shake_msg; // message of alert after shaking
extern NSString *const scInfo_shake_capture; // capture button text of alert after shaking
extern NSString *const scInfo_shake_record; // record button text of alert after shaking
extern NSString *const scInfo_shake_closeShake; // close shaken button text of alert after shaking
extern NSString *const scInfo_shake_cancel; // cancel button text of alert after shaking

/**
 set up custom info, such as the title of the SCDrawerViewController and so on
 NOTICE: the key of the "info" has the prefix: "scInfo_", you can find the "extern" string at top;
 */
@property (nonatomic, strong) NSMutableDictionary *customInfo;

/**
 get a value of the "customInfo"

 @param key has the prefix: "scInfo_", you can find the "extern" string at top
 @return the value (will be empty string when does't exist)
 */
- (NSString*)getInfoForKey:(NSString*)key;





#pragma mark - delegate
@property (nonatomic, weak) id <SCFeedbackDelegate> delegate;






#pragma mark - ----- for custom setting

/**
 the screen recorder, you can do some custom setting with this, such as "screenRecorder.frameRate".
 will be nil when stop record.
 */
@property (nonatomic, strong) SCScreenRecorder *screenRecorder;

/**
 the audio manager, you can do some custom setting such as "audioManager.outputURL" or other operation such as play audio with this, such as "[screenRecorder startPlayWithUrl:url]".
 will be nil when stop record
 */
@property (nonatomic, strong) SCAudioManager *audioManager;





#pragma mark - ----- SCScreenRecorder
/**
 start to record the action on the screen.
 you can do some custom setting with the properties and apis of [SCFeedbackManager sharedManager].screenRecorder before start.
 
 you can record a specific view with the api of [SCFeedbackManager sharedManager].screenRecorder.
 
 @param block complete callback
 */
- (void)startRecordingWhenComplete:(sc_writer_completeBlock)block;

/**
 stop to record the action.
 will be nil when stop record.
 */
- (void)stopRecordView;




#pragma mark - ----- SCAudioManager
/**
 start to record audio.
 you can do more thing such as play audio with the properties and apis of [SCFeedbackManager sharedManager].audioManager

 @param block complete callback
 */
- (void)startRecordAudioWithComplete:(sc_audio_completeBlock)block;

/**
 stop to record audio.
 will be nil when stop record.
 */
- (void)stopRecordAudio;




#pragma mark - ----- SCDrawerViewController
/**
 capture the app window to draw something on it.
 you can custom the UI with your own controller, just init "SCDrawerView" and set the "image" property (just like the code in SCDrawerViewController)

 @param block complete callback
 */
- (void)captureToDrawWhenComplete:(sc_drawer_completeBlock)block;




#pragma mark - ----- SCEditInfoViewController
/**
 show the overlay button to capture or record screen.

 @param type capture or record screen
 */
- (void)showOverlayBtnWithtype:(SCFbOverlayType)type;

/**
 hide the overlay button to capture or record screen.
 */
- (void)hideOverlayBtn;

/**
 when press the "toolBtn" over the keyboard to add one more media info at "SCEditInfoViewController", save the data, and when the "SCEditInfoViewController" show again, fill the saved data to show.
 
 NOTICE: the data will be automatic cleaned when the "SCEditInfoViewController" dismiss without pressed the "toolBtn" over the keyborad.

 @param infosArr the media info array (include image or video info)
 @param text the feedback content inputed
 */
- (void)saveMediaInfos:(NSArray<SCFbMediaInfo*>*)infosArr textContent:(NSString*)text;

/**
 the saved mediaInfos at "SCEditInfoViewController".
 */
- (NSMutableArray<SCFbMediaInfo*>*)getSavedMediaInfos;

/**
 the feedback content inputed at "SCEditInfoViewController".
 */
- (NSString*)getSavedTextContent;

/**
 clean the saved data.
 
 NOTICE: the data will be automatic cleaned when the "SCEditInfoViewController" dismiss without pressed the "toolBtn" over the keyborad.
 */
- (void)cleanSavedData;

@end
