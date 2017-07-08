//
//  SCFeedbackManager.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/5/3.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCFeedbackManager.h"
#import "SCDrawerViewController.h"
#import "SCFbUtils+sc_image.h"
#import "SCFbUtils+VCAndView.h"
#import "UIViewController+scfb_shake.h"
#import "SCFbNavigationController.h"

NSString *const scInfo_drawer_title = @"scInfo_drawer_title"; // SCEditInfoViewController's title

NSString *const scInfo_editInfo_title = @"scInfo_editInfo_title"; // SCEditInfoViewController's title
NSString *const scInfo_editInfo_placeholder = @"scInfo_editInfo_placeholder"; // SCEditInfoViewController, placeholder of textview
NSString *const scInfo_editInfo_beyondNumTitle = @"scInfo_editInfo_beyondNumTitle"; // SCEditInfoViewController, title of alert when the number of attachments is out of 4
NSString *const scInfo_editInfo_beyondNumMsg = @"scInfo_editInfo_beyondNumMsg"; // SCEditInfoViewController, message of alert when the number of attachments is out of 4
NSString *const scInfo_editInfo_beyondNumCancel = @"scInfo_editInfo_beyondNumCancel"; // SCEditInfoViewController, cancel button text of alert when the number of attachments is out of 4

NSString *const scInfo_shake_title = @"scInfo_shake_title"; // title of alert after shaking
NSString *const scInfo_shake_msg = @"scInfo_shake_msg"; // message of alert after shaking
NSString *const scInfo_shake_capture = @"scInfo_shake_capture"; // capture button text of alert after shaking
NSString *const scInfo_shake_record = @"scInfo_shake_record"; // record button text of alert after shaking
NSString *const scInfo_shake_closeShake = @"scInfo_shake_closeShake"; // close shaken button text of alert after shaking
NSString *const scInfo_shake_cancel = @"scInfo_shake_cancel"; // cancel button text of alert after shaking


@interface SCFeedbackManager() <UIAlertViewDelegate> {
    BOOL _sc_isShowingAlert;
}

@property (nonatomic, copy) sc_sendInfo_block sendInfoBlock;

@property (nonatomic, strong) SCFbOverlayWindow *overlayWindow;

@property (nonatomic, strong) NSMutableArray<SCFbMediaInfo*>* infosArr;
@property (nonatomic, copy) NSString *feedbackContent;

@end

@implementation SCFeedbackManager

static NSSet *_noShowAlertPages = nil;

+ (SCFeedbackManager*)sharedManager {
    static SCFeedbackManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SCFeedbackManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _sc_isShowingAlert = NO;
        [self enableShake:YES];
        self.customInfo = [@{
                          scInfo_drawer_title: @"反馈",
                          
                          scInfo_editInfo_title: @"反馈",
                          scInfo_editInfo_placeholder: @"出了什么错？",
                          scInfo_editInfo_beyondNumTitle: @"无法添加附件",
                          scInfo_editInfo_beyondNumMsg: @"删除现有附件以添加新附件",
                          scInfo_editInfo_beyondNumCancel: @"好哒",
                          
                          scInfo_shake_title: @"请问需要反馈什么问题？",
                          scInfo_shake_msg: @"你也可以在个人页的反馈帮助中心里找到这个功能",
                          scInfo_shake_capture: @"截图反馈",
                          scInfo_shake_record: @"录屏反馈",
                          scInfo_shake_closeShake: @"关闭摇一摇反馈",
                          scInfo_shake_cancel: @"没啥事",
                          } mutableCopy];
        [self addNotification:YES];
    }
    return self;
}

- (void)dealloc {
    [self addNotification:NO];
}

#pragma mark - public methods
- (void)enableShake:(BOOL)enable {
    if (enable) {
        SCWeakSelf(self)
        sc_installShakeAction(^(UIEvent *event) {
            SCStrongSelf(self)
            [self didReceiveMotionEvent:event];
        });
    } else {
        sc_uninstallShakeAction();
    }
}

- (NSString*)getInfoForKey:(NSString*)key {
    if (!self.customInfo || !key || key.length <= 0 || !self.customInfo[key]) {
        return @"";
    }
    return self.customInfo[key];
}

#pragma mark - ----- callback
- (void)setupSendInfoBlock:(sc_sendInfo_block)block {
    self.sendInfoBlock = block;
}

#pragma mark - ----- SCScreenRecorder
- (void)startRecordingWhenComplete:(sc_writer_completeBlock)block {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window]; // [[UIApplication sharedApplication] keyWindow];
    [self.screenRecorder startRecordingView:window completeBlock:block];
}

- (void)stopRecordView {
    if (_screenRecorder) {
        [self.screenRecorder stop];
        self.screenRecorder = nil;
    }
}

#pragma mark - ----- SCAudioManager
- (void)startRecordAudioWithComplete:(sc_audio_completeBlock)block {
    [self.audioManager startRecordWithComplete:block];
}

- (void)stopRecordAudio {
    if (_audioManager) {
        [self.audioManager stopRecord];
        self.audioManager = nil;
    }
}

#pragma mark - ----- SCDrawerViewController
- (void)captureToDrawWhenComplete:(sc_drawer_completeBlock)block {
    
    SCDrawerViewController *drawerCon = [[SCDrawerViewController alloc] init];
    drawerCon.image = [SCFbUtils img_snapshotForFullScreen];
    drawerCon.completeBlock = block;
    
    SCFbNavigationController *nav = [[SCFbNavigationController alloc] initWithRootViewController:drawerCon];
    [[SCFbUtils vc_getTopViewController] presentViewController:nav animated:YES completion:^{}];
}

#pragma mark - ----- SCEditInfoViewController
- (void)gotoEditWithMediaInfo:(SCFbMediaInfo *)theNewInfo {
    
    SCEditInfoViewController *editInfoCon = [[SCEditInfoViewController alloc] init];
    editInfoCon.theNewInfo = theNewInfo;
    editInfoCon.completeBlock = self.sendInfoBlock;
    
    UIViewController *topCon = [SCFbUtils vc_getTopViewController];
    
    SCFbNavigationController *nav = [[SCFbNavigationController alloc] initWithRootViewController:editInfoCon];

    UIViewController *preCon = topCon.presentingViewController;
    if (preCon && [topCon isKindOfClass:[SCDrawerViewController class]]) {
        [topCon dismissViewControllerAnimated:NO completion:^{
            [preCon presentViewController:nav animated:YES completion:nil];
        }];
    } else {
        [topCon presentViewController:nav animated:YES completion:^{}];
    }
}

- (void)showOverlayBtnWithtype:(SCFbOverlayType)type {
    self.overlayWindow.hidden = NO;
    self.overlayWindow.type = type;
}

- (void)hideOverlayBtn {
    self.overlayWindow.hidden = YES;
}

- (void)saveMediaInfos:(NSArray<SCFbMediaInfo *> *)infosArr textContent:(NSString *)text {
    [self.infosArr removeAllObjects];
    [self.infosArr addObjectsFromArray:infosArr];
    self.feedbackContent = text;
}

- (NSMutableArray<SCFbMediaInfo*>*)getSavedMediaInfos {
    return self.infosArr;
}

- (NSString*)getSavedTextContent {
    return self.feedbackContent;
}

- (void)cleanSavedData {
    [self.infosArr removeAllObjects];
    self.infosArr = nil;
    self.feedbackContent = nil;
}

#pragma mark - private methods
- (void)didReceiveMotionEvent:(UIEvent *)event {
    if (_sc_isShowingAlert || event.type != UIEventTypeMotion || event.subtype != UIEventSubtypeMotionShake || ![self canShowAlert]) {
        return;
    }
    _sc_isShowingAlert = YES;
    NSString *title = [self getInfoForKey:scInfo_shake_title];
    NSString *msg = [self getInfoForKey:scInfo_shake_msg];
    NSString *first = [self getInfoForKey:scInfo_shake_capture];
    NSString *second = [self getInfoForKey:scInfo_shake_record];
    NSString *third = [self getInfoForKey:scInfo_shake_closeShake];
    NSString *cancel = [self getInfoForKey:scInfo_shake_cancel];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancel otherButtonTitles:first, second, third, nil];
    [alert show];
}

- (BOOL)canShowAlert {
    if (!_noShowAlertPages) {
        _noShowAlertPages = [NSSet setWithObjects:@"SCDrawerViewController", @"SCEditInfoViewController", @"SCFileListViewController", nil];
    }
    NSString *topConClass = NSStringFromClass([[SCFbUtils vc_getTopViewController] class]);
    return ![_noShowAlertPages containsObject:topConClass];
}

- (void)addNotification:(BOOL)toAdd {
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    if (!toAdd) {
        [notiCenter removeObserver:self name:kNotificationDidReachMaxTime_scfb object:nil];
        return;
    }
    SCWeakSelf(self)
    [notiCenter addObserverForName:kNotificationDidReachMaxTime_scfb object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        SCStrongSelf(self)
        [self hideOverlayBtn];
        self.screenRecorder = nil;
    }];
}


#pragma mark - properties
- (SCScreenRecorder *)screenRecorder {
    if (!_screenRecorder) {
        _screenRecorder = [[SCScreenRecorder alloc] init];
    }
    return _screenRecorder;
}

- (SCAudioManager *)audioManager {
    if (!_audioManager) {
        _audioManager = [[SCAudioManager alloc] init];
    }
    return _audioManager;
}

- (SCFbOverlayWindow *)overlayWindow {
    if (!_overlayWindow) {
        _overlayWindow = [[SCFbOverlayWindow alloc] initWithFrame:CGRectMake([SCFbUtils vc_screenWidth] - 60 , [SCFbUtils vc_screenHeight] - 60, 60, 60)];
        _overlayWindow.paddingBottomAndRight = 5;
    }
    return _overlayWindow;
}

- (NSMutableArray<SCFbMediaInfo *> *)infosArr {
    if (!_infosArr) {
        _infosArr = [NSMutableArray array];
    }
    return _infosArr;
}

#pragma mark - ----- alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _sc_isShowingAlert = NO;
    switch (buttonIndex) {
        case 0: {
            break;
        }
        case 1: {
            [self captureToDrawWhenComplete:^(UIImage *image) {
                ;
            }];
            break;
        }
        case 2: {
            [self showOverlayBtnWithtype:SCFbOverlayTypeRecorder];
            [self.overlayWindow didPressOverlayBtn];
            break;
        }
        case 3: {
            [self enableShake:NO];
            break;
        }
        default:
            break;
    }
}

@end
