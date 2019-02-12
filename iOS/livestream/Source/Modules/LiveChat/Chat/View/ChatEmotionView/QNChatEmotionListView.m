//
//  ChatEmotionListView.m
//  dating
//
//  Created by test on 16/9/6.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatEmotionListView.h"
#import "ChatEmotionCreditsCollectionViewCell.h"
#import "ChatEmotionCreditsCollectionViewLayout.h"

@interface QNChatEmotionListView()<UIScrollViewDelegate, ChatEmotionCreditsCollectionViewCellDelegate>
@property (assign) NSInteger curIndex;
@end


@implementation QNChatEmotionListView

+ (instancetype)emotionListView:(id)owner {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"ChatEmotionListView" owner:owner options:nil];
    QNChatEmotionListView* view = [nibs objectAtIndex:0];

    UINib *nib = [UINib nibWithNibName:@"ChatEmotionCreditsCollectionViewCell" bundle:[LiveBundle mainBundle]];
    [view.emotionCollectionView registerNib:nib forCellWithReuseIdentifier:[ChatEmotionCreditsCollectionViewCell cellIdentifier]];
    
    //    ChatEmotionLargeViewFlowLayout *largeFlowLayout = [[ChatEmotionLargeViewFlowLayout alloc] init];
    //    view.emotionList.collectionViewLayout = largeFlowLayout;
//    ChatEmotionCreditsCollectionViewLayout *layout = (ChatEmotionCreditsCollectionViewLayout *)view.emotionCollectionView.collectionViewLayout;
    
    view.pageView.numberOfPages = 0;
    view.pageView.currentPage = 0;
//    
//    UIScrollView* scrollView = view.emotionCollectionView;
//    scrollView.delegate = self;
    
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.creditsTip sizeToFit];
}

- (void)reloadData {

    [self.emotionCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.largeEmotions.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChatEmotionCreditsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ChatEmotionCreditsCollectionViewCell cellIdentifier] forIndexPath:indexPath];

    QNChatHighGradeEmotion *item = [self.largeEmotions objectAtIndex:indexPath.item];
    cell.tag = indexPath.item;
    if( item.image ) {
        cell.largeEmotionImageView.image = item.image;
    } else {
        cell.largeEmotionImageView.image = [UIImage imageNamed:@"LS_Chat_LargeEmotionDefault"];
    }
    cell.creditPrice.text = item.priceText;
    cell.delegate = self;
    
    // 刷新页数
    ChatEmotionCreditsCollectionViewLayout *layout = (ChatEmotionCreditsCollectionViewLayout *)self.emotionCollectionView.collectionViewLayout;
    if( self.pageView.numberOfPages != layout.pageCount ) {
        self.pageView.numberOfPages = layout.pageCount;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatEmotionListView:didSelectLargeEmotion:)]) {
        QNChatHighGradeEmotion *item = [self.largeEmotions objectAtIndex:indexPath.item];
        [self.delegate chatEmotionListView:self didSelectLargeEmotion:item];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - 长按手势回调
- (void)ChatEmotionCreditsCollectionViewCellDidLongPress:(ChatEmotionCreditsCollectionViewCell *)cell gesture:(UILongPressGestureRecognizer *)gesture {
    QNChatHighGradeEmotion *item = nil;
    
    // 取出当前显示的cell
    NSArray <ChatEmotionCreditsCollectionViewCell *>*currentCells =  [self.emotionCollectionView visibleCells];
    for (ChatEmotionCreditsCollectionViewCell *cell in currentCells) {
        // 获取手势在ChatEmotionCreditsCollectionViewCell的响应点
        CGPoint location  = [gesture locationInView:gesture.view.superview];
        // 当前的cell存在响应点,将当前cell的内容传递到显示的view
        if (CGRectContainsPoint(cell.frame, location)) {
            item = [self.largeEmotions objectAtIndex:cell.tag];
            
            switch (gesture.state) {
                case UIGestureRecognizerStateBegan:
                case UIGestureRecognizerStateChanged: {
                    // 根据记录手势,防止重复再当前手势坐标内调用多次
                    if( self.curIndex != cell.tag ) {
                        self.curIndex = cell.tag;
                        if (self.delegate && [self.delegate respondsToSelector:@selector(chatEmotionListView:didLongPressLargeEmotion:)]) {
                            [self.delegate chatEmotionListView:self didLongPressLargeEmotion:item];
                        }
                    }
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    switch (gesture.state) {
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatEmotionListView:didLongPressReleaseLargeEmotion:)]) {
                [self.delegate chatEmotionListView:self didLongPressReleaseLargeEmotion:item];
            }
            self.curIndex = -1;
            break;
        default:
            break;
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 刷新选择分页
    ChatEmotionCreditsCollectionViewLayout *layout = (ChatEmotionCreditsCollectionViewLayout *)self.emotionCollectionView.collectionViewLayout;
    if( self.pageView.currentPage != layout.currentPage ) {
        self.pageView.currentPage = layout.currentPage;
        
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(chatEmotionListView:currentPageNumber:)])
        {
            [self.delegate chatEmotionListView:self currentPageNumber:self.pageView.currentPage];
        }
    }
}

@end
