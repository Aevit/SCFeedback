//
//  SCEditInfoViewController.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/13.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCEditInfoViewController.h"
#import "SCFbMediaView.h"
#import "SCDrawerViewController.h"
#import "SCFbUtils.h"
#import "SCTextView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SCFeedbackManager.h"

#define MEDIA_VIEW_X(idx) (20.0 + idx * 90)

static CGFloat const topViewHeight = 44;
static NSInteger const kTagTitleLbl = 98792;


static CGFloat const infoViewGap = 10;
static CGFloat const mediaAreaHeight = 100;
static CGFloat const kbToolViewHeight = 44;

static NSInteger const kTagToolBtn =1200;

@interface SCEditInfoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    BOOL _isNavBarHidden;
    BOOL _maxMediaNum;
    BOOL _isPressedToolBtn;
}

/**
 data array, each elemenet should be the instance of SCFbMediaInfoImage or SCFbMediaInfoVideo
 */
@property (nonatomic, strong) NSMutableArray<SCFbMediaInfo *> *dataArray;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) SCTextView *textView;

@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UIScrollView *mediaContainerView;
@property (nonatomic, strong) UIView *kbToolView;

@property (nonatomic, copy) sc_maxMediaInfoNum_block toMaxNumBlock;
           
@end

@implementation SCEditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // delegate
    SCFeedbackManager *manager = [SCFeedbackManager sharedManager];
    if ([manager.delegate respondsToSelector:@selector(scFeedback:didShowEditInfoController:)]) {
        [manager.delegate scFeedback:manager didShowEditInfoController:self];
    }
    
    // initialize data
    [self initData];
    
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
    [self setCustomTitle:[[SCFeedbackManager sharedManager] getInfoForKey:scInfo_editInfo_title]];
    
    [self.view addSubview:self.textView];
    self.textView.placeholder = [[SCFeedbackManager sharedManager] getInfoForKey:scInfo_editInfo_placeholder];
    [self.view addSubview:self.infoView];
    [self.infoView addSubview:self.mediaContainerView];
    [self.infoView addSubview:self.kbToolView];
    
    // notification
    [self addNotification:YES];
    
    // show keyboard
    [self.textView becomeFirstResponder];
    
    // refresh content
    if (self.theNewInfo) {
        [self.dataArray addObject:self.theNewInfo];
    }
    [self refreshMediaContent];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    [self addNotification:NO];
    if (!_isPressedToolBtn) {
        [[SCFeedbackManager sharedManager] cleanSavedData];
    }
}

- (void)initData {
    _maxMediaNum = 4;
    _isPressedToolBtn = NO;
    
    NSArray<SCFbMediaInfo*> *savedDataArr = [[SCFeedbackManager sharedManager] getSavedMediaInfos];
    if (savedDataArr && savedDataArr.count > 0) {
        [self.dataArray addObjectsFromArray:savedDataArr];
    }
    self.textView.text = [[[SCFeedbackManager sharedManager] getSavedTextContent] copy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - public methods
- (void)setupMaxMediaNum:(NSInteger)num toMaxBlock:(sc_maxMediaInfoNum_block)block {
    _maxMediaNum = num;
    self.toMaxNumBlock = block;
}

#pragma mark - private methods
- (void)addMediaInfo:(SCFbMediaInfo*)info {
    NSAssert(info, @"SCFeedback: the media info is nil");
    if (!info || ![self canAdd]) {
        return;
    }
    [self.dataArray addObject:info];
    if (_mediaContainerView) {
        [self addMediaView:info];
    }
}

- (void)refreshMediaContent {
    
    if (!_dataArray) {
        return;
    }
    
    [self.mediaContainerView.subviews enumerateObjectsUsingBlock:^(__kindof SCFbMediaView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[SCFbMediaView class]]) {
            [obj removeFromSuperview];
        }
    }];
    
    SCWeakSelf(self)
    [self.dataArray enumerateObjectsUsingBlock:^(SCFbMediaInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SCStrongSelf(self)
        [self addMediaView:obj];
    }];
}

- (BOOL)canAdd {
    if (self.dataArray.count >= 4) {
        if (self.toMaxNumBlock) {
            self.toMaxNumBlock();
        } else {
            NSString *title = [[SCFeedbackManager sharedManager] getInfoForKey:scInfo_editInfo_beyondNumTitle];
            NSString *msg = [[SCFeedbackManager sharedManager] getInfoForKey:scInfo_editInfo_beyondNumMsg];
            NSString *cancel = [[SCFeedbackManager sharedManager] getInfoForKey:scInfo_editInfo_beyondNumCancel];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancel otherButtonTitles:nil];
            [alert show];
        }
        return NO;
    }
    return YES;
}

- (void)addMediaView:(SCFbMediaInfo*)aInfo {
    if (self.dataArray.count <= 0) {
        return;
    }
    SCWeakSelf(self)
    NSInteger idx = [self.dataArray indexOfObject:aInfo];
    if (idx == NSNotFound) {
        return;
    }
    SCFbMediaView *aView = [[SCFbMediaView alloc] initWithFrame:CGRectMake(MEDIA_VIEW_X(idx), 0, 80, mediaAreaHeight) info:aInfo];
    SCWeakSelf(aView);
    
    aView.whenTapSelf = ^(UIButton *btn, SCFbMediaInfo *info) {
        SCStrongSelf(self)
        if (info.type == SCFbMediaTypeImage) {
            SCDrawerViewController *con = [[SCDrawerViewController alloc] init];
            con.isCustomNextStep = YES;
            con.image = [info image];
            SCWeakSelf(con)
            con.completeBlock = ^(UIImage *image) {
                SCStrongSelf(aView);
                SCStrongSelf(con);
                [info refreshImage:image];
                [aView refreshImage:image];
                [con dismissViewControllerAnimated:YES completion:^{}];
            };
            [self presentViewController:con animated:YES completion:^{}];
            return;
        }
        if (info.type == SCFbMediaTypeVideo) {
            [self playVideo:info];
        }
    };
    
    aView.whenTapDeleteBtn = ^(UIButton *btn, SCFbMediaInfo *info) {
        SCStrongSelf(self)
        [self.dataArray removeObject:info];
        [btn.superview removeFromSuperview];
        [self layoutMediaView:info];
    };
    
    [self.mediaContainerView addSubview:aView];
    
    [self resetContentSize];
}

- (void)resetContentSize {
    CGSize size = self.mediaContainerView.contentSize;
    size.width = MEDIA_VIEW_X(self.dataArray.count); // (aView ? CGRectGetMaxX(aView.frame) + 20 : 0);
    self.mediaContainerView.contentSize = size;
}

- (void)layoutMediaView:(SCFbMediaInfo*)info {
    __block NSUInteger count = 0; // the subview of mediaContainerView may not be a "SCFbMediaView"
    [self.mediaContainerView.subviews enumerateObjectsUsingBlock:^(__kindof SCFbMediaView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[SCFbMediaView class]]) {
            CGRect frame = obj.frame;
            frame.origin.x = MEDIA_VIEW_X(count);
            if (CGRectGetMinX(obj.frame) != CGRectGetMinX(frame)) {
                [UIView animateWithDuration:0.3 animations:^{
                    obj.frame = frame;
                } completion:^(BOOL finished) {
                }];
            }
            count++;
        }
    }];
    [self resetContentSize];
}

#pragma mark - properties
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), topViewHeight)];
        _topView.backgroundColor = sc_rgba(246, 246, 246, 1);
        [self setupCloseBtn];
        [self setupNextBtn];
    }
    return _topView;
}

- (SCTextView *)textView {
    if (!_textView) {
        _textView = [[SCTextView alloc] initWithFrame:CGRectMake(0, (self.navigationController ? 0 : topViewHeight), CGRectGetWidth(self.view.frame), 300)];
        _textView.font = [UIFont systemFontOfSize:16];
    }
    return _textView;
}

- (UIView *)infoView {
    if (!_infoView) {
        CGFloat height = mediaAreaHeight + infoViewGap + kbToolViewHeight;
        _infoView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - height, CGRectGetWidth(self.view.frame), height)];
        _infoView.backgroundColor = [UIColor whiteColor];
    }
    return _infoView;
}

- (UIScrollView *)mediaContainerView {
    if (!_mediaContainerView) {
        _mediaContainerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), mediaAreaHeight)];
        _mediaContainerView.backgroundColor = [UIColor whiteColor];
        _mediaContainerView.showsHorizontalScrollIndicator = NO;
    }
    return _mediaContainerView;
}

- (UIView *)kbToolView {
    if (!_kbToolView) {
        _kbToolView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_infoView.frame) - kbToolViewHeight, CGRectGetWidth(self.view.frame), kbToolViewHeight)];
        _kbToolView.backgroundColor = [UIColor whiteColor];
        _kbToolView.layer.borderWidth = 1;
        _kbToolView.layer.borderColor = sc_rgba(227, 226, 228, 1).CGColor;
        for (int i = 0; i < 3; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = kTagToolBtn + i;
            btn.frame = CGRectMake(10 + kbToolViewHeight * i, 0, kbToolViewHeight, kbToolViewHeight);
            NSString *picStr = (i == 0 ? @"sc_recorder_unselected.png" : (i == 1 ? @"sc_camera_unselected.png" : (i == 2 ? @"sc_picture_unselected.png" : @"")));
            [btn setImage:[UIImage imageNamed:picStr] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(toolBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_kbToolView addSubview:btn];
        }
    }
    return _kbToolView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - private methods
- (void)resetState {
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:_isNavBarHidden animated:YES];
    }
}

- (void)addNotification:(BOOL)toAdd {
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    if (!toAdd) {
        [notiCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [notiCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        return;
    }
    SCWeakSelf(self)
    
    __block CGRect infoViewFrame = self.infoView.frame;
    __block CGRect textVFrame = self.textView.frame;
    
    [notiCenter addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSValue *aValue = note.userInfo[UIKeyboardFrameEndUserInfoKey];
        CGFloat keyBoardHeight = aValue.CGRectValue.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            SCStrongSelf(self)
            CGFloat infoViewY = CGRectGetHeight(self.view.frame) - CGRectGetHeight(infoViewFrame) - keyBoardHeight;
            
            infoViewFrame.origin.y = infoViewY;
            self.infoView.frame = infoViewFrame;
            
            textVFrame.size.height = infoViewY;
            self.textView.frame = textVFrame;
        }];
    }];
    [notiCenter addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [UIView animateWithDuration:0.3 animations:^{
            SCStrongSelf(self)
            CGFloat infoViewY = CGRectGetHeight(self.view.frame) - CGRectGetHeight(infoViewFrame);
            
            infoViewFrame.origin.y = infoViewY;
            self.infoView.frame = infoViewFrame;
            
            textVFrame.size.height = infoViewY;
            self.textView.frame = textVFrame;
        }];
    }];
}

- (void)setupCloseBtn {
    if (self.navigationController) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sc_close.png"] style:UIBarButtonItemStylePlain target:self action:@selector(closeBtnPressed:)];
        self.navigationItem.leftBarButtonItem = item;
        return;
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, topViewHeight);
    [btn setImage:[UIImage imageNamed:@"sc_close.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:btn];
}

- (void)closeBtnPressed:(UIButton*)sender {
    [self resetState];
    if (self.navigationController && self.navigationController.viewControllers.count >= 2) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)setupNextBtn {
    if (self.navigationController) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sc_send.png"] style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnPressed:)];
        self.navigationItem.rightBarButtonItem = item;
        return;
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(self.view.frame.size.width - 40, 0, 40, topViewHeight);
    [btn setImage:[UIImage imageNamed:@"sc_send.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(nextBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:btn];
}

- (void)nextBtnPressed:(UIButton*)sender {
    if (self.completeBlock) {
        self.completeBlock(self, self.dataArray, self.textView.text);
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

- (void)toolBtnPressed:(UIButton*)sender {
    if (![self canAdd]) {
        return;
    }
    switch (sender.tag - kTagToolBtn) {
        case 0:
        {
            _isPressedToolBtn = YES;
            [self saveData];
            [[SCFeedbackManager sharedManager] showOverlayBtnWithtype:SCFbOverlayTypeRecorder];
            [self dismissViewControllerAnimated:YES completion:^{}];
            break;
        }
        case 1:
        {
            _isPressedToolBtn = YES;
            [self saveData];
            [[SCFeedbackManager sharedManager] showOverlayBtnWithtype:SCFbOverlayTypeCapture];
            [self dismissViewControllerAnimated:YES completion:^{}];
            break;
        }
        case 2:
        {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                return;
            UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
            imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imgPicker.delegate = self;
            [self presentViewController:imgPicker animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

- (void)saveData {
    [[SCFeedbackManager sharedManager] saveMediaInfos:self.dataArray textContent:self.textView.text];
}

- (void)playVideo:(SCFbMediaInfo*)info {
    if (!info || info.type != SCFbMediaTypeVideo) {
        return;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[info videoFileUrl]];
    [[NSNotificationCenter defaultCenter] removeObserver:playerVC name:MPMoviePlayerPlaybackDidFinishNotification object:playerVC.moviePlayer]; // not auto exit when the video finish playing
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:playerVC.moviePlayer]; // press the Done button to exit
    
    [playerVC.moviePlayer prepareToPlay];
    [playerVC.moviePlayer play];
    
    [self presentMoviePlayerViewControllerAnimated:playerVC];
}

- (void)videoFinished:(NSNotification*)aNotification {
    int value = [[aNotification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonUserExited) {
        [self dismissMoviePlayerViewControllerAnimated];
    }
}

#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    SCFbMediaInfo *mediaInfo = [SCFbMediaInfo infoWithImage:image];
    [self addMediaInfo:mediaInfo];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [_textView becomeFirstResponder];
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



