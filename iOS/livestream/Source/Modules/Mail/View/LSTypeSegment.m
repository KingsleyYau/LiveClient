//
//  LSTypeSegment.m
//  livestream
//
//  Created by test on 2020/4/3.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSTypeSegment.h"



#define kSpacing SCREEN_WIDTH==320?5:SCREEN_WIDTH==375?15:20



@interface LSTypeSegment ()

@property (nonatomic, strong) UIButton *lastClickButton;
/** 设置 */
@property (nonatomic, strong) LSSegmentItem *item;
@end

@implementation LSTypeSegment

- (instancetype)initWithNumberOfTitles:(NSArray *)titles andFrame:(CGRect)frame andSetting:(LSSegmentItem *)item delegate:(id<LSTypeSegmentDelegate>)delegate isSymmetry:(BOOL)isSymmetry {
    if (self = [super initWithFrame:frame]) {
        // 设置代理
        self.delegate = delegate;
        self.item = item;
        NSMutableArray * array = [NSMutableArray array];
        [array addObject:[NSNumber numberWithFloat:0]];
        for (int i = 0; i < titles.count; i++) {
            CGFloat w = [[titles objectAtIndex:i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + (kSpacing);
            [array addObject:[NSNumber numberWithFloat:ceil(w)]];
        }
        
        CGFloat oldW = 0;
        CGFloat symmetryW =  frame.size.width/titles.count;
        CGFloat btnFontSize = (int)titles.count > 2?14:16;
        for (int i = 0; i < titles.count; i ++) {
            CGFloat x = [array[i] floatValue] + oldW;
            oldW = x;

            UIButton *button = nil;
            
            if (isSymmetry) {
              button = [[UIButton alloc] initWithFrame:CGRectMake(i*symmetryW, 0, symmetryW, frame.size.height)];
            }
            else
            {
              button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, [array[i+1] floatValue], frame.size.height)];
            }

            

            // 设置对应的tag
            button.tag = i + 88;
            [button setTitle:titles[i] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:btnFontSize];
            [button addTarget:self action:@selector(buttonChoosed:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundColor:item.normalBgColor];
            [button setTitleColor:item.normalColor forState:UIControlStateNormal];
            
            // 默认选中第一个 设置状态
            if (i == 0) {
                [button setTitleColor:item.textSelectColor forState:UIControlStateNormal];
                [button setBackgroundColor:item.selectBgColor];
                // 保留为上次选择中的button
                _lastClickButton = button;
            }
            [self addSubview:button];
            
            

        }

    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (void)selectButtonTag:(NSInteger)tag
{
    UIButton * button = [self viewWithTag:tag + 88];
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

- (void)buttonChoosed:(UIButton *)button{
    // 连续点击同一个不响应回调
    if (_lastClickButton != button) {
        // 设置状态
        [button setTitleColor:self.item.textSelectColor forState:UIControlStateNormal];
        [button setBackgroundColor:self.item.selectBgColor];
        [_lastClickButton setTitleColor:self.item.normalColor forState:UIControlStateNormal];
        [_lastClickButton setBackgroundColor:self.item.normalBgColor];
        _lastClickButton = button;
        // 回调 可用block
        if ([self.delegate respondsToSelector:@selector(segmentControlSelectedTag:)]) {
            [self.delegate segmentControlSelectedTag:button.tag - 88];
        }
    }
}

@end
