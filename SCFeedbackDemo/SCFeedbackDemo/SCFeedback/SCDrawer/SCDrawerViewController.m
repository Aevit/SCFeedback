//
//  SCDrawerViewController.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/5/15.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCDrawerViewController.h"
#import "SCFbUtils+sc_image.h"
#import "SCDrawerView.h"
#import "SCEditInfoViewController.h"
#import "SCFeedbackManager.h"
#import "SCFbUtils.h"

static CGFloat const horizonGap = 30;
static CGFloat const verticalGap = 10;
static CGFloat const topViewHeight = 44;
static CGFloat const bottomViewHeight = 50;
static NSInteger const kTagTitleLbl = 98792;

// brush
static NSArray *colorArr = nil;
static NSInteger const kTagBottomBtn = 100;

// mosaic
static NSInteger const kTagMosaicSizeBtn = 200;
static NSInteger const kMosaicBottomViewBtnNumber = 6; // with the last close button
static NSString* const kMosaicSizeBtnLayerName = @"kMosaicSizeBtnLayerName";
static CGFloat const kMaxMosaicSize = 50.0;

@interface SCDrawerViewController () {
    BOOL _isNavBarHidden;
}

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *hookImgView;

@property (nonatomic, weak) UIButton *selectedBottomBtn;

@property (nonatomic, strong) UIView *mosaicBottomView;



@end

@implementation SCDrawerViewController

+ (void)initialize {
    if (self == [SCDrawerViewController class]) {
        colorArr = @[sc_rgba(221, 99, 91, 1),
                     sc_rgba(237, 200, 90, 1),
                     sc_rgba(222, 122, 76, 1),
                     sc_rgba(69, 177, 84, 1),
                     sc_rgba(57, 142, 207, 1),
                     sc_rgba(40, 54, 68, 1)];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // delegate
    SCFeedbackManager *manager = [SCFeedbackManager sharedManager];
    if ([manager.delegate respondsToSelector:@selector(scFeedback:didShowDrawerController:)]) {
        [manager.delegate scFeedback:manager didShowDrawerController:self];
    }
    
    // save origin state
    if (self.navigationController) {
        _isNavBarHidden = self.navigationController.isNavigationBarHidden;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    // add views
    if (self.navigationController) {
        [self setupCloseBtn];
        [self setupNextBtn];
    } else {
        [self.view addSubview:self.topView];
    }
    [self setCustomTitle:[[SCFeedbackManager sharedManager] getInfoForKey:scInfo_drawer_title]];
    [self.view addSubview:self.drawerView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.mosaicBottomView];
}

- (void)dealloc {
    self.image = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - properties
- (void)setImage:(UIImage *)image {
    if (image == _image) {
        return;
    }
    _image = image;
    if (_drawerView) {
        _drawerView.image = image;
    }
}

- (SCDrawerView *)drawerView {
    if (!_drawerView) {
        _drawerView = [[SCDrawerView alloc] initWithFrame:CGRectMake(horizonGap, topViewHeight + verticalGap, CGRectGetWidth(self.view.frame) - horizonGap * 2, CGRectGetHeight(self.view.frame) - topViewHeight - bottomViewHeight - verticalGap * 2)];
        _drawerView.image = self.image;
        _drawerView.mosaicSize = kMaxMosaicSize;
        _drawerView.clipsToBounds = YES;
    }
    return _drawerView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), topViewHeight)];
        _topView.backgroundColor = sc_rgba(246, 246, 246, 1);
        [self setupCloseBtn];
        [self setupNextBtn];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - bottomViewHeight, CGRectGetWidth(self.view.frame), bottomViewHeight)];
        _bottomView.backgroundColor = sc_rgba(246, 246, 246, 1);
        
        // bottom buttons
        NSInteger btnCount = colorArr.count + 2;
        CGFloat const eachWidth = self.view.frame.size.width / btnCount;
        UIBezierPath *const path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(eachWidth / 2, bottomViewHeight / 2) radius:10 startAngle:0.0 endAngle:M_PI * 2 clockwise:YES];
        for (int i = 0; i < btnCount; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_bottomView addSubview:btn];
            btn.tag = kTagBottomBtn + i;
            btn.frame = CGRectMake(i * eachWidth, 0, eachWidth, bottomViewHeight);
            btn.contentMode = UIViewContentModeScaleAspectFit;
            [btn addTarget:self action:@selector(bottomBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            if (i < btnCount - 2) {
                CAShapeLayer *layer = [CAShapeLayer layer];
                layer.path = path.CGPath;
                layer.fillColor = ((UIColor*)colorArr[i]).CGColor;
                [btn.layer addSublayer:layer];
            }
            
            if (i == 0) {
                // set the default selected color
                self.drawerView.brushColor = colorArr[0];
                self.selectedBottomBtn = btn;
                [self addHookImgViewIn:btn];
            } else if (i == btnCount - 2) {
                // masaic
                [btn setImage:[SCFbUtils img_imageWithName:@"sc_mosaic_unselected.png"] forState:UIControlStateNormal];
                [btn setImage:[SCFbUtils img_imageWithName:@"sc_mosaic_selected.png"] forState:UIControlStateNormal];
            } else if (i == btnCount - 1) {
                // earser
                [btn setImage:[SCFbUtils img_imageWithName:@"sc_earser.png"] forState:UIControlStateNormal];
            }
        }
    }
    return _bottomView;
}

- (UIImageView *)hookImgView {
    if (!_hookImgView) {
        _hookImgView = [[UIImageView alloc] initWithImage:[SCFbUtils img_imageWithName:@"sc_hook.png"]];
        _hookImgView.frame = CGRectMake(0, 0, 10, 10);
        _hookImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _hookImgView;
}

- (UIView *)mosaicBottomView {
    if (!_mosaicBottomView) {
        CGRect frame = self.bottomView.frame;
        frame.origin.y = CGRectGetMaxY(self.view.frame);
        _mosaicBottomView = [[UIView alloc] initWithFrame:frame];
        _mosaicBottomView.backgroundColor = self.bottomView.backgroundColor;
        
        CGFloat const eachWidth = self.view.frame.size.width / kMosaicBottomViewBtnNumber;
        for (int i = 0; i < kMosaicBottomViewBtnNumber; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_mosaicBottomView addSubview:btn];
            btn.tag = kTagMosaicSizeBtn + i;
            btn.frame = CGRectMake(i * eachWidth, 0, eachWidth, bottomViewHeight);
            btn.contentMode = UIViewContentModeScaleAspectFit;
            [btn addTarget:self action:@selector(mosaicSizeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            if (i < kMosaicBottomViewBtnNumber - 1) {
                UIBezierPath *const path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(eachWidth / 2, bottomViewHeight / 2) radius:6 + i * 1.5 startAngle:0.0 endAngle:M_PI * 2 clockwise:YES];
                CAShapeLayer *layer = [CAShapeLayer layer];
                layer.name = kMosaicSizeBtnLayerName;
                layer.path = path.CGPath;
                layer.fillColor = (i == kMosaicBottomViewBtnNumber - 2 ? sc_rgba(0, 132, 255, 1) : [UIColor clearColor]).CGColor;
                layer.strokeColor = (i == kMosaicBottomViewBtnNumber - 2 ? sc_rgba(0, 132, 255, 1) : sc_rgba(152, 152, 152, 1)).CGColor;
                [btn.layer addSublayer:layer];
                
            } else {
                [btn setImage:[SCFbUtils img_imageWithName:@"sc_close.png"] forState:UIControlStateNormal];
            }
        }
    }
    return _mosaicBottomView;
}

#pragma mark - private methods
- (void)resetState {
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:_isNavBarHidden animated:YES];
    }
}

- (void)setupCloseBtn {
    if (self.navigationController) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[SCFbUtils img_imageWithName:@"sc_close.png"] style:UIBarButtonItemStylePlain target:self action:@selector(closeBtnPressed:)];
        self.navigationItem.leftBarButtonItem = item;
        return;
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, topViewHeight);
    [btn setImage:[SCFbUtils img_imageWithName:@"sc_close.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:btn];
}

- (void)closeBtnPressed:(UIButton*)sender {
    [self resetState];
    UIViewController *con = self.navigationController ? self.navigationController : self;
    [con dismissViewControllerAnimated:YES completion:^{}];
}

- (void)setupNextBtn {
    if (self.navigationController) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[SCFbUtils img_imageWithName:@"sc_arrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnPressed:)];
        self.navigationItem.rightBarButtonItem = item;
        return;
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(self.view.frame.size.width - 40, 0, 40, topViewHeight);
    [btn setImage:[SCFbUtils img_imageWithName:@"sc_arrow.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(nextBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:btn];
}

- (void)nextBtnPressed:(UIButton*)sender {
    UIImage *image = [self.drawerView finalImage];
    if (!self.isCustomNextStep) {
        SCFbMediaInfo *info = [SCFbMediaInfo infoWithImage:image];
        [[SCFeedbackManager sharedManager] gotoEditWithMediaInfo:info];
    }
    if (self.completeBlock) {
        self.completeBlock(image);
    }
}

- (void)setCustomTitle:(NSString *)customTitle {
    if (!customTitle || customTitle.length <= 0) {
        return;
    }
    
    if (self.navigationController) {
        self.navigationItem.title = customTitle;
        return;
    }
    UILabel *lbl = [_topView viewWithTag:kTagTitleLbl];
    if (!lbl) {
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.view.frame.size.width - 40 * 2, topViewHeight)];
        lbl.tag = kTagTitleLbl;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont boldSystemFontOfSize:16];
        lbl.textColor = [UIColor blackColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        [_topView addSubview:lbl];
    }
    lbl.text = customTitle;
}

- (void)bottomBtnPressed:(UIButton*)sender {
    
    NSInteger tag = sender.tag - kTagBottomBtn;
    
    if (tag == colorArr.count + 1) {
        // earser
        [self.drawerView clearAll];
        return;
    }
    
    if (sender == self.selectedBottomBtn) {
        return;
    }
    
    if (tag < colorArr.count) {
        // brush
        self.drawerView.type = SCDrawerTypeBrush;
        [self addHookImgViewIn:sender];
        self.drawerView.brushColor = colorArr[tag];
        return;
    }
    if (tag == colorArr.count) {
        // mosiac
        self.drawerView.type = SCDrawerTypeMosaic;
        [self showMosaicBottomView:YES];
        return;
    }
}

- (void)mosaicSizeBtnPressed:(UIButton*)sender {
    NSInteger tag = sender.tag - kTagMosaicSizeBtn;
    if (tag == kMosaicBottomViewBtnNumber - 1) {
        // close
        self.drawerView.type = SCDrawerTypeBrush;
        [self showMosaicBottomView:NO];
    } else {
        for (UIButton *btn in sender.superview.subviews) {
            if (![btn isKindOfClass:[UIButton class]] && btn.tag < kTagMosaicSizeBtn) {
                continue;
            }
            for (CAShapeLayer *layer in btn.layer.sublayers) {
                if ([layer isKindOfClass:[CAShapeLayer class]] && [layer.name isEqualToString:kMosaicSizeBtnLayerName]) {
                    layer.fillColor = (btn == sender ? sc_rgba(0, 132, 255, 1) : [UIColor clearColor]).CGColor;
                    layer.strokeColor = (btn == sender ? sc_rgba(0, 132, 255, 1) : sc_rgba(152, 152, 152, 1)).CGColor;
                }
            }
        }
        static CGFloat eachSize = kMaxMosaicSize / kMosaicBottomViewBtnNumber - 1;
        self.drawerView.mosaicSize = 10 + tag * eachSize;
    }
}

- (void)addHookImgViewIn:(UIButton*)btn {
    [self.hookImgView removeFromSuperview];
    self.hookImgView.center = CGPointMake(btn.frame.size.width / 2, btn.frame.size.height / 2);
    [btn addSubview:self.hookImgView];
}

- (void)showMosaicBottomView:(BOOL)willShow {
    CGRect frame = self.mosaicBottomView.frame;
    frame.origin.y = CGRectGetMaxY(self.view.frame) - (willShow ? bottomViewHeight : 0);
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.mosaicBottomView.frame = frame;
    } completion:^(BOOL finished) {
        ;
    }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
