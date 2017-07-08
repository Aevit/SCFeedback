//
//  SCFbUtils+VCAndView.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/17.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCFbUtils.h"
#import <UIKit/UIKit.h>

@interface SCFbUtils (VCAndView)

/**
 get the toppest controller.
 may be the visibleController of a navigationController, or the selectedController of a tabbarController.
 
 @return the toppest controller (UIViewController)
 */
+ (UIViewController *)vc_getTopViewController;

/**
 get the controller of a view
 
 @param currView the source view
 @return the owner controller
 */
+ (UIViewController*)vc_viewControllerOfView:(UIView*)currView;

/**
 get the toppest presenting controller (may be a UINavigationController, UITabbarController or UIViewController)
 
 @return the toppest presenting controller
 */
+ (UIViewController *)vc_getTopPresentedViewController;

/**
 screen bounds

 @return CGRect
 */
+ (CGRect)vc_screenBounds;

/**
 screen width

 @return CGFloat
 */
+ (CGFloat)vc_screenWidth;

/**
 screen height

 @return CGFloat
 */
+ (CGFloat)vc_screenHeight;

@end


