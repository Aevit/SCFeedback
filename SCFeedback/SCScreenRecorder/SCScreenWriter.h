//
//  SCScreenWriter.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/5/3.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SCScreenRecorder;

typedef void(^sc_writer_completeBlock)(NSURL *fileUrl, UIImage *coverImage);

@interface SCScreenWriter : NSObject

/**
 a weak refrence of SCScreenRecorder, used to set something, such as outputURL
 */
@property (nonatomic, weak) SCScreenRecorder *owner;

/**
 write a image to the video

 @param image a snapshot
 */
- (void)writeToVideoWithImage:(UIImage*)image;

/**
 stop the write

 @param block callback
 */
- (void)stopWhenComplete:(sc_writer_completeBlock)block;

@end
