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
#import "LSFileCacheManager.h"
#import "LiveBundle.h"
//#import "LiveChannelView.h"
//#import "LiveChannelBottomView.h"
static NSString *headerViewIdentifier = @"headerView";
static NSString *footerViewIdentifier = @"footerView";
@implementation FollowCollectionView
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self initialize];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
    NSBundle *bundle = [LiveBundle mainBundle];
    [self registerNib:[UINib nibWithNibName:@"FollowCollectionViewCell" bundle:bundle] forCellWithReuseIdentifier:[FollowCollectionViewCell cellIdentifier]];
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.minimumLineSpacing = 5.0f;
    flow.minimumInteritemSpacing = 5.0f;
    flow.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5);
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerViewIdentifier];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerViewIdentifier];
    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LiveChannel_DownBackground"]];
    self.backgroundView = imageV;
    self.collectionViewLayout = flow;
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //    return self.items.count;
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    FollowCollectionViewCell *cell = (FollowCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[FollowCollectionViewCell cellIdentifier] forIndexPath:indexPath];

    // 数据填充
    // 数据填充
    //    FollowListItemObject *item = [self.items objectAtIndex:indexPath.item];

    //    // 头像
    //    [cell.imageViewContent setImage:nil];
    //    // 创建新的
    //    cell.imageViewLoader = [LSImageViewLoader loader];
    //    [cell.imageViewLoader loadImageWithImageView:cell.imageViewContent options:0 imageUrl:item.imageUrl
    //                                placeholderImage:[UIImage imageNamed:@""]];
    //
    //    cell.nameLabel.text = item.firstName;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemSize = (self.frame.size.width - 15) / 2.0f;
    return CGSizeMake(itemSize, itemSize);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    //如果是头视图
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
        //        //添加头视图的内容
        //        UIView *vc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 414, 100)];
        //        vc.backgroundColor = [UIColor cyanColor];
        //
        //        UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        //        btn.center = vc.center;
        //        [vc addSubview: btn];
        //        LiveChannelView *vc = [LiveChannelView initLiveChannelViewXib];
        //        [header addSubview:vc];
        return header;
    }
    //如果底部视图
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        //            LiveChannelBottomView *vc = [LiveChannelBottomView LiveChannelBottomViewXib];
        //                 UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerViewIdentifier forIndexPath:indexPath];
        //            [footer addSubview:vc];
        //            return footer;
    }
    return nil;
}

//执行的 headerView 代理 返回 headerView 的高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {

    return CGSizeMake(screenSize.width, 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {

    return CGSizeMake(screenSize.width, 44);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.items.count > 0) {
        return UIEdgeInsetsMake(5, 5, 5, 5);
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return UIEdgeInsetsMake(0, 0,0, 0);
}


@end
