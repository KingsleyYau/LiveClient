//
//  LCSegmentView.m
//  UIWidget
//
//  Created by test on 2018/11/21.
//  Copyright © 2018年 lance. All rights reserved.
//


#import "QNSementView.h"
#import "QNUnreadCountBtn.h"

#define kSelectedColor       [UIColor colorWithRed:41 / 255.0 green:122 / 255.0 blue:243 / 255.0 alpha:1]
#define kTextSelectedColor  [UIColor colorWithRed:56 / 255.0 green:56 / 255.0 blue:56 / 255.0 alpha:1]
#define kNormalColor        [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1]
#define kLineNormalColor    [UIColor whiteColor]
#define kSpacing         [UIScreen mainScreen].bounds.size.width==320?5: [UIScreen mainScreen].bounds.size.width==375?15:20

@interface QNSementView ()<QNUnreadCountBtnDelegate>

@property (nonatomic, strong) QNUnreadCountBtn *lastClickUnreadButton;
@end

@implementation QNSementView

- (instancetype)initWithNumberOfTitles:(NSArray *)titles andFrame:(CGRect)frame delegate:(id<QNSementViewDelegate>)delegate isSymmetry:(BOOL)isSymmetry isShowbottomLine:(BOOL)isBottom{
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
            
            QNUnreadCountBtn *button = nil;
            
            
            if (isSymmetry) {
                button = [[QNUnreadCountBtn alloc] initWithFrame:CGRectMake(i*symmetryW, 0, symmetryW, frame.size.height)];;
            }
            else
            {
                button = [[QNUnreadCountBtn alloc] initWithFrame:CGRectMake(x, 0, [array[i+1] floatValue], frame.size.height)];;
            }
            
            // 默认选中第一个 设置状态
            if (i == 0) {
                button.unreadNameText.textColor = kTextSelectedColor;
                button.lineView.backgroundColor = kSelectedColor;
                // 保留为上次选择中的button
                _lastClickUnreadButton = button;
            }
            // 设置对应的tag
            button.tag = i + 88;
            button.unreadNameText.text = titles[i];
            button.delegate = self;
            [self addSubview:button];
            
        }
        
        if (isBottom) {
            CGFloat bottom = self.frame.origin.y + self.frame.size.height;
            UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
            bottomView.backgroundColor = [UIColor grayColor];
            [self addSubview:bottomView];
        }
    }
    
    return self;
}

- (void)selectButtonTag:(NSInteger)tag
{
    QNUnreadCountBtn * button = [self viewWithTag:tag + 88];
    [self unreadCountBtnDidTap:button];
}

+ (CGFloat)getSegmentControlW:(NSArray *)titles
{
    CGFloat w = 0;
    for (int i = 0; i < titles.count; i++) {
        w = ([[titles objectAtIndex:i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + (kSpacing)) + w;
    }
    
    return w;
}

- (void)unreadCountBtnDidTap:(QNUnreadCountBtn *)btn {
    if (_lastClickUnreadButton != btn) {
        // 设置状态
        btn.unreadNameText.textColor = kTextSelectedColor;
        btn.lineView.backgroundColor = kSelectedColor;
        _lastClickUnreadButton.unreadNameText.textColor = kNormalColor;
        _lastClickUnreadButton.lineView.backgroundColor = kLineNormalColor;
        _lastClickUnreadButton = btn;
        // 回调 可用block
        if ([self.delegate respondsToSelector:@selector(segmentControlSelectedTag:)]) {
            [self.delegate segmentControlSelectedTag:btn.tag - 88];
        }
    }
}




- (void)updateBtnUnreadCount:(NSArray * )countArray
{
    for (int i = 0; i < countArray.count; i++) {
        QNUnreadCountBtn *button = [self viewWithTag:i+88];
        [button updateUnreadCount:countArray[i]];
    }
}

@end

