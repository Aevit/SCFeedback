//
//  SCFbUtils+sc_image.m
//  SCFeedbackDemo
//
//  Created by aevit on 2017/7/2.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCFbUtils+sc_image.h"

@implementation SCFbUtils (sc_image)

/**
 get the snapshot of a view
 
 @param view the target view
 @param rect the area of the view will capture
 @param afterScreenUpdates A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value NO if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes.
 @return the snapshot
 */
+ (UIImage*)img_snapshotForView:(UIView*)view inRect:(CGRect)rect afterScreenUpdates:(BOOL)afterScreenUpdates {
    UIGraphicsBeginImageContextWithOptions(rect.size, view.opaque, [[UIScreen mainScreen] scale]);
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:rect afterScreenUpdates:afterScreenUpdates];
    } else {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}

/**
 get the snapshot of a view, capture the whole area of the view, and afterScreenUpdates == YES
 
 @param view the target view
 @return the snapshot
 */
+ (UIImage*)img_snapshotForView:(UIView*)view {
    return [SCFbUtils img_snapshotForView:view inRect:view.bounds afterScreenUpdates:YES];
}

/**
 get the snapshot for the app window, capture the whole area of the view, and afterScreenUpdates == YES
 
 @return the snapshot
 */
+ (UIImage*)img_snapshotForFullScreen {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window]; // [[UIApplication sharedApplication] keyWindow];
    NSAssert(window != nil, @"SCFeedback: the captured window is nil");
    return [SCFbUtils img_snapshotForView:window];
}

/**
 convert UIColor to UIImage
 
 @param color color
 @param imageSize image size you want
 @return UIImage
 */
+ (UIImage*)img_imageWithColor:(UIColor*)color size:(CGSize)imageSize {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


+ (UIImage *)img_imageWithName:(NSString*)name {
    if (!name || [name isEqual:[NSNull null]] || name.length <= 0) {
        return nil;
    }
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"___SCFeedback" ofType:@"bundle"];
    return [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:name]];
}

@end
