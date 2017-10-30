//
//  DialogOK.m
//  livestream
//
//  Created by Max on 2017/9/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DialogOK.h"
#import "LiveBundle.h"

@interface DialogOK ()
@property (weak) UIView* view;
@property (strong) void(^actionBlock)();
@end

@implementation DialogOK
+ (DialogOK *)dialog {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    DialogOK* view = [nibs objectAtIndex:0];
    
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    
    view.okButton.layer.cornerRadius = 10;
    
    return view;
}

- (void)showDialog:(UIView *)view actionBlock:(void(^)())actionBlock {
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

- (IBAction)actionOK:(id)sender {
    if( self.actionBlock ) {
        self.actionBlock();
    }
}

- (IBAction)closeAction:(id)sender {
    [self removeFromSuperview];
    self.view.userInteractionEnabled = YES;
}


@end
