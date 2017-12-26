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
@property (weak) UIButton *backBtn;
@property (strong) void(^actionBlock)();
@end

@implementation DialogOK
+ (DialogOK *)dialog {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    DialogOK* view = [nibs objectAtIndex:0];
    
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.tag = DialogTag;
    view.okButton.layer.cornerRadius = 10;
    return view;
}

- (void)showDialog:(UIView *)view actionBlock:(void(^)())actionBlock {
    self.actionBlock = actionBlock;
    
//    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    UIButton *btn = [[UIButton alloc] init];
    [btn setBackgroundColor:COLOR_WITH_16BAND_RGB_ALPHA(0x66000000)];
    self.backBtn = btn;
    [view addSubview:self.backBtn];
    [view bringSubviewToFront:self.backBtn];
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(view.mas_width).offset(-60);
        make.centerY.equalTo(view.mas_centerY);
        make.centerX.equalTo(view);
    }];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    [self sizeToFit];
}

- (IBAction)actionOK:(id)sender {
    if( self.actionBlock ) {
        self.actionBlock();
    }
    [self.backBtn removeFromSuperview];
    [self removeFromSuperview];
}

- (IBAction)closeAction:(id)sender {
    [self.backBtn removeFromSuperview];
    [self removeFromSuperview];
}


@end
