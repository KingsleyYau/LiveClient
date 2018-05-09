//
//  VIPAudienceView.m
//  livestream
//
//  Created by randy on 2017/9/28.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "VIPAudienceView.h"
#import "AudienceCell.h"
#import "LiveBundle.h"
#import "LSImageViewLoader.h"

#define ItemSize 40

@interface VIPAudienceView () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation VIPAudienceView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(ItemSize, ItemSize);
        //        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 6;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.bounces = NO;
        NSBundle *bundle = [LiveBundle mainBundle];
        UINib *nib = [UINib nibWithNibName:@"AudienceCell" bundle:bundle];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[AudienceCell cellIdentifier]];
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.collectionView];

        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Public Method
- (void)setAudienceArray:(NSMutableArray *)audienceArray {
    _audienceArray = audienceArray;
    BOOL haveID = NO;
//    for (int index = 0; index < audienceArray.count; index++) {
//        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:0];
//        AudienModel *model = audienceArray[index];
//        if (model.userId.length) {
//            haveID = YES;
//            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexpath]];
//        }
//    }
    if (!haveID) {
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.audienceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AudienceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[AudienceCell cellIdentifier] forIndexPath:indexPath];
//    [cell updateHeadImageWith:self.audienceArray[indexPath.row] radius:ItemSize];
    AudienModel *model = self.audienceArray[indexPath.row];
    cell.headImageView.layer.cornerRadius = ItemSize * 0.5;
    cell.headImageView.layer.masksToBounds = YES;
    
    if (!model.photoUrl.length) {
        [cell.headImageView setImage:model.image];
    } else {
//        [[LSImageViewLoader loader] refreshCachedImage:cell.headImageView options:SDWebImageRefreshCached imageUrl:model.photoUrl
//                            placeholderImage:model.image];
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:model.photoUrl] placeholderImage:model.image options:SDWebImageRefreshCached completed:nil];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(vipLiveAudidenveViewDidSelectItem:indexPath:)]) {
        [self.delegate vipLiveAudidenveViewDidSelectItem:self.audienceArray[indexPath.row] indexPath:indexPath];
    }
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

@end
