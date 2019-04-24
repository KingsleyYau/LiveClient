//
//  MyRidesWaterfallView.m
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MyRidesWaterfallView.h"

@implementation MyRidesWaterfallView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;

    self.alwaysBounceVertical = YES;
    //注册cell
    [self registerNib:[UINib nibWithNibName:@"MyRidesCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:[MyRidesCell cellIdentifier]];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyRidesCell *cell = (MyRidesCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[MyRidesCell cellIdentifier] forIndexPath:indexPath];
    cell.ridesBtn.tag = indexPath.row;
    cell.delegate = self;
    if (self.items.count > 0) {
        RideItemObject *obj = [self.items objectAtIndex:indexPath.row];

        cell.nameLabel.text = obj.name;

        cell.timeLabel.text = [NSString stringWithFormat:@"%@:\n%@ - %@", NSLocalizedString(@"Vaild_Time", @"Vaild_Time"), [cell getTime:obj.startValidDate], [cell getTime:obj.expDate]];

        [cell setRidesBtnBG:obj.isUse];

        [cell.imageViewLoader stop];
        if (!cell.imageViewLoader) {
            cell.imageViewLoader = [LSImageViewLoader loader];
        }
        [cell.imageViewLoader loadImageWithImageView:cell.imageView options:0 imageUrl:obj.photoUrl placeholderImage:nil finishHandler:nil];

        cell.unreadView.hidden = obj.read;
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    if (kind == UICollectionElementKindSectionHeader) {
        reusableview = [self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = (screenSize.width - 30) / 2.0;
    return CGSizeMake(w, w);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.items.count > 0) {
        RideItemObject *obj = [self.items objectAtIndex:indexPath.row];

        if ([self.delegates respondsToSelector:@selector(myRidesWaterfallViewDidRiesId:)]) {
            [self.delegates myRidesWaterfallViewDidRiesId:obj.isUse ? @"" : obj.rideId];
        }
    }
}

- (void)myRidesBtnDid:(NSInteger)row {
    if (self.items.count > 0) {
        RideItemObject *obj = [self.items objectAtIndex:row];

        if ([self.delegates respondsToSelector:@selector(myRidesWaterfallViewDidRiesId:)]) {
            [self.delegates myRidesWaterfallViewDidRiesId:obj.isUse ? @"" : obj.rideId];
        }
    }
}

@end
