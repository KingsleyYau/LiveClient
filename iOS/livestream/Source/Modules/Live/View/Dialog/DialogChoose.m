//
//  DialogChoose.m
//  livestream
//
//  Created by Max on 2017/9/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DialogChoose.h"
#import "LiveBundle.h"

@interface DialogChoose ()
@property (weak) UIView* view;
@property (strong) void(^cancelBlock)();
@property (strong) void(^actionBlock)();

@end

@implementation DialogChoose
+ (DialogChoose *)dialog {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    DialogChoose* view = [nibs objectAtIndex:0];
    
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    view.checkBox.onAnimationType = BEMAnimationTypeBounce;
    view.checkBox.offAnimationType = BEMAnimationTypeBounce;
    view.checkBox.boxType = BEMBoxTypeSquare;
    view.checkBox.tintColor = [UIColor lightGrayColor];
    view.checkBox.onTintColor = Color(29, 239, 232, 1.0);//[UIColor greenColor];
    view.checkBox.onFillColor = Color(29, 239, 232, 1.0);//[UIColor greenColor];
    view.checkBox.onCheckColor = [UIColor whiteColor];
    view.checkBox.animationDuration = 0.3;
    
    view.okButton.layer.cornerRadius = 10;
    view.cancelButton.layer.cornerRadius = 10;
    
    return view;
}

- (void)showDialog:(UIView *)view cancelBlock:(void(^)())cancelBlock actionBlock:(void(^)())actionBlock {
    self.cancelBlock = cancelBlock;
    self.actionBlock = actionBlock;
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    
    self.view = view;
    self.view.userInteractionEnabled = NO;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(window.mas_width).offset(-60);
        make.centerY.equalTo(window.mas_centerY);
        make.centerX.equalTo(window);
    }];
    
    [self sizeToFit];
}

- (IBAction)cancelCancel:(id)sender {
    if( self.cancelBlock ) {
        self.cancelBlock();
    }
    [self removeFromSuperview];
    self.view.userInteractionEnabled = YES;
}

- (IBAction)actionOK:(id)sender {
    if( self.actionBlock ) {
        self.actionBlock();
    }
    [self removeFromSuperview];
    self.view.userInteractionEnabled = YES;
}
@end
