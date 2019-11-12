//
//  UIScrollView+PullRefresh.m
//  UIWidget
//
//  Created by Max on 16/6/20.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "UIScrollView+LSPullRefresh.h"
#import "LSPullRefreshView.h"
#import <objc/runtime.h>


typedef enum {
    RefreshViewTypePullDown = 10000,
    RefreshViewTypePullUp,
} RefreshViewType;

static NSString *delegateKey = @"delegateKey";
static NSString *observeKey = @"observeKey";
static BOOL pullEnabled = NO;

@implementation UIScrollView (LSPullRefresh)
- (LSPullRefreshObserve *)observe{
    return objc_getAssociatedObject(self, &observeKey);
}
- (void)setObserve:(LSPullRefreshObserve *)observe{
    objc_setAssociatedObject(self, &observeKey, observe, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pullScrollEnabled {
    return pullEnabled;
}

- (void)setPullScrollEnabled:(BOOL)pullScrollEnabled {
    pullEnabled = pullScrollEnabled;
}

- (void)setupPullRefresh:(id<UIScrollViewRefreshDelegate>)delegate pullDown:(BOOL)pullDown pullUp:(BOOL)pullUp {
    if (delegate) {
        objc_setAssociatedObject(self, &delegateKey, delegate, OBJC_ASSOCIATION_ASSIGN);
    }

    self.observe = [[LSPullRefreshObserve alloc] init];
    self.observe.scrollView = self;
    [self.observe addObserve];
    // 下拉
    if (pullDown) {
        LSPullRefreshView *pullRefreshView = [self viewWithTag:RefreshViewTypePullDown];
        if (!pullRefreshView) {
            pullRefreshView = [LSPullRefreshView pullRefreshView:self];
            [pullRefreshView setup];

            pullRefreshView.frame = CGRectMake(0, -(pullRefreshView.frame.size.height), self.frame.size.width, pullRefreshView.frame.size.height);
            pullRefreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            pullRefreshView.tag = RefreshViewTypePullDown;
            [self addSubview:pullRefreshView];
        }
    }

    // 上拉
    if (pullUp) {
        LSPullRefreshView *pullRefreshView = [self viewWithTag:RefreshViewTypePullUp];
        if (!pullRefreshView) {
            pullRefreshView = [LSPullRefreshView pullRefreshView:self];
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

- (void)unSetupPullRefresh {
    objc_setAssociatedObject(self, &delegateKey, nil, OBJC_ASSOCIATION_ASSIGN);
    LSPullRefreshView *pullRefreshView = [self viewWithTag:RefreshViewTypePullDown];
    if (pullRefreshView) {
        [self removeFromSuperview];
        [self.observe removeObserve];

    }
}

- (void)startLSPullDown:(BOOL)animation {
    LSPullRefreshView *pullRefreshView = [self viewWithTag:RefreshViewTypePullDown];
    if( pullRefreshView && (pullRefreshView.state == PullRefreshNormal || pullRefreshView.state == PullRefreshPulling) ) {
        [pullRefreshView setState:PullRefreshLoading];
        
        // 设置不可操作
        self.bounces = NO;
        self.pagingEnabled = NO;
        self.scrollEnabled = self.pullScrollEnabled;
        
        if( animation ) {
            [UIView animateWithDuration:0.5 animations:^{
                [self setContentOffset:CGPointMake(0, -pullRefreshView.frame.size.height) animated:NO];
                self.contentInset = UIEdgeInsetsMake(pullRefreshView.frame.size.height, 0, 0, 0);
                
            }
                             completion:^(BOOL finished) {
                                 id<UIScrollViewRefreshDelegate> delegate;
                                 if (self) {
                                     delegate = objc_getAssociatedObject(self, &delegateKey);
                                 }
                                 if( [delegate respondsToSelector:@selector(pullDownRefresh:)] ) {
                                     [delegate pullDownRefresh:self];
                                 }
                                 
                             }];
            
        } else {
            [self setContentOffset:CGPointMake(0, -pullRefreshView.frame.size.height) animated:NO];
            self.contentInset = UIEdgeInsetsMake(pullRefreshView.frame.size.height, 0, 0, 0);
            
            id<UIScrollViewRefreshDelegate> delegate;
            if (self) {
                delegate = objc_getAssociatedObject(self, &delegateKey);
            }
            if( [delegate respondsToSelector:@selector(pullDownRefresh:)] ) {
                [delegate pullDownRefresh:self];
            }
        }
        
    }
}

- (void)finishLSPullDown:(BOOL)animation {
    LSPullRefreshView *pullRefreshView = [self viewWithTag:RefreshViewTypePullDown];

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

- (void)startLSPullUp:(BOOL)animation {
    LSPullRefreshView *pullRefreshView = [self viewWithTag:RefreshViewTypePullUp];
    if (pullRefreshView && (pullRefreshView.state == PullRefreshNormal || pullRefreshView.state == PullRefreshPulling)) {
        [pullRefreshView setState:PullRefreshLoading];

        self.bounces = NO;
        self.pagingEnabled = NO;
        self.scrollEnabled = self.pullScrollEnabled;

        if (animation) {
            [UIView animateWithDuration:0.5 animations:^{
                [self setContentOffset:CGPointMake(0, self.contentSize.height + pullRefreshView.frame.size.height - self.frame.size.height) animated:NO];
                self.contentInset = UIEdgeInsetsMake(0, 0, pullRefreshView.frame.size.height, 0);
                
            }
                             completion:^(BOOL finished) {
                                 id<UIScrollViewRefreshDelegate> delegate;
                                 if (self) {
                                     delegate = objc_getAssociatedObject(self, &delegateKey);
                                 }
                                 if( [delegate respondsToSelector:@selector(pullUpRefresh:)] ) {
                                     [delegate pullUpRefresh:self];
                                 }
                                 
                             }];
        } else {
            [self setContentOffset:CGPointMake(0, self.contentSize.height + pullRefreshView.frame.size.height - self.frame.size.height) animated:NO];
            self.contentInset = UIEdgeInsetsMake(0, 0, pullRefreshView.frame.size.height, 0);
            id<UIScrollViewRefreshDelegate> delegate;
            if (self) {
                delegate = objc_getAssociatedObject(self, &delegateKey);
            }
            if( [delegate respondsToSelector:@selector(pullUpRefresh:)] ) {
                [delegate pullUpRefresh:self];
            }
        }
    }
}

- (void)finishLSPullUp:(BOOL)animation {
    LSPullRefreshView *pullRefreshView = [self viewWithTag:RefreshViewTypePullUp];

    if (pullRefreshView && pullRefreshView.state == PullRefreshLoading) {
        [pullRefreshView setState:PullRefreshLoadFinish];

        if (animation) {
            [UIView animateWithDuration:0.5
                animations:^{
                    self.contentInset = UIEdgeInsetsZero;

                }
                completion:^(BOOL finished) {
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

//- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString *, id> *)change context:(nullable void *)context {
//    if ([keyPath isEqualToString:@"contentOffset"]) {
//        [self lsScrollViewDidScroll];
//    } else if ([keyPath isEqualToString:@"contentSize"]) {
//        [self lsScrollViewDidChangeContentSize];
//    }
//}

- (void)lsScrollViewDidScroll {
    LSPullRefreshView *pullRefreshView = [self viewWithTag:RefreshViewTypePullDown];
    CGFloat offsetY = self.contentOffset.y;
    //    NSLog(@"UIScrollView::scrollViewDidScroll( offsetY : %f, contentInset.top : %f, isDragging : %d, decelerating : %d, pullRefreshView.state : %d )", offsetY, self.contentInset.top, self.isDragging, self.decelerating, pullRefreshView.state);
    if (pullRefreshView) {
        if (self.isDragging) {
            // 正在下拉
            if (pullRefreshView.state != PullRefreshLoading) {
                // 不在加载中
                if (offsetY < -pullRefreshView.frame.size.height) {
                    // 正在下拉, 头部拉出, 标记为可以刷新
                    [pullRefreshView setState:PullRefreshPulling];

                } else {
                    // 正在下拉, 头部未拉出
                    [pullRefreshView setState:PullRefreshNormal];
                }
            }

        } else {
            // 手已经松开
            if (pullRefreshView.state == PullRefreshPulling) {
                // 开始刷新
                [self startLSPullDown:NO];
            }
        }
    }

    pullRefreshView = [self viewWithTag:RefreshViewTypePullUp];
    if (pullRefreshView) {
        if (self.isDragging) {
            // 正在上拉
            if (pullRefreshView.state != PullRefreshLoading) {
                // 不在加载中
                //                if( offsetY > self.contentSize.height + pullRefreshView.frame.size.height - self.frame.size.height) {
                if (offsetY > self.contentSize.height - self.frame.size.height) {
                    // 正在上拉, 底部拉出, 标记为可以刷新
                    [pullRefreshView setState:PullRefreshPulling];

                } else {
                    // 正在上拉, 底部未拉出
                    [pullRefreshView setState:PullRefreshNormal];
                }
            }

        } else {
            // 手已经松开
            if (pullRefreshView.state == PullRefreshPulling && self.contentOffset.y > 0) {
                // 开始刷新更多
                [self startLSPullUp:NO];
            }
        }
    }
}

- (void)lsScrollViewDidChangeContentSize {
    LSPullRefreshView *pullRefreshView = [self viewWithTag:RefreshViewTypePullUp];
    if (pullRefreshView) {
        if (self.contentSize.height >= self.frame.size.height) {
            // 可以滚动
            pullRefreshView.hidden = NO;
            if (pullRefreshView.frame.origin.y != self.contentSize.height) {
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
