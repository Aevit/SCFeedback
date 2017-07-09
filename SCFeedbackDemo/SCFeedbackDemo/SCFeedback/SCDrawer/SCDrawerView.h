//
//  SCDrawerView.h
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/7.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^sc_drawer_completeBlock)(UIImage *image);

typedef NS_ENUM(NSInteger, SCDrawerType) {
    SCDrawerTypeBrush = 0,
    SCDrawerTypeMosaic = 1,
    SCDrawerTypeEraser = 2,
};

@interface SCDrawerView : UIView

/**
 the source image
 */
@property (nonatomic, strong) UIImage *image;

/**
 drawer type, default is SCDrawerTypeBrush
 */
@property (nonatomic, assign) SCDrawerType type;

/**
 the brush width, default is [[UIScreen mainScreen] scale]
 */
@property (nonatomic, assign) CGFloat brushWidth;

/**
 the brush opacity, default is 1.0
 */
@property (nonatomic, assign) CGFloat brushOpacity;

/**
 the brush color, default is [UIColor blackColor]
 */
@property (nonatomic, strong) UIColor *brushColor;

/**
 the size of the mosaic path, default is 60.0
 */
@property (nonatomic, assign) CGFloat mosaicSize;

/**
 get the final image with brush and mosaic

 @return image
 */
- (UIImage*)finalImage;

/**
 clear the brush and mosaic
 */
- (void)clearAll;

@end


