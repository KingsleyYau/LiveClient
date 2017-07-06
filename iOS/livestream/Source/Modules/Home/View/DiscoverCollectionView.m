//
//  DiscoverCollectionView.h
//  livestream
//
//  Created by lance on 2017/5/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DiscoverCollectionView.h"
#import "DiscoverCollectionViewCell.h"
#import "DiscoverHeaderView.h"
#import "DiscoverListItemObject.h"
#import "FileCacheManager.h"

@implementation DiscoverCollectionView

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
    [self registerNib:[UINib nibWithNibName:@"DiscoverCollectionViewCell" bundle:[NSBundle mainBundle]]  forCellWithReuseIdentifier:[DiscoverCollectionViewCell cellIdentifier]];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
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
    DiscoverCollectionViewCell *cell = (DiscoverCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[DiscoverCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    // 数据填充
    // 数据填充
    DiscoverListItemObject *item = [self.items objectAtIndex:indexPath.item];
    
    [cell.imageCoverView setImage:nil];
    // 创建新的
    cell.imageViewLoader = [ImageViewLoader loader];
    [cell.imageViewLoader loadImageWithImageView:cell.imageCoverView options:0 imageUrl:item.imageUrl
                                placeholderImage:[UIImage imageNamed:@""]];
    
    cell.personName.text = item.firstName;
    cell.personDetail.text = @"1234 online";
    
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(34, 34);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        reusableview = [self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        DiscoverHeaderView *headerView = [DiscoverHeaderView initDiscoverHeaderViewXib];
        [reusableview addSubview:headerView];
      
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemSize = (self.frame.size.width - 20)/3.0f;
    return CGSizeMake(itemSize, itemSize + 47);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 禁止头部的弹簧效果
    NSInteger y = scrollView.contentOffset.y;
    if (y <= 0) {
        CGPoint offset = scrollView.contentOffset;
        offset.y = 0;
        scrollView.contentOffset = offset;
    }
}
@end
