//
//  SCDrawerView.m
//  SCFeedbackDemo
//
//  Created by Aevit on 2017/6/7.
//  Copyright © 2017年 Aevit. All rights reserved.
//

#import "SCDrawerView.h"
#import "SCFbUtils.h"
#import "SCFbUtils+sc_image.h"

static NSString *const partMosaicLayerName = @"partMosaicLayerName";

@interface SCDrawerView() {
    dispatch_semaphore_t _lock;
}

// source image
@property (nonatomic, strong) UIImageView *imageView;

// brush
@property (nonatomic, assign) BOOL mouseSwiped;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, strong) UIImageView *mainDrawImgView;
@property (nonatomic, strong) UIImageView *tmpDrawImgView;

// mosaic
@property (nonatomic, strong) CALayer *mosaicLayer;
@property (nonatomic, strong) CAShapeLayer *touchMaskLayer;
@property (nonatomic, assign) CGMutablePathRef touchPath;

@end

@implementation SCDrawerView

- (instancetype)init {
    if (self = [super init]) {
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

- (void)sc_commonInit {
    
    self.layer.borderColor = sc_rgba(79, 148, 251, 1).CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 2;
    
    [self setupDefaultDrawerProperties];
    
    [self addSubview:self.imageView]; // source image
    
    [self.imageView.layer addSublayer:self.mosaicLayer]; // mosiac image
    
    [self.imageView.layer addSublayer:self.touchMaskLayer]; // mask
    self.mosaicLayer.mask = self.touchMaskLayer;
}

- (void)dealloc {
    self.image = nil;
    [self clearAll];
}

#pragma mark - public methods
- (UIImage*)finalImage {
    return [SCFbUtils img_snapshotForView:self.imageView];
}

- (void)clearAll {
    self.mainDrawImgView.image = nil;
    
    [self clearMosaicPath];
    
    [self.imageView.layer.sublayers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:partMosaicLayerName]) {
            [obj removeFromSuperlayer];
        }
    }];
}

#pragma mark - touch methods
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    _lastPoint = [touch locationInView:self.imageView];
    
    switch (self.type) {
        case SCDrawerTypeBrush:
        {
            if (!self.mainDrawImgView) {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.bounds];
                imgView.backgroundColor = [UIColor clearColor];
                [self.imageView addSubview:imgView];
                self.mainDrawImgView = imgView;
            }
            if (!self.tmpDrawImgView) {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.mainDrawImgView.frame];
                imgView.backgroundColor = [UIColor clearColor];
                [self.mainDrawImgView.superview addSubview:imgView];
                self.tmpDrawImgView = imgView;
            }
            
            [self.mainDrawImgView.superview bringSubviewToFront:self.mainDrawImgView];
            [self.mainDrawImgView.superview bringSubviewToFront:self.tmpDrawImgView];
            
            _mouseSwiped = NO;
            break;
        }
        case SCDrawerTypeMosaic:
        {
            CGPathMoveToPoint(self.touchPath, NULL, _lastPoint.x, _lastPoint.y);
            CGMutablePathRef path = CGPathCreateMutableCopy(self.touchPath);
            self.touchMaskLayer.path = path;
            CGPathRelease(path);
            path = NULL;
            break;
        }
        default:
            break;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.imageView];
    
    switch (self.type) {
        case SCDrawerTypeBrush:
        {
            _mouseSwiped = YES;
            
            UIGraphicsBeginImageContext(self.mainDrawImgView.frame.size);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [self.tmpDrawImgView.image drawInRect:self.tmpDrawImgView.bounds];
            CGContextMoveToPoint(ctx, _lastPoint.x, _lastPoint.y);
            CGContextAddLineToPoint(ctx, currentPoint.x, currentPoint.y);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            CGContextSetLineWidth(ctx, _brushWidth);
            CGContextSetStrokeColorWithColor(ctx, _brushColor.CGColor);
            CGContextSetBlendMode(ctx,kCGBlendModeNormal);
            
            CGContextStrokePath(ctx);
            self.tmpDrawImgView.image = UIGraphicsGetImageFromCurrentImageContext();
            [self.tmpDrawImgView setAlpha:_brushOpacity];
            UIGraphicsEndImageContext();
            
            break;
        }
        case SCDrawerTypeMosaic:
        {
            CGPathAddLineToPoint(self.touchPath, NULL, currentPoint.x, currentPoint.y);
            CGMutablePathRef path = CGPathCreateMutableCopy(self.touchPath);
            self.touchMaskLayer.path = path;
            CGPathRelease(path);
            path = NULL;
            break;
        }
        default:
            break;
    }
    _lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self stopTouch:touches withEvent:event isEnd:YES];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self stopTouch:touches withEvent:event isEnd:NO];
}

- (void)stopTouch:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event isEnd:(BOOL)isEnd {
    
    switch (self.type) {
        case SCDrawerTypeBrush:
        {
            if(!_mouseSwiped) {
                UIGraphicsBeginImageContext(self.mainDrawImgView.frame.size);
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                [self.tmpDrawImgView.image drawInRect:self.tmpDrawImgView.bounds];
                CGContextSetLineCap(ctx, kCGLineCapRound);
                CGContextSetLineWidth(ctx, _brushWidth);
                CGContextSetStrokeColorWithColor(ctx, _brushColor.CGColor);
                CGContextMoveToPoint(ctx, _lastPoint.x, _lastPoint.y);
                CGContextAddLineToPoint(ctx, _lastPoint.x, _lastPoint.y);
                CGContextStrokePath(ctx);
                CGContextFlush(ctx);
                self.tmpDrawImgView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            self.mainDrawImgView.image = [self mergeImage:self.mainDrawImgView.image otherImage:self.tmpDrawImgView.image contextRect:self.mainDrawImgView.bounds];
            self.tmpDrawImgView.image = nil;
            break;
        }
        case SCDrawerTypeMosaic:
        {
            break;
        }
        default:
            break;
    }
}

- (UIImage*)mergeImage:(UIImage*)image otherImage:(UIImage*)otherImage contextRect:(CGRect)contextRect {
    UIGraphicsBeginImageContext(contextRect.size);
    [image drawInRect:contextRect blendMode:kCGBlendModeNormal alpha:1.0];
    [otherImage drawInRect:contextRect blendMode:kCGBlendModeNormal alpha:_brushOpacity];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

#pragma mark - private methods
- (void)setupDefaultDrawerProperties {
    // brush
    self.mouseSwiped = NO;
    self.lastPoint = CGPointZero;
    self.brushWidth = [[UIScreen mainScreen] scale];
    self.brushColor = [UIColor blackColor];
    self.brushOpacity = 1.0;
    
    // mosaic
    _mosaicSize = 60.0;
}

/**
 Makes an image blocky by mapping the image to colored squares whose color is defined by the replaced pixels.
 
 @param fromImage the image will convert to mosaic
 @param scale An NSNumber object whose attribute type is CIAttributeTypeDistance and whose display name is Scale. Default value: 8.00
 @return the mosaic image
 */
- (UIImage *)convertToMosaic:(UIImage*)fromImage withScale:(double)scale
{
    /*
     inputImage: A CIImage object whose display name is Image.
     
     inputCenter: A CIVector object whose attribute type is CIAttributeTypePosition and whose display name is Center.
     Default value: [150 150]
     
     inputScale: An NSNumber object whose attribute type is CIAttributeTypeDistance and whose display name is Scale.
     Default value: 8.00
     */
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter= [CIFilter filterWithName:@"CIPixellate"];
    CIImage *inputImage = [[CIImage alloc] initWithImage:fromImage];
    CIVector *vector = [CIVector vectorWithX:fromImage.size.width / 2.0f Y:fromImage.size.height / 2.0f];
    [filter setDefaults];
    [filter setValue:vector forKey:kCIInputCenterKey]; // inputCenter
    [filter setValue:[NSNumber numberWithDouble:scale] forKey:kCIInputScaleKey]; // inputScale
    [filter setValue:inputImage forKey:kCIInputImageKey]; // inputImage
    
    CGImageRef cgiimage = [context createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage scale:1.0f orientation:fromImage.imageOrientation];
    
    CGImageRelease(cgiimage);
    
    return newImage;
}

- (void)clearMosaicPath {
    if (_touchPath) {
        CGPathRelease(_touchPath);
        _touchPath = NULL;
    }
    if (_touchMaskLayer) {
        _touchMaskLayer.path = NULL;
        _mosaicLayer.mask = self.touchMaskLayer;
    }
}

#pragma mark - properties
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:self.image];
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image {
    if (_image == image) {
        return;
    }
    
    _image = image;
    
    self.imageView.image = image;
    
    if (image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *mosaicImage = [self convertToMosaic:image withScale:8.0];
                self.mosaicLayer.contents = (__bridge id _Nullable)(mosaicImage.CGImage);
            });
        });
    }
}

- (CALayer *)mosaicLayer {
    if (!_mosaicLayer) {
        _mosaicLayer = [CALayer layer];
        _mosaicLayer.frame = self.bounds;
    }
    return _mosaicLayer;
}

- (CAShapeLayer *)touchMaskLayer {
    if (!_touchMaskLayer) {
        _touchMaskLayer = [CAShapeLayer layer];
        _touchMaskLayer.frame = self.bounds;
        _touchMaskLayer.lineCap = kCALineCapRound;
        _touchMaskLayer.lineJoin = kCALineJoinRound;
        _touchMaskLayer.lineWidth = _mosaicSize > 0 ? _mosaicSize : 60.0;
        _touchMaskLayer.strokeColor = [UIColor blueColor].CGColor;
        _touchMaskLayer.fillColor = nil;
    }
    return _touchMaskLayer;
}

- (CGMutablePathRef)touchPath {
    if (!_touchPath) {
        _touchPath = CGPathCreateMutable();
    }
    return _touchPath;
}

- (void)setMosaicSize:(CGFloat)mosaicSize {
    if (!_lock) {
        _lock = dispatch_semaphore_create(1);
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    if (mosaicSize == _mosaicSize) {
        dispatch_semaphore_signal(_lock);
        return;
    }
    _mosaicSize = mosaicSize;
    
    if (_imageView && _touchPath) {
        // capture
        UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, NO, [[UIScreen mainScreen] scale]);
        [_mosaicLayer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // merge
        CALayer *layer = [CALayer layer];
        layer.name = partMosaicLayerName;
        layer.frame = self.imageView.bounds;
        layer.contents = (__bridge id _Nullable)(snapshot.CGImage);
        [self.imageView.layer addSublayer:layer];
        
        // clear the path
        [self clearMosaicPath];
        
        // to top
        if (_mainDrawImgView) {
            [_mainDrawImgView.superview bringSubviewToFront:_mainDrawImgView];
        }
    }
    
    if (_touchMaskLayer) {
        _touchMaskLayer.lineWidth = mosaicSize;
    }
    dispatch_semaphore_signal(_lock);
//#if !OS_OBJECT_USE_OBJC
//    dispatch_release(_lock);
//#endif
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
