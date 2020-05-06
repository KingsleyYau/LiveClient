//
//  LSPhizCollectionView.m
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSNormalPhizCollectionView.h"
#import "LSVIPLivePhizCell.h"
#import "LiveBundle.h"

@interface LSNormalPhizCollectionView ()<LSChatEmotionManagerDelegate>

@property (nonatomic, strong) LSChatEmotionManager *emotionManager;

@end

@implementation LSNormalPhizCollectionView
+ (instancetype)emotionChooseView:(id)owner {
    NSBundle *bundle = [LiveBundle mainBundle];
    NSArray *nibs = [bundle loadNibNamedWithFamily:@"LSNormalPhizCollectionView" owner:owner options:nil];
    LSNormalPhizCollectionView* view = [nibs objectAtIndex:0];
    
    UINib *nib = [UINib nibWithNibName:@"LSVIPLivePhizCell" bundle:bundle];
    [view.emotionCollectionView registerNib:nib forCellWithReuseIdentifier:[LSVIPLivePhizCell cellIdentifier]];
    
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
    
     LSVIPLivePhizCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                         [LSVIPLivePhizCell cellIdentifier] forIndexPath:indexPath];
    
    ChatEmotionItem *emotionItem = self.stanListItem.emoList[indexPath.row];
    
    if (self.emotionManager.stanEmotionList.count > 0) {
        for (LSChatEmotion *item in self.emotionManager.stanEmotionList) {
            if ( [item.text isEqualToString:emotionItem.emoSign] ) {
                
                if (item.image) {
                    cell.imageView.image = item.image;
                } else {
                    cell.imageView.image = [UIImage imageNamed:@"Live_Emotion_Nomal"];
                }
                break;
            }
        }
    }
    

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(liveStandardEmotionView:didSelectNomalItem:)] ) {
        [self.delegate liveStandardEmotionView:self didSelectNomalItem:indexPath.item];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int totalNum = SCREEN_WIDTH / 29;
    int num = totalNum - 5;
    CGFloat w = SCREEN_WIDTH / num;
    return CGSizeMake(w, w);
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
