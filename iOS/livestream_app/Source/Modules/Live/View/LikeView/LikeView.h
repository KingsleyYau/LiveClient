//
//  LikeView.h
//  UIWidget
//
//  Created by lance on 2017/6/6.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikeView : UIView



/**
 动画显示

 @param view 执行的页面
 */
- (void)animateInView:(UIView *)view;

/**
 设置是否执行动画
 
 @param AnimationImageView 执行动画的图片
 */
- (void)setupImage:(UIImageView *)AnimationImageView;

/**
 设置抖动动画

 @param shakeAnimationView 抖动动画的图片
 */
- (void)setupShakeAnimation:(UIImageView *)shakeAnimationView;

/**
 设置缩放的动画

 @param heatbeatAnimationView 心跳动画执行
 */
- (void)setupHeatBeatAnim:(UIImageView *)heatbeatAnimationView;
@end
