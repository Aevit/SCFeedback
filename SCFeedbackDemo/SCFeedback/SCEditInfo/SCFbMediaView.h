//
//  SCFbMediaView.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/15.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCFbMediaInfo.h"

@class SCFbMediaView;

typedef void(^SCFbMediaViewTapBlock)(UIButton *btn, SCFbMediaInfo *info);
typedef void(^SCFbMediaViewDeleteBlock)(UIButton* btn, SCFbMediaInfo *info);

@interface SCFbMediaView : UIView

@property (nonatomic, strong) SCFbMediaInfo *info;

@property (nonatomic, copy) SCFbMediaViewDeleteBlock whenTapSelf;

@property (nonatomic, copy) SCFbMediaViewDeleteBlock whenTapDeleteBtn;

- (instancetype)initWithFrame:(CGRect)frame info:(SCFbMediaInfo*)info;

- (void)refreshImage:(UIImage*)image;

@end
