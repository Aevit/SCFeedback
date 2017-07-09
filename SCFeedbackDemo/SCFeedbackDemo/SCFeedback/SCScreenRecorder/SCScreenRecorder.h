//
//  SCScreenRecorder.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/5/3.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCScreenWriter.h"

typedef void(^sc_record_max_time_block)(uint64_t maxTime);

extern NSString *const kNotificationDidReachMaxTime_scfb;

@interface SCScreenRecorder : NSObject

/**
 fps. default is 10, should decrease on thd old device (such as iPhone 4, maybe 4 is ok)
 */
@property (nonatomic, assign) int32_t frameRate;

/**
 the final video path, default is 'Library/Caches/scrcd_{yyyyMMdd_HHmmss}.mp4'.
 you could set the path such as: [NSURL fileURLWithPath:{your_file_path}];
 */
@property (nonatomic, strong) NSURL *outputURL;

/**
 the size of the recording area, default is the screen's bounds
 */
@property (nonatomic, assign) CGSize size;

/**
 whether to show the touch point, default is YES
 */
@property (nonatomic, assign) BOOL showTouchPoint;

/**
 whether to record audio, default is NO;
 */
@property (nonatomic, assign) BOOL includeAudio;

/**
 the cover image of the video, will use the first frame
 */
@property (nonatomic, strong) UIImage *coverImage;

/**
 set the max time of the video, default is 60 (0 means unlimited time)

 @param maxTime default: 60, unlimited time: 0
 @param callback callback when reach the max time
 */
- (void)setupMaxTime:(uint64_t)maxTime callback:(sc_record_max_time_block)callback;

/**
 start to record the key window

 @param block did finish recording callback
 */
- (void)startRecordingWhenComplete:(sc_writer_completeBlock)block;

/**
 start to record the view you want
 
 @param view the target view
 @param block did finish recording callback
 */
- (void)startRecordingView:(UIView*)view completeBlock:(sc_writer_completeBlock)block;

/**
 stop recording
 */
- (void)stop;

/**
 pause recording
 */
- (void)pause;

/**
 resume recording
 */
- (void)resume;

@end




