//
//  UIScrollView+PullRefresh.m
//  UIWidget
//
//  Created by Max on 16/6/20.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "UIScrollView+PullRefresh.h"
#import "PullRefreshView.h"
#import <objc/runtime.h>

typedef enum {
    RefreshViewTypePullDown = 10000,
    RefreshViewTypePullUp,
} RefreshViewType;

static NSString* delegateKey = @"delegateKey";

@implementation UIScrollView (PullRefresh)
- (void)initPullRefresh:(id<UIScrollViewRefreshDelegate>)delegate pullDown:(BOOL)pullDown pullUp:(BOOL)pullUp {
    if( delegate ) {
        objc_setAssociatedObject(self, &delegateKey, delegate, OBJC_ASSOCIATION_ASSIGN);
    }
    
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    // 下拉
    if( pullDown ) {
        PullRefreshView* pullRefreshView = [self viewWithTag:RefreshViewTypePullDown];
        if( !pullRefreshView ) {
            pullRefreshView = [PullRefreshView pullRefreshView:self];
            [pullRefreshView setup];
            
            pullRefreshView.frame = CGRectMake(0, -pullRefreshView.frame.size.height, self.frame.size.width, pullRefreshView.frame.size.height);
            pullRefreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            pullRefreshView.tag = RefreshViewTypePullDown;
            [self addSubview:pullRefreshView];

        }
    }

    // 上拉
    if( pullUp ) {
        PullRefreshView* pullRefreshView = [self viewWithTag:RefreshViewTypePullUp];
        if( !pullRefreshView ) {
            pullRefreshView = [PullRefreshView pullRefreshView:self];
            pullRefreshView.down = NO;
            pullRefreshView.statusTipsNormal = @"Pull to load more";
            pullRefreshView.statusTipsPulling = @"Release to load more";
            pullRefreshView.statusTipsLoading = @"Loading";
            pullRefreshView.statusTipsLoadFinish = @"Load more finish";
            [pullRefreshView setup];
            
            pullRefreshView.frame = CGRectMake(0, self.contentSize.height, self.frame.size.width, pullRefreshView.frame.size.height);
            pullRefreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            pullRefreshView.tag = RefreshViewTypePullUp;
            [self addSubview:pullRefreshView];
        }
    }
}

- (void)unInitPullRefresh {
    PullRefreshView* pullRefreshView = [self viewWithTag:RefreshViewTypePullDown];
    if( pullRefreshView ) {
        [self removeFromSuperview];
        
        [self removeObserver:self forKeyPath:@"contentOffset"];
        [self removeObserver:self forKeyPath:@"contentSize"];
    }
}

- (void)startPullDown:(BOOL)animation {
    PullRefreshView* pullRefreshView = [self viewWithTag:RefreshViewTypePullDown];
    if( pullRefreshView && (pullRefreshView.state == PullRefreshNormal || pullRefreshView.state == PullRefreshPulling) ) {
        [pullRefreshView setState:PullRefreshLoading];
        
        // 设置不可操作
        self.bounces = NO;
        self.pagingEnabled = NO;
        self.scrollEnabled = NO;
        
        if( animation ) {
            [UIView animateWithDuration:0.5 animations:^{
                [self setContentOffset:CGPointMake(0, -pullRefreshView.frame.size.height) animated:NO];
                self.contentInset = UIEdgeInsetsMake(pullRefreshView.frame.size.height, 0, 0, 0);
                
            } completion:^(BOOL finished) {
                id<UIScrollViewRefreshDelegate> delegate = objc_getAssociatedObject(self, &delegateKey);
                if( [delegate respondsToSelector:@selector(pullDownRefresh:)] ) {
                    [delegate pullDownRefresh:self];
                }
                
            }];
            
        } else {
            [self setContentOffset:CGPointMake(0, -pullRefreshView.frame.size.height) animated:NO];
            self.contentInset = UIEdgeInsetsMake(pullRefreshView.frame.size.height, 0, 0, 0);

            id<UIScrollViewRefreshDelegate> delegate = objc_getAssociatedObject(self, &delegateKey);
            if( [delegate respondsToSelector:@selector(pullDownRefresh:)] ) {
                [delegate pullDownRefresh:self];
            }
        }

    }
    
}

- (void)finishPullDown:(BOOL)animation {
    PullRefreshView* pullRefreshView = [self viewWithTag:RefreshViewTypePullDown];
    
    if( pullRefreshView && pullRefreshView.state == PullRefreshLoading ) {
        [pullRefreshView setState:PullRefreshLoadFinish];
        
        if( animation ) {
            [UIView animateWithDuration:0.5 animations:^{
                self.contentInset = UIEdgeInsetsZero;

            } completion:^(BOOL finished) {
                [pullRefreshView setState:PullRefreshNormal];
                
                self.pagingEnabled = NO;
                self.bounces = YES;
                self.scrollEnabled = YES;
            }];
        } else {
            self.contentInset = UIEdgeInsetsZero;
            
            [pullRefreshView setState:PullRefreshNormal];
            
            self.pagingEnabled = NO;
            self.bounces = YES;
            self.scrollEnabled = YES;
        }
    
    }
}

- (void)startPullUp:(BOOL)animation {
    PullRefreshView* pullRefreshView = [self viewWithTag:RefreshViewTypePullUp];
    if( pullRefreshView && (pullRefreshView.state == PullRefreshNormal || pullRefreshView.state == PullRefreshPulling) ) {
        [pullRefreshView setState:PullRefreshLoading];
        
        self.bounces = NO;
        self.pagingEnabled = NO;
        self.scrollEnabled = NO;

        
        if( animation ) {
            [UIView animateWithDuration:0.5 animations:^{
                [self setContentOffset:CGPointMake(0, self.contentSize.height + pullRefreshView.frame.size.height - self.frame.size.height) animated:NO];
                self.contentInset = UIEdgeInsetsMake(0, 0, pullRefreshView.frame.size.height, 0);
                
            } completion:^(BOOL finished) {
                id<UIScrollViewRefreshDelegate> delegate = objc_getAssociatedObject(self, &delegateKey);
                if( [delegate respondsToSelector:@selector(pullUpRefresh:)] ) {
                    [delegate pullUpRefresh:self];
                }
                
            }];
        } else {
            [self setContentOffset:CGPointMake(0, self.contentSize.height + pullRefreshView.frame.size.height - self.frame.size.height) animated:NO];
            self.contentInset = UIEdgeInsetsMake(0, 0, pullRefreshView.frame.size.height, 0);
            
            id<UIScrollViewRefreshDelegate> delegate = objc_getAssociatedObject(self, &delegateKey);
            if( [delegate respondsToSelector:@selector(pullUpRefresh:)] ) {
                [delegate pullUpRefresh:self];
            }
        }
        
    }
}

- (void)finishPullUp:(BOOL)animation {
    PullRefreshView* pullRefreshView = [self viewWithTag:RefreshViewTypePullUp];
    
    if( pullRefreshView && pullRefreshView.state == PullRefreshLoading ) {
        [pullRefreshView setState:PullRefreshLoadFinish];
        
        if( animation ) {
            [UIView animateWithDuration:0.5 animations:^{
                self.contentInset = UIEdgeInsetsZero;
                
            } completion:^(BOOL finished) {
                [pullRefreshView setState:PullRefreshNormal];
                
                self.pagingEnabled = NO;
                self.bounces = YES;
                self.scrollEnabled = YES;
            }];
        } else {
            [self setContentInset:UIEdgeInsetsZero];
            
            [pullRefreshView setState:PullRefreshNormal];
            
            self.pagingEnabled = NO;
            self.bounces = YES;
            self.scrollEnabled = YES;
        }

    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    if( [keyPath isEqualToString:@"contentOffset"] ) {
        [self scrollViewDidScroll];
    } else if( [keyPath isEqualToString:@"contentSize"] ) {
        [self scrollViewDidChangeContentSize];
    }
}

- (void)scrollViewDidScroll {
    PullRefreshView* pullRefreshView = [self viewWithTag:RefreshViewTypePullDown];
    CGFloat offsetY = self.contentOffset.y;
//    NSLog(@"UIScrollView::scrollViewDidScroll( offsetY : %f, contentInset.top : %f, isDragging : %d, decelerating : %d, pullRefreshView.state : %d )", offsetY, self.contentInset.top, self.isDragging, self.decelerating, pullRefreshView.state);
    if( pullRefreshView ) {
        if(self.isDragging) {
            // 正在下拉
            if( pullRefreshView.state != PullRefreshLoading ) {
                // 不在加载中
                if( offsetY < -pullRefreshView.frame.size.height) {
                    // 正在下拉, 头部拉出, 标记为可以刷新
                    [pullRefreshView setState:PullRefreshPulling];
                    
                } else {
                    // 正在下拉, 头部未拉出
                    [pullRefreshView setState:PullRefreshNormal];

                }
            }

        } else {
            // 手已经松开
            if( pullRefreshView.state == PullRefreshPulling ) {
                // 开始刷新
                [self startPullDown:NO];
                
            }
        }
        
    }
    
    pullRefreshView = [self viewWithTag:RefreshViewTypePullUp];
    if( pullRefreshView ) {
        if(self.isDragging) {
            // 正在上拉
            if( pullRefreshView.state != PullRefreshLoading ) {
                // 不在加载中
                if( offsetY > self.contentSize.height + pullRefreshView.frame.size.height - self.frame.size.height) {
                    // 正在上拉, 底部拉出, 标记为可以刷新
                    [pullRefreshView setState:PullRefreshPulling];
                    
                } else {
                    // 正在上拉, 底部未拉出
                    [pullRefreshView setState:PullRefreshNormal];
                    
                }
            }
            
        } else {
            // 手已经松开
            if( pullRefreshView.state == PullRefreshPulling ) {
                // 开始刷新更多
                [self startPullUp:NO];
            }
        }
        
    }
    
}

- (void)scrollViewDidChangeContentSize {
    PullRefreshView* pullRefreshView = [self viewWithTag:RefreshViewTypePullUp];
    if( pullRefreshView ) {
        if( self.contentSize.height >= self.frame.size.height ) {
            // 可以滚动
            pullRefreshView.hidden = NO;
            if( pullRefreshView.frame.origin.y != self.contentSize.height ) {
                pullRefreshView.frame = CGRectMake(0, self.contentSize.height, self.frame.size.width, pullRefreshView.frame.size.height);
            }
            
        } else {
            pullRefreshView.hidden = YES;
        }
    }
}

- (void)scrollViewDidChangeDecelerating {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
