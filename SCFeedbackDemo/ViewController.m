//
//  ViewController.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/5/3.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "ViewController.h"
#import "SCFeedbackManager.h"
#import "SCFileListViewController.h"
#import "SCFbUtils+sc_file.h"
#import "SCDrawerViewController.h"
#import "SCFbUtils+sc_image.h"
#import "SCEditInfoViewController.h"


static NSString *cellInfoKeyTitle = @"cellInfoKeyTitle";
static NSString *cellInfoKeySel = @"cellInfoKeySel";

@interface CellInfo : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *selectorStr;

@end

@implementation CellInfo

- (instancetype)initWithDict:(NSDictionary*)aDict {
    if (self = [super init]) {
        _title = [aDict[cellInfoKeyTitle] copy];
        _selectorStr = [aDict[cellInfoKeySel] copy];
    }
    return self;
}

@end





@interface ViewController () <SCFeedbackDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"SCFeedback";
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"files" style:UIBarButtonItemStylePlain target:self action:@selector(gotoFilesList:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"start record" style:UIBarButtonItemStylePlain target:self action:@selector(startRecord:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
//    [SCFeedbackManager sharedManager].customInfo[scInfo_drawer_title] = @"截图反馈"; // demo
//    [[SCFeedbackManager sharedManager] enableShake:YES];
    [SCFeedbackManager sharedManager].delegate = self;
    [[SCFeedbackManager sharedManager] setupSendInfoBlock:^(UIViewController *editInfoController, NSArray<SCFbMediaInfo *> *dataArray, NSString *text) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hey!" message:@"do something here, such as to compress the images and upload the data" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [editInfoController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
- (void)gotoFilesList:(id)sender {
    [self gotoFilesListController:nil];
}

- (void)startRecord:(UIBarButtonItem*)sender {

    self.isRecording = !self.isRecording;
    
    [sender setTitle:(self.isRecording ? @"stop record" : @"start record")];
    
    if (self.isRecording) {
        [self startRecording:nil];
    } else {
        [self stopRecording:nil];
    }
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count + 1000;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    CellInfo *info = self.dataArray.count > indexPath.row ? self.dataArray[indexPath.row] : nil;
    NSString *text = nil;
    if (!info || isEmptyStr(info.title)) {
        text = [NSString stringWithFormat:@"row: %ld", (long)indexPath.row];
    } else {
        text = [NSString stringWithFormat:@"row: %ld（%@）", (long)indexPath.row, info.title];
    }
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CellInfo *info = self.dataArray.count > indexPath.row ? self.dataArray[indexPath.row] : nil;
    if (!info || isEmptyStr(info.selectorStr)) {
        return;
    }
    
    SEL selector = NSSelectorFromString(info.selectorStr);
    [self performSelector:selector withObject:indexPath afterDelay:0];
}

#pragma mark - private
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:(error ? @"保存失败" : @"已存入手机相册") delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - props
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        
        NSArray *tmp = @[
                         @{cellInfoKeyTitle: @"enable shake action", cellInfoKeySel: @"enableShakeAction:"},
                         @{cellInfoKeyTitle: @"disable shake action", cellInfoKeySel: @"disableShakeAction:"},
                         
                         @{cellInfoKeyTitle: @"", cellInfoKeySel: @""},
                         @{cellInfoKeyTitle: @"show edit controller", cellInfoKeySel: @"showEditController:"},
                         
                         @{cellInfoKeyTitle: @"", cellInfoKeySel: @""},
                         @{cellInfoKeyTitle: @"show overlay recorder", cellInfoKeySel: @"showOverlayRecorder:"},
                         @{cellInfoKeyTitle: @"show overlay capture", cellInfoKeySel: @"showOverlayCapture:"},
                         
                         @{cellInfoKeyTitle: @"", cellInfoKeySel: @""},
                         @{cellInfoKeyTitle: @"start recording", cellInfoKeySel: @"startRecording:"},
                         @{cellInfoKeyTitle: @"stop recording", cellInfoKeySel: @"stopRecording:"},
                         @{cellInfoKeyTitle: @"pause recording", cellInfoKeySel: @"pauseRecording:"},
                         @{cellInfoKeyTitle: @"resume recording", cellInfoKeySel: @"resumeRecording:"},
                         
                         @{cellInfoKeyTitle: @"", cellInfoKeySel: @""},
                         @{cellInfoKeyTitle: @"capture to draw", cellInfoKeySel: @"captureToDraw:"},
                         
                         @{cellInfoKeyTitle: @"", cellInfoKeySel: @""},
                         @{cellInfoKeyTitle: @"start record audio", cellInfoKeySel: @"startRecordAudio:"},
                         @{cellInfoKeyTitle: @"stop record audio", cellInfoKeySel: @"stopRecordAudio:"},
                         @{cellInfoKeyTitle: @"pause record audio", cellInfoKeySel: @"pauseRecordAudio:"},
                         @{cellInfoKeyTitle: @"resume record audio", cellInfoKeySel: @"resumeRecordAudio:"},
                         
                         @{cellInfoKeyTitle: @"", cellInfoKeySel: @""},
                         @{cellInfoKeyTitle: @"go to files list", cellInfoKeySel: @"gotoFilesListController:"},
                         @{cellInfoKeyTitle: @"delete ./Library/Caches/scrcd", cellInfoKeySel: @"deleteAllFiles:"},
                         @{cellInfoKeyTitle: @"delete images in '/scrcd'", cellInfoKeySel: @"deleteAllImage:"},
                         
                         @{cellInfoKeyTitle: @"", cellInfoKeySel: @""},
                         @{cellInfoKeyTitle: @"show webview", cellInfoKeySel: @"showWebview:"},
                        ];
        for (NSDictionary *aDict in tmp) {
            CellInfo *aData = [[CellInfo alloc] initWithDict:aDict];
            [_dataArray addObject:aData];
        }
    }
    return _dataArray;
}

#pragma mark - ------------------------- cell actions
#pragma mark - edit controller
- (void)showEditController:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager] gotoEditWithMediaInfo:nil];
}

#pragma mark - overlay
- (void)showOverlayRecorder:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager] showOverlayBtnWithtype:SCFbOverlayTypeRecorder];
}

- (void)showOverlayCapture:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager] showOverlayBtnWithtype:SCFbOverlayTypeCapture];
}

#pragma mark - recorder
- (void)startRecording:(NSIndexPath*)indexPath {
    if (self.isRecording) {
        return;
    }
    self.isRecording = YES;
    
    SCScreenRecorder *recorder = [SCFeedbackManager sharedManager].screenRecorder;
    
    // custom frameRate
    recorder.frameRate = 8;
    
    // custom output URL
//    NSString *folder = [SCFbUtils file_scrcd_default_folder];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyyMMdd_HHmmss";
//    NSString *date = [formatter stringFromDate:[NSDate date]];
//    NSString *fileName = [NSString stringWithFormat:@"scrcd_%@.mp4", date];
//    NSString *filePath = [NSString stringWithFormat:@"%@/%@", folder, fileName];
//    recorder.outputURL = [NSURL fileURLWithPath:filePath];
    
    // custom size
//    recorder.size = CGSizeMake(100, 200);
    
    // touch point
    recorder.showTouchPoint = YES;
    
    // record audio
    recorder.includeAudio = YES;
    
    SCWeakSelf(self)
    [recorder setupMaxTime:10 callback:^(uint64_t maxTime) {
        SCStrongSelf(self)
        self.isRecording = NO;
        SCFbLog(@"reach the max time");
    }];
    
    [[SCFeedbackManager sharedManager] startRecordingWhenComplete:^(NSURL *fileUrl, UIImage *coverImage) {
//            [SCFeedbackManager sharedManager].screenRecorder = nil;
        SCFbLog(@"SCFeedback: final output video: %@", fileUrl.absoluteString);
        SCFbMediaInfo *info = [SCFbMediaInfo infoWithVideoFileUrl:fileUrl coverImg:coverImage];
        [[SCFeedbackManager sharedManager] gotoEditWithMediaInfo:info];
    }];
}

- (void)stopRecording:(NSIndexPath*)indexPath {
    if (!self.isRecording) {
        return;
    }
    self.isRecording = NO;
    [[SCFeedbackManager sharedManager] stopRecordView];
}

- (void)pauseRecording:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager].screenRecorder pause];
}

- (void)resumeRecording:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager].screenRecorder resume];
}

#pragma mark - capture
- (void)captureToDraw:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager] captureToDrawWhenComplete:^(UIImage *image) {
//        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
//        con.isCustomNextStep = YES;
}

#pragma mark - shake action
- (void)enableShakeAction:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager] enableShake:YES];
}

- (void)disableShakeAction:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager] enableShake:NO];
}

#pragma mark - audio
- (void)startRecordAudio:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager] startRecordAudioWithComplete:^(NSURL *fileUrl) {
//            [SCFeedbackManager sharedManager].audioManager = nil;
        SCFbLog(@"SCFeedback: output audio file path: %@", fileUrl.absoluteString);
    }];
}

- (void)stopRecordAudio:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager] stopRecordAudio];
}

- (void)pauseRecordAudio:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager].audioManager pauseRecord];
}

- (void)resumeRecordAudio:(NSIndexPath*)indexPath {
    [[SCFeedbackManager sharedManager].audioManager resumeRecord];
}

#pragma mark - file
- (void)gotoFilesListController:(NSIndexPath*)indexPath {
    SCFileListViewController *con = [[SCFileListViewController alloc] init];
    [self.navigationController pushViewController:con animated:YES];
}

- (void)deleteAllImage:(NSIndexPath*)indexPath {
    [SCFbUtils file_deleteAllImageInPath:[SCFbUtils file_scrcd_default_folder]];
}

- (void)deleteAllFiles:(NSIndexPath*)indexPath {
    [SCFbUtils file_deleteFolder:[SCFbUtils file_scrcd_default_folder]];
}

#pragma mark - webview
- (void)showWebview:(NSIndexPath*)indexPath {
    UIViewController *con = [[UIViewController alloc] init];
    UIWebView *web = [[UIWebView alloc] initWithFrame:con.view.bounds];
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [con.view addSubview:web];
    [self.navigationController pushViewController:con animated:YES];
}

#pragma mark - SCFeedbackManager delegate
- (void)scFeedback:(SCFeedbackManager *)manager didShowDrawerController:(SCDrawerViewController *)controller {
//    controller.isCustomNextStep = YES;
//    controller.completeBlock = ^(UIImage *image) {
//        // do something with the image
//    };
}

- (void)scFeedback:(SCFeedbackManager *)manager didShowEditInfoController:(SCEditInfoViewController *)controller {
    SCFbLog(@"edit info: %@", controller);
}

- (void)scFeedback:(SCFeedbackManager *)manager didSaveRecordingVideoUrl:(NSURL *)fileUrl coverImage:(UIImage *)coverImage {
    
}

@end







