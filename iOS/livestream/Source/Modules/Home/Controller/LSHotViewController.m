//
//  LSHotViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSHotViewController.h"
#import "PreLiveViewController.h"
#import "LSSessionRequestManager.h"
#import "LSUserUnreadCountManager.h"
#import "GetAnchorListRequest.h"
#import "IntroduceViewController.h"
#import "GetAnchorListRequest.h"
#import "LSLoginManager.h"
#import "BookPrivateBroadcastViewController.h"
#import "AnchorPersonalViewController.h"
#import "LSMessageViewController.h"
#import "LiveModule.h"
#import "LSConfigManager.h"
#import "HomeVouchersManager.h"
#import "InterimShowViewController.h"
#import "LiveWebViewController.h"
#import "LSMessageViewController.h"
#import "HotHeadView.h"
#import "HotTopView.h"
#import "LSAddCreditsViewController.h"
#import "LiveGobalManager.h"
#import "QNChatAndInvitationViewController.h"

#import "LSGreetingsViewController.h"
#import "LSMailViewController.h"

#import "QNChatViewController.h"
#import "LSSendMailViewController.h"
#import "LSMailViewController.h"
#import "LSGreetingsViewController.h"
#import "QNRiskControlManager.h"
#import "LSSendSayHiViewController.h"
#import "SetFavoriteRequest.h"
#import "DialogTip.h"
#import "LSSayHiListViewController.h"
#import "HotListAdManager.h"
#import "LSHotListAdView.h"
#import "LiveUrlHandler.h"
#import "LSImManager.h"
#import "LSGetScheduleInviteStatusRequest.h"

#import "LSSeclectSendScheduleViewController.h"

#define PageSize 50
#define DefaultSize 16
#define kFunctionViewHeight 88
#define OffsetHeight self.pullDowning ? 88 + 60 : 88
#define kTopViewHeight 46
#define adIndex 3
@interface LSHotViewController () <UIScrollViewRefreshDelegate,
                                   HotHeadViewDelegate, HotTopViewDelegate, LSUserUnreadCountManagerDelegate, LSHomeCollectionViewDelegate, HotListAdManagerDelegate, LSHotListAdViewDelegate, IMLiveRoomManagerDelegate, IMManagerDelegate>

/** 接口管理器 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) LSUserUnreadCountManager *unreadManager;

/** 列表 */
@property (nonatomic, strong) NSMutableArray *items;
/** 列表 */
@property (nonatomic, strong) NSMutableArray *noticeItems;

@property (strong, nonatomic) HotTopView *topView;
@property (nonatomic, strong) HotHeadView *headView;

@property (nonatomic, strong) NSArray *hotHeadIconArray;
@property (nonatomic, strong) NSArray *headTitleArray;
@property (nonatomic, strong) NSArray *topIconArray;
/** 是否加载数据 */
@property (nonatomic, assign) BOOL isLoadData;
/** 是否第一次登录 */
@property (nonatomic, assign) BOOL isFirstLogin;
// 是否可点击
@property (nonatomic, assign) BOOL canDidClick;
// 正在下拉
@property (nonatomic, assign) BOOL pullDowning;
// 正在上拉
@property (nonatomic, assign) BOOL pullUping;
@property (nonatomic, strong) LSHotListAdView *liveWebView;

@property (nonatomic, strong) LSImManager *imManager;
@end

@implementation LSHotViewController

- (void)initCustomParam {
    [super initCustomParam];

    self.items = [NSMutableArray array];
    self.noticeItems = [NSMutableArray array];
    self.sessionManager = [LSSessionRequestManager manager];

    self.unreadManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadManager addDelegate:self];

    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];

    [HotListAdManager manager].hotAdDelegate = self;

    //    self.hotHeadIconArray = @[ @"Discover_Message_Btn", @"Discover_Mail_Btn", @"Discover_Greetings_Btn", @"Discover_QpCredits_Btn" ];
    //    self.headTitleArray = @[ @"Chat", @"Mail", @"Greetings", @"Add Credits" ];
    //    self.topIconArray = @[ @"Home_Message_Btn", @"Home_Mail_Btn", @"Home_Greetings_Btn", @"Home_QpCredits_Btn" ];

    if ([LSLoginManager manager].loginItem.userPriv.isSayHiPriv) {
        self.hotHeadIconArray = @[ @"Discover_Sayhi_Btn", @"Discover_Greetings_Btn", @"Discover_Mail_Btn", @"Discover_Message_Btn", @"Discover_QpCredits_Btn" ];
        self.headTitleArray = @[ @"Say Hi", @"Greetings", @"Mail", @"Chat", @"Credits" ];
        self.topIconArray = @[ @"Home_SayHi_Btn", @"Home_Greetings_Btn", @"Home_Mail_Btn", @"Home_Message_Btn", @"Home_QpCredits_Btn" ];
    } else {
        self.hotHeadIconArray = @[ @"Discover_Greetings_Btn", @"Discover_Mail_Btn", @"Discover_Message_Btn", @"Discover_QpCredits_Btn" ];
        self.headTitleArray = @[ @"Greetings", @"Mail", @"Chat", @"Credits" ];
        self.topIconArray = @[ @"Home_Greetings_Btn", @"Home_Mail_Btn", @"Home_Message_Btn", @"Home_QpCredits_Btn" ];
    }

    // 是否第一次登录
    self.isFirstLogin = NO;
    // 是否刷新数据
    self.isLoadData = NO;

    self.canDidClick = YES;

    self.pullDowning = NO;

    self.pullUping = NO;
}

- (void)setCanDidpush:(BOOL)canClick {
    self.canDidClick = canClick;
}

- (void)lsListViewControllerDidClick:(UIButton *)sender {
    [self reloadBtnClick:sender];
}

- (void)dealloc {
    NSLog(@"LSHotViewController %s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.collectionView unSetupPullRefresh];
    [self.unreadManager removeDelegate:self];
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    if (@available(iOS 11, *)) {
    //        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    //    } else {
    //        self.automaticallyAdjustsScrollViewInsets = NO;
    //    }
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

    if (self.pullDowning) {
        [self.collectionView finishLSPullDown:NO];
        self.pullDowning = NO;
    }
    if (self.pullUping) {
        [self.collectionView finishLSPullUp:NO];
        self.pullUping = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)updateTableViewVouchersData {

    [[HomeVouchersManager manager] getVouchersData:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, LSVoucherAvailableInfoItemObject *_Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [HomeVouchersManager manager].item = item;
                [self.collectionView reloadData];
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
    self.headView = [[HotHeadView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kFunctionViewHeight)];
    self.headView.backgroundColor = [UIColor whiteColor];
    self.headView.delagate = self;
    [self.view addSubview:self.headView];

    self.topView = [[HotTopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 46)];
    self.topView.delagate = self;
    [self.view addSubview:self.topView];
    [self.view bringSubviewToFront:self.topView];
    self.topView.alpha = 0;

    self.headView.iconArray = self.hotHeadIconArray;
    self.headView.titleArray = self.headTitleArray;
    self.topView.iconArray = self.topIconArray;
    self.topView.titleArray = self.headTitleArray;

    [self setupListHeadView];

    // self.tableView.tableViewDelegate = self;
    self.collectionView.frame = CGRectMake(0, kFunctionViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kFunctionViewHeight);
    self.collectionView.backgroundColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0xE7E8EE) orDark:COLOR_WITH_16BAND_RGB(0x666666)];
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.iconArray = self.hotHeadIconArray;
    self.collectionView.titleArray = self.headTitleArray;
    [self.collectionView setupPullRefresh:self pullDown:YES pullUp:YES];
    self.collectionView.pullScrollEnabled = YES;
}

- (void)setupListHeadView {
    // 顶部控件加载数据
    self.headView.iconArray = self.hotHeadIconArray;
    self.headView.titleArray = self.headTitleArray;
    self.topView.iconArray = self.topIconArray;
    self.topView.titleArray = self.headTitleArray;
}

#pragma mark - 数据逻辑

- (void)reloadData:(BOOL)isReloadView {
    NSLog(@"LSHotViewController::reloadData( isReloadView : %@ )", BOOL2YES(isReloadView));

    // 数据填充
    if (isReloadView) {
        self.collectionView.items = self.items;
        self.collectionView.noticeItems = self.noticeItems;
        [self.collectionView reloadData];
    }
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
            [self.collectionView startLSPullDown:YES];
            self.isFirstLogin = NO;
        }
    }
}

- (void)reloadUnreadNum {
    // 刷新未读显示
    [self.unreadManager getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
        [self reloadHotHeadView];
    }];
}

- (void)onGetChatlistUnreadCount:(int)count {
    [self reloadHotHeadView];
}

- (void)reloadHotHeadView {
    [self.collectionView.headView.collectionView reloadData];
    [self.headView.collectionView reloadData];
    [self.topView.collectionView reloadData];
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    if (!self.pullUping && !self.pullDowning) {
        [self getListRequest:NO];
    }
    self.pullDowning = YES;
}

- (void)pullUpRefresh {
    if (!self.pullDowning && !self.pullUping) {
        [self getListRequest:YES];
    }
    self.pullUping = YES;
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

- (void)pullUpRefresh:(UIScrollView *)scrollView {
    // 上拉更多回调
    [self pullUpRefresh];
}

#pragma mark 数据逻辑
- (BOOL)getListRequest:(BOOL)loadMore {
    NSLog(@"LSHotViewController::getListRequest( loadMore : %@ )", BOOL2YES(loadMore));

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
    request.isForTest = [LiveModule module].test;
    request.hasWatch = NO;

    // 调用接口
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSHotViewController::getListRequest( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            if (success) {
                //请求试聊券接口
                [[HomeVouchersManager manager] getVouchersData:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, LSVoucherAvailableInfoItemObject *_Nonnull item) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"LSHotViewController::getVouchersData(请求试聊券:[%@])", BOOL2SUCCESS(success));
                        [HomeVouchersManager manager].item = item;
                        self.failView.hidden = YES;
                        //                        if (self.pullDowning) {
                        //                            [self.collectionView finishLSPullDown:YES];
                        //                            self.pullDowning = NO;
                        //                        }
                        //                        if (self.pullUping) {
                        //                            [self.collectionView finishLSPullUp:YES];
                        //                            self.pullUping = NO;
                        //                        }
                        if (!loadMore) {
                            // 清空列表
                            [self.items removeAllObjects];
                            self.isLoadData = NO;
                        }

                        for (LiveRoomInfoItemObject *infoItem in array) {
                            [self.items addObject:infoItem];
                        }

                        if (!loadMore) {
                            [[HotListAdManager manager] getHotListAD];
                            if (self.items.count > 0) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                    // 拉到最顶
                                    [self.collectionView scrollsToTop];
                                });
                            }
                        } else {
                            [self reloadData:YES];

                            //                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            //                                if (self.items.count > PageSize) {
                            //                                    // 拉到下一页
                            //                                    UITableViewCell *cell = [self.tableView visibleCells].firstObject;
                            //                                    NSIndexPath *index = [self.tableView indexPathForCell:cell];
                            //                                    NSInteger row = index.row;
                            //                                    NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:row + 1 inSection:0];
                            //                                    [self.tableView scrollToRowAtIndexPath:nextIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            //                                }
                            //
                            //                            });
                        }
                    });
                }];

            } else {
                if (!loadMore) {
                    // 停止头部
                    [self.items removeAllObjects];
                    self.failView.hidden = NO;
                    self.isLoadData = YES;
                }

                if (self.pullDowning) {
                    [self.collectionView finishLSPullDown:NO];
                    self.pullDowning = NO;
                }
                if (self.pullUping) {
                    [self.collectionView finishLSPullUp:YES];
                    self.pullUping = NO;
                }

                [self reloadData:YES];
            }
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

- (void)hotListADLoad:(LSWomanListAdItemObject *)item Success:(BOOL)success {
    if (success) {
        // 有广告id才显示
        if (item.advertId.length > 0) {
            LiveRoomInfoItemObject *itemObject = [[LiveRoomInfoItemObject alloc] init];
            itemObject.adItem = item;
            if (self.items.count > 4) {
                // 固定广告为为第四位
                [self.items insertObject:itemObject atIndex:adIndex];
            }
        }
    }
    [self getScheduleInviteStatusRequest:NO];
    //    [self reloadData:YES];
}

- (void)reloadBtnClick:(id)sender {
    self.failView.hidden = YES;
    // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
    [self.collectionView startLSPullDown:YES];

    [self.unreadManager getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
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

- (void)waterfallView:(UICollectionView *)waterfallView homeListHotHeadBtnDid:(NSInteger)row {
    [self didSelectHeadViewItemWithIndex:row];
}

#pragma mark - HotHeadViewDelegate
- (void)didSelectHeadViewItemWithIndex:(NSInteger)row {
    if (self.canDidClick) {
        NSInteger indexRow = 0;
        if ([LSLoginManager manager].loginItem.userPriv.isSayHiPriv) {
            indexRow = row;
        } else {
            indexRow = row + 1;
        }
        switch (indexRow) {
            case 0: {
                LSSayHiListViewController *vc = [[LSSayHiListViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:vc animated:YES];
            } break;
            case 1: {
                LSGreetingsViewController *vc = [[LSGreetingsViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:vc animated:YES];
            } break;
            case 2: {
                LSMailViewController *vc = [[LSMailViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:vc animated:YES];
            } break;
            case 3: {
                if (![[QNRiskControlManager manager] isRiskControlType:RiskType_livechat withController:self]) {
                    QNChatAndInvitationViewController *vc = [[QNChatAndInvitationViewController alloc] initWithNibName:nil bundle:nil];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            } break;
            case 4: {
                LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
                [self.navigationController pushViewController:vc animated:YES];
            } break;

            default: {
            } break;
        }
    }
}

#pragma mark - HotTopViewDelegate
- (void)didSelectTopViewItemWithIndex:(NSInteger)row {
    [self didSelectHeadViewItemWithIndex:row];
}

#pragma mark - HotListAdDelegate
//打开重定向URL
- (void)lsLiveWebViewRedirectURL:(NSURL *)url {
    LiveWebViewController *webViewController = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
    webViewController.url = [NSString stringWithFormat:@"%@", url];
    ;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - 瀑布流点击回调
//进入女士详情页
- (void)waterfallView:(UICollectionView *)waterfallView didSelectItem:(LiveRoomInfoItemObject *)item {

    if (item.adItem) {
        NSString *url = [item.adItem.adurl UrlDecode];
        //        if ([url containsString:@"?"]) {
        //            url = [NSString stringWithFormat:@"%@&opentype=%d", url, (int)item.adItem.openType == 0 ? 3 : (int)item.adItem.openType];
        //        } else {
        //            url = [NSString stringWithFormat:@"%@?opentype=%d", url, (int)item.adItem.openType == 0 ? 3 : (int)item.adItem.openType];
        //        }
        //
        //        if (item.adItem.openType == LSAD_OT_SYSTEMBROWER) {
        //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        //        }else if (item.adItem.openType == LSAD_OT_APPBROWER) {
        //            [self lsLiveWebViewRedirectURL:[NSURL URLWithString:url]];
        //        }
        //        else {
        if (!self.liveWebView) {
            self.liveWebView = [[LSHotListAdView alloc] init];
            self.liveWebView.webDelegate = self;
            [self.view addSubview:self.liveWebView];
        }
        [self.liveWebView loadURL:url];
        //        }
    } else {
        AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
        listViewController.anchorId = item.userId;
        listViewController.enterRoom = 1;
        [self.navigationController pushViewController:listViewController animated:YES];
    }
}

/** 付费的公开直播间 */
- (void)waterfallView:(UICollectionView *)waterfallView homeListCellWatchNowBtnDid:(LiveRoomInfoItemObject *)item {
    // TODO:点击立即付费公开
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" anchorName:item.nickName anchorId:item.userId roomType:LiveRoomType_Public];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

/** 豪华的私密直播间 */
- (void)waterfallView:(UICollectionView *)waterfallView homeListCellInviteBtnDid:(LiveRoomInfoItemObject *)item {
    // TODO:点击立即付费豪华私密
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" anchorName:item.nickName anchorId:item.userId roomType:LiveRoomType_Private];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

- (void)navgationControllerPresent:(UIViewController *)vc {
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self toVC:vc];
}

/** 预约的私密直播间 */
- (void)waterfallView:(UICollectionView *)waterfallView homeListCellBookingBtnDid:(LiveRoomInfoItemObject *)item {
    // TODO:预约的私密直播间
    [[LiveModule module].analyticsManager reportActionEvent:SendRequestBooking eventCategory:EventCategoryenterBroadcast];
    BookPrivateBroadcastViewController *vc = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    vc.userId = item.userId;
    vc.userName = item.nickName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)waterfallView:(UICollectionView *)waterfallView homeListCellChatNowBtnDid:(LiveRoomInfoItemObject *)item {
    if (![[QNRiskControlManager manager] isRiskControlType:RiskType_livechat withController:self]) {
        QNChatViewController *vc = [[QNChatViewController alloc] initWithNibName:nil bundle:nil];
        vc.womanId = item.userId;
        vc.firstName = item.nickName;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)waterfallView:(UICollectionView *)waterfallView homeListCellSendMailBtnDid:(LiveRoomInfoItemObject *)item {
    LSSendMailViewController *vc = [[LSSendMailViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = item.userId;
    vc.anchorName = item.nickName;
    vc.photoUrl = item.photoUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)waterfallView:(UICollectionView *)waterfallView homeListCellFocusBtnDid:(LiveRoomInfoItemObject *)item {
    SetFavoriteRequest *request = [[SetFavoriteRequest alloc] init];
    request.userId = item.userId;
    request.isFav = !item.isFollow;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSHotViewController::didFocusBtn( success : %d, errnum : %ld, errmsg : %@ )", success, (long)errnum, errmsg);
            if (success) {
                item.isFollow = !item.isFollow;
                [self.collectionView reloadData];
            } else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"FOLLOW_FAIL")];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)waterfallView:(UICollectionView *)waterfallView homeListCellSayHiBtnDid:(LiveRoomInfoItemObject *)item {
    LSSendSayHiViewController *vc = [[LSSendSayHiViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = item.userId;
    vc.anchorName = item.nickName;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat y = scrollView.contentOffset.y;

    if (self.topView.alpha != 1) {
        if (y <= kFunctionViewHeight / 2) {
            [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        } else {
            [self.collectionView setContentOffset:CGPointMake(0, kFunctionViewHeight) animated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (self.items.count == 0) {
        return;
    }

    CGFloat y = scrollView.contentOffset.y;

    //    NSLog(@"scrollView y:%f",y);

    if (y < kFunctionViewHeight) {
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }

    float alpha = (1 - y / kFunctionViewHeight * 1.5) > 0 ? (1 - y / kFunctionViewHeight * 1.5) : 0;

    self.collectionView.headView.alpha = alpha;
    if (alpha > 0.5) {

        self.topView.alpha = 0;
    } else {

        self.topView.alpha = 1 - alpha * 2;
    }

    if (y < 0) {
        if (self.headView.hidden) {
            self.headView.hidden = NO;

            self.collectionView.frame = CGRectMake(0, kFunctionViewHeight, screenSize.width, screenSize.height - kFunctionViewHeight);
            self.collectionView.isShowHead = NO;
        }
    } else if (y > 0) {
        if (!self.headView.hidden) {
            self.headView.hidden = YES;
            self.collectionView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height - kFunctionViewHeight + 24);
            self.collectionView.isShowHead = YES;
        }
    }
}

- (void)onRecvScheduleStartNotice:(ImScheduleStartInfoObject *_Nonnull)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LSHotViewController::onRecvScheduleStartNotice");
        // 获取刷新即将开播以及已经开播的数字
        [self getScheduleInviteStatusRequest:YES];
    });
}

- (void)onRecvScheduleBeforeStartNotice:(ImScheduleStartInfoObject *)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LSHotViewController::onRecvScheduleBeforeStartNotice");
        [self getScheduleInviteStatusRequest:YES];
    });
}

- (void)updateSchedule:(int)willStartNum andAlreadyStartNum:(int)alreadyNum andLeftTime:(int)leftTime isNeedUpdate:(BOOL)isNeedUpdate {
    // 需要重新刷
    if (isNeedUpdate) {
        [self.noticeItems removeAllObjects];
    }
    int isStartNote = -1;
    int isWillStartNote = -1;

    for (int i = 0; i < self.noticeItems.count; i++) {
        LiveRoomInfoItemObject *item = self.noticeItems[i];
        if ([item.schedule.startNote isEqualToString:@"startNote"]) {
            isStartNote = i;
        }
    }
    if (isStartNote >= 0) {
        // 如果已经开始数量不为0则更新数据
        if (alreadyNum > 0) {
            LiveRoomInfoItemObject *item = [[LiveRoomInfoItemObject alloc] init];
            LSHomeScheduleItem *scheduleItem = [[LSHomeScheduleItem alloc] init];
            scheduleItem.type = HomeScheduleNoteTypeStart;
            scheduleItem.startNum = alreadyNum;
            scheduleItem.leftTime = leftTime;
            scheduleItem.startNote = @"startNote";
            item.schedule = scheduleItem;
            [self.noticeItems replaceObjectAtIndex:isStartNote withObject:item];
        } else {
            // 如果已经开始数量为0则移除数据
            [self.noticeItems removeObjectAtIndex:isStartNote];
        }

    } else {
        LiveRoomInfoItemObject *item = [[LiveRoomInfoItemObject alloc] init];
        LSHomeScheduleItem *scheduleItem = [[LSHomeScheduleItem alloc] init];
        scheduleItem.type = HomeScheduleNoteTypeStart;
        scheduleItem.startNum = alreadyNum;
        scheduleItem.leftTime = leftTime;
        scheduleItem.startNote = @"startNote";
        item.schedule = scheduleItem;
        if ([LSLoginManager manager].loginItem.isShowStartNotice || isNeedUpdate) {
            if (alreadyNum > 0) {
                [self.noticeItems addObject:item];
            }
        }
    }

    for (int i = 0; i < self.noticeItems.count; i++) {
        LiveRoomInfoItemObject *item = self.noticeItems[i];
        if ([item.schedule.willStartNote isEqualToString:@"willStart"]) {
            isWillStartNote = i;
        }
    }
    if (isWillStartNote >= 0) {
        // 如果已经开始数量不为0则更新数据
        if (willStartNum > 0) {
            LiveRoomInfoItemObject *item = [[LiveRoomInfoItemObject alloc] init];
            LSHomeScheduleItem *scheduleItem = [[LSHomeScheduleItem alloc] init];
            scheduleItem.willStartNum = willStartNum;
            scheduleItem.type = HomeScheduleNoteTypeWillStart;
            scheduleItem.leftTime = leftTime;
            scheduleItem.willStartNote = @"willStart";
            item.schedule = scheduleItem;
            [self.noticeItems replaceObjectAtIndex:isWillStartNote withObject:item];
        } else {
            // 如果即将开始数量为0则移除数据
            [self.noticeItems removeObjectAtIndex:isWillStartNote];
        }

    } else {
        LiveRoomInfoItemObject *item = [[LiveRoomInfoItemObject alloc] init];
        LSHomeScheduleItem *scheduleItem = [[LSHomeScheduleItem alloc] init];
        scheduleItem.willStartNum = willStartNum;
        // 即将开始设置开始数据为0
        scheduleItem.type = HomeScheduleNoteTypeWillStart;
        scheduleItem.leftTime = leftTime;
        scheduleItem.willStartNote = @"willStart";
        item.schedule = scheduleItem;
        if ([LSLoginManager manager].loginItem.isShowWillStartNotice || isNeedUpdate) {
            if (willStartNum > 0) {
                [self.noticeItems addObject:item];
            }
        }
    }
}

- (void)waterfallView:(UICollectionView *)waterfallView homeScheduleDidRemove:(LiveRoomInfoItemObject *)item {
    if ([item.schedule.startNote isEqualToString:@"startNote"]) {
        [LSLoginManager manager].loginItem.isShowStartNotice = NO;
    } else if ([item.schedule.willStartNote isEqualToString:@"willStart"]) {
        [LSLoginManager manager].loginItem.isShowWillStartNotice = NO;
    }
    [self.noticeItems removeObject:item];
    [self reloadData:YES];
}

- (void)getScheduleInviteStatusRequest:(BOOL)needUpdate {
    LSGetScheduleInviteStatusRequest *request = [[LSGetScheduleInviteStatusRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSScheduleinviteStatusItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSHotViewController::getScheduleInviteStatusRequest( success : %d, errnum : %ld, errmsg : %@ beStrtTime %d startLeftSeconds %d) ", success, (long)errnum, errmsg, (int)item.beStrtTime, item.startLeftSeconds);
            // 接口完成后才修改z下拉状态
            if (self.pullDowning) {
                [self.collectionView finishLSPullDown:YES];
                self.pullDowning = NO;
            }
            if (self.pullUping) {
                [self.collectionView finishLSPullUp:YES];
                self.pullUping = NO;
            }
            double leftSeconds = item.startLeftSeconds / 60.0f;
            //          向上取整
            int leftToStartTime = ceil(leftSeconds);
            if (success) {
                [self updateSchedule:item.beStartNum andAlreadyStartNum:item.needStartNum andLeftTime:leftToStartTime isNeedUpdate:needUpdate];
            }
            
            [self reloadData:YES];
        });
    };
    [self.sessionManager sendRequest:request];
    
}
@end
