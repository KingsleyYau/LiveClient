//
//  HotViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "HotViewController.h"
#import "PlayViewController.h"
#import "PreLiveViewController.h"
#import "LSSessionRequestManager.h"
#import "UnreadNumManager.h"
#import "PublicViewController.h"
#import "GetAnchorListRequest.h"
#import "IntroduceViewController.h"
#import "GetAnchorListRequest.h"
#import "LSLoginManager.h"
#import "BookPrivateBroadcastViewController.h"
#import "AnchorPersonalViewController.h"
#import "LiveADView.h"
#import "LiveModule.h"
#import "LSConfigManager.h"
#import "HomeVouchersManager.h"
#import "InterimShowViewController.h"
#import "LiveWebViewController.h"
#import "HotHeadView.h"
#import "HotTopView.h"
#define PageSize 50
#define DefaultSize 16
#define kFunctionViewHeight 88
#define kTopViewHeight 46
@interface HotViewController () <UIScrollViewRefreshDelegate, HotTableViewDelegate, LiveADViewDelegate,
                                 HotHeadViewDelegate, HotTopViewDelegate, UnreadNumManagerDelegate>

/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) UnreadNumManager *unreadManager;

/**
 列表
 */
@property (nonatomic, strong) NSMutableArray *items;

/** 广告banner */
@property (nonatomic, strong) LiveADView *adView;

@property (strong, nonatomic)  HotTopView *topView;
@property (nonatomic, strong) HotHeadView * headView;
@property (nonatomic, strong) HotHeadView * tableHeadView;

@property (nonatomic, strong) NSArray *hotHeadIconArray;
@property (nonatomic, strong) NSArray *headTitleArray;
@property (nonatomic, strong) NSArray *topIconArray;

/**
 是否加载数据
 */
@property (nonatomic, assign) BOOL isLoadData;
/**
 是否第一次登录
 */
@property (nonatomic, assign) BOOL isFirstLogin;
@end

@implementation HotViewController

- (void)initCustomParam {
    [super initCustomParam];
    
    self.items = [NSMutableArray array];

    self.sessionManager = [LSSessionRequestManager manager];

    // 设置失败页属性
    self.failTipsText = NSLocalizedString(@"List_FailTips", @"List_FailTips");

    self.failBtnText = NSLocalizedString(@"List_Reload", @"List_Reload");

    
    self.unreadManager = [UnreadNumManager manager];
    [self.unreadManager addDelegate:self];

    self.hotHeadIconArray = @[@"Discover_Mail_Btn",@"Discover_Greetings_Btn",@"Discover_QpCredits_Btn"];
    self.headTitleArray = @[@"Mail",@"Greetings",@"Add Credits"];
    self.topIconArray = @[@"Home_Mail_Btn",@"Home_Greetings_Btn",@"Home_QpCredits_Btn"];
    
    // 是否第一次登录
    self.isFirstLogin = NO;
    // 是否刷新数据
    self.isLoadData = NO;
}

- (void)lsListViewControllerDidClick:(UIButton *)sender {
    [self reloadBtnClick:sender];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tableView unInitPullRefresh];
    [self.unreadManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
//    if (self.items.count == 0 ) {
//        // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
//        [self.tableView startPullDown:NO];
//    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self viewDidAppearGetList:NO];
    [self updateTableViewVouchersData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)updateTableViewVouchersData {
    
    [[HomeVouchersManager manager] getVouchersData:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSVoucherAvailableInfoItemObject * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [HomeVouchersManager manager].item = item;
                [self.tableView reloadData];
            }
        });
    }];
}

- (void)setupContainView {
    [super setupContainView];
    // 初始化主播列表
    [self setupTableView];
}

- (void)setupTableView {

    self.tableView.frame = CGRectMake(0, kFunctionViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kFunctionViewHeight);
    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;

    self.tableHeadView = [[HotHeadView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kFunctionViewHeight)];
    self.tableHeadView.backgroundColor = [UIColor whiteColor];
    self.tableHeadView.delagate = self;
    
    self.headView =  [[HotHeadView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kFunctionViewHeight)];
    self.headView.backgroundColor = [UIColor whiteColor];
    self.headView.delagate = self;
    [self.view addSubview:self.headView];
    
    self.topView = [[HotTopView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 46)];
    self.topView.delagate = self;
    [self.view addSubview:self.topView];
    [self.view bringSubviewToFront:self.topView];
    self.topView.alpha = 0;
    
    self.tableHeadView.iconArray = self.hotHeadIconArray;
    self.tableHeadView.titleArray = self.headTitleArray;
    self.headView.iconArray = self.hotHeadIconArray;
    self.headView.titleArray = self.headTitleArray;
    self.topView.iconArray = self.topIconArray;
    self.topView.titleArray = self.headTitleArray;
    
    [self setupListHeadView];
    
    self.tableView.tableViewDelegate = self;
}

- (void)setupListHeadView {
    // 顶部控件加载数据
    self.tableHeadView.iconArray = self.hotHeadIconArray;
    self.tableHeadView.titleArray = self.headTitleArray;
    self.headView.iconArray = self.hotHeadIconArray;
    self.headView.titleArray = self.headTitleArray;
    self.topView.iconArray = self.topIconArray;
    self.topView.titleArray = self.headTitleArray;
}

#pragma mark banner点击事件
- (void)liveADViewBannerURL:(NSString *)url title:(NSString *)title {
    IntroduceViewController *introduceVc = [[IntroduceViewController alloc] initWithNibName:nil bundle:nil];
    introduceVc.bannerUrl = url;
    introduceVc.titleStr = title;
    [self.navigationController pushViewController:introduceVc animated:YES];
}

#pragma mark - 数据逻辑

- (void)reloadData:(BOOL)isReloadView {
    NSLog(@"HotViewController::reloadData( isReloadView : %@ )", BOOL2YES(isReloadView));

    // 数据填充
    if (isReloadView) {
        self.tableView.items = self.items;
        [self.tableView reloadData];
    }
}

- (void)tableView:(HotTableView *)tableView didSelectItem:(LiveRoomInfoItemObject *)item {
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] init];
    listViewController.anchorId = item.userId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)reloadUnreadNum {
    // 刷新未读显示
    [self.unreadManager getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
        [self reloadHotHeadView];
    }];
}

- (void)reloadHotHeadView {
    [self.tableHeadView.collectionView reloadData];
    [self.headView.collectionView reloadData];
    [self.topView.collectionView reloadData];
}

#pragma mark - HTTP登录调用
- (void)setupLoadData:(BOOL)isLoadData {
    self.isLoadData = isLoadData;
}

- (void)setupFirstLogin:(BOOL)isFirstLogin {
    self.isFirstLogin = isFirstLogin;
}

- (void)viewDidAppearGetList:(BOOL)isSwitchSite {
    // 第一次http登录成功刷列表
    if (self.isFirstLogin || isSwitchSite || self.isLoadData) {
        // 界面是否显示
        if (self.viewDidAppearEver) {
            [self.tableView startPullDown:YES];
            self.isFirstLogin = NO;
        }
    }
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest:NO];
}

- (void)pullUpRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest:YES];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    [self.adView loadAD];
    // 下拉刷新回调
    [self pullDownRefresh];
}

- (void)pullUpRefresh:(UIScrollView *)scrollView {
    // 上拉更多回调
    [self pullUpRefresh];
}

#pragma mark 数据逻辑
- (BOOL)getListRequest:(BOOL)loadMore {
    NSLog(@"HotViewController::getListRequest( loadMore : %@ )", BOOL2YES(loadMore));

    BOOL bFlag = NO;

    GetAnchorListRequest *request = [[GetAnchorListRequest alloc] init];

    int start = 0;
    if (!loadMore) {
        // 刷最新
        start = 0;

    } else {
        // 刷更多
        start = self.items ? ((int)self.items.count) : 0;
    }

    // 每页最大纪录数
    request.start = start;
    request.step = PageSize;
    request.isForTest = [LiveModule module].isForTest;
    request.hasWatch = NO;

    // 调用接口
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"HotViewController::getListRequest( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            if (success) {
                //请求试聊券接口
                [[HomeVouchersManager manager] getVouchersData:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSVoucherAvailableInfoItemObject * _Nonnull item) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"HotViewController::getVouchersData(请求试聊券:[%@])", BOOL2SUCCESS(success));
                        [HomeVouchersManager manager].item = item;
                         self.failView.hidden = YES;
                        [self.tableView.tableHeaderView setHidden:NO];
                        if (!loadMore) {
                            // 停止头部
                            [self.tableView finishPullDown:YES];
                            // 清空列表
                            [self.items removeAllObjects];
                            self.isLoadData = NO;
                        } else {
                            // 停止底部
                            [self.tableView finishPullUp:YES];
                        }
                        
                        for (LiveRoomInfoItemObject *item in array) {
                            [self.items addObject:item];
                        }
                        
                        // 没有数据隐藏banner
                        if (!(self.items.count > 0)) {
                            [self.tableView.tableHeaderView setHidden:YES];
                        }
                        
                        [self reloadData:YES];
                        
                        if (!loadMore) {
                            if (self.items.count > 0) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                    // 拉到最顶
                                    [self.tableView scrollsToTop];
                                });
                            }
                        } else {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                if (self.items.count > PageSize) {
                                    // 拉到下一页
                                    UITableViewCell *cell = [self.tableView visibleCells].firstObject;
                                    NSIndexPath *index = [self.tableView indexPathForCell:cell];
                                    NSInteger row = index.row;
                                    NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:row + 1 inSection:0];
                                    [self.tableView scrollToRowAtIndexPath:nextIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                }
                                
                            });
                        }
                    });
                }];

            } else {
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:NO];
                    [self.items removeAllObjects];
                    [self.tableView.tableHeaderView setHidden:YES];
                    self.failView.hidden = NO;
                    self.isLoadData = YES;
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                }

                [self reloadData:YES];
            }
            self.view.userInteractionEnabled = YES;
        });
    };

    bFlag = [self.sessionManager sendRequest:request];

    return bFlag;
}

- (void)addItemIfNotExist:(LiveRoomInfoItemObject *_Nonnull)itemNew {
    bool bFlag = NO;

    for (LiveRoomInfoItemObject *item in self.items) {
        if ([item.userId isEqualToString:itemNew.userId]) {
            // 已经存在
            bFlag = true;
            break;
        }
    }

    if (!bFlag) {
        // 不存在
        [self.items addObject:itemNew];
    }
}

- (void)reloadBtnClick:(id)sender {
    self.failView.hidden = YES;
    // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
    [self.tableView startPullDown:YES];
    
    [self.unreadManager getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
        self.tableHeadView.iconArray = self.hotHeadIconArray;
        self.tableHeadView.titleArray = self.headTitleArray;
        self.headView.iconArray = self.hotHeadIconArray;
        self.headView.titleArray = self.headTitleArray;
        self.topView.iconArray = self.topIconArray;
        self.topView.titleArray = self.headTitleArray;
    }];
}

#pragma mark - UnreadNumManagerDelegate
- (void)reloadUnreadView:(TotalUnreadNumObject *)model {
    [self reloadHotHeadView];
}

#pragma mark - HotHeadViewDelegate
- (void)didSelectHeadViewItemWithIndex:(NSInteger)row {
    switch (row) {
        case 0:{
            LiveWebViewController *vc = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
            vc.isIntimacy = NO;
            vc.isUserProtocol = YES;
            vc.gaScreenName = NSLocalizedString(@"MAIL", nil);
            vc.url = [LSConfigManager manager].item.emfH5Url;
            vc.title = NSLocalizedString(@"MAIL", nil);
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            
        case 1:{
            LiveWebViewController *vc = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
            vc.isIntimacy = NO;
            vc.isUserProtocol = YES;
            vc.gaScreenName = NSLocalizedString(@"GREETING", nil);
            vc.url = [LSConfigManager manager].item.loiH5Url;
            vc.title = NSLocalizedString(@"GREETING", nil);
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            
        default:{
            [self.navigationController pushViewController:[LiveModule module].addCreditVc animated:YES];
        }break;
    }
}

#pragma mark - HotTopViewDelegate
- (void)didSelectTopViewItemWithIndex:(NSInteger)row {
    switch (row) {
        case 0:{
            LiveWebViewController *vc = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
            vc.isIntimacy = NO;
            vc.isUserProtocol = YES;
            vc.url = [LSConfigManager manager].item.emfH5Url;
            vc.title = NSLocalizedString(@"MAIL", nil);
            vc.gaScreenName = NSLocalizedString(@"MAIL", nil);
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            
        case 1:{
            LiveWebViewController *vc = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
            vc.isIntimacy = NO;
            vc.isUserProtocol = YES;
            vc.url = [LSConfigManager manager].item.loiH5Url;
            vc.title = NSLocalizedString(@"GREETING", nil);
            vc.gaScreenName = NSLocalizedString(@"GREETING", nil);
            [self.navigationController pushViewController:vc animated:YES];
        }break;
            
        default:{
            [self.navigationController pushViewController:[LiveModule module].addCreditVc animated:YES];
        }break;
    }
}

/** 免费的公开直播间 */
- (void)tableView:(HotTableView *)tableView didPublicViewFreeBroadcast:(NSInteger)index {
    
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    if (item.showInfo.showLiveId.length > 0) {
        InterimShowViewController * vc = [[InterimShowViewController alloc]init];
        // TODO:点击进入节目直播间
        [[LiveModule module].analyticsManager reportActionEvent:ShowEnterShowBroadcast eventCategory:EventCategoryenterBroadcast];
        LiveRoom *liveRoom = [[LiveRoom alloc] init];
        liveRoom.roomType = LiveRoomType_Public;
        liveRoom.httpLiveRoom = item;
        vc.liveRoom = liveRoom;
        // 继承导航栏控制器
        [self navgationControllerPresent:vc];
    }
    else
    {
        // TODO:点击立即免费公开
        [[LiveModule module].analyticsManager reportActionEvent:EnterPublicBroadcast eventCategory:EventCategoryenterBroadcast];
        PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
        LiveRoom *liveRoom = [[LiveRoom alloc] init];
        liveRoom.roomType = LiveRoomType_Public;
        
        liveRoom.httpLiveRoom = item;
        vc.liveRoom = liveRoom;
        // 继承导航栏控制器
        [self navgationControllerPresent:vc];
    }

}

/** 付费的公开直播间 */
- (void)tableView:(HotTableView *)tableView didPublicViewVipFeeBroadcast:(NSInteger)index {
    
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    if (item.showInfo.showLiveId.length > 0) {
        // TODO:点击进入节目直播间
        [[LiveModule module].analyticsManager reportActionEvent:ShowEnterShowBroadcast eventCategory:EventCategoryenterBroadcast];
        InterimShowViewController * vc = [[InterimShowViewController alloc]init];
        LiveRoom *liveRoom = [[LiveRoom alloc] init];
        liveRoom.roomType = LiveRoomType_Public;
        liveRoom.httpLiveRoom = item;
        vc.liveRoom = liveRoom;
        // 继承导航栏控制器
        [self navgationControllerPresent:vc];
    }
    else
    {
        // TODO:点击立即付费公开
        [[LiveModule module].analyticsManager reportActionEvent:EnterVipBroadcast eventCategory:EventCategoryenterBroadcast];
        PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
        LiveRoom *liveRoom = [[LiveRoom alloc] init];
        liveRoom.roomType = LiveRoomType_Public_VIP;
        liveRoom.httpLiveRoom = item;
        vc.liveRoom = liveRoom;
        // 继承导航栏控制器
        [self navgationControllerPresent:vc];
    }
}

/** 普通的私密直播间 */
- (void)tableView:(HotTableView *)tableView didPrivateStartBroadcast:(NSInteger)index {
    // TODO:点击立即付费私密
    [[LiveModule module].analyticsManager reportActionEvent:EnterPrivateBroadcast eventCategory:EventCategoryenterBroadcast];
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Private;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;
    // 继承导航栏控制器
    [self navgationControllerPresent:vc];
}
/** 豪华的私密直播间 */
- (void)tableView:(HotTableView *)tableView didStartVipPrivteBroadcast:(NSInteger)index {
    // TODO:点击立即付费豪华私密
    [[LiveModule module].analyticsManager reportActionEvent:EnterVipPrivateBroadcast eventCategory:EventCategoryenterBroadcast];
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Private;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;
    // 继承导航栏控制器
    [self navgationControllerPresent:vc];
}

- (void)navgationControllerPresent:(UIViewController *)controller {
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:controller];
    nvc.flag = YES;
    nvc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    nvc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    nvc.navigationBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, nil];
    [nvc.navigationBar setTitleTextAttributes:attributes];
    [nvc.navigationItem setHidesBackButton:YES];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

/** 预约的私密直播间 */
- (void)tableView:(HotTableView *)tableView didBookPrivateBroadcast:(NSInteger)index {
    // TODO:预约的私密直播间
    [[LiveModule module].analyticsManager reportActionEvent:SendRequestBooking eventCategory:EventCategoryenterBroadcast];
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    BookPrivateBroadcastViewController * vc = [[BookPrivateBroadcastViewController alloc]initWithNibName:nil bundle:nil];
    vc.userId = item.userId;
    vc.userName = item.nickName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat y = scrollView.contentOffset.y;

    if (self.topView.alpha != 1) {
        if (y <= kFunctionViewHeight/2) {
            [self.tableView  scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }else {
            [self.tableView setContentOffset:CGPointMake(0,kFunctionViewHeight) animated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    
    //NSLog(@"scrollView y:%f",y);
    
    if (y < kFunctionViewHeight) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    }
    
    float alpha = (1 - y/kFunctionViewHeight*1.5) >0 ? (1 - y/kFunctionViewHeight*1.5): 0;
    
    self.tableHeadView.alpha = alpha;
    if (alpha > 0.5) {
        
        self.topView.alpha = 0;
    } else {
        
        self.topView.alpha = 1 - alpha * 2;
    }
    
    if (y <= 0) {
        
        if (self.headView.hidden) {
            self.headView.hidden = NO;
            self.headView.tx_width = SCREEN_WIDTH;
            self.tableView.tx_y = kFunctionViewHeight;
            self.tableView.tx_height = SCREEN_HEIGHT - kFunctionViewHeight - (SCREEN_HEIGHT == 812?88:64);
            [self.tableView setTableHeaderView:[UIView new]];
        }
    }
    else if (y > 0)
    {
        if (!self.headView.hidden) {
            self.headView.hidden = YES;
            self.tableView.tx_y = 0;
            self.tableView.tx_height = SCREEN_HEIGHT - (SCREEN_HEIGHT == 812?88:64);
            [self.tableView setTableHeaderView:self.tableHeadView];
        }
    }
}
@end
