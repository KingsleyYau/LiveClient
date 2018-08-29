//
//  GiftStatisticsView.m
//  livestream
//
//  Created by Randy_Fan on 2018/4/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "GiftStatisticsView.h"
#import "GiftStatisticsViewCell.h"
#import "LiveBundle.h"
#import "LSImageViewLoader.h"
#import "LSImManager.h"
#import "LSGiftManager.h"

@interface GiftStatisticsView () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) LSGiftManager *giftDownloadManager;

@end

@implementation GiftStatisticsView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(32, 32);
        layout.minimumLineSpacing = 4;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.bounces = NO;
        NSBundle *bundle = [LiveBundle mainBundle];
        UINib *nib = [UINib nibWithNibName:@"GiftStatisticsViewCell" bundle:bundle];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[GiftStatisticsViewCell cellIdentifier]];
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.giftDownloadManager = [LSGiftManager manager];
    }
    return self;
}

#pragma mark - Public Method
- (void)reloadGiftCount {
    [self.collectionView reloadData];
}

- (void)setGiftCountArray:(NSMutableArray *)giftCountArray {
    _giftCountArray = giftCountArray;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftCountArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GiftStatisticsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GiftStatisticsViewCell cellIdentifier] forIndexPath:indexPath];
    IMGiftNumItemObject *obj = self.giftCountArray[indexPath.row];
    LSGiftManagerItem *item = [self.giftDownloadManager getGiftItemWithId:obj.giftId];
    [cell updataCellViewItem:item num:obj.giftNum];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    [self.delegate liveAudidenceView:self didTapHeadWithObject:self.audienceArray[indexPath.row]];
}

#pragma mark - UIScrollViewDelegate

//刷到底部
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    CGPoint offset = scrollView.contentOffset;  // 当前滚动位移
    //    CGRect bounds = scrollView.bounds;          // UIScrollView 可视宽度
    //    CGSize size = scrollView.contentSize;         // 滚动区域
    //    UIEdgeInsets inset = scrollView.contentInset;
    //    float x = offset.x + bounds.size.width - inset.right;
    //    float w = size.width;
    //    float reload_distance = 10;
    //    if (x > w + reload_distance) {
    //        [self.delegate liveLoadingAudienceView:self];
    //    }
    //
    //    [self.delegate liveAudidenveViewDidScroll];
}

//停在第一页
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        //这里写上停止时要执行的代码
        CGPoint offset = scrollView.contentOffset; // 当前滚动位移
        if (offset.x == 0) {
            [self.delegate vipLiveReloadAudidenceView:self];
        }
    }
}

//停在第一页
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset; // 当前滚动位移
    if (offset.x == 0) {
        [self.delegate vipLiveReloadAudidenceView:self];
    }
    [self.delegate vipLiveAudidenveViewDidEndScrolling];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self.delegate vipLiveAudidenveViewDidEndScrolling];
}

@end
