//
//  SCTextView.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/17.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCTextView.h"

@interface SCTextView()

@end

@implementation SCTextView

#pragma mark - UIView
- (instancetype)init {
    if (self = [super init]) {
        [self sc_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self sc_commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self sc_commonInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.text.length != 0 || !self.attributedPlaceholder) {
        return;
    }
    [self.attributedPlaceholder drawInRect:[self placeholderRectForBounds:self.bounds]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

#pragma mark - override
- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)insertText:(NSString *)text {
    [super insertText:text];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    [super setContentInset:contentInset];
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.attributedPlaceholder && self.text.length == 0) {
        [self setNeedsDisplay];
    }
}

#pragma mark - properties
- (void)setPlaceholder:(NSString *)placeholder {
    if ([placeholder isEqualToString:self.attributedPlaceholder.string]) {
        return;
    }
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    if ([self isFirstResponder] && self.typingAttributes) {
        [attributes addEntriesFromDictionary:self.typingAttributes];
    } else {
        attributes[NSFontAttributeName] = self.font;
        attributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
        
        if (self.textAlignment != NSTextAlignmentLeft) {
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.alignment = self.textAlignment;
            attributes[NSParagraphStyleAttributeName] = paragraph;
        }
    }
    
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder ? [placeholder copy] : @"" attributes:attributes];
}

- (NSString *)placeholder {
    return self.attributedPlaceholder.string;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    [self setNeedsDisplay];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
    if ([_attributedPlaceholder isEqualToAttributedString:attributedPlaceholder]) {
        return;
    }
    _attributedPlaceholder = attributedPlaceholder;
    [self setNeedsDisplay];
}

#pragma mark - private
- (void)sc_commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self];
}

- (void)textDidChange:(NSNotification*)notification {
    [self setNeedsDisplay];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect rect = UIEdgeInsetsInsetRect(bounds, self.contentInset);
    
    if ([self respondsToSelector:@selector(textContainer)]) {
        rect = UIEdgeInsetsInsetRect(rect, self.textContainerInset);
        CGFloat padding = self.textContainer.lineFragmentPadding;
        rect.origin.x += padding;
        rect.size.width -= padding * 2.0f;
    } else {
        if (self.contentInset.left == 0.0f) {
            rect.origin.x += 8.0f;
        }
        rect.origin.y += 8.0f;
    }
    
    return rect;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
