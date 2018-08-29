//
//  ShowTipView.m
//  livestream
//
//  Created by Calvin on 2018/4/19.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ShowTipView.h"

@implementation ShowTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView * bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 197, 50)];
        bgImageView.image = [UIImage imageNamed:@"ShowTipBG"];
        [self addSubview:bgImageView];
        
        UILabel * tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, bgImageView.frame.size.width - 30, 45)];
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.textColor = COLOR_WITH_16BAND_RGB(0x666666);
        tipLabel.tag = 999;
        [bgImageView addSubview:tipLabel];
        
        self.alpha = 0;
        self.hidden = YES;
        
        self.userInteractionEnabled = YES;
    }
    return self;
}


- (void)showTipViewMsg:(NSString *)msg
{
    UILabel * tipLabel = [self viewWithTag:999];
    tipLabel.text = msg;
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)hideTipView
{
    self.hidden = YES;
}

@end
