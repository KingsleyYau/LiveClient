//
//  LSLiveAdvancedEmotionView.m
//  livestream
//
//  Created by randy on 2017/8/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSLiveAdvancedEmotionView.h"
#import "LSEmotionCollectionViewCell.h"
#import "LiveBundle.h"

@interface LSLiveAdvancedEmotionView ()<LSChatEmotionManagerDelegate>

@property (nonatomic, strong) LSChatEmotionManager *emotionManager;
@end

@implementation LSLiveAdvancedEmotionView

+ (instancetype)friendlyEmotionView:(id)owner {
    NSBundle *bundle = [LiveBundle mainBundle];
    NSArray *nibs = [bundle loadNibNamedWithFamily:@"LSLiveAdvancedEmotionView" owner:owner options:nil];
    LSLiveAdvancedEmotionView* view = [nibs objectAtIndex:0];
    
    UINib *nib = [UINib nibWithNibName:@"LSEmotionCollectionViewCell" bundle:bundle];
    [view.emotionCollectionView registerNib:nib forCellWithReuseIdentifier:[LSEmotionCollectionViewCell cellIdentifier]];
    
    view.pageView.numberOfPages = 0;
    view.pageView.currentPage = 0;
    view.emotionManager = [LSChatEmotionManager emotionManager];
    view.emotionManager.delegate = view;
    
    return view;
}


- (void)reloadData {
    [self.emotionCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.advanListItem.emoList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                                 [LSEmotionCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    ChatEmotionItem *emotionItem = self.advanListItem.emoList[indexPath.row];
    
    if (self.emotionManager.advanEmotionList.count > 0) {
        for (LSChatEmotion *item in self.emotionManager.advanEmotionList) {
            if ([item.text isEqualToString:emotionItem.emoSign]) {
                
                if (item.image) {
                    cell.imageView.image = item.image;
                } else {
                    cell.imageView.image = [UIImage imageNamed:@"Live_Emotion_Nomal"];
                }
            }
        }
    }

    LSEmotionCollectionViewLayout *layout = (LSEmotionCollectionViewLayout *)self.emotionCollectionView.collectionViewLayout;
    if( self.pageView.numberOfPages != layout.pageCount ) {
        self.pageView.numberOfPages = layout.pageCount;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(LSLiveAdvancedEmotionView:didSelectNomalItem:)] ) {
        [self.delegate LSLiveAdvancedEmotionView:self didSelectNomalItem:indexPath.item];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 刷新选择分页
    LSEmotionCollectionViewLayout *layout = (LSEmotionCollectionViewLayout *)self.emotionCollectionView.collectionViewLayout;
    if( self.pageView.currentPage != layout.currentPage ) {
        self.pageView.currentPage = layout.currentPage;
    }
    
}

#pragma mark - LSChatEmotionManagerDelegate
- (void)downLoadAdvanListFinshHandle:(NSInteger)index {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSIndexPath *lastPath = [[self.emotionCollectionView indexPathsForVisibleItems] lastObject];
    if (lastPath.row > index) {
        [self.emotionCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
    }
}

- (void)downLoadStanListFinshHandle:(NSInteger)index {
}

- (void)friendlyIsImpove:(BOOL)isImpove {
    
    self.tipView.hidden = isImpove;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
