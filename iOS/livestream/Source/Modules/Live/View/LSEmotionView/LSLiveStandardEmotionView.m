//
//  LSLiveStandardEmotionView.m
//  dating
//
//  Created by Max on 16/5/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSLiveStandardEmotionView.h"
#import "LSEmotionCollectionViewCell.h"
#import "LiveBundle.h"

@interface LSLiveStandardEmotionView()<LSChatEmotionManagerDelegate>

@property (nonatomic, strong) LSChatEmotionManager *emotionManager;
@end

@implementation LSLiveStandardEmotionView 

+ (instancetype)emotionChooseView:(id)owner {
    NSBundle *bundle = [LiveBundle mainBundle];
    NSArray *nibs = [bundle loadNibNamedWithFamily:@"LSLiveStandardEmotionView" owner:owner options:nil];
    LSLiveStandardEmotionView* view = [nibs objectAtIndex:0];
    
    UINib *nib = [UINib nibWithNibName:@"LSEmotionCollectionViewCell" bundle:bundle];
    [view.emotionCollectionView registerNib:nib forCellWithReuseIdentifier:[LSEmotionCollectionViewCell cellIdentifier]];
    
    view.pageView.numberOfPages = 0;
    view.pageView.currentPage = 0;
    
    view.tipView.hidden = YES;
    view.emotionManager = [LSChatEmotionManager emotionManager];
    view.emotionManager.delegate = view;
    
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
    
    return self.stanListItem.emoList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSEmotionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                                 [LSEmotionCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    ChatEmotionItem *emotionItem = self.stanListItem.emoList[indexPath.row];
    
    if (self.emotionManager.stanEmotionList.count > 0) {
        for (LSChatEmotion *item in self.emotionManager.stanEmotionList) {
            if ( [item.text isEqualToString:emotionItem.emoSign] ) {
                
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
    
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(LSLiveStandardEmotionView:didSelectNomalItem:)] ) {
        [self.delegate LSLiveStandardEmotionView:self didSelectNomalItem:indexPath.item];
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
- (void)downLoadStanListFinshHandle:(NSInteger)index {
    
    if (self.stanListItem.emoList.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.emotionCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
    }
}

- (void)downLoadAdvanListFinshHandle:(NSInteger)index{
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
