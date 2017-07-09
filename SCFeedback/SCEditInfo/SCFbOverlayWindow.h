//
//  SCFbOverlayWindow.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/17.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCFbOverlayType) {
    SCFbOverlayTypeUnknown = -1,
    SCFbOverlayTypeRecorder = 0,
    SCFbOverlayTypeCapture = 1
};

@interface SCFbOverlayWindow : UIWindow

/**
 to caputre or record screen
 */
@property (nonatomic, assign) SCFbOverlayType type;

/**
 the bottom and right padding in the app window, default is 5
 */
@property (nonatomic, assign) CGFloat paddingBottomAndRight;

/**
 send the UIControlEventTouchUpInside action for the button
 */
- (void)didPressOverlayBtn;

@end
