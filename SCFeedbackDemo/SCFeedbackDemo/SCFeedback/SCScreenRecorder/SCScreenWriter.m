//
//  SCScreenWriter.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/5/3.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCScreenWriter.h"
#import <AVFoundation/AVFoundation.h>
#import "SCScreenRecorder.h"
#import "SCFbUtils.h"
#import "SCFeedbackManager.h"

@interface SCScreenWriter()


@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *writerInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;
@property (nonatomic, assign) int64_t currFrameNum;

@end

@implementation SCScreenWriter {
    dispatch_semaphore_t _lock;
}

- (instancetype)init {
    if (self = [super init]) {
        self.currFrameNum = 0;
    }
    return self;
}

- (void)dealloc {
    [self cleanUp];
}

#pragma mark - public methods
- (void)writeToVideoWithImage:(UIImage*)image {
    
    if (!image) {
        return;
    }
    
    if (!_writer) {
        [self writer];
    }
    
    if (![self.writerInput isReadyForMoreMediaData]) {
        SCFbLog(@"SCFeedback: not ready to write");
        return;
    }
    
    if (!_lock) {
        _lock = dispatch_semaphore_create(1);
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    CVPixelBufferRef buffer = [self pixelBufferForImage:image];
    self.currFrameNum++;
    BOOL result = [self.adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(self.currFrameNum, self.owner.frameRate)];
    if (!result) {
        SCFbLog(@"SCFeedback: failed to write: %@", self.writer.error);
    }
    NSAssert(result == YES, @"SCFeedback: failed to write");
    CVPixelBufferRelease(buffer);
    
    dispatch_semaphore_signal(_lock);
//#if !OS_OBJECT_USE_OBJC
//    dispatch_release(_lock);
//#endif
}

- (void)stopWhenComplete:(sc_writer_completeBlock)block {
    
    AVAssetWriterStatus status = self.writer.status;
    while (status == AVAssetWriterStatusUnknown) {
        SCFbLog(@"SCFeedback: waiting for writting");
        [NSThread sleepForTimeInterval:0.5f];
        status = self.writer.status;
    }
    
    [self.writerInput markAsFinished];
    
    [self.writer finishWritingWithCompletionHandler:^{
        [self cleanUp];
    }];
    
    // block
    if (block) {
        block(self.owner.outputURL, self.owner.coverImage);
    }
    
    // delegate
    SCFeedbackManager *manager = [SCFeedbackManager sharedManager];
    if ([manager.delegate respondsToSelector:@selector(scFeedback:didSaveRecordingVideoUrl:coverImage:)]) {
        [manager.delegate scFeedback:manager didSaveRecordingVideoUrl:self.owner.outputURL coverImage:self.owner.coverImage];
    }
        
}

#pragma mark - props
- (AVAssetWriter *)writer {
    if (!_writer) {
        // writer
        NSError *error = nil;
        _writer = [[AVAssetWriter alloc] initWithURL:self.owner.outputURL fileType:AVFileTypeQuickTimeMovie error:&error];
#ifdef DEBUG
        NSString *errMsg = [NSString stringWithFormat:@"SCFeedback: %@", error.debugDescription];
        NSAssert(error == nil, errMsg);
#endif
        
        // input
        [_writer addInput:self.writerInput];
        
        // adaptor
        [self adaptor];
        
        // start to write
        [_writer startWriting];
        [_writer startSessionAtSourceTime:kCMTimeZero];
    }
    return _writer;
}

- (AVAssetWriterInput *)writerInput {
    if (!_writerInput) {
        NSDictionary *settings = @{
                                   AVVideoCodecKey: AVVideoCodecH264,
                                   AVVideoWidthKey: @(self.owner.size.width),
                                   AVVideoHeightKey: @(self.owner.size.height),
                                   AVVideoCompressionPropertiesKey: @{
                                           AVVideoAverageBitRateKey: @(self.owner.size.width * self.owner.size.height)
                                           },
                                   };
        _writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
        _writerInput.expectsMediaDataInRealTime = YES;
    }
    return _writerInput;
}

- (AVAssetWriterInputPixelBufferAdaptor *)adaptor {
    if (!_adaptor) {
        NSDictionary *attrs = @{
                                (NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB),
                                (NSString*)kCVPixelBufferWidthKey: @(self.owner.size.width),
                                (NSString*)kCVPixelBufferHeightKey: @(self.owner.size.height),
                                };
        _adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.writerInput sourcePixelBufferAttributes:attrs];
    }
    return _adaptor;
}

#pragma mark - private methods
- (CVPixelBufferRef)pixelBufferForImage:(UIImage *)image {
    
    CGImageRef cgImage = image.CGImage;
    
    NSDictionary *options = @{
                              (NSString *)kCVPixelBufferCGImageCompatibilityKey: @(YES),
                              (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @(YES)
                              };
    CVPixelBufferRef buffer = NULL;
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options, &buffer);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    void *data                  = CVPixelBufferGetBaseAddress(buffer);
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    CGContextRef context        = CGBitmapContextCreate(data, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage), 8, 4 * CGImageGetWidth(cgImage), colorSpace, (kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipFirst));
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage)), cgImage);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    return buffer;
}

- (void)cleanUp {
    self.adaptor = nil;
    self.writerInput = nil;
    self.writer = nil;
    self.currFrameNum = 0;
    self.owner.outputURL = nil;
    _lock = nil;
}

@end
