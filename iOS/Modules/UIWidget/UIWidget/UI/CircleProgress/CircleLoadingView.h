//
//  CircleLoadingView.h
//  progressline
//
//  Created by lance on 16/4/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleLoadingView : UIView
/** 线的长度,默认为1 */
@property (nonatomic, assign) CGFloat lineWidth;

/** 线的颜色,默认为灰色 */
@property (nonatomic, strong) UIColor *lineColor;

/** 是否执行动画 */
@property (nonatomic, readonly) BOOL isAnimating;

- (void)startAnimation;
- (void)stopAnimation;
@end
