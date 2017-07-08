//
//  SCFeedbackDelegate.h
//  SCFeedbackDemo
//
//  Created by aevit on 2017/7/8.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCFeedbackManager;

@protocol SCFeedbackDelegate <NSObject>

@optional
/**
 callback in the 'viewDidLoad' of SCDrawerViewController
 
 @param manager SCFeedbackManager
 @param controller the drawer controller
 */
- (void)scFeedback:(SCFeedbackManager*)manager didShowDrawerController:(SCDrawerViewController*)controller;

/**
 callback in the 'viewDidLoad' of SCEditInfoViewController
 
 @param manager SCFeedbackManager
 @param controller the edit info controller
 */
- (void)scFeedback:(SCFeedbackManager*)manager didShowEditInfoController:(SCEditInfoViewController*)controller;

/**
 callback when finish recording video
 
 @param manager SCFeedbackManager
 @param fileUrl the file url of the video
 @param coverImage the cover image of the video
 */
- (void)scFeedback:(SCFeedbackManager*)manager didSaveRecordingVideoUrl:(NSURL*)fileUrl coverImage:(UIImage*)coverImage;

@end
