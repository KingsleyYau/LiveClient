//
//  GiftListWaterfallView.m
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftListWaterfallView.h"
#import "GiftListCell.h"
#import "LiveGiftDownloadManager.h"

@interface GiftListWaterfallView()
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;
@end

@implementation GiftListWaterfallView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
    
    self.alwaysBounceVertical = YES;
    //注册cell
    [self registerNib:[UINib nibWithNibName:@"GiftListCell" bundle:[LiveBundle mainBundle]]  forCellWithReuseIdentifier:[GiftListCell cellIdentifier]];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    
    self.giftDownloadManager = [LiveGiftDownloadManager manager];
}


#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GiftListCell *cell = (GiftListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[GiftListCell cellIdentifier] forIndexPath:indexPath];
    
    if (self.items.count > 0) {
        BackGiftItemObject * obj = [self.items objectAtIndex:indexPath.row];
        cell.unreadView.hidden = obj.read;
        cell.numLabel.text = [NSString stringWithFormat:@"%d",obj.num];
        
        cell.timeLabel.text = [NSString stringWithFormat:@"Use by:%@",[cell getTime:obj.expDate]];
        
       AllGiftItem *giftItem = [self.giftDownloadManager backGiftItemWithGiftID:obj.giftId];
        
        cell.giftNameLabel.text = giftItem.infoItem.name;
        
        [cell.imageViewLoader stop];
        if (!cell.imageViewLoader) {
            cell.imageViewLoader = [LSImageViewLoader loader];
        }
        [cell.imageViewLoader loadImageWithImageView:cell.giftImageView options:0 imageUrl:giftItem.infoItem.smallImgUrl placeholderImage:nil];
        
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc]init];
    if (kind == UICollectionElementKindSectionHeader){
        reusableview = [self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat w = (screenSize.width - 50)/3.0;
    return CGSizeMake(w, w);
}

@end
