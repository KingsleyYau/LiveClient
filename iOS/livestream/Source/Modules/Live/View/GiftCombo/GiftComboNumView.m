//
//  GiftComboNumView.m
//  liveDemo
//
//  Created by Calvin on 17/5/31.
//  Copyright © 2017年 Calvin. All rights reserved.
//

#import "GiftComboNumView.h"


@interface GiftComboNumView ()

@property (nonatomic, assign) NSInteger startFrameX;

@property (nonatomic, strong) UIView * xIV;
@property (nonatomic, strong) UIView * bgView;
@property (nonatomic, assign) NSInteger lastNumber;/**< 最后显示的数字 */
@end

@implementation GiftComboNumView

@synthesize number = _number;

- (void)initParam {
    self.startFrameX = 10;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initParam];
}

- (void)setNumber:(NSInteger)number {
    self.lastNumber = number;
}

- (NSInteger)number {
    _number = self.lastNumber ;
    self.lastNumber += 1;
    return _number;
}

/**
 获取显示的数字
 
 @return 显示的数字
 */
- (NSInteger)getLastNumber {
    return self.lastNumber - 1;
}

/**
 改变数字显示
 
 @param numberStr 显示的数字
 */
- (void)changeNumber:(NSInteger)numberStr {
    if (numberStr <= 0) {
//        [self removeFromSuperview];
        self.hidden = YES;
        return;
    }

    self.hidden = NO;
    [self removeAllSubviews];
//    [self.bgView removeFromSuperview];
//    self.bgView = [[UIView alloc] init];
//    [self addSubview:self.bgView];
//    self.bgView.clipsToBounds = NO;
    
    CGRect orgFrame = self.frame;
    
    NSInteger width = 0;
    NSInteger itemWidth = 20;
    
    self.xIV.frame = CGRectMake(0, 0, itemWidth, self.frame.size.height * 2.0 / 3.0);
    self.xIV.center = CGPointMake(0, self.frame.size.height / 2);
    [self addSubview:self.xIV];
    width += itemWidth;

    NSString * count = [NSString stringWithFormat:@"%ld", (long)numberStr];
    for (int i = 1; i <= count.length; i++) {
        NSString * num = [[count substringToIndex:i] substringFromIndex:i-1<0?0:i-1];
        UIView* view = nil;
        
        // 用图片展现
        UIImage* icon = [UIImage imageNamed:[NSString stringWithFormat:@"w_%@",num]];
        UIImageView* imageView = [[UIImageView alloc]initWithImage:icon];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        view = imageView;
        
        // 用文字展现
//        UILabel* label = [[UILabel alloc] init];
//        label.frame = CGRectMake(0, 0, 20, self.bgView.frame.size.height);
//        label.center = CGPointMake(self.startFrameX + i * 20, self.bgView.center.y);
//        label.clipsToBounds = NO;
//        label.font = [UIFont boldSystemFontOfSize:30];
//        label.textColor = [UIColor colorWithIntRGB:255 green:210 blue:5 alpha:255];
//        label.layer.shadowOpacity = 1.0;
//        label.layer.shadowRadius = 2.0;
//        label.layer.shadowColor = [UIColor grayColor].CGColor;
//        label.layer.shadowOffset = CGSizeMake(0, 1);
//        label.text = num;
//        view = label;
        
        view.frame = CGRectMake(0, 0, width, self.frame.size.height);
        view.center = CGPointMake(i * itemWidth, self.frame.size.height / 2);
        
        [self addSubview:view];
        width += itemWidth;
    }
    
    self.frame = CGRectMake(orgFrame.origin.x, orgFrame.origin.y, width, orgFrame.size.height);
}

- (UIView *)xIV {
    if (!_xIV) {
        // 用图片展现
        UIImage* icon = [UIImage imageNamed:@"w_x"];
        UIImageView* imageView = [[UIImageView alloc]initWithImage:icon];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        _xIV = imageView;
        
//        // 用文字展现
//        UILabel* label = [[UILabel alloc] init];
//        label.frame = CGRectMake(0, 0, 20, self.frame.size.height);
//        label.clipsToBounds = NO;
//        label.font = [UIFont boldSystemFontOfSize:30];
//        label.textColor = [UIColor colorWithIntRGB:255 green:210 blue:5 alpha:255];
//        label.layer.shadowOpacity = 1.0;
//        label.layer.shadowRadius = 2.0;
//        label.layer.shadowColor = [UIColor grayColor].CGColor;
//        label.layer.shadowOffset = CGSizeMake(0, 1);
//        label.text = @"X";
//        _xIV = label;
    }
    return _xIV;
}

@end
