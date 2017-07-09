//
//  SCDrawerViewController.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/5/15.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDrawerView.h"

@interface SCDrawerViewController : UIViewController

/**
 the image will be drawed, default is the snapshot of current full screen view
 */
@property (nonatomic, strong) UIImage *image;

/**
 callback when click the next step btn, and you will get the drawed image
 */
@property (nonatomic, copy) sc_drawer_completeBlock completeBlock;

/**
 the main drawer view
 */
@property (nonatomic, strong) SCDrawerView *drawerView;

/**
 whether custom your next step when you press the next button, default is NO (will auto push to "SCEditInfoViewController").
 if you set this to YES, you should do something with the property "completeBlock".
 */
@property (nonatomic, assign) BOOL isCustomNextStep;

@end
