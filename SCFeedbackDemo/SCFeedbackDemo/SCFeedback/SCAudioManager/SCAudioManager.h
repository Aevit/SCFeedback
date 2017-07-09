//
//  SCAudioManager.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/5/8.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^sc_audio_completeBlock)(NSURL *fileUrl);

@interface SCAudioManager : NSObject

#pragma mark - audio recorder

/**
 record audio setting, default is:
 
 @{
    AVFormatIDKey: @(kAudioFormatMPEG4AAC), // format
    AVSampleRateKey: @8000.0f, // sample rate: 8000.0f/44100.0f/96000.0f/128000.0f
    AVNumberOfChannelsKey: @1, // channel: 1/2
    AVEncoderBitDepthHintKey: @16, // sample bit: 8/16/24/32
    AVEncoderAudioQualityKey: @(AVAudioQualityMedium) // quality
 };
 
 */
@property (nonatomic, copy) NSDictionary *audioSetting;

/**
 the final audio path, default is 'Library/Caches/scrcd_{yyyyMMdd_HHmmss}.caf'.
 you could set the path such as: [NSURL fileURLWithPath:{your_file_path}];
 */
@property (nonatomic, strong) NSURL *outputURL;

/**
 start to record audio

 @param block complete callback
 */
- (void)startRecordWithComplete:(sc_audio_completeBlock)block;

/**
 stop to reacord audio
 */
- (void)stopRecord;

/**
 pause audio recording
 */
- (void)pauseRecord;

/**
 resume audio recording
 */
- (void)resumeRecord;


#pragma mark - audio player
/**
 audio player
 */
@property (nonatomic, strong) AVAudioPlayer *player;

/**
 start to play a audio file

 @param fileUrl the audio file url
 */
- (void)startPlayWithUrl:(NSURL*)fileUrl;

/**
 stop to play audio file
 */
- (void)stopPlay;

/**
 pause playing audio file
 */
- (void)pausePlay;

/**
 resume playing audio file
 */
- (void)resumePlay;

@end
