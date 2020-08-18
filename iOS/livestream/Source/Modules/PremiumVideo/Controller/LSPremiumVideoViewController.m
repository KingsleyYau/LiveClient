//
//  LSPremiumVideoViewController.m
//  livestream
//
//  Created by logan on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumVideoViewController.h"
#import "QNSementView.h"
#import "LSAllVideoContainerView.h"
#import "LSMyfavoriteContainerView.h"
#import "LSGetPremiumVideoTypeListRequest.h"
#import "LSPremiumVideoDetailViewController.h"
#import "LSVideoItemCellViewModelProtocol.h"
#import "GetTotalNoreadNumRequest.h"
#import "LSRequestVideoKeyViewController.h"
#import "AnchorPersonalViewController.h"
#import "LiveWebViewController.h"
#import "LSConfigManager.h"
@interface LSPremiumVideoViewController ()<LSPZPagingScrollViewDelegate,QNSementViewDelegate,LSVideoCollectionViewScrollProtocol,LSVideoItemCellViewControlProtocol,UIScrollViewDelegate,LSMyfavoriteContainerViewDelegate>

/*UI部分*/
@property (weak, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (weak, nonatomic) IBOutlet UIView *bottomBgView;
@property (weak, nonatomic) IBOutlet UILabel *topNumLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConst;
@property (weak, nonatomic) IBOutlet UIView *topTabBgView;
@property (weak, nonatomic) IBOutlet LSPZPagingScrollView *pageScrollView;
@property (weak, nonatomic) IBOutlet UIButton *toTopBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *requestBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *topRequestBtn;
/** 标签栏 */
@property (nonatomic, strong) QNSementView * sementView;
/** 所有视频列表的容器 */
@property (nonatomic, strong) LSAllVideoContainerView * allVideoContainView;
/** 我收藏的列表的容器 */
@property (nonatomic, strong) LSMyfavoriteContainerView * myFavoriteContainView;
/** 所有视频顶部标签scrollview */
@property (nonatomic, strong) UIScrollView * topTabScrollView;
@property (weak, nonatomic) IBOutlet UILabel *topTipsLab;

/*数据源部分*/
/** 所有视频的标签数组 */
@property (nonatomic, copy) NSArray <LSPremiumVideoTypeItemObject *>* allVideoTypeArr;

/** 当前tab index */
@property (nonatomic, assign) NSInteger tabIndex;

/** 记录底层scrollview的offset.y */
@property (nonatomic, assign) CGFloat bgScrollViewOffsetY;
/** 记录底层scrollview停止时的offset.y */
@property (nonatomic, assign) CGFloat bgScrollViewEndOffsetY;
/** 记录当期滚动列表的起始offset.y */
@property (nonatomic, assign) CGFloat currentStartOffsetY;
/** 记录所有视频列表的结束offset.y */
@property (nonatomic, assign) CGFloat allViewCVEndOffsetY;
/** 记录收藏列表的结束offset.y */
@property (nonatomic, assign) CGFloat myfavoriteViewCVEndOffsetY;
/** 记录是否点击top按钮触发的滚动 */
@property (nonatomic, assign) BOOL isTopScroll;

@end

@implementation LSPremiumVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel * titleLab = [[UILabel alloc] init];
    titleLab.textColor = COLOR_WITH_16BAND_RGB(0x383838);
    titleLab.font = [UIFont systemFontOfSize:17.0];
    titleLab.text = @"Premium Video";
    self.navigationItem.titleView = titleLab;
    
    if (@available(iOS 11.0, *)) {
        _bgScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomViewHeightConst.constant = self.view.tx_height - 7;//7是顶部预留的高度
        self.pageScrollView.frame = CGRectMake(self.pageScrollView.tx_x, self.pageScrollView.tx_y, self.pageScrollView.tx_width, self.bottomViewHeightConst.constant - self.pageScrollView.tx_y);
        [self initSubViews];
    });
    
    [self getVideoTagData];
    [self getUnlockVideos];
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)dealloc{
    NSLog(@"dealloc -- ");
}

- (void)viewDidLayoutSubviews{
    if (self.view.tx_width <= 320) {
        _requestBtnWidthConstraint.constant = 300;
    }
}

- (void)initCustomParam{
    [super initCustomParam];
}

- (void)getUnlockVideos{
    GetTotalNoreadNumRequest * request = [GetTotalNoreadNumRequest new];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSMainUnreadNumItemObject *userInfoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                if (userInfoItem.requestReplyUnreadNum > 0) {
                    self.topNumLab.hidden = NO;
                    self.topNumLab.text = [NSString stringWithFormat:@"%d",userInfoItem.requestReplyUnreadNum];
                }
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

//获取视频标签
- (void)getVideoTagData{
    LSGetPremiumVideoTypeListRequest * request = [[LSGetPremiumVideoTypeListRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSPremiumVideoTypeItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.allVideoContainView setPullScrollEnable:YES];
                //拼接一个All类型
                LSPremiumVideoTypeItemObject * allTypeObj = [LSPremiumVideoTypeItemObject new];
                allTypeObj.typeId = @"";
                allTypeObj.typeName = @"All";
                allTypeObj.isDefault = NO;
                NSMutableArray * customTypeArr = [NSMutableArray new];
                [customTypeArr addObject:allTypeObj];
                [customTypeArr addObjectsFromArray:array];
                self.allVideoTypeArr = customTypeArr;
                if(self.allVideoContainView) [self.allVideoContainView setTagArr:self.allVideoTypeArr];
            }else{
                [self.allVideoContainView setPullScrollEnable:NO];
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

- (void)initSubViews{

    _bgScrollView.delegate = self;
    
    _bottomBgView.layer.cornerRadius = 7;
    _bottomBgView.layer.masksToBounds = YES;
    /*
    //阴影
    _bottomBgView.layer.shadowColor = COLOR_WITH_16BAND_RGB(0x0066FF).CGColor;
    _bottomBgView.layer.shadowOpacity = 0.27f;
    _bottomBgView.layer.shadowOffset = CGSizeMake(2,2);*/
    
    _topRequestBtn.layer.cornerRadius = _topRequestBtn.tx_height / 2;
    _topRequestBtn.layer.masksToBounds = YES;
    
    _topNumLab.layer.cornerRadius = _topNumLab.tx_height / 2;
    _topNumLab.layer.masksToBounds = YES;
    _topNumLab.hidden = YES;//默认隐藏
    
    _toTopBtn.alpha = 0;//默认透明
    
    _topTipsLab.userInteractionEnabled = YES;
    UITapGestureRecognizer * tipsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toTipsVC)];
    [_topTipsLab addGestureRecognizer:tipsTap];
    NSString * tipsStr = NSLocalizedStringFromSelf(@"LS_VideoVC_TopDec");
    NSString * rangeStr = NSLocalizedStringFromSelf(@"LS_VideoVC_TopDec_LineStr");
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:tipsStr];
    [attrStr addAttributes:@{NSForegroundColorAttributeName:Color(44, 157, 252, 1),NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)} range:[tipsStr rangeOfString:rangeStr]];
    _topTipsLab.attributedText = attrStr;
    
    _pageScrollView.pagingViewDelegate = self;
    _pageScrollView.scrollEnabled = NO;
    [_pageScrollView displayPagingViewAtIndex:0 animated:YES];
    //顶部tab切换
    _sementView = [[QNSementView alloc] initWithNumberOfTitles:@[@"All Videos",@"My Favorite Videos"] andFrame:_topTabBgView.bounds delegate:self isSymmetry:YES isShowbottomLine:NO];
    [_sementView setTextNormalColor:COLOR_WITH_16BAND_RGB(0x383838) andSelectedColor:COLOR_WITH_16BAND_RGB(0xff6600)];
    [_sementView setLineNormalColor:nil andelectedColor:COLOR_WITH_16BAND_RGB(0xff6600)];
    [_sementView setTitleFont:[UIFont fontWithName:@"ArialMT" size:16.0]];
    [_sementView setTitleSelectFont:[UIFont fontWithName:@"Arial-BoldMT" size:16.0]];
    [_topTabBgView addSubview:_sementView];
}
- (IBAction)toRequestUnlock:(id)sender {
    LSRequestVideoKeyViewController *vc = [[LSRequestVideoKeyViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)toTopBtnCheck:(id)sender {
    
    if (_tabIndex == 0) {//all videos
        _isTopScroll = YES;
        [_allVideoContainView setScrollToTop];
    }else{
        [_myFavoriteContainView setScrollToTop];
    }
}
- (void)toTipsVC{
    //TODO:跳转说明界面
    NSString *url = [LSConfigManager manager].item.howItWorkUrl;
    LSWKWebViewController *webViewController = [[LSWKWebViewController alloc] initWithNibName:nil bundle:nil];
    UILabel * titleLab = [[UILabel alloc] init];
    titleLab.textColor = COLOR_WITH_16BAND_RGB(0x383838);
    titleLab.text = @"How Premium Videos works";
    titleLab.font = [UIFont systemFontOfSize:17.0];
    webViewController.navigationItem.titleView = titleLab;
    webViewController.requestUrl = url;
    webViewController.isShowTaBar = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - LSMyfavoriteContainerViewDelegate
- (void)favoriteContainerViewDidClickBottomEmptyTips:(LSMyfavoriteContainerView *)conView{
    [_pageScrollView displayPagingViewAtIndex:0 animated:YES];
}

#pragma mark - LSVideoItemCellViewControlProtocol
- (void)itemCellViewToUserDetailCheck:(UIView *)view data:(id<LSVideoItemCellViewModelProtocol>)data{
    //跳转用户详情
    LSPremiumVideoinfoItemObject * obj = data;
    AnchorPersonalViewController * userViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    userViewController.anchorId = obj.anchorId;
    userViewController.enterRoom = 1;
    [self.navigationController pushViewController:userViewController animated:YES];
}
- (void)itemCellViewToVideoDetailCheck:(UIView *)view data:(id<LSVideoItemCellViewModelProtocol>)data{
    //跳转视频详情
    LSPremiumVideoinfoItemObject * obj = data;
    LSPremiumVideoDetailViewController * vc = [[LSPremiumVideoDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.womanId = obj.anchorId;
    vc.videoId = obj.videoId;
    vc.videoTitle = obj.title;
    vc.videoSubTitle = obj.describe;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //TODO: y = (120 - 7) 最底 , y = 0 最顶
    _bgScrollViewOffsetY = scrollView.contentOffset.y;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _bgScrollViewEndOffsetY = scrollView.contentOffset.y;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _bgScrollViewEndOffsetY = scrollView.contentOffset.y;
}

#pragma mark - LSVideoCollectionViewScrollProtocol
- (void)protocolVideoCollectionViewWillBeginDragging:(LSVideoCollectionView *)collectionView{
    _currentStartOffsetY = collectionView.contentOffset.y;
    _allVideoContainView.isClickRequest = NO;
    _myFavoriteContainView.isTabRequest = NO;
    _isTopScroll = NO;
}
- (void)protocolVideoCollectionViewDidEndDragging:(LSVideoCollectionView *)collectionView willDecelerate:(BOOL)decelerate{
    _bgScrollView.scrollEnabled = YES;
    if (_allVideoContainView.allVideoCollectionView == collectionView) {
        _allViewCVEndOffsetY = collectionView.contentOffset.y;
    }else
        _myfavoriteViewCVEndOffsetY = collectionView.contentOffset.y;
}
- (void)protocolVideoCollectionViewDidEndDecelerating:(LSVideoCollectionView *)collectionView{
    _bgScrollView.scrollEnabled = YES;
    if (_allVideoContainView.allVideoCollectionView == collectionView) {
        _allViewCVEndOffsetY = collectionView.contentOffset.y;
    }else
        _myfavoriteViewCVEndOffsetY = collectionView.contentOffset.y;
}
- (void)protocolVideoCollectionViewDidScroll:(LSVideoCollectionView *)collectionView{
    if (_allVideoContainView.allVideoCollectionView == collectionView) {
        if (collectionView.contentOffset.y > 100) {//all videos才处理滚动到顶部
            _toTopBtn.alpha = (collectionView.contentOffset.y - 100)/200;
        }else{
            _toTopBtn.alpha = 0;
        }
    }
    
    if(_currentStartOffsetY < 0) return;
    if(_isTopScroll) {
        _allViewCVEndOffsetY = collectionView.contentOffset.y;
        return;
    }
    
    if (collectionView.contentOffset.y > _currentStartOffsetY) {//向上滚动[手指上滑]
        if (_bgScrollViewOffsetY < 113) {
            [collectionView setContentOffset:CGPointMake(0, _allVideoContainView.allVideoCollectionView == collectionView?_allViewCVEndOffsetY : _myfavoriteViewCVEndOffsetY)];
        }
    }else{//向下滚动[手指下滑]
        if(collectionView.contentOffset.y == _currentStartOffsetY) return;
        
        if (collectionView.contentOffset.y > 0) {
            if (_bgScrollViewOffsetY > _bgScrollViewEndOffsetY) {
                _bgScrollViewEndOffsetY = _bgScrollViewOffsetY;
            }
            [_bgScrollView setContentOffset:CGPointMake(0, _bgScrollViewEndOffsetY)];
        }else{
            if (_bgScrollViewOffsetY > 0 && _allVideoContainView.isClickRequest == NO && _myFavoriteContainView.isTabRequest == NO) {
                [collectionView setContentOffset:CGPointMake(0, 0)];
            }
        }
        //快速上下滑动过渡效果处理
        if (collectionView.contentOffset.y > 200 && _bgScrollViewEndOffsetY == 113) {
            _bgScrollView.scrollEnabled = NO;
        }else{
            _bgScrollView.scrollEnabled = YES;
        }
    }
}

#pragma mark - QNSementViewDelegate
- (void)segmentControlSelectedTag:(NSInteger)tag{
    [_pageScrollView displayPagingViewAtIndex:tag animated:YES];
    _tabIndex = tag;
    if (tag == 0) {
        _toTopBtn.hidden = NO;
        if (_allVideoTypeArr.count == 0) {//重新获取
            [self getVideoTagData];
        }
    }else{
        _toTopBtn.hidden = YES;
        [_myFavoriteContainView startPullDown];
    }
}

#pragma mark - LSPZPagingScrollViewDelegate
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index{
    if (index == 0) {
        return [LSAllVideoContainerView class];
    }else{
        return [LSMyfavoriteContainerView class];
    }
}
- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView{
    return 2;
}
- (UIView *)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index{
    
    if (index == 0) {
        _allVideoContainView = [[LSAllVideoContainerView alloc] initWithFrame:pagingScrollView.bounds];
        _allVideoContainView.colVScrollDelegate = self;
        _allVideoContainView.delegate = self;
        return _allVideoContainView;
    }else{
        _myFavoriteContainView = [[LSMyfavoriteContainerView alloc] initWithFrame:pagingScrollView.bounds];
        _myFavoriteContainView.colVScrollDelegate = self;
        _myFavoriteContainView.cellDelegate = self;
        _myFavoriteContainView.delegate = self;
        return _myFavoriteContainView;
    }
}
- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index{
    if (index == 0) {
        //拿到当前最新的offsetY [tab切换时系统没有触发列表滚动停止代理]
        _allViewCVEndOffsetY = _allVideoContainView.allVideoCollectionView.contentOffset.y;
    }else{
        //拿到当前最新的offsetY [tab切换时系统没有触发列表滚动停止代理]
        _myfavoriteViewCVEndOffsetY = _myFavoriteContainView.myFavoriteCollectionView.contentOffset.y;
    }
}
- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index{
    [_sementView selectButtonTag:index];
}

@end
