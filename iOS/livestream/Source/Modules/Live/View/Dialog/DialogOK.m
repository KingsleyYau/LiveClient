//
//  DialogOK.m
//  livestream
//
//  Created by Max on 2017/9/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DialogOK.h"

@interface DialogOK ()
@property (strong) UIView* view;
@property (strong) void(^actionBlock)();
@end

@implementation DialogOK
+ (DialogOK *)dialog {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    DialogOK* view = [nibs objectAtIndex:0];
    
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    view.okButton.layer.cornerRadius = 10;
    
    return view;
}

- (void)showDialog:(UIView *)view actionBlock:(void(^)())actionBlock {
    self.actionBlock = actionBlock;
    
    self.view = view;
    self.view.userInteractionEnabled = NO;
    UIWindow* window = AppDelegate().window;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(window.mas_width).offset(-60);
        make.centerY.equalTo(window.mas_centerY);
        make.centerX.equalTo(window);
    }];
    
    [self sizeToFit];
}

- (IBAction)actionOK:(id)sender {
    if( self.actionBlock ) {
        self.actionBlock();
    }
    [self removeFromSuperview];
    self.view.userInteractionEnabled = YES;
}

@end
