//
//  UIScrollView+PullRefresh.h
//  UIWidget
//
//  Created by Max on 16/6/20.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPullRefreshObserve.h"

@class UIScrollView;
@protocol UIScrollViewRefreshDelegate <NSObject>
@optional
- (void)pullDownRefresh:(UIScrollView *)scrollView;
- (void)pullUpRefresh:(UIScrollView *)scrollView;
@end

@interface UIScrollView (LSPullRefresh)
@property (nonatomic, strong) LSPullRefreshObserve *observe;

@property (nonatomic, assign) BOOL pullScrollEnabled;

- (void)setupPullRefresh:(id<UIScrollViewRefreshDelegate>)delegate pullDown:(BOOL)pullDown pullUp:(BOOL)pullUp;
- (void)unSetupPullRefresh;

- (void)startLSPullDown:(BOOL)animation;
- (void)finishLSPullDown:(BOOL)animation;

- (void)startLSPullUp:(BOOL)animation;
- (void)finishLSPullUp:(BOOL)animation;

- (void)lsScrollViewDidScroll;
- (void)lsScrollViewDidChangeContentSize;
@end
