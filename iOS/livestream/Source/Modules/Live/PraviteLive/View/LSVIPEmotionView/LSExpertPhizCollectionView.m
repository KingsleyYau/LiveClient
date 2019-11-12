//
//  LSExpertPhizCollectionView.m
//  livestream
//
//  Created by Calvin on 2019/9/3.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSExpertPhizCollectionView.h"
#import "LSVIPLivePhizCell.h"
#import "LiveBundle.h"
@interface LSExpertPhizCollectionView ()<LSChatEmotionManagerDelegate>
@property (nonatomic, strong) LSChatEmotionManager *emotionManager;
@end

@implementation LSExpertPhizCollectionView

+ (instancetype)friendlyEmotionView:(id)owner {
    NSBundle *bundle = [LiveBundle mainBundle];
    NSArray *nibs = [bundle loadNibNamedWithFamily:@"LSExpertPhizCollectionView" owner:owner options:nil];
    LSExpertPhizCollectionView* view = [nibs objectAtIndex:0];
    
    UINib *nib = [UINib nibWithNibName:@"LSVIPLivePhizCell" bundle:bundle];
    [view.emotionCollectionView registerNib:nib forCellWithReuseIdentifier:[LSVIPLivePhizCell cellIdentifier]];
    
  
    view.emotionManager = [LSChatEmotionManager emotionManager];
    view.emotionManager.delegate = view;
    
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tipBGView.layer.cornerRadius = 4;
    self.tipBGView.layer.masksToBounds = YES;
}


- (void)reloadData {
    [self.emotionCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.advanListItem.emoList.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSVIPLivePhizCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                         [LSVIPLivePhizCell cellIdentifier] forIndexPath:indexPath];
    if (self.isCanSend) {
        cell.alpha = 1;
    }else {
        cell.alpha = 0.5;
    }
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
 
    
    return cell;
}

- (void)setIsCanSend:(BOOL)isCanSend {
    _isCanSend = isCanSend;
    [self.emotionCollectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.isCanSend) {
        self.tipBGView.hidden = NO;
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:3 animations:^{
            self.tipBGView.alpha = 0;
        }completion:^(BOOL finished) {
            self.tipBGView.alpha = 1;
            self.tipBGView.hidden = YES;
            self.userInteractionEnabled = YES;
        }];
        return;
    }
    
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(liveAdvancedEmotionView:didSelectNomalItem:)] ) {
        [self.delegate liveAdvancedEmotionView:self didSelectNomalItem:indexPath.item];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int totalNum = SCREEN_WIDTH / 29;
    int num = totalNum - 5;
    CGFloat w = SCREEN_WIDTH / num;
    return CGSizeMake(w, w);
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

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
