//
//  LSMainViewController.m
//  livestream
//
//  Created by Max on 2017/5/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSMainViewController.h"

#import "StreamTestViewController.h"
#import "PreLiveViewController.h"
#import "BookPrivateBroadcastViewController.h"
#import "MeLevelViewController.h"
#import "LiveChannelAdViewController.h"
#import "MeLevelViewController.h"
#import "MyBackpackViewController.h"
#import "LSMyReservationsViewController.h"
#import "AnchorPersonalViewController.h"
#import "MyTicketPageViewController.h"

#import "LSChatListViewController.h"
#import "LSChatViewController.h"

#import "LSHomeSettingViewController.h"

// Modify by Max 2018/01/25
#import "HotViewController.h"
#import "FollowingViewController.h"
#import "LSUserInfoListViewController.h"

#import "LSLoginManager.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LiveMutexService.h"
#import "LSConfigManager.h"
#import "Masonry.h"

#import "LSInvitedToViewController.h"
#import "LSLiveGuideViewController.h"

#import "LSImManager.h"

// Modify by Max 2018/01/26
#import "LSUserUnreadCountManager.h"
#import "UnreadNumManager.h"

#import "HangOutViewController.h"

#import "LiveWebViewController.h"
#import "ShowListViewController.h"
#import "InterimShowViewController.h"
#import "HangOutPreViewController.h"
#import "LSChatListViewController.h"
#import "IntentionletterListViewController.h"
#import "CorrespondencePageViewController.h"

#import "ShowTipView.h"
#import "StartHangOutTipView.h"

#import "HangoutInvitePageViewController.h"

#import "LiveHeaderScrollview.h"
#import "HomeSegmentControl.h"
#import "LSPZPagingScrollView.h"

#import "LSBackgroudReloadManager.h"
@interface LSMainViewController () <LiveUrlHandlerDelegate, LoginManagerDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate, FollowingViewControllerDelegate, LSUserUnreadCountManagerDelegate, LSPZPagingScrollViewDelegate, StartHangOutTipViewDelegate, LiveHeaderScrollviewDelegate, UnreadNumManagerDelegate, UIGestureRecognizerDelegate, LSBackgroudReloadManagerDelegate, ShowListViewControllerDelegate>
/**
 内容页
 */
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;

@property (nonatomic, weak) IBOutlet LSPZPagingScrollView * pagingScrollView;

/**
 *  Login管理器
 */
@property (nonatomic, strong) LSLoginManager *loginManager;

/** 链接跳转管理器 */
@property (nonatomic, strong) LiveUrlHandler *handler;

// IM管理器
@property (nonatomic, strong) LSImManager *imManager;

// Modify by Max 2018/01/26
@property (nonatomic, strong) LSUserUnreadCountManager *unreadCountManager;
@property (nonatomic, assign) int unreadCount;

@property (nonatomic, strong) LiveHeaderScrollview *liveHeaderScrollview;

@property (nonatomic, strong) HomeSegmentControl *segment;

@property (nonatomic, strong) StartHangOutTipView *hangoutTipView;

@property (nonatomic, strong) UIButton *closeHangoutTipBtn;

@property (nonatomic, strong) UnreadNumManager *unreadManager;

@property (nonatomic, strong) LSHomeSettingViewController * settingVC;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipe;

@property (nonatomic, strong) UIView *coverView;
/**
 是否第一次登录
 */
@property (nonatomic, assign) BOOL isFirstLogin;

/**
 是否换站
 */
@property (nonatomic, assign) BOOL isSwitchSite;
@end

@implementation LSMainViewController

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat y = 64;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - 310) / 2;
    self.hangoutTipView.frame = CGRectMake(x, y, 310, 228);
}
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    NSLog(@"LSMainViewController::initCustomParam()");
    
    //self.navigationTitle = NSLocalizedStringFromSelf(@"NAVIGATION_ITEM_TITLE");
    
    // 监听登录事件
    self.loginManager = [LSLoginManager manager];
    [self.loginManager addDelegate:self];
    
    // 路径跳转
    self.handler = [LiveUrlHandler shareInstance];
    self.handler.delegate = self;
    
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    self.unreadCountManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadCountManager addDelegate:self];
    self.unreadCount = 0;
    
    self.unreadManager = [UnreadNumManager manager];
    [self.unreadManager addDelegate:self];
    
    [LSBackgroudReloadManager manager].delegate = self;
    
    // 第一次登录
    self.isFirstLogin = YES;
    // 是否换站
    self.isSwitchSite = NO;
}

- (void)dealloc {
    NSLog(@"LSMainViewController::dealloc()");
    
    // 去掉登录事件
    [self.loginManager removeDelegate:self];
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    [self.unreadCountManager removeDelegate:self];
    [self.unreadManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.curIndex = 0;
    
    // 主播Hot列表
    HotViewController *vcHot = [[HotViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:vcHot];
    
    // 主播Follow列表
    FollowingViewController *vcFollow = [[FollowingViewController alloc] initWithNibName:nil bundle:nil];
    vcFollow.followVCDelegate = self;
    [self addChildViewController:vcFollow];
    
    ShowListViewController *vcShowList = [[ShowListViewController alloc]initWithNibName:nil bundle:nil];
    vcShowList.showDelegate = self;
    [self addChildViewController:vcShowList];
    
    self.viewControllers = [NSArray arrayWithObjects:vcHot, vcFollow,vcShowList, nil];

    self.pagingScrollView.pagingViewDelegate = self;

    self.hangoutTipView = [[StartHangOutTipView alloc] init];
    self.hangoutTipView.hidden = YES;
    self.hangoutTipView.delegate = self;
    [self.navigationController.view addSubview:self.hangoutTipView];
    
    self.coverView = [[UIView alloc] init];
    self.coverView.backgroundColor = Color(0, 0, 0, 0.5);
    self.coverView.hidden = YES;
    [self.navigationController.view addSubview:self.coverView];
    
    [self addSwipeGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"LSMainViewController::viewWillAppear( animated : %@ )", BOOL2YES(animated));
    // 头部颜色
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

}

- (void)addSwipeGesture {
    if (self.swipe == nil) {
        self.swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
        self.swipe.delegate = self;
        [self.swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    }
}

- (void)removeSwipeGesture {
    if (self.swipe) {
        self.swipe = nil;
        self.swipe.delegate = nil;
        [self.view removeGestureRecognizer:self.swipe];
    }
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)sender {
    
    if(self.curIndex == 0 && sender.direction==UISwipeGestureRecognizerDirectionRight) {
        [self addSettingView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return YES;
}

- (void)backAction:(id)sender {
    [self addSettingView];
}

- (void)addSettingView {
    self.settingVC = [[LSHomeSettingViewController alloc]initWithNibName:nil bundle:nil];
    self.settingVC.mainVC = self;
    [self.navigationController addChildViewController:self.settingVC];
    [self.navigationController.view addSubview:self.settingVC.view];
    [self.settingVC viewWillAppear:NO];
    [self.settingVC showSettingView];
}

- (void)removeSettingView {
    [self.settingVC removeHomeSettingVC];
    [self.settingVC viewWillDisappear:NO];
}

- (void)enterHangoutRoom {
    HangOutPreViewController *vc = [[HangOutPreViewController alloc] initWithNibName:nil bundle:nil];
    [self navgationControllerPresent:vc];
    
    [self showHangoutTipView];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"LSMainViewController::viewDidAppear( animated : %@, viewDidAppearEver : %@ )", BOOL2YES(animated), BOOL2YES(self.viewDidAppearEver));
    if (!self.viewDidAppearEver) {
        // 选中默认页, 第一次进入
    }
    
    [super viewDidAppear:animated];
    
    [self.view addGestureRecognizer:self.swipe];
    
    // 禁止主界面右滑
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

    
    // 处理跳转URL
    [[LiveUrlHandler shareInstance] handleOpenURL];
    // 刷新未读
    [self reloadUnreadCount];
    
    [self.pagingScrollView layoutIfNeeded];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
    
    // 判断登录状态显示loading
    [self showLoadingForStatus];
}

- (void)showLoadingForStatus {
    switch (self.loginManager.status) {
        case NONE:
        case LOGINING:{
            [self.coverView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(self.navigationController.view);
            }];
            self.coverView.hidden = NO;
            [self showLoading];
        }break;
            
        default:{
            // 如果第一次登录 刷新列表数据
            if (self.isFirstLogin) {
                [self reloadVCData:NO];
                self.isFirstLogin = NO;
            }
            // 如果换站 刷新列表数据以及刷新标志位
            if (self.isSwitchSite) {
                [self reloadVCData:self.isSwitchSite];
                [self resetMainListLoad:YES];
                self.isSwitchSite = NO;
            }
            // 请求未读刷新hot页
            [self.unreadManager getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
                if (success) {
                    if (self.curIndex == 0) {
                        HotViewController *hotVC = (HotViewController *)self.viewControllers[self.curIndex];
                        [hotVC reloadHotHeadView];
                    }
                }
            }];
        }break;
    }
}

- (void)willMoveToParentViewController:(nullable UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    
    NSLog(@"LSMainViewController::willMoveToParentViewController( parent : %@ )", parent);
    
    if (!parent) {
        // 停止互斥服务
        [[LiveMutexService service] closeService];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"END_MODULE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self removeSettingView];
    } else {
        // 开始互斥服务
        [[LiveMutexService service] startService];
        [[NSUserDefaults standardUserDefaults] setObject:@"live" forKey:@"END_MODULE"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // 换站到直播服务
        if (!self.isFirstLogin) {
            self.isSwitchSite = YES;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"LSMainViewController::viewWillDisappear( animated : %@ )", BOOL2YES(animated));
    [self removeSettingView];
    // 移除手势
//    [self removeSwipeGesture];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"LSMainViewController::viewDidDisappear( animated : %@ )", BOOL2YES(animated));
    // 恢复右滑手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }

}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(backAction:) image:[UIImage imageNamed:@"Home_Me_Btn"]];
    
    self.liveHeaderScrollview  = [[LiveHeaderScrollview alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 45, 44)];
    self.liveHeaderScrollview.delegate = self;
    self.liveHeaderScrollview.dataSource = [NSArray arrayWithArray:[self setUpDataSource]];
    self.navigationItem.titleView = self.liveHeaderScrollview;
    
//    UIButton *rightBtn = [[UIButton alloc] init];
//    [rightBtn setImage:[UIImage imageNamed:@"Navigation_Right_Button"] forState:UIControlStateNormal];
//    [rightBtn addTarget:self action:@selector(enterHangoutRoom) forControlEvents:UIControlEventTouchUpInside];
//    [rightBtn sizeToFit];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];//为导航栏添加右侧按钮
}

- (NSArray *)setUpDataSource {
    return @[@"DISCOVER",@"FOLLOW",@"CALENDAR"];
}

#pragma mark - LiveHeaderScrollviewDelegate
- (void)header_disSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.curIndex = indexPath.row;
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
}

//- (void)segmentControlSelectedTag:(NSInteger)tag {
//    self.curIndex = tag;
//    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
//}

#pragma mark - ShowListViewControllerDelegate
- (void)reloadNowShowList {
    [self.liveHeaderScrollview reloadHeaderScrollview:NO];
}

#pragma mark - UnreadNumManagerDelegate
- (void)reloadUnreadView:(TotalUnreadNumObject *)model {
    if (model.ticketNoreadNum > 0) {
        [self.liveHeaderScrollview reloadHeaderScrollview:YES];
        ShowListViewController *showListVC = (ShowListViewController *)self.viewControllers[2];
        [showListVC setupLoadData:YES];
    }
}

#pragma mark - 画廊回调 (LSPZPagingScrollViewDelegate)
- (Class)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView classForIndex:(NSUInteger)index {
    return [UIView class];
}

- (NSUInteger)pagingScrollViewPagingViewCount:(LSPZPagingScrollView *)pagingScrollView {
    return (nil == self.viewControllers) ? 0 : self.viewControllers.count;
}

- (UIView *)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView pageViewForIndex:(NSUInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height)];
    return view;
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView preparePageViewForDisplay:(UIView *)pageView forIndex:(NSUInteger)index {
    
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    CGFloat pageViewHeight = pageView.self.frame.size.height;
    
    if (vc.view != nil) {
        [vc.view removeFromSuperview];
    }
    
    [pageView removeAllSubviews];
    
    [vc.view setFrame:CGRectMake(0, 0, pageView.self.frame.size.width, pageViewHeight)];
    [pageView addSubview:vc.view];
}

- (void)pagingScrollView:(LSPZPagingScrollView *)pagingScrollView didShowPageViewForDisplay:(NSUInteger)index {
    self.curIndex = index;
    [self reportDidShowPage:index];
    [self.liveHeaderScrollview scrollCollectionItemToDesWithDesIndex:self.curIndex];
    
    if (self.curIndex == 0) {
        HotViewController *hotVC = (HotViewController *)self.viewControllers[self.curIndex];
        [hotVC reloadUnreadNum];
    }
}

#pragma mark - LSLoginManager回调
- (void)manager:(LSLoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *_Nullable)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *_Nonnull)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errnum == HTTP_LCC_ERR_SUCCESS) {
            self.coverView.hidden = YES;
            [self hideLoading];
            
            [self.unreadManager getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
            }];
            
            if (self.viewControllers.count && self.isFirstLogin) {
                [self reloadVCData:NO];
                self.isFirstLogin = NO;
            }
        }
    });
}

- (void)manager:(LSLoginManager * _Nonnull)manager onLogout:(LogoutType)type msg:(NSString * _Nullable)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeSettingView];
        self.isFirstLogin = YES;
        [self resetMainListLoad:NO];
        [self resetMainListLogin:NO];
    });
}

#pragma mark - 刷新数据
- (void)reloadVCData:(BOOL)isSwitchSite {
    for (int index = 0; index < self.viewControllers.count; index++) {
        switch (index) {
            case 0:{
                HotViewController *hotVC = (HotViewController *)self.viewControllers[index];
                [hotVC setupFirstLogin:self.isFirstLogin];
                if (self.curIndex == index) {
                    [hotVC viewDidAppearGetList:isSwitchSite];
                    [hotVC reloadUnreadNum];
                }
            }break;
                
            case 1:{
                FollowingViewController *followVC = (FollowingViewController *)self.viewControllers[index];
                [followVC setupFirstLogin:self.isFirstLogin];
                if (self.curIndex == index) {
                    [followVC viewDidAppearGetList:isSwitchSite];
                }
            }break;
                
            default:{
                ShowListViewController *showListVC = (ShowListViewController *)self.viewControllers[index];
                [showListVC setupFirstLogin:self.isFirstLogin];
                if (self.curIndex == index) {
                    [showListVC viewDidAppearGetList:isSwitchSite];
                }
            }break;
        }
    }
}

- (void)resetMainListLoad:(BOOL)isLoadData {
    for (int index = 0; index < self.viewControllers.count; index++) {
        switch (index) {
            case 0:{
                HotViewController *hotVC = (HotViewController *)self.viewControllers[index];
                [hotVC setupLoadData:isLoadData];
            }break;
                
            case 1:{
                FollowingViewController *followVC = (FollowingViewController *)self.viewControllers[index];
                [followVC setupLoadData:isLoadData];
            }break;
                
            default:{
                ShowListViewController *showListVC = (ShowListViewController *)self.viewControllers[index];
                [showListVC setupLoadData:isLoadData];
            }break;
        }
    }
}

- (void)resetMainListLogin:(BOOL)isFirstLogin {
    for (int index = 0; index < self.viewControllers.count; index++) {
        switch (index) {
            case 0:{
                HotViewController *hotVC = (HotViewController *)self.viewControllers[index];
                [hotVC setupFirstLogin:isFirstLogin];
            }break;
                
            case 1:{
                FollowingViewController *followVC = (FollowingViewController *)self.viewControllers[index];
                [followVC setupFirstLogin:isFirstLogin];
            }break;
                
            default:{
                ShowListViewController *showListVC = (ShowListViewController *)self.viewControllers[index];
                [showListVC setupFirstLogin:isFirstLogin];
            }break;
        }
    }
}

#pragma mark - 多人互动
- (void)showHangoutTipView {
    [self.navigationController.view bringSubviewToFront:self.closeHangoutTipBtn];
    [self.navigationController.view bringSubviewToFront:self.hangoutTipView];
    [self.hangoutTipView showMainHangoutTip];
    self.closeHangoutTipBtn.hidden = NO;
    self.hangoutTipView.hidden = NO;
}

- (void)removeHangoutTip:(id)sender {
    self.closeHangoutTipBtn.hidden = YES;
    self.hangoutTipView.hidden = YES;
}

#pragma mark - StartHangOutTipViewDelegate
- (void)requestHangout:(StartHangOutTipView *)view {
    self.closeHangoutTipBtn.hidden = YES;
    self.hangoutTipView.hidden = YES;
    
    HangOutPreViewController *vc = [[HangOutPreViewController alloc] initWithNibName:nil bundle:nil];
    [self navgationControllerPresent:vc];
}

- (void)closeHangoutTip:(StartHangOutTipView *)view {
    self.closeHangoutTipBtn.hidden = YES;
    self.hangoutTipView.hidden = YES;
}

#pragma mark - 内容界面通知
- (void)followingVCBrowseToHot {
    // TODO:从Following列表切换到Hot列表
    self.curIndex = 0;
    [self reportDidShowPage:self.curIndex];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
    [self.liveHeaderScrollview scrollCollectionItemToDesWithDesIndex:self.curIndex];
}


#pragma mark - 获取用户中心未读数
- (void)reloadUnreadCount {
    // TODO:获取未读数量
    self.unreadCount = 0;
    [self.unreadCountManager getResevationsUnredCount];
}

- (void)onGetResevationsUnredCount:(BookingUnreadUnhandleNumItemObject *)item {
    // TODO:获取预约未读返回
    self.unreadCount = item.totalNoReadNum;
    [self.unreadCountManager getBackpackUnreadCount];
}

- (void)onGetBackpackUnreadCount:(GetBackPackUnreadNumItemObject *)item {
    // TODO:获取背包未读返回
    //    if (self.unreadCount == 0 && item.total > 0) {
    //        // TODO:显示红点
    //        LSUITabBarItem *tabBarItem = (LSUITabBarItem *)[self.tabBar.items objectAtIndex:3];
    //        tabBarItem.isShowNum = NO;
    //        tabBarItem.badgeValue = @"";
    //    } else {
    //        [self reloadUnreadMessage];
    //    }
}

- (void)reloadUnreadMessage {
    // TODO:刷新界面未读消息
    //    LSUITabBarItem *tabBarItem = (LSUITabBarItem *)[self.tabBar.items objectAtIndex:3];
    //    tabBarItem.isShowNum = YES;
    //    tabBarItem.badgeValue = nil;
    //    if (self.unreadCount == 0) {
    //        tabBarItem.badgeValue = nil;
    //    } else {
    //        if (self.unreadCount > 99) {
    //            tabBarItem.badgeValue = @"99+";
    //        } else {
    //            tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", self.unreadCount];
    //        }
    //    }
}

- (void)onRecvBackpackUpdateNotice:(BackpackInfoObject *)item {
    // TODO:接收背包更新通知
    [self reloadUnreadCount];
}

- (void)onRecvScheduledInviteUserNotice:(NSString *_Nonnull)inviteId anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    // TODO:接收主播预约私密邀请通知
    [self reloadUnreadCount];
}

- (void)onRecvSendBookingReplyNotice:(ImBookingReplyObject *_Nonnull)item {
    // TODO:接收预约私密邀请回复通知
    [self reloadUnreadCount];
}

- (void)onRecvBookingNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg leftSeconds:(int)leftSeconds {
    // TODO:接收预约开始倒数通知
    [self reloadUnreadCount];
}

- (void)onHandleLoginOnGingShowList:(NSArray<IMOngoingShowItemObject *> *)ongoingShowList
{
    IMOngoingShowItemObject * item = [ongoingShowList firstObject];
    NSLog(@"LSMainViewController 第一次IM登录接收节目开播通知类型:%d 消息内容:%@",item.type,item.msg);
    
    [self onRecvProgramPlayNotice:item.showInfo type:item.type msg:item.msg];
}

#pragma mark - LiveUrlHandler通知
- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openPublicLive:(NSString *_Nullable)roomId userId:(NSString *_Nullable)userId roomType:(LiveRoomType)roomType {
    // TODO:点击立即免费公开
    [[LiveModule module].analyticsManager reportActionEvent:EnterPublicBroadcast eventCategory:EventCategoryenterBroadcast];
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomId = roomId;
    liveRoom.userId = userId;
    liveRoom.roomType = roomType;
    vc.liveRoom = liveRoom;
    // 继承导航栏控制器
    [self navgationControllerPresent:vc];
}


- (void)liveUrlHandler:(LiveUrlHandler *)handler openPreLive:(NSString *)roomId userId:(NSString *)userId roomType:(LiveRoomType)roomType {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 主动邀请], roomId : %@, userId : %@, roomType : %u )", roomId, userId, roomType);
    // TODO:主动邀请, 跳转过渡页
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomId = roomId;
    liveRoom.userId = userId;
    liveRoom.roomType = roomType;
    vc.liveRoom = liveRoom;
    
    [self navgationControllerPresent:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openShow:(NSString *)showId userId:(NSString *)userId roomType:(LiveRoomType)roomType
{
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 进入节目], roomId : %@, userId : %@, roomType : %u )", showId, userId, roomType);
    // TODO:进入节目过渡页
    InterimShowViewController *vc = [[InterimShowViewController alloc] initWithNibName:nil bundle:nil];
    
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.showId = showId;
    liveRoom.userId = userId;
    liveRoom.roomType = roomType;
    vc.liveRoom = liveRoom;
    
    [self navgationControllerPresent:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openInvited:(NSString *_Nullable)userName userId:(NSString *_Nullable)userId inviteId:(NSString *_Nullable)inviteId {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 应邀], userName : %@, userId : %@, inviteId : %@ )", userName, userId, inviteId);
    // TODO:收到通知进入应邀过渡页
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.userId = userId;
    liveRoom.userName = userName;
    
    LSInvitedToViewController *vc = [[LSInvitedToViewController alloc] init];
    vc.inviteId = inviteId;
    vc.liveRoom = liveRoom;
    
    [self navgationControllerPresent:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler OpenHangout:(NSString *)roomId anchorId:(NSString * _Nullable)anchorId nickName:(NSString * _Nullable)nickName {
    NSLog(@"LSMainViewController::liveUrlHandlerOpenHangoutPre( [URL跳转, 进入多人互动直播间], roomId : %@, userId : %@)", roomId , anchorId);
    HangOutPreViewController *vc = [[HangOutPreViewController alloc] initWithNibName:nil bundle:nil];
    vc.roomId = roomId;
    
    vc.inviteAnchorId = anchorId;
    vc.inviteAnchorName = nickName;
    [self navgationControllerPresent:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openMainType:(int)index {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 主页], index : %i )", index);
    // TODO:收到通知进入主页
    [self.navigationController popToViewController:self animated:NO];
    self.curIndex = index;
    // 界面显示再切换标题页
    if (self.viewDidAppearEver) {
        [self.pagingScrollView layoutIfNeeded];
        [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openAnchorDetail:(NSString *)anchorId {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 主播资料页], anchorId : %@ )", anchorId);
    // TODO:收到通知进入主播资料页
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = anchorId;
    listViewController.enterRoom = 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:listViewController animated:NO];
    });
}

- (void)liveUrlHandler:(LiveUrlHandler *_Nonnull)handler openBooking:(NSString *_Nullable)anchorId userName:(NSString * _Nullable)userName{
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 新建预约页], anchorId : %@ )", anchorId);
    [self.navigationController popToViewController:self animated:NO];
    // TODO:收到通知进入新建预约页
    BookPrivateBroadcastViewController *bookPrivate = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    bookPrivate.userId = anchorId;
    bookPrivate.userName = userName;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    if (vc.presentedViewController) {
        vc = vc.presentedViewController;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [vc.navigationController pushViewController:bookPrivate animated:NO];
            });
        }
    }else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:bookPrivate animated:NO];
        });
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBookingList:(int)bookType {
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 预约列表页], bookType : %i )", bookType);
    [self.navigationController popToViewController:self animated:NO];
    // TODO:收到通知进入预约列表页
    LSMyReservationsViewController *reservation = [[LSMyReservationsViewController alloc] initWithNibName:nil bundle:nil];
    reservation.curIndex = bookType;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:reservation animated:NO];
    });
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBackpackList:(int)BackpackType {
    [self.navigationController popToViewController:self animated:NO];
    MyBackpackViewController *backPack = [[MyBackpackViewController alloc] initWithNibName:nil bundle:nil];
    backPack.curIndex = BackpackType ;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:backPack animated:NO];
    });

}

- (void)liveUrlHandlerOpenAddCredit:(LiveUrlHandler *)handler {
    //[self.navigationController popToViewController:self animated:NO];
    UIViewController *vc = [LiveModule module].addCreditVc;
    if (vc) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:NO];
        });
    }
}

- (void)liveUrlHandlerOpenMyLevel:(LiveUrlHandler *)handler {
    // TODO:进入我的等级界面
    [self.navigationController popToViewController:self animated:NO];
    MeLevelViewController *level = [[MeLevelViewController alloc] initWithNibName:nil bundle:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:level animated:NO];
    });
}

- (void)liveUrlHandlerOpenChatlist:(LiveUrlHandler *)handler {
    [self.navigationController popToViewController:self animated:NO];
    LSChatListViewController *chatlistVc = [[LSChatListViewController alloc] initWithNibName:nil bundle:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:chatlistVc animated:NO];
    });
}

- (void)liveUrlHandlerOpenGreetmaillist:(LiveUrlHandler *)handler {
    [self.navigationController popToViewController:self animated:NO];
    LiveWebViewController *vc = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
    vc.isIntimacy = NO;
    vc.isUserProtocol = YES;
    vc.gaScreenName =  NSLocalizedString(@"GREETING", nil);
    vc.url = [LSConfigManager manager].item.loiH5Url;
    vc.title = NSLocalizedString(@"GREETING", nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:NO];
    });
}

- (void)liveUrlHandlerOpenMaillist:(LiveUrlHandler *)handler {
    [self.navigationController popToViewController:self animated:NO];
    LiveWebViewController *vc = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
    vc.isIntimacy = NO;
    vc.isUserProtocol = YES;
    vc.gaScreenName = NSLocalizedString(@"MAIL", nil);
    vc.url = [LSConfigManager manager].item.emfH5Url;
    vc.title = NSLocalizedString(@"MAIL", nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:NO];
    });
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openChatWithAnchor:(NSString *)anchorId {
//    LSChatViewController *chatVc = [[LSChatViewController alloc] initWithNibName:nil bundle:nil];
//    [self.navigationController pushViewController:chatVc animated:NO];
}

- (void)navgationControllerPresent:(UIViewController *)controller {
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:controller];
    nvc.flag = YES;
    nvc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    nvc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    nvc.navigationBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,nil];
    [nvc.navigationBar setTitleTextAttributes:attributes];
    [nvc.navigationItem setHidesBackButton:YES];
    [self.navigationController presentViewController:nvc animated:NO completion:nil];
}

#pragma mark - 后台刷新
- (void)WillEnterForegroundReloadData {
    [self resetMainListLoad:YES];
    [self reloadVCData:NO];
}
@end
