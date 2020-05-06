//
//  LSStoreCollectionView.m
//  livestream
//
//  Created by Calvin on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSStoreCollectionView.h"
#import "LSStoreListCell.h"
#import "LSStoreListSectionView.h"
@interface LSStoreCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,LSStoreListCellDelegate>
@property (nonatomic, strong) LSStoreListSectionView * sectionView;
@property (nonatomic, assign) NSInteger lastcontentOffset; 
@end

@implementation LSStoreCollectionView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        UIView *containerView = [[LiveBundle mainBundle] loadNibNamed:@"LSStoreCollectionView" owner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.isUpScroll = YES;
    
    //注册cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"LSStoreListCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:[LSStoreListCell cellIdentifier]];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"LSStoreListSectionView"];
    
    self.collectionView.backgroundColor = [LSColor colorWithLight:[UIColor whiteColor] orDark:COLOR_WITH_16BAND_RGB(0x666666)];
}

- (void)reloadData {
     
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.items.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    LSStoreFlowerGiftItemObject * item = self.items[section];
    return item.giftList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *result = [[UICollectionViewCell alloc] init];
    // 防止数组越界判断
    if (indexPath.section < self.items.count) {
        LSStoreFlowerGiftItemObject * item = self.items[indexPath.section];
        // 防止数组越界判断
        if (indexPath.row < item.giftList.count) {
            LSFlowerGiftItemObject * data = item.giftList[indexPath.row];

            LSStoreListCell *cell = (LSStoreListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[LSStoreListCell cellIdentifier] forIndexPath:indexPath];
                result = cell;
            cell.addBtn.tag = cell.tag;
            cell.cellDelegate = self;
            [cell uploadUI:data];
        }
    }
    
    return result;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:didSelectItem:)]) {
        LSStoreFlowerGiftItemObject * item = self.items[indexPath.section];
        [self.collectionViewDelegate waterfallView:self didSelectItem:item.giftList[indexPath.row]];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [[UICollectionReusableView alloc] init];
    if (kind == UICollectionElementKindSectionHeader) {
        view = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"LSStoreListSectionView" forIndexPath:indexPath];
        self.sectionView = [[LSStoreListSectionView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 44)];
        [view addSubview:self.sectionView];
        LSStoreFlowerGiftItemObject * item = self.items[indexPath.section];
        [self.sectionView  updateContent:item.typeName isShowFreeCard:item.isHasGreeting];
    }
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (elementKind == UICollectionElementKindSectionHeader) {
        if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:willDisplaySupplementaryViewAtIndexPath:)]) {
            [self.collectionViewDelegate waterfallView:self willDisplaySupplementaryViewAtIndexPath:indexPath];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (elementKind == UICollectionElementKindSectionHeader) {
        if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:didEndDisplayingSupplementaryViewAtIndexPath:)]) {
            [self.collectionViewDelegate waterfallView:self didEndDisplayingSupplementaryViewAtIndexPath:indexPath];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeZero;
    }
    return CGSizeMake(screenSize.width, 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat w = (screenSize.width - 50) / 2.0;
    CGFloat h = w + 53;
    return CGSizeMake(w, h);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat bottom = section == self.items.count - 1 ? 80 : 0;
    return UIEdgeInsetsMake(10, 20, bottom, 20);
}

#pragma mark - 滚动界面回调 (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 
    CGFloat hight = scrollView.frame.size.height;
       CGFloat contentOffset = scrollView.contentOffset.y;
       CGFloat distanceFromBottom = scrollView.contentSize.height - contentOffset;
       CGFloat offset = contentOffset - self.lastcontentOffset;
       self.lastcontentOffset = contentOffset;
       
       if (offset > 0 && contentOffset > 0) {
           self.isUpScroll = YES;
       }
       if (offset < 0 && distanceFromBottom > hight) {
           self.isUpScroll = NO;
       }
    
    if (self.items.count > 0 && self.collectionView.contentOffset.y <= 0)
    {
        if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallViewLoadHeadViw)]) {
            [self.collectionViewDelegate waterfallViewLoadHeadViw];
        }
    }
}

 
- (void)stroeListCellAddCartBtnDid:(NSString *)giftId forImageView:(UIImageView *)imageView{
    
    if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:addCart:forImageView:)]) {
        [self.collectionViewDelegate waterfallView:self addCart:giftId forImageView:imageView];
    }
}
@end
