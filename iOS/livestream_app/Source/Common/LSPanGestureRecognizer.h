//
//  LSPanGestureRecognizer.h
//  livestream
//
//  Created by test on 2018/1/15.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSPanGestureRecognizer : UIPanGestureRecognizer


@property(assign, nonatomic) CGPoint beginPoint;
@property(assign, nonatomic) CGPoint movePoint;

- (instancetype)initWithTarget:(id)target action:(SEL)action inview:(UIView*)view;
@end
