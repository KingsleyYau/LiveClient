//
//  LSDeliveryListTableViewCell.m
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSDeliveryListTableViewCell.h"
#import "LSDeliveryGiftCollectionViewCell.h"

@implementation LSDeliveryListTableViewCell

+ (NSString *)cellIdentifier {
    return @"LSDeliveryListTableViewCell";
}

+ (NSInteger)cellHeight {
    return 175;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSDeliveryListTableViewCell *cell = (LSDeliveryListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSDeliveryListTableViewCell cellIdentifier]];
    if (nil == cell) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSDeliveryListTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.imageViewLoader = [LSImageViewLoader loader];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.anchorIcon.layer.cornerRadius = cell.anchorIcon.frame.size.width * 0.5f;
        cell.anchorIcon.layer.masksToBounds = YES;
        cell.anchorIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(anchorIconTap:)];
        [cell.anchorIcon addGestureRecognizer:tap];
        
        UINib *giftViewNib = [UINib nibWithNibName:@"LSDeliveryGiftCollectionViewCell" bundle:[LiveBundle mainBundle]];
        [cell.giftListCollectionView registerNib:giftViewNib forCellWithReuseIdentifier:[LSDeliveryGiftCollectionViewCell cellIdentifier]];
        cell.giftListCollectionView.delaysContentTouches = NO;
        cell.giftListCollectionView.dataSource = cell;
        cell.giftListCollectionView.delegate = cell;
    
    }
    return cell;
}
- (IBAction)statusAction:(id)sender {
    if ([self.deliveryDelegate respondsToSelector:@selector(lsDeliveryListTableViewCellDidClickStatusAction:)]) {
        [self.deliveryDelegate lsDeliveryListTableViewCellDidClickStatusAction:self];
    }
}

- (void)anchorIconTap:(UITapGestureRecognizer *)gesture {
    if ([self.deliveryDelegate respondsToSelector:@selector(lsDeliveryListTableViewCellDidAnchorIcon:)]) {
        [self.deliveryDelegate lsDeliveryListTableViewCellDidAnchorIcon:self];
    }
}

- (void)setFrame:(CGRect)frame {
    frame.origin.y += 6;
    frame.size.height -= 6;
    [super setFrame:frame];
}


#pragma mark - 礼物商品列表
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.giftArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSDeliveryGiftCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSDeliveryGiftCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    if (indexPath.row < self.giftArray.count) {
        LSFlowerGiftBaseInfoItemObject *item = [self.giftArray objectAtIndex:indexPath.row];
        
        [cell.imageViewLoader stop];
        [cell.imageViewLoader loadImageWithImageView:cell.giftImageView
                                             options:0
                                            imageUrl:item.giftImg
                                    placeholderImage:[UIImage imageNamed:@""]
                                       finishHandler:nil];
        if (item.giftNumber > 1) {
            cell.giftCount.hidden = NO;
            [cell.giftCount setTitle:[NSString stringWithFormat:@"%d",item.giftNumber] forState:UIControlStateNormal];
            cell.giftCountWidth.constant = 15;
            if (item.giftNumber > 99) {
                cell.giftCountWidth.constant = 26;
                [cell.giftCount setTitle:@"99+" forState:UIControlStateNormal];
            }
        }else {
            cell.giftCount.hidden = YES;
            cell.giftCountWidth.constant = 15;
        }

    }

    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat sizeWidth = [LSDeliveryGiftCollectionViewCell cellWidth];
    return CGSizeMake(sizeWidth, sizeWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     LSFlowerGiftBaseInfoItemObject *item = [self.giftArray objectAtIndex:indexPath.row];
    if ([self.deliveryDelegate respondsToSelector:@selector(lsDeliveryListTableViewCell:didClickGiftInfo:)]) {
        [self.deliveryDelegate lsDeliveryListTableViewCell:self didClickGiftInfo:item];
    }
}
@end
