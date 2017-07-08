//
//  UIViewController+scfb_shake.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/25.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "UIViewController+scfb_shake.h"
#import <objc/runtime.h>
#import "SCFeedbackManager.h"

static BOOL sc_installed = NO;
static SCFbShakeBlock shakeBlock = nil;

void swizzleMethod(SEL origSel, SEL scSel) {
    
    Class class = [UIWindow class];
    
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method scMethod = class_getInstanceMethod(class, scSel);
    
    BOOL success = class_addMethod(class, origSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    if (success) {
        class_replaceMethod(class, scSel, method_getImplementation(scMethod), method_getTypeEncoding(scMethod));
    } else {
        method_exchangeImplementations(origMethod, scMethod);
    }
}

void sc_installShakeAction(SCFbShakeBlock block) {
    dispatch_semaphore_t lock = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    if (!sc_installed) {
        shakeBlock = [block copy];
        swizzleMethod(NSSelectorFromString(@"sendEvent:"), NSSelectorFromString(@"sc_shake_sendEvent:"));
        sc_installed = YES;
    }
    dispatch_semaphore_signal(lock);
}

void sc_uninstallShakeAction() {
    dispatch_semaphore_t lock = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    if (sc_installed) {
        shakeBlock = nil;
        swizzleMethod(NSSelectorFromString(@"sendEvent:"), NSSelectorFromString(@"sc_shake_sendEvent:"));
        sc_installed = NO;
    }
    dispatch_semaphore_signal(lock);
}

@implementation UIWindow (scfb_shake)

- (void)sc_shake_sendEvent:(UIEvent*)event {
    [self sc_shake_sendEvent:event];
    if (shakeBlock) {
        shakeBlock(event);
    }
}

@end
