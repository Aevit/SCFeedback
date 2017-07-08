//
//  SCTouchPointer.h
//  SCTouchPointerDemo
//
//  Created by Aevit on 2017/5/3.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 show pointer view when touch
 
 @param pointRadius the touch pointer view radius, if your pass '0', it will be the default data 15
 
 @param pointColor the touch pointer view color, if you pass 'nil', it will be the deafult data: [UIColor colorWithRed:253/255.0 green:129/255.0 blue:129/255.0 alpha:1];
 */
void sc_installTouchPointer(CGFloat pointRadius, UIColor *pointColor);



/**
 NOT pointer view when touch
 */
void sc_uninstallTouchPointer();
