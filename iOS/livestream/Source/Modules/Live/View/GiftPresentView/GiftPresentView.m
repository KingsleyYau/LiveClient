//
//  GiftPresentView.m
//  livestream
//
//  Created by randy on 2017/8/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftPresentView.h"

@interface GiftPresentView ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIView* selectedButtonBackgroundView;
@property (nonatomic,assign) BOOL isShowed;

@end


@implementation GiftPresentView

+ (instancetype)giftPresentView:(id)owner {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"GiftPresentView" owner:owner options:nil];
    GiftPresentView* view = [nibs objectAtIndex:0];
    view.chooseGiftScrollView.pagingViewDelegate = view;
    return view;
}

- (void)reloadData {
    
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
        
        [self.chooseGiftScrollView displayPagingViewAtIndex:0 animated:NO];
        self.chooseGiftScrollView.scrollEnabled = NO;
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat itemWidth = self.buttonsView.frame.size.width;
    CGFloat itemHeight = self.buttonsView.frame.size.height;
    
    NSInteger curIndex = 0;
    for(UIButton* button in self.buttons) {
        button.frame = CGRectMake(curIndex * (itemWidth * 0.5), 0, itemWidth * 0.5, itemHeight);
        curIndex++;
        
        if( button.selected ) {
            self.selectedButtonBackgroundView.frame = button.frame;
        }
    }
}


- (IBAction)buttonAction:(id)sender {
    NSInteger index = ((UIButton *)sender).tag;
    
    for(UIButton* button in self.buttons) {
        if( sender == button ) {
            [button setSelected:YES];
            self.selectedButtonBackgroundView.frame = button.frame;
        } else {
            [button setSelected:NO];
        }
    }
    
    [self.chooseGiftScrollView displayPagingViewAtIndex:index animated:NO];
}


#pragma mark - 画廊回调 (PZPagingScrollViewDelegate)
- (Class)pagingScrollView:(PZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    Class cls = [UIView class];
    if( [self.delegate respondsToSelector:@selector(giftPresentView:classForIndex:)] ) {
        cls = [self.delegate giftPresentView:self classForIndex:index];
    }
    return cls;
}

- (NSUInteger)pagingScrollViewPagingViewCount:(PZPagingScrollView *)pagingScrollView {
    NSUInteger count = 0;
    if( [self.delegate respondsToSelector:@selector(chooseGiftPageViewCount:)] ) {
        count = [self.delegate chooseGiftPageViewCount:self];
    }
    return count;
}

- (UIView *)pagingScrollView:(PZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIView *view = nil;
    if( [self.delegate respondsToSelector:@selector(giftPresentView:pageViewForIndex:)] ) {
        view = [self.delegate giftPresentView:self pageViewForIndex:index];
    }
    return view;
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    if( [self.delegate respondsToSelector:@selector(giftPresentView:preparePageViewForDisplay:forIndex:)] ) {
        [self.delegate giftPresentView:self preparePageViewForDisplay:pageView forIndex:index];
    }
}

- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    for(UIButton* button in self.buttons) {
        if( button.tag == index ) {
            [button setSelected:YES];
            self.selectedButtonBackgroundView.frame = button.frame;
        } else {
            [button setSelected:NO];
        }
    }
    
    if( [self.delegate respondsToSelector:@selector(giftPresentView:didShowPageViewForDisplay:)] ) {
        [self.delegate giftPresentView:self didShowPageViewForDisplay:index];
    }
}

@end
