//
//  JDSegmentControl.m
//  livestream
//
//  Created by Calvin on 17/10/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "JDSegmentControl.h"

#define kSelectedColor      COLOR_WITH_16BAND_RGB(0x297AF3)
#define kTextSelectedColor  COLOR_WITH_16BAND_RGB(0x1A1A1A)
#define kNormalColor        COLOR_WITH_16BAND_RGB(0x666666)
#define kLineNormalColor    [UIColor whiteColor]
#define kSpacing SCREEN_WIDTH==320?5:SCREEN_WIDTH==375?15:20

@interface JDUnreadButton:UIButton

@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UILabel * unreadLabel;
@end

@implementation JDUnreadButton

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
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:lineView];
        [self addSubview:label];
        
    }
    return self;
}

- (void)updateUnreadCount:(NSString *)count
{
    if ([count intValue] == 0) {
        _unreadLabel.hidden = YES;
    }
    else
    {
        _unreadLabel.hidden = NO;
        if ([count intValue] > 99) {
            _unreadLabel.frame = CGRectMake(self.frame.size.width - 20, 5, 20, 12);
            _unreadLabel.text = @"99+";
        }
        else
        {
           _unreadLabel.frame = CGRectMake(self.frame.size.width - 15, 5, 12, 12);
            _unreadLabel.text = count;
        }
    }
}

@end

@interface JDSegmentControl ()

@property (nonatomic, strong) JDUnreadButton *lastClickButton;
@end

@implementation JDSegmentControl

- (instancetype)initWithNumberOfTitles:(NSArray *)titles andFrame:(CGRect)frame delegate:(id<JDSegmentControlDelegate>)delegate isSymmetry:(BOOL)isSymmetry isShowbottomLine:(BOOL)isBottom{
    if (self = [super initWithFrame:frame]) {
        // 设置代理
        self.delegate = delegate;
       
        NSMutableArray * array = [NSMutableArray array];
        [array addObject:[NSNumber numberWithFloat:0]];
        for (int i = 0; i < titles.count; i++) {
            CGFloat w = [[titles objectAtIndex:i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + (kSpacing);
            [array addObject:[NSNumber numberWithFloat:ceil(w)]];
        }
        
        CGFloat oldW = 0;
        CGFloat symmetryW =  frame.size.width/titles.count;
        for (int i = 0; i < titles.count; i ++) {
            CGFloat x = [array[i] floatValue] + oldW;
            oldW = x;

            JDUnreadButton *button = nil;
            
            if (isSymmetry) {
              button = [[JDUnreadButton alloc] initWithFrame:CGRectMake(i*symmetryW, 0, symmetryW, frame.size.height)];;
            }
            else
            {
              button = [[JDUnreadButton alloc] initWithFrame:CGRectMake(x, 0, [array[i+1] floatValue], frame.size.height)];;
            }
           
            // 默认选中第一个 设置状态
            if (i == 0) {
                [button setTitleColor:kTextSelectedColor forState:UIControlStateNormal];
                button.lineView.backgroundColor = kSelectedColor;
                // 保留为上次选择中的button
                _lastClickButton = button;
            }
            // 设置对应的tag
            button.tag = i + 88;
            [button setTitle:titles[i] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonChoosed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];

        }
        
        if (isBottom) {
            CGFloat bottom = self.frame.origin.y + self.frame.size.height;
            UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
            bottomView.backgroundColor = COLOR_WITH_16BAND_RGB(0xdb96ff);
            [self addSubview:bottomView];
        }
    }
    
    return self;
}

- (void)selectButtonTag:(NSInteger)tag
{
    JDUnreadButton * button = [self viewWithTag:tag + 88];
    [self buttonChoosed:button];
}

+ (CGFloat)getSegmentControlW:(NSArray *)titles
{
    CGFloat w = 0;
    for (int i = 0; i < titles.count; i++) {
         w = ([[titles objectAtIndex:i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + (kSpacing)) + w;
    }
    
    return w;
}

- (void)buttonChoosed:(JDUnreadButton *)button{
    // 连续点击同一个不响应回调
    if (_lastClickButton != button) {
        // 设置状态
        [button setTitleColor:kTextSelectedColor forState:UIControlStateNormal];
        button.lineView.backgroundColor = kSelectedColor;
        [_lastClickButton setTitleColor:kNormalColor forState:UIControlStateNormal];
        _lastClickButton.lineView.backgroundColor = kLineNormalColor;
        _lastClickButton = button;
        // 回调 可用block
        if ([self.delegate respondsToSelector:@selector(segmentControlSelectedTag:)]) {
            [self.delegate segmentControlSelectedTag:button.tag - 88];
        }
    }
}

- (void)updateBtnUnreadCount:(NSArray * )countArray
{
    for (int i = 0; i < countArray.count; i++) {
        JDUnreadButton * button = [self viewWithTag:i + 88];
        [button updateUnreadCount:countArray[i]];
    }
}

@end
