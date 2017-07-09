//
//  SCFbMediaInfo.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/15.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCFbMediaType) {
    SCFbMediaTypeImage = 0,
    SCFbMediaTypeVideo = 1
};

@interface SCFbMediaInfo : NSObject

@property (nonatomic, assign) SCFbMediaType type;

- (instancetype)initWithImage:(UIImage*)image;

+ (instancetype)infoWithImage:(UIImage *)image;

- (instancetype)initWithVideoFileUrl:(NSURL*)fileUrl coverImg:(UIImage *)coverImg;

+ (instancetype)infoWithVideoFileUrl:(NSURL*)fileUrl coverImg:(UIImage *)coverImg;

/**
 if type is SCFbMediaTypeVideo, return the cover image of the video (the first frame of the video)

 @return the image
 */
- (UIImage*)image;

/**
 if type is SCFbMediaTypeVideo, return the video path in the sanbox

 @return the absolute video path
 */
- (NSURL*)videoFileUrl;

/**
 update the image

 @param image the new image
 */
- (void)refreshImage:(UIImage*)image;

@end
