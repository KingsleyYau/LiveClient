//
//  FollowCollectionView.m
//  Hot
//
//  Created by lance on 2017/5/27.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "FollowCollectionView.h"
#import "FollowCollectionViewCell.h"
#import "FollowListItemObject.h"
#import "FileCacheManager.h"

@implementation FollowCollectionView
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
          [self initialize];
    }
    
    return self;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
    
    self.alwaysBounceVertical = YES;
    //注册cell
    [self registerNib:[UINib nibWithNibName:@"FollowCollectionViewCell" bundle:[NSBundle mainBundle]]  forCellWithReuseIdentifier:[FollowCollectionViewCell cellIdentifier]];
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.minimumLineSpacing = 5.0f;
    flow.minimumInteritemSpacing = 5.0f;
    flow.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5);
    
    self.collectionViewLayout = flow;

}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FollowCollectionViewCell *cell = (FollowCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[FollowCollectionViewCell cellIdentifier] forIndexPath:indexPath];

    // 数据填充
    // 数据填充
    FollowListItemObject *item = [self.items objectAtIndex:indexPath.item];
    

    
    // 头像
    [cell.imageViewContent setImage:nil];
    // 停止旧的
    if( cell.imageViewLoader ) {
        [cell.imageViewLoader stop];
    }
    // 创建新的
    cell.imageViewLoader = [ImageViewLoader loader];
    cell.imageViewLoader.view = cell.imageViewContent;
    cell.imageViewLoader.url = item.imageUrl;
    cell.imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:cell.imageViewLoader.url];
    [cell.imageViewLoader loadImage];
    
//    cell.imageViewLoader.sdWebImageView = cell.imageViewContent;
//    [cell.imageViewLoader loadImageWithOptions:SDWebImageRefreshCached placeholderImage:[UIImage imageNamed:@""]];
    
    
    cell.nameLabel.text = item.firstName;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}




- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemSize = (self.frame.size.width - 15)/2.0f;
    return CGSizeMake(itemSize, itemSize);
}

@end
