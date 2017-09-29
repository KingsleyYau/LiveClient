//
//  ChardTipView.m
//  livestream
//
//  Created by randy on 2017/9/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ChardTipView.h"

#define PublicTip @"Public Broadcast is free to watch."
#define VIPPublicTip @"VIP Public Broadcast is billed at "
#define PrivateTip @"Private broadcast is billed at "
#define VIPPrivateTip @"VIP Private Broadcast is billed at "
#define CreditTip @" credit per minute."

@interface ChardTipView ()

@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation ChardTipView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = Color(255, 255, 255, 0);
        
        UIImage *image = [UIImage imageNamed:@"Live_Public_Img_Remind"];
        UIImageView *remindImageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:remindImageView];
        [remindImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.centerX.equalTo(self);
        }];
        
        self.backgroundView = [[UIView alloc] init];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        self.backgroundView.layer.masksToBounds = YES;
        self.backgroundView.layer.cornerRadius = 3;
        [self addSubview:self.backgroundView];
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(remindImageView.mas_bottom);
            make.left.right.bottom.equalTo(self);
        }];
        
        self.tipLabel = [[UILabel alloc] init];
        self.tipLabel.font = [UIFont systemFontOfSize:11];
        self.tipLabel.textColor = COLOR_WITH_16BAND_RGB(0x5a5a5a);
        self.tipLabel.numberOfLines = 0;
        [self addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backgroundView.mas_top).offset(DESGIN_TRANSFORM_3X(7));
            make.left.equalTo(self.mas_left).offset(DESGIN_TRANSFORM_3X(11));
            make.right.equalTo(self.mas_right).offset(-DESGIN_TRANSFORM_3X(11));
        }];
        
        self.gotBtn = [[UIButton alloc] init];
        [self.gotBtn setTitle:@"Got it" forState:UIControlStateNormal];
        [self.gotBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.gotBtn.titleLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(12)];
        self.gotBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x5d0e86);
        self.gotBtn.layer.cornerRadius = 3;
        [self.gotBtn addTarget:self action:@selector(hiddenChardTip) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.gotBtn];
        [self.gotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.backgroundView);
            make.top.equalTo(self.tipLabel.mas_bottom).offset(DESGIN_TRANSFORM_3X(7));
            make.bottom.equalTo(self.backgroundView.mas_bottom).offset(-DESGIN_TRANSFORM_3X(5));
            make.width.equalTo(@DESGIN_TRANSFORM_3X(60));
            make.height.equalTo(@DESGIN_TRANSFORM_3X(20));
        }];
        
    }
    return self;
}


- (void)setTipWithRoomPrice:(double)roomPrice roomTip:(NSString *)roomtip creditText:(NSString *)creditTexe{
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] init];
    if (roomPrice) {
        NSString *credit = [NSString stringWithFormat:@"%.2f",roomPrice];
        [attributedStr appendAttributedString:[self parseMessage:roomtip font:[UIFont systemFontOfSize:11] color:COLOR_WITH_16BAND_RGB(0x5a5a5a)]];
        [attributedStr appendAttributedString:[self parseMessage:credit font:[UIFont systemFontOfSize:12] color:COLOR_WITH_16BAND_RGB(0xffd205)]];
        [attributedStr appendAttributedString:[self parseMessage:creditTexe font:[UIFont systemFontOfSize:11] color:COLOR_WITH_16BAND_RGB(0x5a5a5a)]];
    } else {
        
        [attributedStr appendAttributedString:[self parseMessage:roomtip font:[UIFont systemFontOfSize:11]
                                                           color:COLOR_WITH_16BAND_RGB(0x5a5a5a)]];
    }
    self.tipLabel.attributedText = attributedStr;
}


- (BOOL)hiddenChardTip{
    
    BOOL isShow;
    
    isShow = self.hidden = YES;
    
    [self.gotBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0);
        make.bottom.equalTo(self.backgroundView.mas_bottom);
    }];
    return isShow;
}

- (NSAttributedString *)parseMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)
     ];
    return attributeString;
}

@end
