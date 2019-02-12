//
//  ChatSmallEmotionView.m
//  dating
//
//  Created by test on 16/11/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatSmallEmotionView.h"
#import "QNChatSmallEmotionCollectionViewCell.h"



@interface QNChatSmallEmotionView()<UIScrollViewDelegate>
/** 当前页数 */
@property (nonatomic,assign) NSInteger curIndex;

@end

@implementation QNChatSmallEmotionView

+ (instancetype)chatSmallEmotionView:(id)owner {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"QNChatSmallEmotionView" owner:owner options:nil];
    QNChatSmallEmotionView* view = [nibs objectAtIndex:0];
    
    UINib *nib = [UINib nibWithNibName:@"QNChatSmallEmotionCollectionViewCell" bundle:[LiveBundle mainBundle]];
    [view.emotionCollectionView registerNib:nib forCellWithReuseIdentifier:[QNChatSmallEmotionCollectionViewCell cellIdentifier]];
    
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
//    self.pageView.numberOfPages = 0;
//    self.pageView.currentPage = 0;
    
    [self.emotionCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.smallEmotions.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 小高表cell
    QNChatSmallEmotionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[QNChatSmallEmotionCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    // 小高表模型
   QNChatSmallGradeEmotion  *item = [self.smallEmotions objectAtIndex:indexPath.item];
    cell.tag = indexPath.item;
    if( item.image ) {
        cell.imageView.image = item.image;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"LS_Chat_LargeEmotionDefault"];
    }
    
    
    // 刷新页数 小高表布局
    QNChatEmotionCreditsCollectionViewLayout *layout = (QNChatEmotionCreditsCollectionViewLayout *)self.emotionCollectionView.collectionViewLayout;
    if( self.pageView.numberOfPages != layout.pageCount ) {
        self.pageView.numberOfPages = layout.pageCount + 1 ;
    }
    CGFloat pageWidth = self.emotionCollectionView.frame.size.width;
    self.pageView.currentPage = self.emotionCollectionView.contentOffset.x / pageWidth + 1;
    

    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatSmallEmotionView:didSelectSmallEmotion:)]) {
        QNChatSmallGradeEmotion *item = [self.smallEmotions objectAtIndex:indexPath.item];
        [self.delegate chatSmallEmotionView:self didSelectSmallEmotion:item];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//     刷新选择分页
//    ChatEmotionCreditsCollectionViewLayout *layout = (ChatEmotionCreditsCollectionViewLayout *)self.emotionCollectionView.collectionViewLayout;
//    if( self.pageView.currentPage != layout.currentPage ) {
//        self.pageView.currentPage = layout.currentPage;
//    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatSmallEmotionView:currentPageNumber:)]) {
        QNChatEmotionCreditsCollectionViewLayout *layout = (QNChatEmotionCreditsCollectionViewLayout *)self.emotionCollectionView.collectionViewLayout;
        [self.delegate chatSmallEmotionView:self currentPageNumber:layout.currentPage];
    }
}

@end
