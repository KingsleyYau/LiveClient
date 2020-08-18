//
//  LSPremiumInterestView.m
//  livestream
//
//  Created by Albert on 2020/7/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumInterestView.h"
#import "LSPremiumVideoCollectionCell.h"
#import "LSUserUnreadCountManager.h"
#import "GiftItemLayout.h"
#import "LSLoginManager.h"

#import "LSVideoItemCollectionViewCell.h"
#import "LSAddInterestedPremiumVideoRequest.h"
#import "LSDeleteInterestedPremiumVideoRequest.h"

@interface LSPremiumInterestView ()<UICollectionViewDelegate, UICollectionViewDataSource,LSPremiumInterestViewDelegate,LSPremiumVideoCellDelegate, LSVideoItemCollectionViewCellDelegate>
//@property (nonatomic, strong) LSUserUnreadCountManager *unreadManager;
@end

@implementation LSPremiumInterestView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init{
    self = [super init];
    if (self) {
       self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPremiumInterestView" owner:self options:0].firstObject;

        self.collectionView.delaysContentTouches = NO;
        [self initSubView];
    }
    return self;
}

- (void)initSubView
{
    [self.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
    [self.titleLabel setTextColor:[UIColor colorWithRed:255/255.0 green:128/255.0 blue:1/255.0 alpha:1/1.0]];
    
    UINib *nib = [UINib nibWithNibName:@"LSVideoItemCollectionViewCell" bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[LSVideoItemCollectionViewCell identifier]];

    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView reloadData];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageLoader = [LSImageViewLoader loader];
    
    //[self initSubView];
    _itemsArray = [NSArray array];
    UINib *nib = [UINib nibWithNibName:@"LSVideoItemCollectionViewCell" bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[LSVideoItemCollectionViewCell identifier]];

    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView reloadData];
}

-(void)setTitleAlignment:(NSTextAlignment)alignment
{
    [self.titleLabel setTextAlignment:alignment];
}

-(void)reloadData
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;//UICollectionViewScrollDirectionHorizontal;
        
    CGFloat maxHeight = self.bounds.size.height - 45.f;
    if (maxHeight > 235) {
        maxHeight = 235;
    }
    CGFloat maxWidth = maxHeight*170.f/235;
    CGSize itemSize = CGSizeMake(maxWidth, maxHeight);
    
    layout.itemSize = itemSize;
    layout.minimumLineSpacing = 0.f;
//    layout.minimumInteritemSpacing = 10.f;//方案1:固定item的间距，通过调整collectionView的宽度适配
    layout.minimumInteritemSpacing = self.bounds.size.width-40.f-itemSize.width * 2;//方案2:固定collectionView的宽度，通过调整item的间距适配
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.collectionViewLayout = layout;
    
    [self.collectionView reloadData];
    
//    self.collectionViewW.constant = itemSize.width * 2 + 10.f;//方案1
    
    [self.titleLabel setHidden:self.itemsArray.count == 0];
}

//收藏
- (void)addFavoriteRequestModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    LSAddInterestedPremiumVideoRequest * request = [LSAddInterestedPremiumVideoRequest new];
    request.videoId = model.videoId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                //刷新单个
                model.isInterested = YES;
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}
//取消收藏
- (void)deleteFavoriteRequestModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    LSDeleteInterestedPremiumVideoRequest * request = [LSDeleteInterestedPremiumVideoRequest new];
    request.videoId = model.videoId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                //刷新单个
                model.isInterested = NO;
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"numberOfItemsInSection self.itemsArray:%@",self.itemsArray);
    return self.itemsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSVideoItemCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSVideoItemCollectionViewCell identifier] forIndexPath:indexPath];
    [cell setModel:self.itemsArray[indexPath.row] index:indexPath.row];
    cell.delegate = self;
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //CGFloat maxWidth = 170.f;
    CGFloat maxHeight = self.bounds.size.height - 45.f;
    CGFloat maxWidth = maxHeight*170.f/235;
    
    CGSize itemSize = CGSizeMake(maxWidth>170.f?170.f:maxWidth, maxHeight>235.f?235.f:maxHeight);
    
    //self.collectionViewW.constant = itemSize.width * 2 + 10.f;
    
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectInterestItemWithIndex:)]) {
        [self.delegate didSelectInterestItemWithIndex:indexPath.row];
    }
}


#pragma mark - LSVideoItemCollectionViewCellDelegate
- (void)favoriteCellCheck:(LSVideoItemCollectionViewCell *)cell dataModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    if (model.isInterested) {
        [self deleteFavoriteRequestModel:model index:index];
    }else
        [self addFavoriteRequestModel:model index:index];
}
- (void)toVideoDetailCellCheck:(LSVideoItemCollectionViewCell *)cell dataModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectInterestItemWithIndex:)]) {
        [self.delegate didSelectInterestItemWithIndex:index];
    }
}
- (void)toUserDetailCellCheck:(LSVideoItemCollectionViewCell *)cell dataModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectInterestHeadViewItemWithIndex:)]) {
        [self.delegate didSelectInterestHeadViewItemWithIndex:index];
    }
}

@end
