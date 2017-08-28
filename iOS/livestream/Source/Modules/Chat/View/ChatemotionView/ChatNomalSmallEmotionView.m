//
//  ChatNomalSmallEmotionView.m
//  dating
//
//  Created by test on 16/11/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatNomalSmallEmotionView.h"

#import <AVFoundation/AVFoundation.h>

@interface ChatNomalSmallEmotionView()
/** 普通和小高级表情 */
@property (nonatomic, strong) ChatEmotionChooseView *emotionInputView;
@end



@implementation ChatNomalSmallEmotionView


+ (instancetype)chatNormalSmallEmotionView:(id)owner {
    ChatNomalSmallEmotionView* view  = [[NSBundle mainBundle] loadNibNamedWithFamily:@"ChatNomalSmallEmotionView" owner:owner options:nil].firstObject;
    //    ChatNomalSmallEmotionView* view = [nibs objectAtIndex:0];
    
    
    view.pageView.numberOfPages = 0;
    view.pageView.currentPage = 0;
    
    view.pageScrollView.pagingEnabled = YES;
    view.pageScrollView.showsVerticalScrollIndicator = NO;
    view.pageScrollView.showsHorizontalScrollIndicator = NO;
    view.pageScrollView.delegate = view;
    
    view.emotionInputView = [ChatEmotionChooseView emotionChooseView:owner];
    
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
    
    NSInteger pageItemCount = self.defaultEmotionArray.count - lineCount;
    
    NSInteger page = pageItemCount / (lineCount * 2) + 1;
    if (page < 0) {
        page = 0;
    }
    
    self.pageView.numberOfPages = page + 1;
    self.pageView.currentPage = 0;
    
    self.emotionInputView.emotions = self.defaultEmotionArray;
    
    NSMutableArray *smallArray = [NSMutableArray array];
    for (NSInteger i = lineCount; i < self.defaultEmotionArray.count; i++) {
        [smallArray addObject:self.defaultEmotionArray[i]];
    }
    
    self.pageScrollView.contentSize = CGSizeMake(screenSize.width * 2, 0);
    
    self.emotionInputView.frame = CGRectMake(0, 0, screenSize.width, self.frame.size.height);
    [self.pageScrollView addSubview:self.emotionInputView];
    
//    self.smallEmotionView.frame = CGRectMake(screenSize.width, 0, screenSize.width, self.frame.size.height);
//    [self.pageScrollView addSubview:self.smallEmotionView];
}

- (void)reloadData {
    [self.emotionInputView reloadData];
//    [self.smallEmotionView reloadData];
}

- (void)pageScrollViewToTop
{
    [self.pageScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
//    [self.smallEmotionView.emotionCollectionView setContentOffset:CGPointMake(0, 0)];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatNormalSmallEmotionViewDidScroll:)]) {
        [self.delegate chatNormalSmallEmotionViewDidScroll:self];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = scrollView.frame.size.width;
    self.pageView.currentPage = scrollView.contentOffset.x / pageWidth;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatNormalSmallEmotionViewDidEndDecelerating:)]) {
        [self.delegate chatNormalSmallEmotionViewDidEndDecelerating:self];
    }
}

@end
