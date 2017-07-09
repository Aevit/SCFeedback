//
//  SCTouchPointer.m
//  SCTouchPointerDemo
//
//  Created by Aevit on 2017/5/3.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCTouchPointer.h"
#import <objc/runtime.h>

static BOOL sc_installed = NO;
static CGFloat sc_pointRadius = 0;
static UIColor *sc_pointColor = nil;





#pragma mark ---------- touch pointer view

@interface SCTouchPointerView: UIView

@property (nonatomic, strong) NSSet<UITouch *> *touches;

@end

@implementation SCTouchPointerView

- (void)drawRect:(CGRect)rect {
    for (UITouch *touch in self.touches) {
        CGRect touchRect = CGRectZero;
        touchRect.origin = [touch locationInView:self];
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(touchRect, -sc_pointRadius, -sc_pointRadius)];
        [sc_pointColor set];
        [path fill];
    }
}

@end





#pragma mark ---------- window category
@interface UIWindow (sc_touchPointer)

/**
 the touch pointer view
 */
@property (nonatomic, strong) SCTouchPointerView *touchPointerView;

@end

@implementation UIWindow (sc_touchPointer)

#pragma mark - swizzled methods
- (void)sc_pointer_sendEvent:(UIEvent *)event {
    
    if (!self.touchPointerView) {
        self.touchPointerView = [[SCTouchPointerView alloc] initWithFrame:self.bounds];
        self.touchPointerView.backgroundColor = [UIColor clearColor];
        self.touchPointerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.touchPointerView.userInteractionEnabled = NO;
        [self addSubview:self.touchPointerView];
    }
    [self bringSubviewToFront:self.touchPointerView];
    self.touchPointerView.touches = event.allTouches;
    [self.touchPointerView setNeedsDisplay];
    
    [self sc_pointer_sendEvent:event];
}

#pragma mark - property
- (SCTouchPointerView *)touchPointerView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTouchPointerView:(SCTouchPointerView *)touchPointerView {
    objc_setAssociatedObject(self, @selector(touchPointerView), touchPointerView, OBJC_ASSOCIATION_RETAIN);
}

@end






#pragma mark ---------- public methods

void swizzleSendEvent() {
    
    Class class = [UIWindow class];
    
    SEL origSel = sel_registerName("sendEvent:");
    SEL scSel = sel_registerName("sc_pointer_sendEvent:");
    
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method scMethod = class_getInstanceMethod(class, scSel);
    
    BOOL success = class_addMethod(class, origSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    if (success) {
        class_replaceMethod(class, scSel, method_getImplementation(scMethod), method_getTypeEncoding(scMethod));
    } else {
        method_exchangeImplementations(origMethod, scMethod);
    }
}

void sc_installTouchPointer(CGFloat pointRadius, UIColor *pointColor) {
    dispatch_semaphore_t lock = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    if (!sc_installed) {
        sc_installed = YES;
        
        sc_pointRadius = pointRadius > 0 ? pointRadius : 15;
        sc_pointColor = pointColor ? pointColor : [UIColor colorWithRed:253/255.0 green:129/255.0 blue:129/255.0 alpha:1];
        
        swizzleSendEvent();
    }
    dispatch_semaphore_signal(lock);
}

void sc_uninstallTouchPointer() {
    dispatch_semaphore_t lock = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    if (sc_installed) {
        sc_installed = NO;
        
        swizzleSendEvent();
        
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if (![window isKindOfClass:[UIWindow class]]) {
                continue;
            }
            if (window.touchPointerView) {
                [window.touchPointerView removeFromSuperview];
                window.touchPointerView = nil;
            }
        }
    }
    dispatch_semaphore_signal(lock);
}


















