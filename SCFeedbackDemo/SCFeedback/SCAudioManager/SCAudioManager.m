//
//  SCAudioManager.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/5/8.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCAudioManager.h"
#import "SCFbUtils+sc_file.h"
#import "SCFbUtils.h"

@interface SCAudioManager()

/**
 audio recorder
 */
@property (nonatomic, strong) AVAudioRecorder *recorder;

/**
 complete callback
 */
@property (nonatomic, copy) sc_audio_completeBlock block;

@end

@implementation SCAudioManager

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc {
    if (_recorder) {
        [_recorder stop];
    }
    self.recorder = nil;
    self.audioSetting = nil;
    self.outputURL = nil;
    self.block = nil;
    
    [self stopPlay];
    self.player = nil;
}

#pragma mark - public methods
#pragma mark record
- (void)startRecordWithComplete:(sc_audio_completeBlock)block {
    
    NSError *sessionError = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    [session setActive:YES error:&sessionError]; // prevent the playing background audio
    
    self.block = block;
    if ([self.recorder prepareToRecord]) {
        [self.recorder record];
    } else {
        SCFbLog(@"SCFeedback: failed to prepare to record audio");
    }
}

- (void)stopRecord {
    if (_recorder && _recorder.isRecording) {
        [_recorder stop];
        if (self.block) {
            self.block(self.outputURL);
        }
    }
}

- (void)pauseRecord {
    if (_recorder && _recorder.isRecording) {
        [self.recorder pause];
    }
}

- (void)resumeRecord {
    if (_recorder && !_recorder.isRecording) {
        if ([self.recorder prepareToRecord]) {
            [self.recorder record];
        } else {
            SCFbLog(@"SCFeedback: failed to prepare to record audio");
        }
    }
}

#pragma mark play
- (void)startPlayWithUrl:(NSURL*)fileUrl {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [self setupPlayerWithUrl:fileUrl];
    [self.player play];
}

- (void)stopPlay {
    if (_player && _player.isPlaying) {
        [self.player stop];
    }
}

- (void)pausePlay {
    if (_player && _player.isPlaying) {
        [self.player pause];
    }
}

- (void)resumePlay {
    if (_player && !_player.isPlaying) {
        [self.player play];
    }
}

#pragma mark - private methods
- (void)setupPlayerWithUrl:(NSURL*)url {
    self.player = nil;
    NSAssert(url != nil, @"SCFeedback: empty audio file");
    if (!url) {
        return;
    }
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.numberOfLoops = 0;
    self.player = player;
}

#pragma mark - properties
- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        NSError *error = nil;
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.outputURL settings:self.audioSetting error:&error];
        _recorder.meteringEnabled = YES;
    }
    return _recorder;
}

- (NSDictionary *)audioSetting {
    if (!_audioSetting) {
        _audioSetting = @{
                          AVFormatIDKey: @(kAudioFormatMPEG4AAC), // format
                          AVSampleRateKey: @8000.0f, // sample rate: 8000.0f/44100.0f/96000.0f/128000.0f
                          AVNumberOfChannelsKey: @1, // channel: 1/2
                          AVEncoderBitDepthHintKey: @16, // sample bit: 8/16/24/32
                          AVEncoderAudioQualityKey: @(AVAudioQualityMedium) // quality
                          };
    }
    return _audioSetting;
}

- (NSInteger)fileNameType {
    return 2;
}

- (NSURL *)outputURL {
    if (!_outputURL) {
        _outputURL = [self defaultOutputUrl];
    }
    return _outputURL;
}

- (NSURL*)defaultOutputUrl {
    NSString *folder = [SCFbUtils file_scrcd_default_folder];
    NSString *fileName = @"";
    if ([self fileNameType] == 1) {
        // 1. timestamp
        fileName = [NSString stringWithFormat:@"scrcd_%d.caf", (int)[[NSDate date] timeIntervalSince1970]];
    } else if ([self fileNameType] == 2) {
        // 2. yyyyMMdd_HHmmss
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMdd_HHmmss";
        NSString *date = [formatter stringFromDate:[NSDate date]];
        fileName = [NSString stringWithFormat:@"scrcd_%@.caf", date];
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", folder, fileName];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        [manager removeItemAtPath:filePath error:nil];
    }
    return [NSURL fileURLWithPath:filePath];
}

@end
