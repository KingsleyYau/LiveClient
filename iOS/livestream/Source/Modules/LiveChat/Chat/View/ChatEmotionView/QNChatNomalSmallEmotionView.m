//
//  ChatNomalSmallEmotionView.m
//  dating
//
//  Created by test on 16/11/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatNomalSmallEmotionView.h"

#import <AVFoundation/AVFoundation.h>

@interface QNChatNomalSmallEmotionView()
/** 小高表 */
@property (nonatomic, strong) QNChatSmallEmotionView *smallEmotionView;
/** 普通和小高级表情 */
@property (nonatomic, strong) QNChatEmotionChooseView *emotionInputView;
@end



@implementation QNChatNomalSmallEmotionView




+ (instancetype)chatNormalSmallEmotionView:(id)owner {
    QNChatNomalSmallEmotionView* view  = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"QNChatNomalSmallEmotionView" owner:owner options:nil].firstObject;
    //    ChatNomalSmallEmotionView* view = [nibs objectAtIndex:0];
    
    
    view.pageView.numberOfPages = 0;
    view.pageView.currentPage = 0;
    
    view.pageScrollView.pagingEnabled = YES;
    view.pageScrollView.showsVerticalScrollIndicator = NO;
    view.pageScrollView.showsHorizontalScrollIndicator = NO;
    view.pageScrollView.delegate = view;
    
    view.emotionInputView = [QNChatEmotionChooseView emotionChooseView:owner];
    // 小高表
    view.smallEmotionView = [QNChatSmallEmotionView chatSmallEmotionView:owner];
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
//        view.pageView.currentPageIndicatorTintColor = [UIColor darkGrayColor];
//        view.pageView.pageIndicatorTintColor = [UIColor lightGrayColor];
//    }
    
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)createUI
{
    self.pageScrollView.frame = CGRectMake(0, 0, screenSize.width, self.frame.size.height);
    
    NSInteger lineCount = (screenSize.width - 60) / ( 60 + 10 ) + 1 ;
    
    
    NSInteger pageItemCount = self.smallEmotionArray.count - lineCount;
    
    CGFloat page = pageItemCount / (lineCount * 2.0f);
    if (page < 0) {
        page = 0;
    }
    
    self.pageView.numberOfPages = ceil(page) + 1;
    self.pageView.currentPage = 0;
    
    self.emotionInputView.emotions = self.defaultEmotionArray;
    self.emotionInputView.smallEmotions = self.smallEmotionArray;
    
    NSMutableArray *smallArray = [NSMutableArray array];
    for (NSInteger i = lineCount; i < self.smallEmotionArray.count; i++) {
        [smallArray addObject:self.smallEmotionArray[i]];
    }
    self.smallEmotionView.smallEmotions = smallArray;
    
    self.pageScrollView.contentSize = CGSizeMake(screenSize.width * 2, 0);
    
    self.emotionInputView.frame = CGRectMake(0, 0, screenSize.width, self.frame.size.height);
    [self.pageScrollView addSubview:self.emotionInputView];
    
    self.smallEmotionView.frame = CGRectMake(screenSize.width, 0, screenSize.width, self.frame.size.height);
    [self.pageScrollView addSubview:self.smallEmotionView];
}

- (void)reloadData {
    [self.emotionInputView reloadData];
    [self.smallEmotionView reloadData];
}

- (void)pageScrollViewToTop
{
    [self.pageScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self.smallEmotionView.emotionCollectionView setContentOffset:CGPointMake(0, 0)];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    self.pageView.currentPage = scrollView.contentOffset.x / pageWidth;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatNormalSmallEmotionViewDidScroll:)]) {
        [self.delegate chatNormalSmallEmotionViewDidScroll:self];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatNormalSmallEmotionViewDidEndDecelerating:)]) {
        [self.delegate chatNormalSmallEmotionViewDidEndDecelerating:self];
    }
}

@end
