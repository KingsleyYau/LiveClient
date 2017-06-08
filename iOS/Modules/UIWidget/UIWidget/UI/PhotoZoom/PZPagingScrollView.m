//
//  PZPagingScrollView.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "PZPagingScrollView.h"

#pragma mark -  Class Extension
#pragma mark -

@interface PZPagingScrollView () <UIScrollViewDelegate>

@property (nonatomic, retain) UIView *curView;
@property (nonatomic, retain) NSMutableSet *recycledPages;
@property (nonatomic, retain) NSMutableSet *visiblePages;

@end

@implementation PZPagingScrollView {
    NSUInteger _currentPagingIndex;
}
@synthesize curView;
@synthesize recycledPages;
@synthesize visiblePages;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.pagingViewDelegate = nil;
        self.backgroundColor = [UIColor blackColor];
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}
- (void)setupView {
    self.pagingEnabled = YES;
//    self.backgroundColor = [UIColor blackColor];
//    self.showsVerticalScrollIndicator = NO;
//    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    
    //self.backgroundColor = [UIColor clearColor];
    // it is very important to auto resize
//    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.recycledPages = [NSMutableSet set];//[[NSMutableSet alloc] init];
    self.visiblePages  = [NSMutableSet set];//[[NSMutableSet alloc] init];
}

- (void)didReceiveMemoryWarning {
    [self didReceiveMemoryWarning];
    
    @synchronized (self) {
        // in case views start to pile up, make it possible to clear them out when memory gets low
        if (self.recycledPages.count > 3) {
            [self.recycledPages removeAllObjects];
        }
    }
}

#pragma mark - Calculations for Size and Positioning
#pragma mark -

#define PADDING  4

- (CGRect)frameForPagingScrollView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect pageFrame = self.bounds;
//    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (self.bounds.size.width * index);// + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    
    if(self.pagingViewDelegate == nil)
        return CGSizeZero;
    NSUInteger count = [self.pagingViewDelegate pagingScrollViewPagingViewCount:self];
    
    return CGSizeMake(self.bounds.size.width * count, self.bounds.size.height);
}

- (CGPoint)scrollPositionForIndex:(NSUInteger)index {
    CGFloat x = self.bounds.size.width * index;
    return CGPointMake(x, 0);
}

- (NSUInteger)currentPagingIndex {
    NSUInteger index = (NSUInteger)(ceil(self.contentOffset.x / self.bounds.size.width));
    NSUInteger count = [self.pagingViewDelegate pagingScrollViewPagingViewCount:self];
    if(index >= count) {
        index = count - 1;
    }
    return index;
}

- (void)configurePage:(UIView *)page forIndex:(NSUInteger)index {
    //assert(self.pagingViewDelegate != nil);
    
    if (self.pagingViewDelegate == nil) {
        return;
    }
    
    [self.pagingViewDelegate pagingScrollView:self preparePageViewForDisplay:page forIndex:index];
    page.frame = [self frameForPageAtIndex:index];
    page.tag = index;
}

- (void)tilePages {
    if (self.suspendTiling) {
        // tiling during rotation causes odd behavior so it is best to suspend it
        return;
    }
    if(!self.pagingViewDelegate) {
        return;
    }
//    assert(self.pagingViewDelegate != nil);
    NSUInteger count = [self.pagingViewDelegate pagingScrollViewPagingViewCount:self];
    if(count == 0) {
        return;
    }
    
    // Calculate which pages are visible
    CGRect visibleBounds = self.bounds;
    visibleBounds = CGRectMake(self.contentOffset.x, 0, self.bounds.size.width, 0);
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, (int)count - 1);
    
    // Recycle no-longer-visible pages
    for (UIView *page in self.visiblePages) {
        NSUInteger index = page.tag;
        if (index < firstNeededPageIndex || index > lastNeededPageIndex) {
            [self.recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [self.visiblePages minusSet:self.recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            [self dequeueRecycledPage:index];
//            [self configurePage:page forIndex:index];
//            [self addSubview:page];
//            [self.visiblePages addObject:page];
        }
        else {
            
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Layout Debugging Support
#pragma mark -

- (void)logRect:(CGRect)rect withName:(NSString *)name {
    NSLog(@"%@ : [%f, %f / %f, %f]", name, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)logLayout {
//    DebugLog(@"#### PZPagingScrollView ###");
    
//    [self logRect:self.bounds withName:@"self.bounds"];
//    [self logRect:self.frame withName:@"self.frame"];
//    
//    DebugLog(@"contentSize: %f, %f", self.contentSize.width, self.contentSize.height);
//    DebugLog(@"contentOffset: %f, %f", self.contentOffset.x, self.contentOffset.y);
//    DebugLog(@"contentInset: %f, %f, %f, %f", self.contentInset.top, self.contentInset.right, self.contentInset.bottom, self.contentInset.left);
//    
//    if ([self.visiblePageView respondsToSelector:@selector(logLayout)]) {
//        [self.visiblePageView performSelector:@selector(logLayout)];
//    }
}

#pragma mark - Reuse Queue
#pragma mark -

- (UIView *)dequeueRecycledPage:(NSUInteger)index {
    UIView *page = nil;
    
    //assert(self.pagingViewDelegate != nil);
    if(self.pagingViewDelegate == nil)
        return nil;
    
    if (self.pagingViewDelegate != nil) {
        for (UIView *recycledPage in self.recycledPages) {
            if ([recycledPage isKindOfClass:[self.pagingViewDelegate pagingScrollView:self classForIndex:index]]) {
                page = recycledPage;
                break;
            }
        }
        if (page != nil) {
//            if ([page respondsToSelector:@selector(prepareForReuse)]) {
//                [page performSelector:@selector(prepareForReuse)];
//            }
            [self.visiblePages addObject:page];
            [self.recycledPages removeObject:page];
        }
        else {
            page = [self.pagingViewDelegate pagingScrollView:self pageViewForIndex:index];
            [self.visiblePages addObject:page];
        }
        [self configurePage:page forIndex:index];
        [self addSubview:page];
    }
    
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    BOOL foundPage = NO;
    for (UIView *page in self.visiblePages) {
        NSUInteger pageIndex = page.tag;
        if (pageIndex == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

#pragma mark - Public Implementation
#pragma mark -

- (UIView *)visiblePageView {
    NSUInteger index = [self currentPagingIndex];
    for (UIView *pageView in self.visiblePages) {
        NSUInteger pageIndex = pageView.tag;
        if (pageIndex == index) {
            return pageView;
        }
    }
    
    return nil;
}

- (void)displayPagingViewAtIndex:(NSUInteger)index animated:(BOOL)animated {
//    assert([self conformsToProtocol:@protocol(UIScrollViewDelegate)]);
//    assert(self.delegate == self);
//    assert(self.pagingViewDelegate != nil);
    if(self.pagingViewDelegate == nil) {
        return;
    }
    _currentPagingIndex = index;
    
    self.contentSize = [self contentSizeForPagingScrollView];
    
    CGPoint offset = [self scrollPositionForIndex:index];
    CGPoint offsetOld = self.contentOffset;
    
    if( animated && !CGPointEqualToPoint(offset, offsetOld) ) {
        self.userInteractionEnabled = NO;
    }
    [self setContentOffset:[self scrollPositionForIndex:index] animated:animated];
    
    [self tilePages];
    
    if( !animated ) {
        _currentPagingIndex = [self currentPagingIndex];
        [self.pagingViewDelegate pagingScrollView:self didShowPageViewForDisplay:_currentPagingIndex];
    }
}

- (void)resetDisplay {
    [self cleanUp];
    NSUInteger count = [self.pagingViewDelegate pagingScrollViewPagingViewCount:self];
    if(count > 0) {
        [self displayPagingViewAtIndex:0 animated:false];
    }
//    assert(_currentPagingIndex < count);
    
    self.contentSize = [self contentSizeForPagingScrollView];
    [self setContentOffset:[self scrollPositionForIndex:_currentPagingIndex] animated:FALSE];
    
    for (UIView *pageView in self.visiblePages) {
        NSUInteger index = pageView.tag;
        pageView.frame = [self frameForPageAtIndex:index];
    }
}
- (void)cleanUp {
    for(UIView *view in self.visiblePages) {
        [view removeFromSuperview];
    }
    [self.visiblePages removeAllObjects];
    
    for(UIView *view in self.recycledPages) {
        [view removeFromSuperview];
    }
    [self.recycledPages removeAllObjects];
}
#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self tilePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.userInteractionEnabled = YES;
    _currentPagingIndex = [self currentPagingIndex];
    [self.pagingViewDelegate pagingScrollView:self didShowPageViewForDisplay:_currentPagingIndex];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.userInteractionEnabled = YES;
    _currentPagingIndex = [self currentPagingIndex];
    [self.pagingViewDelegate pagingScrollView:self didShowPageViewForDisplay:_currentPagingIndex];
}
@end
