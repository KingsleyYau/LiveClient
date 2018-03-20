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
#import "PublicViewController.h"
#import "GetAnchorListRequest.h"
#import "IntroduceViewController.h"
#import "GetAnchorListRequest.h"
#import "LSLoginManager.h"
#import "BookPrivateBroadcastViewController.h"
#import "AnchorPersonalViewController.h"
#import "LiveADView.h"
#import "LiveModule.h"
#import "HomeVouchersManager.h"
#define PageSize 50
#define DefaultSize 16
@interface HotViewController () <UIScrollViewRefreshDelegate, HotTableViewDelegate, LiveADViewDelegate, LSListViewControllerDelegate>

/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

/**
 列表
 */
@property (nonatomic, strong) NSMutableArray *items;

/** 广告banner */
@property (nonatomic, strong) LiveADView *adView;

@end

@implementation HotViewController

- (void)initCustomParam {
    [super initCustomParam];

    // Items for tab
    LSUITabBarItem *tabBarItem = [[LSUITabBarItem alloc] init];
    self.tabBarItem = tabBarItem;
//    self.tabBarItem.title = @"Discover";
    self.tabBarItem.image = [[UIImage imageNamed:@"TabBarHot"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"TabBarHot-Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSDictionary *normalColor = [NSDictionary dictionaryWithObject:Color(51, 51, 51, 1) forKey:NSForegroundColorAttributeName];
    NSDictionary *selectedColor = [NSDictionary dictionaryWithObject:Color(52, 120, 247, 1) forKey:NSForegroundColorAttributeName];
    [self.tabBarItem setTitleTextAttributes:normalColor forState:UIControlStateNormal];
    [self.tabBarItem setTitleTextAttributes:selectedColor forState:UIControlStateSelected];
    
    self.items = [NSMutableArray array];

    self.sessionManager = [LSSessionRequestManager manager];

    // 设置失败页属性
    self.failTipsText = NSLocalizedString(@"List_FailTips", @"List_FailTips");

    self.failBtnText = NSLocalizedString(@"List_Reload", @"List_Reload");

    //    self.delegateSelect = @selector(reloadBtnClick:);
    self.delegate = self;
}

- (void)lsListViewController:(LSListViewController *)listView didClick:(UIButton *)sender {
    [self reloadBtnClick:sender];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tableView unInitPullRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 初始化主播列表
    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if (self.items.count == 0 ) {
        // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
        [self.tableView startPullDown:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    __weak typeof(self) weakSelf = self;
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:app
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakSelf.tableView startPullDown:YES];
                                                  }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableViewVouchersData) name:@"updateTableViewVouchersData" object:nil];
    [[HomeVouchersManager manager] getVouchersData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateTableViewVouchersData" object:nil];
}

- (void)updateTableViewVouchersData {
    [self.tableView reloadData];
}

- (void)setupContainView {
    [super setupContainView];
}

- (void)setupTableView {
    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];

    
    LiveADView *adView = [[LiveADView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    adView.delegate = self;
    self.adView = adView;
    [self.tableView setTableHeaderView:adView];

    if (self.items.count > 0) {
        [self.tableView.tableHeaderView setHidden:NO];
    } else {
        [self.tableView.tableHeaderView setHidden:YES];
    }

    self.tableView.tableViewDelegate = self;
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
                self.failView.hidden = YES;
                [[HomeVouchersManager manager] getVouchersData];
                [self.tableView.tableHeaderView setHidden:NO];
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    // 清空列表
                    [self.items removeAllObjects];

                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                }
                //排重
                //                for (LiveRoomInfoItemObject *item in array) {
                //                    [self addItemIfNotExist:item];
                //                }
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
            } else {
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    [self.items removeAllObjects];
                    [self.tableView.tableHeaderView setHidden:YES];
                    self.failView.hidden = NO;

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
}

/** 免费的公开直播间 */
- (void)tableView:(HotTableView *)tableView didPublicViewFreeBroadcast:(NSInteger)index {
    // TODO:点击立即免费公开
    [[LiveModule module].analyticsManager reportActionEvent:EnterPublicBroadcast eventCategory:EventCategoryenterBroadcast];
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Public;
//    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
//    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;
    // 继承导航栏控制器
    [self navgationControllerPresent:vc];
}

/** 付费的公开直播间 */
- (void)tableView:(HotTableView *)tableView didPublicViewVipFeeBroadcast:(NSInteger)index {
    // TODO:点击立即付费公开
    [[LiveModule module].analyticsManager reportActionEvent:EnterVipBroadcast eventCategory:EventCategoryenterBroadcast];
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Public_VIP;
//    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
//    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;
    // 继承导航栏控制器
    [self navgationControllerPresent:vc];
}

/** 普通的私密直播间 */
- (void)tableView:(HotTableView *)tableView didPrivateStartBroadcast:(NSInteger)index {
    // TODO:点击立即付费私密
    [[LiveModule module].analyticsManager reportActionEvent:EnterPrivateBroadcast eventCategory:EventCategoryenterBroadcast];
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Private;
//    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
//    liveRoom.httpLiveRoom = item;
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
//    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
//    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;
    // 继承导航栏控制器
    [self navgationControllerPresent:vc];
}

- (void)navgationControllerPresent:(UIViewController *)controller {
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:controller];
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
@end
