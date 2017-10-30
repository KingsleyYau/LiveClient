//
//  LSPZPagingScrollView.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUIView.h"

@protocol LSPZPagingScrollViewDelegate;
@interface LSPZPagingScrollView : UIScrollView
@property (assign, nonatomic) IBOutlet id<LSPZPagingScrollViewDelegate> pagingViewDelegate;
@property (readonly) UIView *visiblePageView;
@property (assign) BOOL suspendTiling;
@property (assign, readonly) NSUInteger currentPagingIndex;

- (void)displayPagingViewAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)resetDisplay;
@end

@protocol LSPZPagingScrollViewDelegate <NSObject>
@required
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index;
- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView;
- (UIView *)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index;
- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index;
- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index;
@end
