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
//        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
//        self.collectionView.dataSource = self;
//        self.collectionView.delegate = self;
//        self.collectionView.showsHorizontalScrollIndicator = NO;
//        self.collectionView.bounces = NO;
//        NSBundle *bundle = [LiveBundle mainBundle];
//        UINib *nib = [UINib nibWithNibName:@"AudienceCell" bundle:bundle];
//        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[AudienceCell cellIdentifier]];
//        self.collectionView.backgroundColor = [UIColor clearColor];
//        [self addSubview:self.collectionView];

        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)updateUserInfo {
    
    [self removeAllSubviews];
    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.userInteractionEnabled = YES;
    [self addSubview:scrollView];
    for (int i = 0; i < self.audienceArray.count; i++) {
        AudienModel *model = self.audienceArray[i];
        UIImageView * headView = [[UIImageView alloc]initWithFrame:CGRectMake(i*(ItemSize +10), 0, ItemSize, ItemSize)];
        headView.userInteractionEnabled = YES;
        headView.layer.cornerRadius = ItemSize * 0.5;
        headView.layer.masksToBounds = YES;
        headView.tag = i + 88;
        [scrollView addSubview:headView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headViewDid:)];
        [headView addGestureRecognizer:tap];
        if (model.photoUrl.length) {
        [[LSImageViewLoader loader] refreshCachedImage:headView options:0 imageUrl:model.photoUrl placeholderImage:model.image];
        }
        else
        {
           headView.image = model.image;
        }

        if (model.isHasTicket) {
            UIImageView * icon = [[UIImageView alloc]initWithFrame:CGRectMake(i*(ItemSize + 10) + 23, 23, 17, 17)];
            icon.image = [UIImage imageNamed:@"LiveShowIcon"];
            [scrollView addSubview:icon];
        }
        
        scrollView.contentSize = CGSizeMake(i*(ItemSize +10) + ItemSize, self.frame.size.height);
    }
}

- (void)headViewDid:(UITapGestureRecognizer *)tap {
    
    int tag = (int)tap.view.tag - 88;
    if ([self.delegate respondsToSelector:@selector(vipLiveAudidenveViewDidSelectItem:)]) {
        [self.delegate vipLiveAudidenveViewDidSelectItem:self.audienceArray[tag]];
    }
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
 
    AudienModel *model = self.audienceArray[indexPath.row];
    cell.headImageView.layer.cornerRadius = ItemSize * 0.5;
    cell.headImageView.layer.masksToBounds = YES;
    
    if (model.photoUrl.length) {
        [[LSImageViewLoader loader] refreshCachedImage:cell.headImageView options:SDWebImageRefreshCached imageUrl:model.photoUrl
                                      placeholderImage:model.image];
    }
    else
    {
        cell.headImageView.image = model.image;
    }

    if (model.isHasTicket) {
        cell.showIcon.hidden = NO;
    }
    else
    {
        cell.showIcon.hidden = YES;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.delegate respondsToSelector:@selector(vipLiveAudidenveViewDidSelectItem:indexPath:)]) {
//        [self.delegate vipLiveAudidenveViewDidSelectItem:self.audienceArray[indexPath.row] indexPath:indexPath];
//    }
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
