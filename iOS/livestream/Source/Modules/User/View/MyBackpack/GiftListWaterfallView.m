//
//  GiftListWaterfallView.m
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftListWaterfallView.h"
#import "GiftListCell.h"
#import "LSGiftManager.h"

@interface GiftListWaterfallView()
@property (nonatomic, strong) LSGiftManager *giftDownloadManager;
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
    
    self.giftDownloadManager = [LSGiftManager manager];
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
        if (obj.num > 999) {
            cell.numLabel.text = @"x999+";
        }
        else
        {
         cell.numLabel.text = [NSString stringWithFormat:@"x %d",obj.num];
        }
        
        
        cell.timeLabel.text = [NSString stringWithFormat:@"%@:\n%@ - %@",NSLocalizedString(@"Vaild_Time", @"Vaild_Time"),[cell getTime:obj.startValidDate],[cell getTime:obj.expDate]];
        
       LSGiftManagerItem *giftItem = [self.giftDownloadManager getGiftItemWithId:obj.giftId];
        
        cell.giftNameLabel.text = giftItem.infoItem.name;
        
        [cell.imageViewLoader stop];
        if (!cell.imageViewLoader) {
            cell.imageViewLoader = [LSImageViewLoader loader];
        }
        [cell.imageViewLoader loadImageWithImageView:cell.giftImageView options:0 imageUrl:giftItem.infoItem.bigImgUrl placeholderImage:nil];
        
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
    CGFloat w = (screenSize.width - 30)/2.0;
    return CGSizeMake(w, w * 0.78);
}

@end
