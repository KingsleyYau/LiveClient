//
//  PZPagingScrollView.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUIView.h"
@protocol PZPagingScrollViewDelegate;

@interface PZPagingScrollView : UIScrollView

@property (assign, nonatomic) IBOutlet id<PZPagingScrollViewDelegate>pagingViewDelegate;
@property (readonly) UIView *visiblePageView;
@property (assign) BOOL suspendTiling;
@property (assign, readonly) NSUInteger currentPagingIndex;

- (void)displayPagingViewAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)resetDisplay;

@end

@protocol PZPagingScrollViewDelegate <NSObject>

@required

- (Class)pagingScrollView:(PZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index;
- (NSUInteger)pagingScrollViewPagingViewCount:(PZPagingScrollView *)pagingScrollView;
- (UIView *)pagingScrollView:(PZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index;
- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index;
- (void)pagingScrollView:(PZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index;
@end
