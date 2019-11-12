//
//  LSPanGestureRecognizer.m
//  livestream
//
//  Created by test on 2018/1/15.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


@interface LSPanGestureRecognizer ()
@property(strong, nonatomic) UIView *targetView;
@end


@implementation LSPanGestureRecognizer

-(instancetype)initWithTarget:(id)target action:(SEL)action inview:(UIView*)view{
    
    self = [super initWithTarget:target action:action];
    if(self) {
        self.targetView = view;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent*)event{
    
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.beginPoint = [touch locationInView:self.targetView];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.movePoint = [touch locationInView:self.targetView];
}

@end
