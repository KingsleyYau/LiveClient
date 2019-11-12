//
//  LSClipShapeLayer.m
//  livestream
//
//  Created by test on 2018/1/15.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSClipShapeLayer.h"


@implementation LSClipShapeLayer

static CGFloat const lineWidth = 3;
- (instancetype)init {
    self = [super init];
    if (self) {
        _cropAreaLeft = 50;
        _cropAreaTop = 50;
        _cropAreaRight = SCREEN_WIDTH - self.cropAreaLeft;
        _cropAreaBottom = 400;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    UIGraphicsPushContext(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft, self.cropAreaTop);
    CGContextAddLineToPoint(ctx, self.cropAreaLeft, self.cropAreaBottom);
    CGContextSetShadow(ctx, CGSizeMake(2, 0), 2.0);
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft, self.cropAreaTop);
    CGContextAddLineToPoint(ctx, self.cropAreaRight, self.cropAreaTop);
    CGContextSetShadow(ctx, CGSizeMake(0, 2), 2.0);
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaRight, self.cropAreaTop);
    CGContextAddLineToPoint(ctx, self.cropAreaRight, self.cropAreaBottom);
    CGContextSetShadow(ctx, CGSizeMake(-2, 0), 2.0);
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft, self.cropAreaBottom);
    CGContextAddLineToPoint(ctx, self.cropAreaRight, self.cropAreaBottom);
    CGContextSetShadow(ctx, CGSizeMake(0, -2), 2.0);
    CGContextStrokePath(ctx);
    
    UIGraphicsPopContext();
}

- (void)setCropAreaLeft:(NSInteger)cropAreaLeft {
    _cropAreaLeft = cropAreaLeft;
    [self setNeedsDisplay];
}

- (void)setCropAreaTop:(NSInteger)cropAreaTop {
    _cropAreaTop = cropAreaTop;
    [self setNeedsDisplay];
}

- (void)setCropAreaRight:(NSInteger)cropAreaRight {
    _cropAreaRight = cropAreaRight;
    [self setNeedsDisplay];
}

- (void)setCropAreaBottom:(NSInteger)cropAreaBottom {
    _cropAreaBottom = cropAreaBottom;
    [self setNeedsDisplay];
}

- (void)setCropAreaLeft:(NSInteger)cropAreaLeft CropAreaTop:(NSInteger)cropAreaTop CropAreaRight:(NSInteger)cropAreaRight CropAreaBottom:(NSInteger)cropAreaBottom {
    _cropAreaLeft = cropAreaLeft;
    _cropAreaRight = cropAreaRight;
    _cropAreaTop = cropAreaTop;
    _cropAreaBottom = cropAreaBottom;
    
    [self setNeedsDisplay];
}

@end
