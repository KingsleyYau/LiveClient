//
//  Dialog.m
//  livestream
//
//  Created by Max on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "Dialog.h"
#import "LiveBundle.h"

@interface Dialog ()
@property (strong) UIView *view;
@property (strong) void (^actionBlock)();
@end

@implementation Dialog

+ (Dialog *)dialog {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    Dialog *view = [nibs objectAtIndex:0];

    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;

    return view;
}

- (void)showDialog:(UIView *)view actionBlock:(void (^)())actionBlock {
    self.actionBlock = actionBlock;

    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    
    self.view = view;
//        self.view.userInteractionEnabled = NO;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(window.mas_width).offset(-60);
        make.centerY.equalTo(window.mas_centerY);
        make.centerX.equalTo(window);
    }];

    [self sizeToFit];
    
    // 2秒后消失
    [self performSelector:@selector(hideDialog) withObject:self afterDelay:2];
}

- (void)hideDialog {
    [UIView animateWithDuration:0.5
        animations:^{
            self.alpha = 0;
        }
        completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
}

- (IBAction)action:(id)sender {
//    if (self.actionBlock) {
//        self.actionBlock();
//    }
//    [self removeFromSuperview];
//    self.view.userInteractionEnabled = YES;
}

@end
