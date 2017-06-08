//
//  UIScrollView+PullRefresh.h
//  UIWidget
//
//  Created by Max on 16/6/20.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIScrollView;
@protocol UIScrollViewRefreshDelegate <NSObject>
@optional
- (void)pullDownRefresh:(UIScrollView *)scrollView;
- (void)pullUpRefresh:(UIScrollView *)scrollView;
@end

@interface UIScrollView (PullRefresh)

- (void)initPullRefresh:(id<UIScrollViewRefreshDelegate>)delegate pullDown:(BOOL)pullDown pullUp:(BOOL)pullUp;
- (void)unInitPullRefresh;

- (void)startPullDown:(BOOL)animation;
- (void)finishPullDown:(BOOL)animation;

- (void)startPullUp:(BOOL)animation;
- (void)finishPullUp:(BOOL)animation;

@end
