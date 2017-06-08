//
//  PromptView.m
//  livestream
//
//  Created by randy on 17/6/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PromptView.h"

@interface PromptView()

@end

@implementation PromptView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
    
        // 阴影背景
        UIButton *backBtn = [[UIButton alloc]init];
        backBtn.backgroundColor = [UIColor blackColor];
        backBtn.alpha = 0.7;
        [self addSubview:backBtn];
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UIView *backView = [[UIView alloc]init];
        [backView setBackgroundColor:[UIColor whiteColor]];
        backView.layer.cornerRadius = 10;
        backView.layer.masksToBounds = YES;
        [self addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@DESGIN_TRANSFORM_3X(161));
            make.width.equalTo(@DESGIN_TRANSFORM_3X(304));
            make.center.equalTo(backBtn);
        }];
        
        UILabel *promptLabel = [[UILabel alloc]init];
        promptLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(15)];
        [promptLabel setTextColor:COLOR_WITH_16BAND_RGB(0x383838)];
        promptLabel.text = @"This account has already been registered.";
        [self addSubview:promptLabel];
        [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(backView);
            make.top.equalTo(backView.mas_top).offset(DESGIN_TRANSFORM_3X(33));
        }];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
        cancelBtn.layer.cornerRadius = 10;
        cancelBtn.layer.masksToBounds = YES;
        [cancelBtn addTarget:self action:@selector(cancelPrompt) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@DESGIN_TRANSFORM_3X(87));
            make.height.equalTo(@DESGIN_TRANSFORM_3X(36));
            make.left.equalTo(backView.mas_left).offset(DESGIN_TRANSFORM_3X(41));
            make.top.equalTo(promptLabel.mas_bottom).offset(DESGIN_TRANSFORM_3X(45));
        }];
        
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginBtn setTitle:@"Log in" forState:UIControlStateNormal];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0x5d0e86)];
        loginBtn.layer.cornerRadius = 10;
        loginBtn.layer.masksToBounds = YES;
        [loginBtn addTarget:self action:@selector(loginUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:loginBtn];
        [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerY.equalTo(cancelBtn);
            make.left.equalTo(cancelBtn.mas_right).offset(DESGIN_TRANSFORM_3X(48));
        }];
        
    }
    
    return self;
}

- (void)cancelPrompt {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = self.frame;
        rect.origin.y = -SCREEN_HEIGHT;
        self.frame = rect;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

- (void)loginUserInfo {
    
    if ([self.promptDelegate respondsToSelector:@selector(pushToLogin)]) {
        [self.promptDelegate pushToLogin];
    }
    
}

- (void)promptViewShow {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.frame;
        rect.origin.y = 0;
        self.frame = rect;
    }];
}

@end
