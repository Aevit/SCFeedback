//
//  SCFileListViewController.m
//  SCScreenRecorder
//
//  Created by Aevit on 2017/5/1.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCFileListViewController.h"
#import "SCFbUtils+sc_file.h"
#import "SCFbUtils+sc_image.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SCFeedbackManager.h"

@interface SCFileListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *filesArr;

@property (nonatomic, strong) MPMoviePlayerViewController *playerVC;

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation SCFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!self.fileFolder || [self.fileFolder isEqual:[NSNull null]] || self.fileFolder.length <= 0) {
        self.fileFolder = [SCFbUtils file_scrcd_default_folder];
    }
    self.filesArr = [NSMutableArray arrayWithArray:[[SCFbUtils file_getAllFilesInPath:self.fileFolder] reverseObjectEnumerator].allObjects];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.title = @"Files";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"edit" style:UIBarButtonItemStylePlain target:self action:@selector(editBtnPressed:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self resetNavi];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if ([SCFeedbackManager sharedManager].audioManager.player.isPlaying) {
        [[SCFeedbackManager sharedManager].audioManager stopPlay];
    }
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

#pragma mark - private methods
- (void)setupCloseBtn {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[SCFbUtils img_imageWithName:@"sc_close.png"] style:UIBarButtonItemStylePlain target:self action:@selector(closeBtnPressed:)];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)resetNavi {
    if (self.navigationController && self.navigationController.viewControllers.count <= 1) {
        [self setupCloseBtn];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    self.navigationItem.rightBarButtonItem.title = @"edit";
}

#pragma mark - actions
- (void)closeBtnPressed:(id)sender {
    UIViewController *con = self.navigationController ? self.navigationController : self;
    [con dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filesArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    NSURL *fileUrl = self.filesArr[indexPath.row];
    
    // file name
    NSString *fileName = [fileUrl lastPathComponent];
    // file size
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileUrl.path error:nil] fileSize];
    NSString *otherInfoText = [NSString stringWithFormat:@"%llukb", fileSize / 1024];
    
    // video duration
    CMTime duration = kCMTimeZero;
    if ([[SCFbUtils file_sc_videoTypeSet] containsObject:[fileUrl pathExtension]] || [[SCFbUtils file_sc_audioTypeSet] containsObject:[fileUrl pathExtension]]) {
        AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:fileUrl options:nil];
        duration = sourceAsset.duration;
        otherInfoText = [NSString stringWithFormat:@"%@ - %.2fs", otherInfoText, CMTimeGetSeconds(duration)];
    }
    
    cell.textLabel.text = fileName;
    cell.detailTextLabel.text = otherInfoText;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        return;
    }
    NSURL *url = self.filesArr[indexPath.row];
    if ([[SCFbUtils file_sc_videoTypeSet] containsObject:[url pathExtension]]) {
        [self playVideo:url];
    } else if ([[SCFbUtils file_sc_picTypeSet] containsObject:[url pathExtension]]) {
        [self showImage:url];
    } else if ([[SCFbUtils file_sc_audioTypeSet] containsObject:[url pathExtension]]) {
        [[SCFeedbackManager sharedManager].audioManager startPlayWithUrl:url];
    }
}

#pragma mark - actions
- (void)editBtnPressed:(id)sender {
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
    
    if (self.tableView.isEditing) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteBtnPressed:)];
        self.navigationItem.leftBarButtonItem = leftItem;
        self.navigationItem.rightBarButtonItem.title = @"cancel";
    } else {
        [self resetNavi];
    }
}

- (void)deleteBtnPressed:(id)sender {
    
    [self resetNavi];
    
    NSMutableArray *files = [NSMutableArray array];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        [files addObject:self.filesArr[indexPath.row]];
    }
    
    [SCFbUtils file_deleteFiles:files];
    [self.filesArr removeObjectsInArray:files];
    [self.tableView reloadData];
    
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}

- (void)playVideo:(NSURL*)url {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    self.playerVC.moviePlayer.contentURL = url;
    [self.playerVC.moviePlayer prepareToPlay];
    [self.playerVC.moviePlayer play];
    [self presentMoviePlayerViewControllerAnimated:self.playerVC];
}

- (void)videoFinished:(NSNotification*)aNotification {
    int value = [[aNotification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonUserExited) {
        [self dismissMoviePlayerViewControllerAnimated];
    }
}

- (void)showImage:(NSURL*)url {
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    self.imgView.image = image;
    self.imgView.alpha = 0;
    [self.view addSubview:self.imgView];
    [UIView animateWithDuration:0.3 animations:^{
        self.imgView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didTapImgView:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.imgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.imgView removeFromSuperview];
    }];
}

#pragma mark - props
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.allowsMultipleSelectionDuringEditing = YES;
    }
    return _tableView;
}

- (MPMoviePlayerViewController *)playerVC {
    if (_playerVC == nil) {
        _playerVC = [[MPMoviePlayerViewController alloc] init];
        [[NSNotificationCenter defaultCenter] removeObserver:_playerVC name:MPMoviePlayerPlaybackDidFinishNotification object:_playerVC.moviePlayer]; // not auto exit when the video finish playing
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:_playerVC.moviePlayer]; // press the Done button to exit
    }
    return _playerVC;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        _imgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImgView:)];
        [_imgView addGestureRecognizer:tapGes];
    }
    return _imgView;
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
