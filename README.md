## SCFeedback

[![Build Status](https://travis-ci.org/Aevit/SCFeedback.svg?branch=master)](https://travis-ci.org/Aevit/SCFeedback)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SCFeedback.svg?style=flat)](https://github.com/Aevit/SCFeedback)
[![Platform](https://img.shields.io/cocoapods/p/SCFeedback.svg?style=flat)](http://cocoadocs.org/docsets/SCFeedback)
[![Language](https://img.shields.io/badge/language-ObjectiveC-orange.svg)](http://cocoadocs.org/docsets/SCFeedback)
[![LICENSE](https://img.shields.io/cocoapods/l/SCFeedback.svg?style=flat)](https://raw.githubusercontent.com/Aevit/SCFeedback/master/LICENSE)

In-App Feedback for iOS (simplified version of [Instabug](https://instabug.com/))  

* in-app recording video  
* capture screen and draw with mark or mosiac


## Demo
[Demo Video](http://aevit.qiniudn.com/scfeedback_demo.mp4)

[or download the video (1.7MB)](https://raw.githubusercontent.com/Aevit/SCFeedback/master/demo.mp4)


## Requirements
* iOS 7.0 or later  
* Xcode 8.0 or later  


## Installation

### [CocoaPods](https://cocoapods.org/)
* add this line to your Podfile: `pod 'SCFeedback'`  
* install the pod: `pod install`  


## Usage

### Simply use
* add the `microphone` and `photoLibrary` authority to the `info.plist`:  

```
<dict>
...
	
	<key>NSMicrophoneUsageDescription</key>
	<string>需要您的同意,才能访问麦克风</string>
	
	<key>NSPhotoLibraryUsageDescription</key>
	<string>需要您的同意,才能访问相册</string>
	
...
</dict>
```

* import the header file, and then setup the block to send the feedback content (image/video/text):  

```
#import <SCFeedback/SCFeedbackManager.h>

[[SCFeedbackManager sharedManager] setupSendInfoBlock:^(UIViewController *editInfoController, NSArray<SCFbMediaInfo *> *dataArray, NSString *text) {
	// Hey, do something here, such as to compress the images and upload the data
	[editInfoController dismissViewControllerAnimated:YES completion:nil];
}];
```


> you could add the code above where you want, such as in `AppDelegate.m` or your custom file.  


`SCFbMediaInfo` is a `ClassCluster`, you can get the image or video url like this:  

```
// SCFbMediaInfo *info = dataArray[0];

UIImage *image = [info image];

NSURL *fileUrl = [info videoFileUrl];
```

* shake your device to use

### Customize

You can customize something with the properties and apis in the file [`SCFeedbackManager.h`](https://github.com/Aevit/SCFeedback/blob/master/SCFeedback/SCFeedbackManager.h) ---- just scroll down the file and you will see something more :)  

#### show the edit info controller
You can show the edit info controller without nothing:  

```
[[SCFeedbackManager sharedManager] gotoEditWithMediaInfo:nil];
```

#### disable the shake action
When you shake your device, will show a alert, if you want to disable the alert, just code like this:  

```
[[SCFeedbackManager sharedManager] enableShake:NO];
```

#### in-app recording

##### video
You can do something customize (set the frameRate of the video, set the outputURL of the video and so on) with the properties and apis of `[SCFeedbackManager sharedManager].screenRecorder`:  

[SCScreenRecorder.h](https://github.com/Aevit/SCFeedback/blob/master/SCFeedback/SCScreenRecorder/SCScreenRecorder.h)

There is a protocol to get the video file url and cover image when finish recording video:  

```
[SCFeedbackManager sharedManager].delegate = self;

- (void)scFeedback:(SCFeedbackManager *)manager didSaveRecordingVideoUrl:(NSURL *)fileUrl coverImage:(UIImage *)coverImage {
    
}

```

##### audio

You can do something customize with the properties and apis of `[SCFeedbackManager sharedManager].audioManager`:  

[SCAudioManager.h](https://github.com/Aevit/SCFeedback/blob/master/SCFeedback/SCAudioManager/SCAudioManager.h)


#### capture screeen

If you want to customize your next step when pressing the button at the top-right corner, use the `SCFeedbackDelegate`:  


```
[SCFeedbackManager sharedManager].delegate = self;

- (void)scFeedback:(SCFeedbackManager *)manager didShowDrawerController:(SCDrawerViewController *)controller {
    controller.isCustomNextStep = YES;
    controller.completeBlock = ^(UIImage *image) {
        // do something with the image
    };
}
```

#### text
You can change the text of the alert and the placeholder of textview just like this:  

```
[SCFeedbackManager sharedManager].customInfo[scInfo_drawer_title] = @"Drawer title";
```

The keys of `customInfo` below can be used to change text (you can find them in the file `SCFeedbackManager.h`):  

```
extern NSString *const scInfo_drawer_title; // SCEditInfoViewController's title

extern NSString *const scInfo_editInfo_title; // SCEditInfoViewController's title
extern NSString *const scInfo_editInfo_placeholder; // SCEditInfoViewController, placeholder of textview
extern NSString *const scInfo_editInfo_beyondNumTitle; // SCEditInfoViewController, title of alert when the number of attachments is out of 4
extern NSString *const scInfo_editInfo_beyondNumMsg; // SCEditInfoViewController, message of alert when the number of attachments is out of 4
extern NSString *const scInfo_editInfo_beyondNumCancel; // SCEditInfoViewController, cancel button text of alert when the number of attachments is out of 4

extern NSString *const scInfo_shake_title; // title of alert after shaking
extern NSString *const scInfo_shake_msg; // message of alert after shaking
extern NSString *const scInfo_shake_capture; // capture button text of alert after shaking
extern NSString *const scInfo_shake_record; // record button text of alert after shaking
extern NSString *const scInfo_shake_closeShake; // close shaken button text of alert after shaking
extern NSString *const scInfo_shake_cancel; // cancel button text of alert after shaking
```


#### overlay button
You can show or hide the overlay button at bottom-right corner like this:   

```
// for in-app recording
[[SCFeedbackManager sharedManager] showOverlayBtnWithtype:SCFbOverlayTypeRecorder];

// for capture screen
[[SCFeedbackManager sharedManager] showOverlayBtnWithtype:SCFbOverlayTypeCapture];

// hide
[[SCFeedbackManager sharedManager] hideOverlayBtn];
```

#### default video path
The default path is `'Library/Caches/scrcd_{yyyyMMdd_HHmmss}.mp4'`, you can change the path with the property:   
`[[SCFeedbackManager sharedManager].screenRecorder.outputURL`.  


You can use the api of `[SCFeedbackManager sharedManager]` to show all the video and audio files:  

```
/**
 show the video saved in the sanbox

 @param folder the files in the folder will be shown, if it is nil or empty, will find the default folder
 */
- (void)showFileListWithFolder:(NSString*)folder;
```


## Thanks
[KTouchPointerWindow](https://github.com/itok/KTouchPointerWindow)

## License
This code is distributed under the terms and conditions of the MIT license.