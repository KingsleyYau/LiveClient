//
//  LSMyfavoriteContainerView.m
//  livestream
//
//  Created by logan on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSMyfavoriteContainerView.h"
#import "LSVideoItemCollectionViewCell.h"
#import "LSGetInterestedPremiumVideoListRequest.h"
#import "LSAddInterestedPremiumVideoRequest.h"
#import "LSDeleteInterestedPremiumVideoRequest.h"
#import "LSRecommendPremiumVideoListRequest.h"
#import "LSPremiumInterestView.h"

@interface LSMyfavoriteContainerView ()<UIScrollViewRefreshDelegate,UICollectionViewDelegate,UICollectionViewDataSource,LSVideoItemCollectionViewCellDelegate,LSPremiumInterestViewDelegate>

/** 列表数据 */
@property (nonatomic, strong) NSMutableArray * dataList;

/** 推荐列表数据 */
@property (nonatomic, strong) NSArray * interestList;

/** 推荐列表view */
@property (nonatomic, strong) LSPremiumInterestView * interestView;

@end

@implementation LSMyfavoriteContainerView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"LSMyfavoriteContainerView" owner:self options:nil].firstObject;
        self.frame = frame;
        
        [self initSubViews];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"dealloc");
    [self.myFavoriteCollectionView unSetupPullRefresh];
}

- (void)initSubViews{

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    layout.footerReferenceSize = CGSizeMake(self.tx_width, 160 + 300);//设置footerview高度
    _myFavoriteCollectionView = [[LSVideoCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.tx_width, self.tx_height) collectionViewLayout:layout];
    [_myFavoriteCollectionView setBackgroundColor:[UIColor whiteColor]];
    [_myFavoriteCollectionView registerNib:[UINib nibWithNibName:@"LSVideoItemCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:[LSVideoItemCollectionViewCell identifier]];
    [_myFavoriteCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView"];
    [_myFavoriteCollectionView setAlwaysBounceVertical:YES];
    [_myFavoriteCollectionView setShowsVerticalScrollIndicator:NO];
    _myFavoriteCollectionView.delegate = self;
    _myFavoriteCollectionView.dataSource = self;
    [_myFavoriteCollectionView setupPullRefresh:self pullDown:YES pullUp:YES];
    
    [self addSubview:_myFavoriteCollectionView];
    
    [_myFavoriteCollectionView startLSPullDown:YES];
}

- (void)setScrollToTop{
    [_myFavoriteCollectionView setContentOffset:CGPointZero animated:YES];
}

- (void)startPullDown{
    if (_dataList.count == 0) {
        _isTabRequest = YES;
        [_myFavoriteCollectionView startLSPullDown:YES];
    }
}

#pragma mark - 接口数据处理模块
//上拉刷新 或 下拉加载更多
- (void)getListNewData:(BOOL)isNew{
    LSGetInterestedPremiumVideoListRequest * request = [LSGetInterestedPremiumVideoListRequest new];
    request.start = isNew?0:(int)self.dataList.count;
    request.step = 20;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int totalCount, NSArray<LSPremiumVideoinfoItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isNew) {
                [self.myFavoriteCollectionView finishLSPullDown:YES];
            }else
                [self.myFavoriteCollectionView finishLSPullUp:YES];
            
            if (success) {
                if (isNew) {
                    [self.dataList removeAllObjects];
                }
                [self.dataList addObjectsFromArray:array];
                [self.myFavoriteCollectionView reloadData];
            }
            if(self.dataList.count == 0) [self getLSRecommendPremiumVideoListRequest];
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}
//收藏
- (void)addFavoriteRequestModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    LSAddInterestedPremiumVideoRequest * request = [LSAddInterestedPremiumVideoRequest new];
    request.videoId = model.videoId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                //刷新单个
                //model.isInterested = YES;
                //[self.myFavoriteCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
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
                //model.isInterested = NO;
                //[self.myFavoriteCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}
//推荐列表
- (void)getLSRecommendPremiumVideoListRequest{
    LSRecommendPremiumVideoListRequest * request = [LSRecommendPremiumVideoListRequest new];
    request.num = 2;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int num, NSArray<LSPremiumVideoinfoItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.interestList = array;
                [self.myFavoriteCollectionView reloadData];
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

- (void)toAllVideoList{
    if (self.delegate && [self.delegate respondsToSelector:@selector(favoriteContainerViewDidClickBottomEmptyTips:)]) {
        [self.delegate favoriteContainerViewDidClickBottomEmptyTips:self];
    }
}

#pragma mark - LSVideoItemCollectionViewCellDelegate
- (void)favoriteCellCheck:(LSVideoItemCollectionViewCell *)cell dataModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    if (model.isInterested) {
        model.isInterested = NO;
        [self deleteFavoriteRequestModel:model index:index];
    }else{
        model.isInterested = YES;
        [self addFavoriteRequestModel:model index:index];
    }
        
    //刷新单个
    [self.myFavoriteCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
}
- (void)toVideoDetailCellCheck:(LSVideoItemCollectionViewCell *)cell dataModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(itemCellViewToVideoDetailCheck:data:)]) {
        [self.cellDelegate itemCellViewToVideoDetailCheck:self data:model];
    }
}
- (void)toUserDetailCellCheck:(LSVideoItemCollectionViewCell *)cell dataModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(itemCellViewToUserDetailCheck:data:)]) {
        [self.cellDelegate itemCellViewToUserDetailCheck:self data:model];
    }
}
#pragma mark - LSPremiumInterestViewDelegate
- (void)didSelectInterestHeadViewItemWithIndex:(NSInteger)row{
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(itemCellViewToUserDetailCheck:data:)]) {
        [self.cellDelegate itemCellViewToUserDetailCheck:self data:self.interestList[row]];
    }
}

- (void)didSelectInterestItemWithIndex:(NSInteger)row{
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(itemCellViewToVideoDetailCheck:data:)]) {
        [self.cellDelegate itemCellViewToVideoDetailCheck:self data:self.interestList[row]];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.colVScrollDelegate && [self.colVScrollDelegate respondsToSelector:@selector(protocolVideoCollectionViewWillBeginDragging:)]) {
        [self.colVScrollDelegate protocolVideoCollectionViewWillBeginDragging:_myFavoriteCollectionView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.colVScrollDelegate && [self.colVScrollDelegate respondsToSelector:@selector(protocolVideoCollectionViewDidEndDragging:willDecelerate:)]) {
        [self.colVScrollDelegate protocolVideoCollectionViewDidEndDragging:_myFavoriteCollectionView willDecelerate:decelerate];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.colVScrollDelegate && [self.colVScrollDelegate respondsToSelector:@selector(protocolVideoCollectionViewDidEndDecelerating:)]) {
        [self.colVScrollDelegate protocolVideoCollectionViewDidEndDecelerating:_myFavoriteCollectionView];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.colVScrollDelegate && [self.colVScrollDelegate respondsToSelector:@selector(protocolVideoCollectionViewDidScroll:)]) {
        [self.colVScrollDelegate protocolVideoCollectionViewDidScroll:_myFavoriteCollectionView];
    }
}

#pragma mark - UIScrollViewRefreshDelegate
- (void)pullDownRefresh:(UIScrollView *)scrollView{
    [self getListNewData:YES];
}
- (void)pullUpRefresh:(UIScrollView *)scrollView{
    [self getListNewData:NO];
}

#pragma mark - LSAllVideoCollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LSVideoItemCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSVideoItemCollectionViewCell identifier] forIndexPath:indexPath];
    [cell setModel:self.dataList[indexPath.row] index:indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.tx_width - 18) / 2.0, (self.tx_width - 18) / 2 * 1.367);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(6, 6, 6, 6);
}

//cell左右的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 6.0f;
}

//cell上下的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 6.0f;
}

//footerView的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (self.dataList.count == 0) {//显示底部推荐数据
        return CGSizeMake(0, 160 + 285);
    }else
        return CGSizeZero;
}
//footerView内容
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView * reusableView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView" forIndexPath:indexPath];
        [reusableView removeAllSubviews];
        if (self.dataList.count == 0) {//推荐view
            UILabel * emptyTipsLal = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, reusableView.tx_width, 160)];
            emptyTipsLal.userInteractionEnabled = YES;
            emptyTipsLal.font = [UIFont systemFontOfSize:14.0];
            emptyTipsLal.textAlignment = NSTextAlignmentCenter;
            emptyTipsLal.textColor = COLOR_WITH_16BAND_RGB(0x999999);
            emptyTipsLal.text = @"Your Interested List is empty.";
            [reusableView addSubview:emptyTipsLal];
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toAllVideoList)];
            [emptyTipsLal addGestureRecognizer:tap];
            if (!_interestList) {
                _interestView = [[LSPremiumInterestView alloc] init];
            }
            _interestView.frame = CGRectMake(0, emptyTipsLal.tx_bottom, reusableView.tx_width, reusableView.tx_height - emptyTipsLal.tx_bottom);
            _interestView.delegate = self;
            [_interestView setItemsArray:self.interestList];
            [_interestView reloadData];
            [reusableView addSubview:_interestView];
        }
    }
    return reusableView;
}

#pragma mark - lazy
- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray new];
    }
    return _dataList;
}

@end
