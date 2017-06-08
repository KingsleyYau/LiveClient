//
//  CircleLoadingView.m
//  progressline
//
//  Created by lance on 16/4/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CircleLoadingView.h"


#define angle(location) 2 * M_PI/ 360 * location

@interface CircleLoadingView()

/** 弧度 0 - 1 */
@property (nonatomic, assign) CGFloat anglePer;
/** 计时器 */
@property (nonatomic, strong) NSTimer *timer;

@end



@implementation CircleLoadingView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/**
 *  设置弧度
 *
 *  @param anglePer 弧度
 */
- (void)setAnglePer:(CGFloat)anglePer{
    _anglePer = anglePer;
    [self setNeedsDisplay];
}


/**
 *  开始动画
 */
- (void)startAnimation{
    //正在播放停止定时器和动画
    if (self.isAnimating) {
        [self stopAnimation];
        [self.layer removeAllAnimations];
    }
    //重新设置播放动画为yes
    _isAnimating = YES;
    
    //重新开始执行转圈动画
    self.anglePer = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(drawPathAnimation:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

/**
 *  移除动画
 */
- (void)stopAnimation{
    //动画状态设置为no
    _isAnimating = NO;
    
    //移除定时器
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self stopRotateAnimation];
}

/**
 *
 *
 *  @param timer 计时器
 */
- (void)drawPathAnimation:(NSTimer *)timer{
    self.anglePer += 0.03f;
    
    if (self.anglePer >= 1) {
        self.anglePer = 1;
        [timer invalidate];
        self.timer = nil;
        [self startRotateAnimation];
    }
}

/**
 *  开始执行旋转动画
 */
- (void)startRotateAnimation{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(0);
    animation.toValue = @(2 * M_PI);
    animation.duration = 1.0f;
    animation.repeatCount = INT_MAX;
    
    [self.layer addAnimation:animation forKey:@"keyFrameAnimation"];
}

/**
 *  停止旋转动画
 */
- (void)stopRotateAnimation{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.anglePer = 0;
        [self.layer removeAllAnimations];
        self.alpha = 1;
    }];
}

/**
 *  重新绘制
 *
 *  @param rect 尺寸
 */
- (void)drawRect:(CGRect)rect{
    if (self.anglePer <= 0) {
        _anglePer = 0;
    }
    
    CGFloat lineWidth = 1.0f;
    UIColor *lineColor = [UIColor lightGrayColor];
    if (self.lineWidth) {
        lineWidth = self.lineWidth;
    }
    if (self.lineColor) {
        lineColor = self.lineColor;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextAddArc(context,CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), CGRectGetWidth(self.bounds) / 2 - lineWidth, angle(120), angle(120) + angle(330)* self.anglePer,
                    0);
    CGContextStrokePath(context);
}


@end
