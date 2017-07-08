//
//  SCFbMediaView.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/15.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCFbMediaView.h"
#import "SCFbUtils.h"

static CGFloat const padding = 5;

@interface SCFbMediaView()

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation SCFbMediaView

- (instancetype)init
{
    SCFbLog(@" ╔———————————————— SCFeedback: WARNING ———————————————╗");
    SCFbLog(@" | [[SCFbMediaView alloc] init] is not allowed        |");
    SCFbLog(@" | Please use  \"initWithFrame:info\" , thanks!       |");
    SCFbLog(@" ╚————————————————————————————————————————————————————╝");
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    SCFbLog(@" ╔—————————————————— SCFeedback: WARNING ——————————————————————╗");
    SCFbLog(@" |    [[SCFbMediaView alloc] initWithFrame] is not allowed     |");
    SCFbLog(@" |    Please use  \"initWithFrame:info\" , thanks!             |");
    SCFbLog(@" ╚—————————————————————————————————————————————————————————————╝");
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame info:(SCFbMediaInfo*)info {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.info = info;
        [self addContent];
    }
    return self;
}

- (void)dealloc {
    self.info = nil;
}

#pragma mark - public methods
- (void)refreshImage:(UIImage *)image {
    self.imgView.image = image;
}

#pragma mark - private methods
- (void)addContent {
    if (!_info) {
        return;
    }
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[_info image]];
    imgView.frame = CGRectMake(padding, padding, CGRectGetWidth(self.frame) - padding * 2, CGRectGetHeight(self.frame) - padding * 2);
    imgView.clipsToBounds = YES;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imgView];
    self.imgView = imgView;
    
    [self addCoverBtnWithView:imgView];
    
    [self addDeleteBtn];
}

- (void)addCoverBtnWithView:(UIImageView*)imgView {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = imgView.frame;
    btn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [btn addTarget:self action:@selector(coverBtnBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (_info && _info.type == SCFbMediaTypeVideo) {
        [btn setImage:[UIImage imageNamed:@"sc_play_btn.png"] forState:UIControlStateNormal];
    }
    [self addSubview:btn];
}

- (void)coverBtnBtnPressed:(UIButton*)sender {
    if (self.whenTapSelf) {
        self.whenTapSelf(sender, self.info);
    }
}

- (void)addDeleteBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(CGRectGetWidth(self.frame) - 20, 0, 20, 20);
    [btn setImage:[UIImage imageNamed:@"sc_right_delete.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(deleteBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (void)deleteBtnPressed:(UIButton*)sender {
    if (self.whenTapDeleteBtn) {
        self.whenTapDeleteBtn(sender, self.info);
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
