//
//  SCFbOverlayWindow.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/17.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCFbOverlayWindow.h"
#import "SCFbUtils.h"
#import "SCFbUtils+VCAndView.h"
#import "SCFbUtils+sc_image.h"
#import "SCFeedbackManager.h"
#import "SCEditInfoViewController.h"

@interface SCFbOverlayWindow()

/**
 overlay button
 */
@property (nonatomic, strong) UIButton *overlayBtn;

@property (nonatomic, assign) CGRect orginFrame;

@end

@implementation SCFbOverlayWindow

- (instancetype)init {
    if (self = [super init]) {
        [self sc_commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self sc_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self sc_commonInit];
    }
    return self;
}

- (void)sc_commonInit {
    _paddingBottomAndRight = 5;
    _type = SCFbOverlayTypeUnknown;
    [self addSubview:self.overlayBtn];
    self.windowLevel = UIWindowLevelAlert + 1;
    [self addNotification:YES];
}

- (void)dealloc {
    [self addNotification:NO];
}

#pragma mark - public methods
- (void)didPressOverlayBtn {
    [self.overlayBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - private methods
- (void)addNotification:(BOOL)toAdd {
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    if (!toAdd) {
        [notiCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [notiCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        return;
    }
    SCWeakSelf(self)
    
    [notiCenter addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSValue *aValue = note.userInfo[UIKeyboardFrameEndUserInfoKey];
        CGFloat keyBoardHeight = aValue.CGRectValue.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            SCStrongSelf(self)
            CGRect frame = self.frame;
            frame.origin.x = [SCFbUtils vc_screenWidth] - CGRectGetWidth(frame) - _paddingBottomAndRight;
            frame.origin.y = [SCFbUtils vc_screenHeight] - CGRectGetHeight(frame) - keyBoardHeight - _paddingBottomAndRight;
            self.frame = frame;
        }];
    }];
    [notiCenter addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [UIView animateWithDuration:0.3 animations:^{
            SCStrongSelf(self)
            CGRect frame = self.frame;
            frame.origin.x = [SCFbUtils vc_screenWidth] - CGRectGetWidth(frame) - _paddingBottomAndRight;
            frame.origin.y = [SCFbUtils vc_screenHeight] - CGRectGetHeight(frame) - _paddingBottomAndRight;
            self.frame = frame;
        }];
    }];
}

#pragma mark - properties
- (UIButton *)overlayBtn {
    if (!_overlayBtn) {
        _overlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _overlayBtn.frame = self.bounds;
        [_overlayBtn addTarget:self action:@selector(overlayBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _overlayBtn;
}

- (void)setType:(SCFbOverlayType)type {
    if (_type == type) {
        return;
    }
    _type = type;
    NSString *imgName = (_type == SCFbOverlayTypeCapture ? @"sc_camera_overlay.png" : @"sc_recorder_overlay.png");
    [self.overlayBtn setImage:[SCFbUtils img_imageWithName:imgName] forState:UIControlStateNormal];
    [self.overlayBtn setImage:(_type == SCFbOverlayTypeRecorder ? [SCFbUtils img_imageWithName:@"sc_stop_record.png"] : nil) forState:UIControlStateSelected];
}

#pragma mark - private methods
- (void)overlayBtnPressed:(UIButton*)sender {
    switch (_type) {
        case SCFbOverlayTypeCapture:
        {
            [[SCFeedbackManager sharedManager] captureToDrawWhenComplete:^(UIImage *image) {
                SCFbMediaInfo *info = [SCFbMediaInfo infoWithImage:image];
                [[SCFeedbackManager sharedManager] gotoEditWithMediaInfo:info];
            }];
            
            self.hidden = YES;
            
            break;
        }
        case SCFbOverlayTypeRecorder:
        {
            if (sender.selected) {
                [[SCFeedbackManager sharedManager] stopRecordView];
                self.hidden = YES;
            } else {
                [[SCFeedbackManager sharedManager] startRecordingWhenComplete:^(NSURL *fileUrl, UIImage *coverImage) {
                    SCFbMediaInfo *info = [SCFbMediaInfo infoWithVideoFileUrl:fileUrl coverImg:coverImage];
                    [[SCFeedbackManager sharedManager] gotoEditWithMediaInfo:info];
                }];
            }
            sender.selected = !sender.selected;
            break;
        }
        default:
            break;
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
