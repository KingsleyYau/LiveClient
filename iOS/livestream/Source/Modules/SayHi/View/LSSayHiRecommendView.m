//
//  LSSayHiRecommendCollectionView.m
//  livestream
//
//  Created by test on 2019/4/28.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiRecommendView.h"
#import "LSSayHiRecommendViewCell.h"

@implementation LSSayHiRecommendView


- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
    //注册cell
    [self registerNib:[UINib nibWithNibName:@"LSSayHiRecommendViewCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:[LSSayHiRecommendViewCell cellIdentifier]];
    

}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // 最多显示2个,暂时不会低于2个
    NSInteger count = 0;
    if (self.items.count > 0) {
        count = 2;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *result = [[UICollectionViewCell alloc] init];
    if (indexPath.row < self.items.count) {
        LSSayHiAnchorItemObject *item = [self.items objectAtIndex:indexPath.row];
        LSSayHiRecommendViewCell *cell = (LSSayHiRecommendViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[LSSayHiRecommendViewCell cellIdentifier] forIndexPath:indexPath];
        result = cell;
        cell.anchorName.text = item.nickName;
        [cell.imageViewLoader stop];
        [cell.imageViewLoader loadImageWithImageView:cell.anchorPhoto options:0 imageUrl:item.coverImg placeholderImage:[UIImage imageNamed:@"" ] finishHandler:nil];
        if (item.onlineStatus == ONLINE_STATUS_LIVE) {
            cell.onlineImageView.hidden = NO;
            if (item.roomType == HTTPROOMTYPE_FREEPUBLICLIVEROOM || item.roomType == HTTPROOMTYPE_CHARGEPUBLICLIVEROOM) {
                cell.statusView.hidden = NO;
                cell.onlineImageView.hidden = YES;
                NSMutableArray *animationVIPPublicRTArray = [NSMutableArray array];
                for (int i = 1; i <= 3; i++) {
                    NSString *imageName = [NSString stringWithFormat:@"Home_HotAndFollow_ImageView_Live%d", i];
                    UIImage *image = [UIImage imageNamed:imageName];
                    [animationVIPPublicRTArray addObject:image];
                }
                cell.statusImageView.animationImages = animationVIPPublicRTArray;
                cell.statusImageView.animationRepeatCount = 0;
                cell.statusImageView.animationDuration = 0.6;
                [cell.statusImageView startAnimating];
                
            }else {
                cell.statusView.hidden = YES;
            }
        }else {
            cell.onlineImageView.hidden = YES;
            cell.statusView.hidden = YES;
        }
        
    }
   
    return result;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = [LSSayHiRecommendViewCell cellWidth];
    CGFloat h = self.frame.size.height;
    return CGSizeMake(w,h);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.items.count) {
        LSSayHiAnchorItemObject *item = [self.items objectAtIndex:indexPath.row];
        if ([self.recommendDelegate respondsToSelector:@selector(lsSayHiRecommendView:didSelectAchor:)]) {
            [self.recommendDelegate lsSayHiRecommendView:self didSelectAchor:item];
        }
    }
}

@end
