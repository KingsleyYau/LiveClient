//
//  UpdateDialog.m
//  livestream
//
//  Created by Calvin on 2018/1/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "UpdateDialog.h"

@interface UpdateDialog ()
@property (weak) UIView* view;
@property (weak) UIButton *backBtn;
@property (strong) void (^actionBlock)();
@property (strong) void(^cancelBlock)();
@property (strong) void(^updateActionBlock)();
@end

@implementation UpdateDialog

+ (UpdateDialog *)dialog {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    UpdateDialog *view = [nibs objectAtIndex:0];
    
    view.tag = DialogTag;
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.okButton.layer.cornerRadius = 10;
    view.notBtn.layer.cornerRadius = 8;
    view.updateBtn.layer.cornerRadius = 8;
    return view;
}

- (void)showDialog:(UIView *)view actionBlock:(void (^)())actionBlock {
    self.actionBlock = actionBlock;
    
    self.okButton.hidden = NO;
    self.notBtn.hidden = YES;
    self.updateBtn.hidden = YES;
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setBackgroundColor:COLOR_WITH_16BAND_RGB_ALPHA(0x66000000)];
    self.backBtn = btn;
    [view addSubview:self.backBtn];
    [view bringSubviewToFront:self.backBtn];
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(view.mas_width).offset(-60);
        make.center.equalTo(view);
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
    //强制更新点击不消失
//    [self.backBtn removeFromSuperview];
//    [self removeFromSuperview];
}

- (void)showDialog:(UIView *)view cancelBlock:(void(^)())cancelBlock actionBlock:(void(^)())actionBlock {
    self.updateActionBlock = actionBlock;;
    self.cancelBlock = cancelBlock;
    
    self.okButton.hidden = YES;
    self.notBtn.hidden = NO;
    self.updateBtn.hidden = NO;
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setBackgroundColor:COLOR_WITH_16BAND_RGB_ALPHA(0x66000000)];
    self.backBtn = btn;
    [view addSubview:self.backBtn];
    [view bringSubviewToFront:self.backBtn];
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(view.mas_width).offset(-60);
        make.center.equalTo(view);
    }];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    [self sizeToFit];
}

- (IBAction)updateBtn:(UIButton *)sender {
    if( self.updateActionBlock ) {
        self.updateActionBlock();
    }
    [self.backBtn removeFromSuperview];
    [self removeFromSuperview];
}

- (IBAction)cancelBtn:(UIButton *)sender {
    if( self.cancelBlock ) {
        self.cancelBlock();
    }
    [self.backBtn removeFromSuperview];
    [self removeFromSuperview];
}

@end
