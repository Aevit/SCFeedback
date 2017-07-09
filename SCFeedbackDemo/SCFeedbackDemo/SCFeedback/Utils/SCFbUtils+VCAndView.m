//
//  SCFbUtils+VCAndView.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/17.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCFbUtils+VCAndView.h"

@implementation SCFbUtils (VCAndView)

#pragma mark - public methods
+ (UIViewController *)vc_getTopViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    return [self vc_topVisibleViewController:rootViewController];
}

+ (UIViewController*)vc_viewControllerOfView:(UIView*)currView {
    for (UIView *next = currView.superview; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

+ (UIViewController *)vc_getTopPresentedViewController {
    UIViewController *topViewController = [[[UIApplication sharedApplication].windows objectAtIndex:0] rootViewController];
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    
    return topViewController;
}

+ (CGRect)vc_screenBounds {
    return [UIScreen mainScreen].bounds;
}

+ (CGFloat)vc_screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)vc_screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

#pragma mark - private methods
+ (UIViewController *)vc_topVisibleViewController:(UIViewController*)vc {
    
    if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self vc_topVisibleViewController:((UITabBarController *)vc).selectedViewController];
        
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self vc_topVisibleViewController:((UINavigationController *)vc).visibleViewController];
        
    } else if (vc.presentedViewController) {
        return [self vc_topVisibleViewController:vc.presentedViewController];
        
    } else if (vc.childViewControllers.count > 0) {
        return [self vc_topVisibleViewController:vc.childViewControllers.lastObject];
    }
    return vc;
}

@end
