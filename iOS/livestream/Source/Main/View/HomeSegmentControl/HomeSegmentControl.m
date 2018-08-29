//
//  HomeSegmentControl.m
//  livestream
//
//  Created by Calvin on 2018/6/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HomeSegmentControl.h"

#define kSelectedColor      COLOR_WITH_16BAND_RGB(0x297AF3)
#define kTextSelectedColor  COLOR_WITH_16BAND_RGB(0x297AF3)
#define kNormalColor        COLOR_WITH_16BAND_RGB(0x1A1A1A)
#define kLineNormalColor    [UIColor whiteColor]
#define kSpacing SCREEN_WIDTH==320?5:SCREEN_WIDTH==375?15:20
#define TitleFont 16

@interface HomeUnreadButton:UIButton

@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UILabel * unreadLabel;
@end

@implementation HomeUnreadButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        CGFloat lineWidth = 2;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - lineWidth, frame.size.width, lineWidth)];
        // 设置初始状态
        lineView.backgroundColor = kLineNormalColor;
        _lineView = lineView;
        
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 15, 5, 12, 12)];
        label.backgroundColor = [UIColor redColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:9];
        label.layer.cornerRadius = label.frame.size.height/2;
        label.layer.masksToBounds = YES;
        label.hidden = YES;
        _unreadLabel = label;
        
        [self setTitleColor:kNormalColor forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:TitleFont];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:lineView];
        [self addSubview:label];
        
    }
    return self;
}



@end

@interface HomeSegmentControl ()

@property (nonatomic, strong) HomeUnreadButton *lastClickButton;
@end

@implementation HomeSegmentControl

- (instancetype)initWithNumberOfTitles:(NSArray *)titles andFrame:(CGRect)frame delegate:(id<HomeSegmentControlDelegate>)delegate{
    if (self = [super initWithFrame:frame]) {
        // 设置代理
        self.delegate = delegate;
        
        NSMutableArray * array = [NSMutableArray array];
        [array addObject:[NSNumber numberWithFloat:0]];
        for (int i = 0; i < titles.count; i++) {
            CGFloat w = [[titles objectAtIndex:i] sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:TitleFont]}].width + (kSpacing);
            [array addObject:[NSNumber numberWithFloat:ceil(w)]];
        }
        
        CGFloat oldW = 0;
        CGFloat symmetryW =  frame.size.width/titles.count;
        for (int i = 0; i < titles.count; i ++) {
            CGFloat x = [array[i] floatValue] + oldW;
            oldW = x;
            
            HomeUnreadButton *button = nil;
            
            button = [[HomeUnreadButton alloc] initWithFrame:CGRectMake(i*symmetryW, 0, symmetryW, frame.size.height)];;
            
            // 默认选中第一个 设置状态
            if (i == 0) {
                [button setTitleColor:kTextSelectedColor forState:UIControlStateNormal];
                // 保留为上次选择中的button
                _lastClickButton = button;
            }
            // 设置对应的tag
            button.tag = i + 88;
            [button setTitle:titles[i] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonChoosed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            
        }
    }
    
    return self;
}

- (void)selectButtonTag:(NSInteger)tag
{
    HomeUnreadButton * button = [self viewWithTag:tag + 88];
    [self buttonChoosed:button];
}



- (void)buttonChoosed:(HomeUnreadButton *)button{
    // 连续点击同一个不响应回调
    if (_lastClickButton != button) {
        // 设置状态
        [button setTitleColor:kTextSelectedColor forState:UIControlStateNormal];
        [_lastClickButton setTitleColor:kNormalColor forState:UIControlStateNormal];
        _lastClickButton = button;
        // 回调 可用block
        if ([self.delegate respondsToSelector:@selector(segmentControlSelectedTag:)]) {
            [self.delegate segmentControlSelectedTag:button.tag - 88];
        }
    }
}

@end
