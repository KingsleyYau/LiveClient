//
//  DeletTipView.m
//  TZImagePickerController
//
//  Created by randy on 17/6/19.
//  Copyright © 2017年 谭真. All rights reserved.
//

#import "DeleteTipView.h"

@interface DeleteTipView ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIButton *keepOutBtn;

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIButton *cancleBtn;

@property (nonatomic, strong) UIButton *okBtn;

@end

@implementation DeleteTipView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
    
        _keepOutBtn = [[UIButton alloc]init];
        [_keepOutBtn setBackgroundColor:[UIColor blackColor]];
        _keepOutBtn.alpha = 0.4;
        [self addSubview:_keepOutBtn];
        [_keepOutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        _backgroundView = [[UIView alloc]init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        _backgroundView.layer.cornerRadius = 10;
        [self addSubview:_backgroundView];
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.equalTo(@DESGIN_TRANSFORM_3X(164));
            make.width.equalTo(@DESGIN_TRANSFORM_3X(304));
        }];
        
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(13)];
        _tipLabel.textColor = [UIColor blackColor];
        _tipLabel.text = @"Are you sure you wish to delete this cover?";
        [self addSubview:_tipLabel];
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_backgroundView.mas_top).offset(DESGIN_TRANSFORM_3X(33));
            make.centerX.equalTo(_backgroundView);
        }];
        
        _cancleBtn = [[UIButton alloc]init];
        [_cancleBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:COLOR_WITH_16BAND_RGB(0x383838) forState:UIControlStateNormal];
        [_cancleBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)];
        _cancleBtn.layer.cornerRadius = 7.5;
        [_cancleBtn addTarget:self action:@selector(cancelPrompt) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancleBtn];
        [_cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@DESGIN_TRANSFORM_3X(73));
            make.height.equalTo(@DESGIN_TRANSFORM_3X(30));
            make.top.equalTo(_tipLabel.mas_bottom).offset(DESGIN_TRANSFORM_3X(45));
            make.left.equalTo(_backgroundView.mas_left).offset(DESGIN_TRANSFORM_3X(55));
        }];
        
        _okBtn = [[UIButton alloc]init];
        [_okBtn setTitle:@"OK" forState:UIControlStateNormal];
        [_okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_okBtn setBackgroundColor:COLOR_WITH_16BAND_RGB(0x5d0e86)];
        _okBtn.layer.cornerRadius = 7.5;
        [_okBtn addTarget:self action:@selector(deleteImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_okBtn];
        [_okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(_cancleBtn);
            make.centerY.equalTo(_cancleBtn);
            make.left.equalTo(_cancleBtn.mas_right).offset(DESGIN_TRANSFORM_3X(48));
        }];
        
    }
    return self;
}

- (void)cancelPrompt {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = self.frame;
        rect.origin.y = -[UIScreen mainScreen].bounds.size.width;
        self.frame = rect;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

- (void)deleteImage{
    
    if ([self.deleteDelegate respondsToSelector:@selector(deleteImageFromeController)]) {
        [self.deleteDelegate deleteImageFromeController];
    }
}


- (void)deleteTipViewShowWithTap:(NSInteger)tag {
    
    self.tagNum = tag;

    [AppDelegate().window addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.frame;
        rect.origin.y = 0;
        self.frame = rect;
    }];
}

@end
