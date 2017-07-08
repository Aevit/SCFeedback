//
//  SCScreenRecorder.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/5/3.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCScreenRecorder.h"
#import "SCFbUtils+sc_image.h"
#import "SCScreenWriter.h"
#import "SCTouchPointer.h"
#import "SCFbUtils+sc_file.h"
#import "SCAudioManager.h"
#import "SCFbUtils.h"
#import "SCFbUtils+sc_image.h"
#import "SCFeedbackManager.h"

NSString *const kNotificationDidReachMaxTime_scfb = @"kNotificationDidReachMaxTime_scfb";

@interface SCScreenRecorder()

@property (nonatomic, strong) UIView *recordingView;
@property (nonatomic, copy) sc_writer_completeBlock completeBlock;

@property (nonatomic, strong) SCScreenWriter *writer;
@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, strong) SCAudioManager *audioManager;

@property (nonatomic, assign) uint64_t maxTime;
@property (nonatomic, copy) sc_record_max_time_block maxTimeBlock;

@end

@implementation SCScreenRecorder {
    dispatch_source_t _source;
    BOOL _isTimerSuspend;
}

- (instancetype)init {
    if (self = [super init]) {
        _frameRate = 10;
        _showTouchPoint = YES;
        _isTimerSuspend = NO;
        _includeAudio = NO;
        _maxTime = 60 * NSEC_PER_SEC;
    }
    return self;
}

- (void)dealloc {
    [self stopTimerSource];
    self.writer = nil;
    self.audioManager = nil;
    self.outputURL = nil;
}

#pragma mark - public methods
- (void)setupMaxTime:(uint64_t)maxTime callback:(sc_record_max_time_block)callback {
    self.maxTime = maxTime * NSEC_PER_SEC;
    self.maxTimeBlock = callback;
}

- (void)startRecordingWhenComplete:(sc_writer_completeBlock)block {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window]; // [[UIApplication sharedApplication] keyWindow];
    NSAssert(window != nil, @"SCFeedback: the recording window is nil");
    return [self startRecordingView:window completeBlock:block];
}

- (void)startRecordingView:(UIView *)view completeBlock:(sc_writer_completeBlock)block {
    
    if (self.showTouchPoint) {
        sc_installTouchPointer(0, nil); // set (0, nil) to use default radius and color
    }
    
    _isRecording = YES;
    self.recordingView = view;
    self.completeBlock = block;
    
    // writer
    self.writer.owner = self;
    
    SCWeakSelf(self)
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue = dispatch_queue_create("xyz.aevit.screenRecorder.queue", DISPATCH_QUEUE_CONCURRENT);
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    uint64_t interval = 1.0 / self.frameRate * NSEC_PER_SEC;
    __block uint64_t executedTime = 0;
    dispatch_source_set_timer(_source, dispatch_walltime(NULL, 0), interval, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_source, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            SCStrongSelf(self)
            if (_isRecording) {
                
                if (_maxTime > 0 && executedTime > _maxTime) {
                    executedTime = 0;
                    [self stop];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidReachMaxTime_scfb object:nil];
                    if (self.maxTimeBlock) {
                        self.maxTimeBlock(_maxTime);
                    }
                    return;
                }
                executedTime += interval;
                
                UIImage *image = [self snapshotForView:self.recordingView];
                if (!self.coverImage) {
                    self.coverImage = image;
                }
//#ifdef DEBUG
//                [weakSelf saveImageForDebug:image];
//#endif
                [self.writer writeToVideoWithImage:image];
            }
        });
    });
    dispatch_resume(_source);
    
    if (_includeAudio) {
        [self.audioManager startRecordWithComplete:^(NSURL *fileUrl) {
            SCFbLog(@"SCFeedback: file url: %@", fileUrl);
        }];
    }
}

- (void)stop {
    
    if (!_writer || !_source) {
        return;
    }
    
    if (self.showTouchPoint) {
        sc_uninstallTouchPointer();
    }
    
    [self stopTimerSource];
    
    [self.writer stopWhenComplete:self.completeBlock];
    
    if (_includeAudio && _audioManager) {
        [_audioManager stopRecord];
        NSURL *mergedUrl = [self defaultOutputUrl];
        [SCScreenRecorder mergeVideo:self.outputURL andAudio:self.audioManager.outputURL outputUrl:mergedUrl completeBlock:^(AVAssetExportSessionStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status != AVAssetExportSessionStatusCompleted) {
                    SCFbLog(@"SCFeedback: merged status: %ld, complete merge: %@", (long)status, mergedUrl);
                }
                if (_includeAudio && _audioManager) {
                    self.audioManager = nil;
                }
            });
        }];
    }
}

- (void)pause {
    if (_source && !_isTimerSuspend) {
        _isTimerSuspend = YES;
        dispatch_suspend(_source);
    }
    if (_includeAudio && _audioManager) {
        [_audioManager pauseRecord];
    }
}

- (void)resume {
    if (_source && _isTimerSuspend) {
        _isTimerSuspend = NO;
        dispatch_resume(_source);
    }
    if (_includeAudio && _audioManager) {
        [_audioManager resumeRecord];
    }
}

#pragma mark - properties
- (SCScreenWriter *)writer {
    if (!_writer) {
        _writer = [[SCScreenWriter alloc] init];
    }
    return _writer;
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
        fileName = [NSString stringWithFormat:@"scrcd_%d.mp4", (int)[[NSDate date] timeIntervalSince1970]];
    } else if ([self fileNameType] == 2) {
        // 2. yyyyMMdd_HHmmss
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMdd_HHmmss";
        NSString *date = [formatter stringFromDate:[NSDate date]];
        fileName = [NSString stringWithFormat:@"scrcd_%@.mp4", date];
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", folder, fileName];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        [manager removeItemAtPath:filePath error:nil];
    }
    return [NSURL fileURLWithPath:filePath];
}

- (CGSize)size {
    if (CGSizeEqualToSize(_size, CGSizeZero)) {
        return self.recordingView.frame.size; // [UIScreen mainScreen].bounds.size;
    }
    return _size;
}

- (SCAudioManager *)audioManager {
    if (!_audioManager) {
        _audioManager = [[SCAudioManager alloc] init];
    }
    return _audioManager;
}

#pragma mark - private methods
- (UIImage*)snapshotForView:(UIView*)view {
    NSInteger w_ratio = floor(view.frame.size.width / 16);
    UIImage *image = [SCFbUtils img_snapshotForView:view inRect:CGRectMake(0, 0, w_ratio * 16, view.frame.size.height) afterScreenUpdates:NO];
    return image;
}

#ifdef DEBUG
- (void)saveImageForDebug:(id)sender {
    UIImage *image = [self snapshotForView:self.recordingView];
    static NSInteger frameCount = 0;
    if (frameCount < 3) {
        NSString *filename = [NSString stringWithFormat:@"Library/Caches/frame_%ld.png", (long)frameCount];
        NSString *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
        [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
        frameCount++;
    }
}
#endif

- (void)stopTimerSource {
    
    _isRecording = NO;
    
    if (_isTimerSuspend) {
        // can NOT cancel a suspended source
        // http://stackoverflow.com/questions/9572055/dispatch-source-cancel-on-a-suspended-timer-causes-exc-bad-instruction?noredirect=1&lq=1
        [self resume];
    }
    if (_source) {
        dispatch_source_cancel(_source);
        _source = nil;
    }
}

+ (void)mergeVideo:(NSURL*)videoUrl andAudio:(NSURL*)audioUrl outputUrl:(NSURL*)outputUrl completeBlock:(void (^)(AVAssetExportSessionStatus status))completeBlock {
    
    NSAssert(videoUrl, @"SCFeedBack: the videoUrl is nil");
    NSAssert(audioUrl, @"SCFeedBack: the audioUrl is nil");
    
    // --- prepare
    outputUrl = (outputUrl ? outputUrl : [NSURL fileURLWithPath:[[SCFbUtils file_documentsPath] stringByAppendingPathComponent:@"scrcd_merged.mp4"]]);
    
    CMTime startTime = kCMTimeZero;
    AVMutableComposition *comosition = [AVMutableComposition composition];
    
    // --- for video
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:startTime error:nil];
    
    // --- for audio
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration); // videoTimeRange;
    AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:startTime error:nil];
    
    // --- for export
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPresetMediumQuality]; // medium quality
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.outputURL = outputUrl;
    assetExport.shouldOptimizeForNetworkUse = YES;
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        if (completeBlock) {
            completeBlock(assetExport.status);
        }
    }];
}

@end
