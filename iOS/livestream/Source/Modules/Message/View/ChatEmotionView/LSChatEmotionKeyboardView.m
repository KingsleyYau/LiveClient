//
//  ChatEmotionKeyboardView.m
//  dating
//
//  Created by Max on 16/10/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSChatEmotionKeyboardView.h"
#import "Masonry.h"

@interface LSChatEmotionKeyboardView ()
@property (nonatomic,strong) UIView* selectedButtonBackgroundView;
@property (nonatomic,assign) BOOL isShowed;
@end

@implementation LSChatEmotionKeyboardView
+ (instancetype)chatEmotionKeyboardView:(id)owner {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSChatEmotionKeyboardView" owner:owner options:nil];
    LSChatEmotionKeyboardView* view = [nibs objectAtIndex:0];
    
    view.pagingScrollView.pagingViewDelegate = view;
    
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)reloadData {
    
    
    [self.pagingScrollView displayPagingViewAtIndex:0 animated:NO];
    
    /*
    if (self.isShowed) {
        return;
    }
    self.isShowed = YES;
    [self.buttonsView removeAllSubviews];
    
    if( [self.buttons count] > 0 ) {
        self.selectedButtonBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.selectedButtonBackgroundView setBackgroundColor:Color(246, 246, 246, 1.0)];
//        [self.selectedButtonBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
        [self.buttonsView addSubview:self.selectedButtonBackgroundView];
        
        NSInteger index = 0;
        for(UIButton* button in self.buttons) {
            button.tag = index++;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setSelected:NO];

            [button removeFromSuperview];
            [self.buttonsView addSubview:button];
        }
        
        [[self.buttons objectAtIndex:0] setSelected:YES];

        [self setNeedsLayout];
        [self layoutIfNeeded];

        [self.pagingScrollView displayPagingViewAtIndex:0 animated:NO];
    }
     */
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat itemWidth = self.buttonsView.frame.size.height;
    CGFloat itemHeight = itemWidth;
    
    NSInteger curIndex = 0;
    for(UIButton* button in self.buttons) {
        button.frame = CGRectMake(curIndex * itemWidth, 0, itemWidth, itemHeight);
        curIndex++;
        
        if( button.selected ) {
            self.selectedButtonBackgroundView.frame = button.frame;
        }
    }
}

- (IBAction)buttonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chatEmotionKeyboardViewSendEmotion)]) {
        [self.delegate chatEmotionKeyboardViewSendEmotion];
    }
}

#pragma mark - 画廊回调 (PZPagingScrollViewDelegate)
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    Class cls = [UIView class];
    if( [self.delegate respondsToSelector:@selector(chatEmotionKeyboardView:classForIndex:)] ) {
        cls = [self.delegate chatEmotionKeyboardView:self classForIndex:index];
    }
    return cls;
}

- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView {
    NSUInteger count = 0;
    if( [self.delegate respondsToSelector:@selector(pagingViewCount:)] ) {
        count = [self.delegate pagingViewCount:self];
    }
    return count;
}

- (UIView *)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIView *view = nil;
    if( [self.delegate respondsToSelector:@selector(chatEmotionKeyboardView:pageViewForIndex:)] ) {
        view = [self.delegate chatEmotionKeyboardView:self pageViewForIndex:index];
    }
    return view;
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    if( [self.delegate respondsToSelector:@selector(chatEmotionKeyboardView:preparePageViewForDisplay:forIndex:)] ) {
        [self.delegate chatEmotionKeyboardView:self preparePageViewForDisplay:pageView forIndex:index];
    }
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    for(UIButton* button in self.buttons) {
        if( button.tag == index ) {
            [button setSelected:YES];
            self.selectedButtonBackgroundView.frame = button.frame;
        } else {
            [button setSelected:NO];
        }
    }
    
    if( [self.delegate respondsToSelector:@selector(chatEmotionKeyboardView:didShowPageViewForDisplay:)] ) {
        [self.delegate chatEmotionKeyboardView:self didShowPageViewForDisplay:index];
    }
}

@end
