//
//  SCTextView.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/17.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCTextView : UITextView

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic, strong) NSAttributedString *attributedPlaceholder;

@end
