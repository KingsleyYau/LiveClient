//
//  LikeView.m
//  UIWidget
//
//  Created by lance on 2017/6/6.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "LikeView.h"
#define angelToRandian(x)  ((x)/180.0*M_PI)

@interface LikeView()
@property(nonatomic,strong) UIColor *strokeColor;
@property(nonatomic,strong) UIColor *fillColor;

@end


@implementation LikeView

static CGFloat PI = M_PI;
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.anchorPoint = CGPointMake(0.5, 1);
    }
    return self;
}



- (void)setupImage:(UIImageView *)AnimationImageView {
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.anchorPoint = CGPointMake(0.5, 1);
}


- (void)setupShakeAnimation:(UIImageView *)shakeAnimationView {
    // 创建动画对象
    CAKeyframeAnimation* anim = [CAKeyframeAnimation animation];
    // 表示幅度的
    anim.keyPath = @"transform.rotation";
    // 幅度的旋转
    anim.values=@[@(angelToRandian(-16)),@(angelToRandian(16)),@(angelToRandian(-16))];
    // MAXFLOAT 动画执行次数为无限次
    anim.repeatCount = MAXFLOAT;
    // 动画执行的时间
    anim.duration = 0.5;
    [shakeAnimationView.layer addAnimation:anim forKey:nil];
}

- (void)setupHeatBeatAnim:(UIImageView *)heatbeatAnimationView {
    // 创建动画对象
    CABasicAnimation *heartbeatAnim = [CABasicAnimation animation];
    // transform.scale 表示长和宽都缩放
    heartbeatAnim.keyPath = @"transform.scale";
    // 缩放洗漱
    heartbeatAnim.toValue = @0.9;
    // 设置动画执行时间
    heartbeatAnim.duration = 0.3;
    // MAXFLOAT 动画执行次数为无限次
    heartbeatAnim.repeatCount = MAXFLOAT;
    // 控制动画反转 让尺寸0到1也是有过程的
    heartbeatAnim.autoreverses = YES;
    
    [heatbeatAnimationView.layer addAnimation:heartbeatAnim forKey: nil];
}


- (void)animateInView:(UIView *)view{
    
    
    
    // 逐渐放大动画
    [UIView animateWithDuration:1 animations:^{
        
        CGAffineTransform transfrom = CGAffineTransformMakeScale(2, 2);
        self.transform = CGAffineTransformScale(transfrom, 1, 1);
    }];
    

    NSTimeInterval totalAnimationDuration = 6;
    CGFloat heartSize = CGRectGetWidth(self.bounds);
    CGFloat heartCenterX = self.center.x;
    CGFloat viewHeight = CGRectGetHeight(view.bounds);
    
    //Pre-Animation setup
    self.transform = CGAffineTransformMakeScale(0, 0);
    self.alpha = 0;
    
    
    
    // Bloom
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:1.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = 0.9;
    } completion:NULL];
    
    
    NSInteger i = arc4random_uniform(2);
    // -1 OR 1
    NSInteger rotationDirection = 1 - (2 * i);
    NSInteger rotationFraction = arc4random_uniform(10);
    [UIView animateWithDuration:totalAnimationDuration animations:^{
        self.transform = CGAffineTransformMakeRotation(rotationDirection * PI / (16 + rotationFraction * 0.2));
    } completion:NULL];
    
    UIBezierPath *heartTravelPath = [UIBezierPath bezierPath];
    [heartTravelPath moveToPoint:self.center];
    
    //random end point
    CGPoint endPoint = CGPointMake(heartCenterX + (rotationDirection) * arc4random_uniform(heartSize), viewHeight/6.0 + arc4random_uniform(viewHeight/4.0));
    
    //random Control Points
    NSInteger j = arc4random_uniform(2);
    NSInteger travelDirection = 1 - (2 * j);// -1 OR 1
    
    //randomize x and y for control points
    CGFloat xDelta = (heartSize/2.0 + arc4random_uniform(3 * heartSize)) * travelDirection;
    CGFloat yDelta = MAX(endPoint.y ,MAX(arc4random_uniform(6 * heartSize), heartSize));
    CGPoint controlPoint1 = CGPointMake(heartCenterX + xDelta, viewHeight - yDelta);
    CGPoint controlPoint2 = CGPointMake(heartCenterX - 2 * xDelta, yDelta);
    
    [heartTravelPath addCurveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyFrameAnimation.path = heartTravelPath.CGPath;
    keyFrameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    keyFrameAnimation.duration = totalAnimationDuration + endPoint.y / viewHeight;
    [self.layer addAnimation:keyFrameAnimation forKey:@"positionOnPath"];
    
    // Alpha & remove from superview
    [UIView animateWithDuration:totalAnimationDuration animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

- (void)shakeAnimationForView:(UIView *) view {
    // 获取到当前的View
    CALayer *viewLayer = view.layer;
    // 获取当前View的位置
    CGPoint position = viewLayer.position;
    // 移动的两个终点位置
    CGPoint x = CGPointMake(position.x + 10, position.y);
    CGPoint y = CGPointMake(position.x - 10, position.y);
    // 设置动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 设置运动形式
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    // 设置开始位置
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    // 设置结束位置
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    // 设置自动反转
    [animation setAutoreverses:YES];
    // 设置时间
    [animation setDuration:3];
    // 设置次数
    [animation setRepeatCount:MAXFLOAT];
    // 添加上动画
    [viewLayer addAnimation:animation forKey:nil];
}





@end
