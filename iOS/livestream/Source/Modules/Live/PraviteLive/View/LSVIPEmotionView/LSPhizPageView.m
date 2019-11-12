//
//  LSPhizPageView.m
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSPhizPageView.h"

@interface LSPhizPageView ()
@property (nonatomic,strong) UIView* selectedButtonBackgroundView;
@property (nonatomic,assign) BOOL isShowed;
@end

@implementation LSPhizPageView
+ (instancetype)LSPageChooseKeyboardView:(id)owner {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPhizPageView" owner:owner options:nil];
    LSPhizPageView* view = [nibs objectAtIndex:0];
    
    view.pagingScrollView.pagingViewDelegate = view;
    
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)reloadData {
    
    if (self.isShowed) {
        return;
    }
    self.isShowed = YES;
    [self.buttonsView removeAllSubviews];
    
    if( [self.buttons count] > 0 ) {
        self.selectedButtonBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.selectedButtonBackgroundView setBackgroundColor:COLOR_WITH_16BAND_RGB(0xD1D1D1)];
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
        self.pagingScrollView.scrollEnabled = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat itemWidth = 62;
    CGFloat itemHeight = self.buttonsView.frame.size.height;
    
    NSInteger curIndex = 0;
    for(UIButton* button in self.buttons) {
        button.frame = CGRectMake(curIndex * itemWidth, 0, itemWidth, itemHeight);
        curIndex++;
        
        if( button.selected ) {
            self.selectedButtonBackgroundView.frame = button.frame;
        }
    }
}

- (void)buttonAction:(id)sender {
    NSInteger index = ((UIButton *)sender).tag;
    
    for(UIButton* button in self.buttons) {
        if( sender == button ) {
            [button setSelected:YES];
            self.selectedButtonBackgroundView.frame = button.frame;
        } else {
            [button setSelected:NO];
        }
    }
    
    [self.pagingScrollView displayPagingViewAtIndex:index animated:NO];
}

// 切换选中按钮及相应界面
- (void)toggleButtonSelect:(NSInteger)index {
    for (UIButton *btn in self.buttons) {
        if (index == btn.tag) {
            [btn setSelected:YES];
            self.selectedButtonBackgroundView.frame = btn.frame;
        } else {
            [btn setSelected:NO];
        }
    }
    [self.pagingScrollView displayPagingViewAtIndex:index animated:NO];
}

- (IBAction)sendBtnDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(pageChooseKeyboardViewDidSendBtn)]) {
        [self.delegate pageChooseKeyboardViewDidSendBtn];
    }
}

#pragma mark - 画廊回调 (LSPZPagingScrollViewDelegate)
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    
    Class cls = [UIView class];
    if( [self.delegate respondsToSelector:@selector(pageChooseKeyboardView:classForIndex:)] ) {
        cls = [self.delegate pageChooseKeyboardView:self classForIndex:index];
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
    if( [self.delegate respondsToSelector:@selector(pageChooseKeyboardView:pageViewForIndex:)] ) {
        view = [self.delegate pageChooseKeyboardView:self pageViewForIndex:index];
    }
    return view;
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    if( [self.delegate respondsToSelector:@selector(pageChooseKeyboardView:preparePageViewForDisplay:forIndex:)] ) {
        [self.delegate pageChooseKeyboardView:self preparePageViewForDisplay:pageView forIndex:index];
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
    
    if( [self.delegate respondsToSelector:@selector(pageChooseKeyboardView:didShowPageViewForDisplay:)] ) {
        [self.delegate pageChooseKeyboardView:self didShowPageViewForDisplay:index];
    }
}
@end
