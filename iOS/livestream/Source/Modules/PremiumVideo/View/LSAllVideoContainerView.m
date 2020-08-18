
//
//  LSAllVideoContainerView.m
//  livestream
//
//  Created by logan on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSAllVideoContainerView.h"
#import "LSVideoItemCollectionViewCell.h"
#import "LSGetPremiumVideoListRequest.h"
#import "LSAddInterestedPremiumVideoRequest.h"
#import "LSDeleteInterestedPremiumVideoRequest.h"

static NSInteger BTN_TAG = 100;

@interface LSAllVideoContainerView ()<UIScrollViewRefreshDelegate,UICollectionViewDelegate,UICollectionViewDataSource,LSVideoItemCollectionViewCellDelegate>

@property (nonatomic, strong) UIScrollView * topTabScrollView;

/** 列表数据 */
@property (nonatomic, strong) NSMutableArray * dataList;

/** 需要请求的typeID数组 */
@property (nonatomic, strong) NSMutableArray <NSString *>* requestIds;

/** 标签按钮数组 */
@property (nonatomic, strong) NSMutableArray * tagBtnArr;

/** 是否正在请求数据 */
@property (nonatomic, assign) BOOL isLoadingData;

@end

@implementation LSAllVideoContainerView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"LSAllVideoContainerView" owner:self options:nil].firstObject;
        self.frame = frame;
        [self initSubViews];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"dealloc");
    [self.allVideoCollectionView unSetupPullRefresh];
}

- (void)setScrollToTop{
    [_allVideoCollectionView setContentOffset:CGPointZero animated:YES];
}

- (void)setTagArr:(NSArray<LSPremiumVideoTypeItemObject *> *)tagArr{
    
    _tagArr = tagArr;
    
    NSInteger selectIndex = 0;//选中的index
    BOOL isHasDefault = NO;//记录原始数据是否有默认选中的,没有则选中All
    CGFloat space = 8;
    CGFloat btnHeight = 28;
    for (int i = 0; i < tagArr.count; i ++) {
        UIButton * btn = [[UIButton alloc] init];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.layer.cornerRadius = 4;
        btn.layer.borderWidth = 0.5;
        [btn setTitleColor:COLOR_WITH_16BAND_RGB(0x383838) forState:UIControlStateNormal];
        [btn setTitle:tagArr[i].typeName forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnCheck:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = BTN_TAG + i;
        [btn sizeToFit];
        [btn setFrame:CGRectMake(i == 0?0:space + _topTabScrollView.contentSize.width,0 ,btn.tx_width + 33, btnHeight)];
        UIImageView * img = [UIImageView new];
        img.image = [UIImage imageNamed:@"Select_Note_Select_Icon"];
        [btn addSubview:img];
        img.tag = 2*BTN_TAG + i;
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(20);
            make.right.bottom.mas_equalTo(0);
        }];
        if (tagArr[i].isDefault) {
            selectIndex = i;
            isHasDefault = YES;
            btn.selected = YES;
            [self.requestIds addObject:tagArr[i].typeId];
        }
        [self updateBtnStatusUI:btn];
        [self.tagBtnArr addObject:btn];
        [_topTabScrollView addSubview:btn];
        _topTabScrollView.contentSize = CGSizeMake(btn.tx_right, 0);
    }
    
    if (!isHasDefault) {//没有默认选中的则请求All
        [self setAllBtnSelectStatus:YES];
        [self.requestIds removeAllObjects];
        [self.requestIds addObject:@""];
    }else{//将默认选中的按钮滚动到中间
        if(_topTabScrollView.contentSize.width <= _topTabScrollView.tx_width) return;
        UIButton * defaultBtn = self.tagBtnArr[selectIndex];
        if (defaultBtn.tx_x + defaultBtn.tx_width / 2 > _topTabScrollView.tx_width / 2) {
            CGFloat centerX = defaultBtn.tx_x - (_topTabScrollView.tx_width - defaultBtn.tx_width) / 2;
            if (defaultBtn.tx_x + (_topTabScrollView.tx_width + defaultBtn.tx_width) / 2 >= _topTabScrollView.contentSize.width) {
                centerX = _topTabScrollView.contentSize.width - _topTabScrollView.tx_width;
            }
            [_topTabScrollView setContentOffset:CGPointMake(centerX, 0) animated:YES];
        }
    }
    [_allVideoCollectionView startLSPullDown:YES];
}

- (void)updateBtnStatusUI:(UIButton *)btn{
    if (btn.isSelected) {
        btn.layer.borderColor = COLOR_WITH_16BAND_RGB(0xffa40e).CGColor;
        UIImageView * img = [btn viewWithTag:btn.tag + BTN_TAG];
        img.hidden = NO;
    }else{
        btn.layer.borderColor = COLOR_WITH_16BAND_RGB(0xc4c4c4).CGColor;
        UIImageView * img = [btn viewWithTag:btn.tag + BTN_TAG];
        img.hidden = YES;
    }
}

- (NSString *)getRequestString{
    NSMutableString * typeIds = [[NSMutableString alloc] init];
    for (int i = 0; i < self.requestIds.count; i ++) {
        [typeIds appendString:self.requestIds[i]];
        if (i < self.requestIds.count - 1) {
            [typeIds appendString:@","];
        }
    }
    return typeIds;
}

//设置All按钮的状态
- (void)setAllBtnSelectStatus:(BOOL)selected{
    for (int i = 0; i < self.tagBtnArr.count; i ++) {
        if (selected) {//All按钮选中状态,其他按钮全部设为非选中状态
            if (i == 0) {
                UIButton * btn = self.tagBtnArr[i];
                btn.selected = YES;
                [self updateBtnStatusUI:btn];
            }else{
                UIButton * btn = self.tagBtnArr[i];
                btn.selected = NO;
                [self updateBtnStatusUI:btn];
            }
        }else{//All按钮非选中状态
            if (i == 0) {//All按钮非选中状态,其他按钮保持原有状态
                UIButton * btn = self.tagBtnArr[i];
                btn.selected = NO;
                [self updateBtnStatusUI:btn];
                break;
            }
        }
    }
}

- (void)btnCheck:(UIButton *)btn{
    NSLog(@"btnTag = %ld",btn.tag);
    
    if(self.isLoadingData) return;//请求中不允许触发
    
    if (btn.selected && _requestIds.count == 1) {//最少保留一个选中的按钮
        return;
    }
    
    btn.selected = !btn.selected;
    NSInteger index = btn.tag - BTN_TAG;
    NSString * checkId = _tagArr[index].typeId;
    [self updateBtnStatusUI:btn];
    
    if (btn.isSelected) {
        if (checkId.length == 0) {//选了全部
            [self setAllBtnSelectStatus:YES];
            [_requestIds removeAllObjects];
            [_requestIds addObject:@""];//添加一个空字符串
        }else{
            if([_requestIds containsObject:@""]) [_requestIds removeObject:@""];
            [_requestIds addObject:checkId];
            [self setAllBtnSelectStatus:NO];
        }
    }else{
        if ([_requestIds containsObject:checkId]) {
            [_requestIds removeObject:checkId];
        }
    }
    _isClickRequest = YES;
    [_allVideoCollectionView startLSPullDown:YES];
}

- (void)initSubViews{
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tx_width, 38)];
    [topView setBackgroundColor:[UIColor whiteColor]];
    _topTabScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(8, 0, self.tx_width - 16, 38)];
    [_topTabScrollView setBackgroundColor:[UIColor whiteColor]];
    _topTabScrollView.showsHorizontalScrollIndicator = NO;
    //阴影
    topView.layer.shadowColor = COLOR_WITH_16BAND_RGB(0x0066FF).CGColor;
    topView.layer.shadowOpacity = 0.27f;
    topView.layer.shadowOffset = CGSizeMake(2,2);
    [topView addSubview:_topTabScrollView];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _allVideoCollectionView = [[LSVideoCollectionView alloc] initWithFrame:CGRectMake(0, _topTabScrollView.tx_bottom, self.tx_width, self.tx_height - _topTabScrollView.tx_height) collectionViewLayout:layout];
    [_allVideoCollectionView setBackgroundColor:[UIColor whiteColor]];
    [_allVideoCollectionView registerNib:[UINib nibWithNibName:@"LSVideoItemCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:[LSVideoItemCollectionViewCell identifier]];
    [_allVideoCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView"];
    [_allVideoCollectionView setAlwaysBounceVertical:YES];
    [_allVideoCollectionView setShowsVerticalScrollIndicator:NO];
    _allVideoCollectionView.delegate = self;
    _allVideoCollectionView.dataSource = self;
    [_allVideoCollectionView setupPullRefresh:self pullDown:YES pullUp:YES];
    
    [self addSubview:_allVideoCollectionView];
    [self addSubview:topView];
}

- (void)setPullScrollEnable:(BOOL)isEnable{
    [_allVideoCollectionView setScrollEnabled:isEnable];
}

#pragma mark - 接口数据处理
//下拉刷新
- (void)getListNewData{
    self.isLoadingData = YES;
    LSGetPremiumVideoListRequest * request = [LSGetPremiumVideoListRequest new];
    request.typeIds = [self getRequestString];
    request.start = 0;
    request.step = 20;//每页20个
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int totalCount, NSArray<LSPremiumVideoinfoItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.allVideoCollectionView finishLSPullDown:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                self.isLoadingData = NO;
            });
            if (success) {
                [self.dataList removeAllObjects];
                [self.dataList addObjectsFromArray:array];
                [self.allVideoCollectionView reloadData];
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}
//上拉加载更多
- (void)getListMoreData{
    self.isLoadingData = YES;
    LSGetPremiumVideoListRequest * request = [LSGetPremiumVideoListRequest new];
    request.typeIds = [self getRequestString];
    request.start = (int)self.dataList.count;//从哪个位置开始
    request.step = 20;//每页20个
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int totalCount, NSArray<LSPremiumVideoinfoItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.allVideoCollectionView finishLSPullUp:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                self.isLoadingData = NO;
            });
            if (success) {
                [self.dataList addObjectsFromArray:array];
                [self.allVideoCollectionView reloadData];
            }
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
                //[self.allVideoCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
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
                //[self.allVideoCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
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
    [self.allVideoCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
}
- (void)toVideoDetailCellCheck:(LSVideoItemCollectionViewCell *)cell dataModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCellViewToVideoDetailCheck:data:)]) {
        [self.delegate itemCellViewToVideoDetailCheck:self data:model];
    }
}
- (void)toUserDetailCellCheck:(LSVideoItemCollectionViewCell *)cell dataModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCellViewToUserDetailCheck:data:)]) {
        [self.delegate itemCellViewToUserDetailCheck:self data:model];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.colVScrollDelegate && [self.colVScrollDelegate respondsToSelector:@selector(protocolVideoCollectionViewWillBeginDragging:)]) {
        [self.colVScrollDelegate protocolVideoCollectionViewWillBeginDragging:_allVideoCollectionView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.colVScrollDelegate && [self.colVScrollDelegate respondsToSelector:@selector(protocolVideoCollectionViewDidEndDragging:willDecelerate:)]) {
        [self.colVScrollDelegate protocolVideoCollectionViewDidEndDragging:_allVideoCollectionView willDecelerate:decelerate];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.colVScrollDelegate && [self.colVScrollDelegate respondsToSelector:@selector(protocolVideoCollectionViewDidEndDecelerating:)]) {
        [self.colVScrollDelegate protocolVideoCollectionViewDidEndDecelerating:_allVideoCollectionView];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.colVScrollDelegate && [self.colVScrollDelegate respondsToSelector:@selector(protocolVideoCollectionViewDidScroll:)]) {
        [self.colVScrollDelegate protocolVideoCollectionViewDidScroll:_allVideoCollectionView];
    }
}
#pragma mark - UIScrollViewRefreshDelegate
- (void)pullDownRefresh:(UIScrollView *)scrollView{
    [self getListNewData];
}
- (void)pullUpRefresh:(UIScrollView *)scrollView{
    [self getListMoreData];
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

//cell之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 6.0f;
}

//cell上下的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 6.0f;
}

#pragma mark - lazy
- (NSMutableArray<NSString *> *)requestIds{
    if (!_requestIds) {
        _requestIds = [NSMutableArray new];
    }
    return _requestIds;
}
- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray new];
    }
    return _dataList;
}
- (NSMutableArray *)tagBtnArr{
    if (!_tagBtnArr) {
        _tagBtnArr = [NSMutableArray new];
    }
    return _tagBtnArr;
}

@end
