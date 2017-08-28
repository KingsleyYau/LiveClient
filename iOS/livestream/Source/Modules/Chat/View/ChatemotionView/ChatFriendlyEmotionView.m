//
//  ChatFriendlyEmotionView.m
//  livestream
//
//  Created by randy on 2017/8/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ChatFriendlyEmotionView.h"
#import "ChatEmotionChooseCollectionViewCell.h"

@interface ChatFriendlyEmotionView ()


@end

@implementation ChatFriendlyEmotionView

+ (instancetype)friendlyEmotionView:(id)owner {
    
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"ChatFriendlyEmotionView" owner:owner options:nil];
    ChatFriendlyEmotionView* view = [nibs objectAtIndex:0];
    
    UINib *nib = [UINib nibWithNibName:@"ChatEmotionChooseCollectionViewCell" bundle:nil];
    [view.emotionCollectionView registerNib:nib forCellWithReuseIdentifier:[ChatEmotionChooseCollectionViewCell cellIdentifier]];
    
    view.pageView.numberOfPages = 0;
    view.pageView.currentPage = 0;
    
    return view;
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
    
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(chatFriendlyEmotionView:didSelectNomalItem:)] ) {
        [self.delegate chatFriendlyEmotionView:self didSelectNomalItem:indexPath.item];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 刷新选择分页
    ChatEmotionChooseCollectionViewLayout *layout = (ChatEmotionChooseCollectionViewLayout *)self.emotionCollectionView.collectionViewLayout;
    if( self.pageView.currentPage != layout.currentPage ) {
        self.pageView.currentPage = layout.currentPage;
    }
    
}

- (void)friendlyIsImpove:(BOOL)isImpove {
    
    self.tipView.hidden = isImpove;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
