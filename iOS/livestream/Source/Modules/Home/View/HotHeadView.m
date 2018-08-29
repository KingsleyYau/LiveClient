//
//  HotHeadView.m
//  livestream
//
//  Created by Calvin on 2018/6/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HotHeadView.h"
#import "HotHeadViewCell.h"
#import "UnreadNumManager.h"
#import "GiftItemLayout.h"

@interface HotHeadView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UnreadNumManager *unreadManager;
@end

@implementation HotHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"HotHeadView" owner:self options:0].firstObject;
        self.frame = frame;
        self.unreadManager = [UnreadNumManager manager];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UINib *nib = [UINib nibWithNibName:@"HotHeadViewCell" bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[HotHeadViewCell cellIdentifier]];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)setIconArray:(NSArray *)iconArray {
    _iconArray = iconArray;
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = self.frame.size.width / _iconArray.count;
    CGFloat height = self.frame.size.height;
    layout.itemSize = CGSizeMake(width , height);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.collectionViewLayout = layout;
    
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.iconArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HotHeadViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HotHeadViewCell cellIdentifier] forIndexPath:indexPath];
    cell.iconImageView.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@",self.titleArray[indexPath.row]];
    if (indexPath.row != self.iconArray.count - 1) {
        NSInteger type = indexPath.row + 1;
        int unreadNum = [self.unreadManager getUnreadNum:(UnreadType)type];
        [cell setUnreadNum:unreadNum];
    } else {
        [cell setUnreadNum:0];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self.unreadManager setUnreadNum:(UnreadType)indexPath.row];
    [self.collectionView reloadData];
    
    if ([self.delagate respondsToSelector:@selector(didSelectHeadViewItemWithIndex:)]) {
        [self.delagate didSelectHeadViewItemWithIndex:indexPath.row];
    }
}


@end
