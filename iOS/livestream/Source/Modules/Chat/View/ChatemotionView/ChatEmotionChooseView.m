//
//  ChatEmotionChooseView.m
//  dating
//
//  Created by Max on 16/5/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatEmotionChooseView.h"
#import "ChatEmotionChooseCollectionViewCell.h"

@implementation ChatEmotionChooseView 

+ (instancetype)emotionChooseView:(id)owner {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"ChatEmotionChooseView" owner:owner options:nil];
    ChatEmotionChooseView* view = [nibs objectAtIndex:0];
        
    UINib *nib = [UINib nibWithNibName:@"ChatEmotionChooseCollectionViewCell" bundle:nil];
    [view.emotionCollectionView registerNib:nib forCellWithReuseIdentifier:[ChatEmotionChooseCollectionViewCell cellIdentifier]];
    
    view.pageView.numberOfPages = 0;
    view.pageView.currentPage = 0;
    
    view.tipView.hidden = YES;
    
    return view;
}

- (void)isHaveStandard:(BOOL)isHave tipString:(NSString *)str {
    
    self.tipView.hidden = isHave;
    if (str) {
        self.tipLabel.text = str;
    }
}


- (void)reloadData {
    [self.emotionCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.emotions.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatEmotionChooseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                                 [ChatEmotionChooseCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    ChatEmotion* item = [self.emotions objectAtIndex:indexPath.item];
    cell.imageView.image = item.image;
    
    ChatEmotionChooseCollectionViewLayout *layout = (ChatEmotionChooseCollectionViewLayout *)self.emotionCollectionView.collectionViewLayout;
    if( self.pageView.numberOfPages != layout.pageCount ) {
        self.pageView.numberOfPages = layout.pageCount;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(chatEmotionChooseView:didSelectNomalItem:)] ) {
        [self.delegate chatEmotionChooseView:self didSelectNomalItem:indexPath.item];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 刷新选择分页
    ChatEmotionChooseCollectionViewLayout *layout = (ChatEmotionChooseCollectionViewLayout *)self.emotionCollectionView.collectionViewLayout;
    if( self.pageView.currentPage != layout.currentPage ) {
        self.pageView.currentPage = layout.currentPage;
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
