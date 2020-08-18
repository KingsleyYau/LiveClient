//
//  LSSlidingView.m
//  calvinTest
//
//  Created by Calvin on 2018/10/17.
//  Copyright © 2018年 dating. All rights reserved.
//

#import "LSSlidingView.h"

@interface LSSlidingView ()
@property (nonatomic, strong) NSArray * moreArray;
@end

@implementation LSSlidingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton * moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.frame = CGRectMake(0, 0, 35, self.frame.size.height);
        [moreBtn setImage:[UIImage imageNamed:@"LS_MyContacts_MoveBtn"] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(moreBtnDid) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreBtn];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIButton * moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.frame = CGRectMake(0, 0, 35, self.frame.size.height);
        [moreBtn setImage:[UIImage imageNamed:@"LS_MyContacts_MoveBtn"] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(moreBtnDid) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreBtn];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

 
- (void)setMoreBtns:(NSArray *)array {
    
    self.moreArray = array;
    for (int i = 0; i < array.count; i++) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(35 + i*self.frame.size.height, 0, self.frame.size.height, self.frame.size.height);
        
        NSString * type = array[i];
        
        if ([type isEqualToString:@"wacth"]) {
            [btn setImage:[UIImage imageNamed:@"LS_Mycontacts_Watch"] forState:UIControlStateNormal];
            btn.backgroundColor = COLOR_WITH_16BAND_RGB(0x00CA00);
        }else if ([type isEqualToString:@"invite"]) {
            [btn setImage:[UIImage imageNamed:@"LS_Mycontacts_Invite"] forState:UIControlStateNormal];
            btn.backgroundColor = COLOR_WITH_16BAND_RGB(0x287AF3);
        }else if ([type isEqualToString:@"chat"]) {
            [btn setImage:[UIImage imageNamed:@"LS_Mycontacts_Chat"] forState:UIControlStateNormal];
            btn.backgroundColor = COLOR_WITH_16BAND_RGB(0x20AE31);
        }else if ([type isEqualToString:@"mail"]) {
            [btn setImage:[UIImage imageNamed:@"LS_Mycontacts_Mail"] forState:UIControlStateNormal];
            btn.backgroundColor = COLOR_WITH_16BAND_RGB(0xFF7100);
        }else if ([type isEqualToString:@"book"]) {
            [btn setImage:[UIImage imageNamed:@"LS_Mycontacts_Book"] forState:UIControlStateNormal];
            btn.backgroundColor = COLOR_WITH_16BAND_RGB(0xF4A343);
        }else {
            
        }
        
        btn.tag = 88 + i;
        [btn addTarget:self action:@selector(moreBtnDid:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    
    CGRect rect = self.frame;
    rect.size.width = 35 + (array.count * self.frame.size.height);
    self.frame = rect;
}

- (void)moreBtnDid {
    
    if ([self.delegate respondsToSelector:@selector(slidingViewMoreBtnDid)]) {
        [self.delegate slidingViewMoreBtnDid];
    }
}

- (void)moreBtnDid:(UIButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(slidingViewBtnDidRow:)]) {
        NSInteger tag = btn.tag - 88;
        [self.delegate slidingViewBtnDidRow:self.moreArray[tag]];
    }
    
}

@end
