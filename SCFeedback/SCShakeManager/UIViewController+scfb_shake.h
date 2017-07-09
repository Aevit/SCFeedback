//
//  UIViewController+scfb_shake.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/25.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SCFbShakeBlock)(UIEvent *event);

void sc_installShakeAction(SCFbShakeBlock block);

void sc_uninstallShakeAction();
