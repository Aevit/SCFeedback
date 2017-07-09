//
//  SCFbMediaInfo.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/15.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCFbMediaInfo.h"

#pragma mark - ------- image

@interface SCFbMediaInfoImage : SCFbMediaInfo

@property (nonatomic, strong) UIImage *theImage;

@end

@implementation SCFbMediaInfoImage

+ (instancetype)infoWithImage:(UIImage *)image {
    SCFbMediaInfoImage *info = [[SCFbMediaInfoImage alloc] init];
    info.type = SCFbMediaTypeImage;
    info.theImage = image;
    return info;
}

- (UIImage *)image {
    return self.theImage;
}

- (void)refreshImage:(UIImage*)image {
    self.theImage = image;
}

@end






#pragma mark - ------- video
@interface SCFbMediaInfoVideo : SCFbMediaInfo

@property (nonatomic, strong) UIImage *theImage;
@property (nonatomic, strong) NSURL *fileUrl;

@end

@implementation SCFbMediaInfoVideo

+ (instancetype)infoWithVideoFileUrl:(NSURL*)fileUrl coverImg:(UIImage *)coverImg {
    SCFbMediaInfoVideo *info = [[SCFbMediaInfoVideo alloc] init];
    info.type = SCFbMediaTypeVideo;
    info.fileUrl = fileUrl;
    info.theImage = coverImg;
    return info;
}

- (UIImage *)image {
    return self.theImage;
}

- (NSURL*)videoFileUrl {
    return self.fileUrl;
}

@end






#pragma mark - ------- father
@interface SCFbMediaInfo()

@end

@implementation SCFbMediaInfo

- (instancetype)initWithImage:(UIImage*)image {
    return [SCFbMediaInfo infoWithImage:image];
}

+ (instancetype)infoWithImage:(UIImage *)image {
    return [SCFbMediaInfoImage infoWithImage:image];
}

- (instancetype)initWithVideoFileUrl:(NSURL*)fileUrl coverImg:(UIImage *)coverImg {
    return [SCFbMediaInfo infoWithVideoFileUrl:fileUrl coverImg:coverImg];
}

+ (instancetype)infoWithVideoFileUrl:(NSURL*)fileUrl coverImg:(UIImage *)coverImg {
    return [SCFbMediaInfoVideo infoWithVideoFileUrl:fileUrl coverImg:coverImg];
}

- (UIImage*)image {
    return nil;
}

- (void)refreshImage:(UIImage *)image {
    
}

- (NSURL*)videoFileUrl {
    return nil;
}

@end
