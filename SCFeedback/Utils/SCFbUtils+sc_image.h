//
//  SCFbUtils+sc_image.h
//  SCFeedbackDemo
//
//  Created by aevit on 2017/7/2.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCFbUtils.h"
#import <UIKit/UIKit.h>

@interface SCFbUtils (sc_image)

/**
 get the snapshot of a view
 
 @param view the target view
 @param rect the area of the view will capture
 @param afterScreenUpdates A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value NO if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes.
 @return the snapshot
 */
+ (UIImage*)img_snapshotForView:(UIView*)view inRect:(CGRect)rect afterScreenUpdates:(BOOL)afterScreenUpdates;

/**
 get the snapshot of a view, capture the whole area of the view, and afterScreenUpdates == YES
 
 @param view the target view
 @return the snapshot
 */
+ (UIImage*)img_snapshotForView:(UIView*)view;

/**
 get the snapshot for the app window, capture the whole area of the view, and afterScreenUpdates == YES
 
 @return the snapshot
 */
+ (UIImage*)img_snapshotForFullScreen;

/**
 convert UIColor to UIImage
 
 @param color color
 @param imageSize image size you want
 @return UIImage
 */
+ (UIImage*)img_imageWithColor:(UIColor*)color size:(CGSize)imageSize;


/**
 get UIImage from SCFeedback_resources.bundle

 @param name the image name
 @return UIImage
 */
+ (UIImage *)img_imageWithName:(NSString*)name;

@end
