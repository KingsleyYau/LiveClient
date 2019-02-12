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
#import "MeLevelViewController.h"
#import "MyBackpackViewController.h"
#import "LSMyReservationsViewController.h"
#import "AnchorPersonalViewController.h"
#import "MyTicketPageViewController.h"

#import "LSChatViewController.h"
#import "LSMessageViewController.h"
#import "LSHomeSettingViewController.h"

// Modify by Max 2018/01/25
#import "LSHotViewController.h"
#import "LSFollowingViewController.h"
#import "LSUserInfoListViewController.h"
#import "LSHangoutListViewController.h"

#import "LiveGobalManager.h"
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

#import "HangOutViewController.h"

#import "LiveWebViewController.h"
#import "ShowListViewController.h"
#import "InterimShowViewController.h"
#import "HangOutPreViewController.h"
#import "IntentionletterListViewController.h"
#import "CorrespondencePageViewController.h"

#import "ShowTipView.h"
#import "StartHangOutTipView.h"

#import "HangoutInvitePageViewController.h"

#import "LiveHeaderScrollview.h"
#import "HomeSegmentControl.h"
#import "LSPZPagingScrollView.h"

#import "LSBackgroudReloadManager.h"
#import "LSAddCreditsViewController.h"

#import "QNChatAndInvitationViewController.h"

#import "QNLadyListNotificationView.h"
#import "QNChatViewController.h"
#import "LSSendMailViewController.h"
#import "LSMailViewController.h"
#import "LSGreetingsViewController.h"

#import "LSMainNotificationManager.h"
#import "MainNotificaitonView.h"
#import "HangoutDialogViewController.h"

#define MainPageOverView 3

typedef enum AlertType {
    AlertTypeUpdate = 9001,
} AlertType;


@interface LSMainViewController () <LiveUrlHandlerDelegate, LiveUrlHandlerParseDelegate, LoginManagerDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate, LSFollowingViewControllerDelegate, LSPZPagingScrollViewDelegate, StartHangOutTipViewDelegate, LiveHeaderScrollviewDelegate, LSUserUnreadCountManagerDelegate, UIGestureRecognizerDelegate, LSBackgroudReloadManagerDelegate, ShowListViewControllerDelegate, LSHomeSettingViewControllerDelegate, UIAlertViewDelegate,LiveModuleDelegate,LadyListNotificationViewDelegate,LSMainNotificationManagerDelegate>


/**
 内容页
 */
@property (nonatomic, strong) NSArray<LSGoogleAnalyticsViewController *> *viewControllers;

@property (nonatomic, weak) IBOutlet LSPZPagingScrollView *pagingScrollView;

/**
 *  Login管理器
 */
@property (nonatomic, strong) LSLoginManager *loginManager;

/** 链接跳转管理器 */
@property (nonatomic, strong) LiveUrlHandler *handler;

// IM管理器
@property (nonatomic, strong) LSImManager *imManager;

@property (nonatomic, strong) LiveHeaderScrollview *liveHeaderScrollview;

@property (nonatomic, strong) HomeSegmentControl *segment;

@property (nonatomic, strong) StartHangOutTipView *hangoutTipView;

@property (nonatomic, strong) UIButton *closeHangoutTipBtn;

@property (nonatomic, strong) LSUserUnreadCountManager *unreadManager;

@property (nonatomic, weak) LSHomeSettingViewController *settingVC;

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


@property (nonatomic, strong) QNLadyListNotificationView * notificationView;

@property (nonatomic, strong) MainNotificaitonView * mainNotificaitonView;

@end

@implementation LSMainViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat y = 64;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - 310) / 2;
    self.hangoutTipView.frame = CGRectMake(x, y, 310, 228);
}
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    //self.navigationTitle = NSLocalizedStringFromSelf(@"NAVIGATION_ITEM_TITLE");
    
    // 监听登录事件
    self.loginManager = [LSLoginManager manager];
    [self.loginManager addDelegate:self];
    
    // 路径跳转
    self.handler = [LiveUrlHandler shareInstance];
    self.handler.delegate = self;
    self.handler.parseDelegate = self;
    
    self.imManager = [LSImManager manager];
    [self.imManager addDelegate:self];
    [self.imManager.client addDelegate:self];
    
    self.unreadManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadManager addDelegate:self];
    
    [LSBackgroudReloadManager manager].delegate = self;
    
    [LiveModule module].noticeDelegate = self;
    
    [LSMainNotificationManager manager].delegate = self;
    // 第一次登录
    self.isFirstLogin = YES;
    // 是否换站
    self.isSwitchSite = NO;
}

- (void)dealloc {
    // 去掉登录事件
    [self.loginManager removeDelegate:self];
    
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    
    [self.unreadManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.curIndex = 0;
    
    // 主播Hot列表
    LSHotViewController *vcHot = [[LSHotViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:vcHot];
    
    //多人互动列表
    LSHangoutListViewController * hangoutVC = [[LSHangoutListViewController alloc]initWithNibName:nil bundle:nil];
    [self addChildViewController:hangoutVC];
    
    // 主播Follow列表
    LSFollowingViewController *vcFollow = [[LSFollowingViewController alloc] initWithNibName:nil bundle:nil];
    vcFollow.followVCDelegate = self;
    [self addChildViewController:vcFollow];
    
    ShowListViewController *vcShowList = [[ShowListViewController alloc] initWithNibName:nil bundle:nil];
    vcShowList.showDelegate = self;
    [self addChildViewController:vcShowList];
    
    self.viewControllers = [NSArray arrayWithObjects:vcHot, hangoutVC, vcFollow, vcShowList, nil];
    
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
    
    // 头部颜色
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)addSwipeGesture {
    if (self.swipe == nil) {
        self.swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
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
    
    if (self.curIndex == 0 && sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [self addSettingView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:[UICollectionView class]]) {
        return NO;
    }
    return YES;
}

- (void)backAction:(id)sender {
    [self addSettingView];
    //    LSChatAndInvitationViewController *vc = [[LSChatAndInvitationViewController alloc] initWithNibName:nil bundle:nil];
    //    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addSettingView {
    if ([self.navigationController.topViewController isEqual:self]) {
        LSHotViewController *hotVC = (LSHotViewController *)self.viewControllers.firstObject;
        [hotVC setCanDidpush:NO];
        LSHomeSettingViewController *settingVC = [[LSHomeSettingViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController addChildViewController:settingVC];
        [self.navigationController.view addSubview:settingVC.view];
        self.settingVC = settingVC;
        self.settingVC.homeDelegate = self;
        [self.settingVC showSettingView];
        [self.settingVC viewWillAppear:NO];
        [self reportDidShowPage:MainPageOverView];
    }
}

- (void)lsHomeSettingViewControllerDidRemoveVC:(LSHomeSettingViewController *)homeSettingVC {
    [homeSettingVC.view removeFromSuperview];
    [homeSettingVC removeFromParentViewController];
    [self reportDidShowPage:self.curIndex];
    LSHotViewController *hotVC = (LSHotViewController *)self.viewControllers.firstObject;
    [hotVC setCanDidpush:YES];
}

- (void)removeSettingView {
    [self.settingVC removeHomeSettingVC];
    [self.settingVC viewWillDisappear:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewDidAppearEver) {
        // 选中默认页, 第一次进入
        
        if ([LiveModule module].isUpdate) {
            // 存在可以升级的版本
            UIAlertView *updateAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Update_Title", nil) message:[LiveModule module].updateDesc delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Not_Now", nil), NSLocalizedString(@"Update", nil), nil];
            updateAlertView.tag = AlertTypeUpdate;
            [updateAlertView show];
        }
    }
    
    [super viewDidAppear:animated];
    
    [self.view addGestureRecognizer:self.swipe];
    
    // 禁止主界面右滑
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // 登录成功后判断是否有内部链接未打开，有则跳转
    [[LiveUrlHandler shareInstance] openURL];
    
    [self.pagingScrollView layoutIfNeeded];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
    
    // 判断登录状态显示loading
    [self showLoadingForStatus];
}

- (void)showLoadingForStatus {
    switch (self.loginManager.status) {
        case NONE:
        case LOGINING: {
            [self.coverView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.bottom.equalTo(self.navigationController.view);
            }];
            self.coverView.hidden = NO;
            [self showLoading];
        } break;
            
        default: {
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
                        LSHotViewController *hotVC = (LSHotViewController *)self.viewControllers[self.curIndex];
                        [hotVC reloadHotHeadView];
                    }
                }
            }];
        } break;
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
        //        [self removeSettingView];
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
    [self removeSettingView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 恢复右滑手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(backAction:) image:[UIImage imageNamed:@"Home_Me_Btn"]];
    
    self.liveHeaderScrollview = [[LiveHeaderScrollview alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 45, 44)];
    self.liveHeaderScrollview.delegate = self;
    self.liveHeaderScrollview.dataSource = [NSArray arrayWithArray:[self setUpDataSource]];
    self.navigationItem.titleView = self.liveHeaderScrollview;
    
}

- (NSArray *)setUpDataSource {
    return @[ @"DISCOVER",@"HANG-OUT", @"FOLLOW", @"CALENDAR" ];
}

#pragma mark - LiveHeaderScrollviewDelegate
- (void)header_disSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
        ShowListViewController *showListVC = (ShowListViewController *)self.viewControllers[3];
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
        LSHotViewController *hotVC = (LSHotViewController *)self.viewControllers[self.curIndex];
        [hotVC reloadUnreadNum];
    }
}

#pragma mark - LSLoginManager回调
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LSMainViewController::onLogin() success : %@", BOOL2SUCCESS(success));
        self.coverView.hidden = YES;
        [self hideLoading];
        if (errnum == HTTP_LCC_ERR_SUCCESS) {
            [self.unreadManager getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel){
            }];
            
            if (self.viewControllers.count && self.isFirstLogin) {
                [self reloadVCData:NO];
                self.isFirstLogin = NO;
            }
        } else {
            // 如果自动登录失败, 退出模块
            NSString *sessionErrorMsg = [LSSessionRequestManager manager].sessionErrorMsg;
            // 如果不是身份失效提示,使用登录回调的提示
            if (!sessionErrorMsg) {
                sessionErrorMsg = errmsg;
            }
            [manager logout:LogoutTypeKick msg:sessionErrorMsg];
            NSLog(@"LSMainViewController sessionErrorMsg: %@  errmsg:%@",sessionErrorMsg,errmsg);
        }
    });
}

- (void)manager:(LSLoginManager *)manager onLogout:(LogoutType)type msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        //        [self removeSettingView];
        self.isFirstLogin = YES;
        [self resetMainListLoad:NO];
        [self resetMainListLogin:NO];
        // 如果被踢添加弹窗提示
        if (type == LogoutTypeKick) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alertView show];
            NSLog(@"LSMainViewController onLogout: %d  errmsg:%@",type,msg);
        }
        
    });
}

#pragma mark - 刷新数据
- (void)reloadVCData:(BOOL)isSwitchSite {
    for (int index = 0; index < self.viewControllers.count; index++) {
        LSGoogleAnalyticsViewController *vc = self.viewControllers[index];
        [vc setupFirstLogin:self.isFirstLogin];
        if (self.curIndex == index) {
            [vc viewDidAppearGetList:isSwitchSite];
            [vc reloadUnreadNum];
        }
    }
}

- (void)resetMainListLoad:(BOOL)isLoadData {
    for (int index = 0; index < self.viewControllers.count; index++) {
        LSGoogleAnalyticsViewController *vc = self.viewControllers[index];
        [vc setupLoadData:isLoadData];
    }
}

- (void)resetMainListLogin:(BOOL)isFirstLogin {
    for (int index = 0; index < self.viewControllers.count; index++) {
        LSGoogleAnalyticsViewController *vc = self.viewControllers[index];
        [vc setupFirstLogin:isFirstLogin];
    }
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
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self toVC:vc];
}

- (void)closeHangoutTip:(StartHangOutTipView *)view {
    self.closeHangoutTipBtn.hidden = YES;
    self.hangoutTipView.hidden = YES;
}

#pragma mark - 内容界面通知
- (void)followingVCBrowseToHot {
    // TODO:从Following列表切换到Hot列表
    self.curIndex = 0;
    //    [self reportDidShowPage:self.curIndex];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:YES];
    [self.liveHeaderScrollview scrollCollectionItemToDesWithDesIndex:self.curIndex];
}

- (void)onHandleLoginOnGingShowList:(NSArray<IMOngoingShowItemObject *> *)ongoingShowList {
    IMOngoingShowItemObject *item = [ongoingShowList firstObject];
    NSLog(@"LSMainViewController 第一次IM登录接收节目开播通知类型:%d 消息内容:%@", item.type, item.msg);
    
    [self onRecvProgramPlayNotice:item.showInfo type:item.type msg:item.msg];
}

- (void)moduleOnNotification:(LiveModule *)module {
    [module pushInviteNotice];
}


#pragma mark - 链接打开内部模块处理
- (void)handlerUpdateUrl:(LiveUrlHandler *)handler {
    NSLog(@"LSMainViewController::handlerUpdateUrl( [URL更新], self : %p, viewDidAppearEver : %@ )", self, BOOL2YES(self.viewDidAppearEver));
    
    // TODO:如果界面已经展现, 收到URL打开模块通知, 直接处理
    if (self.viewDidAppearEver) {
        [self.settingVC removeHomeSettingVC];
        [handler openURL];
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openMainType:(LiveUrlMainListType)type {
    // TODO:收到通知进入主页
    int index = 0;
    switch (type) {
        case LiveUrlMainListTypeHot: {
            index = 0;
        } break;
        case LiveUrlMainListUrlTypeHangout: {
            index = 1;
        } break;
        case LiveUrlMainListUrlTypeFollow: {
            index = 2;
        } break;
        case LiveUrlMainListUrlTypeCalendar: {
            index = 3;
        } break;
        default:
            break;
    }
    
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 主页], type : %d, index : %d )", type, index);
    
    [self.navigationController popToViewController:self animated:NO];
    [self reportScreenForce];
    
    self.curIndex = index;
    
    // 界面显示再切换标题页
    if (self.viewDidAppearEver) {
        [self.pagingScrollView layoutIfNeeded];
        [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];
    }
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openAnchorDetail:(NSString *)anchorId {
    // TODO:收到通知进入主播资料页
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 主播资料页], anchorId : %@ )", anchorId);
    
    AnchorPersonalViewController *vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = anchorId;
    vc.enterRoom = 1;
    
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openPublicLive:(NSString *)roomId anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType {
    // TODO:点击立即免费公开
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 进入公开直播间], roomId : %@, anchorId : %@, roomType : %u )", roomId, anchorId, roomType);
    
    [[LiveModule module].analyticsManager reportActionEvent:EnterPublicBroadcast eventCategory:EventCategoryenterBroadcast];
    
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomId = roomId;
    liveRoom.userId = anchorId;
    liveRoom.roomType = roomType;
    vc.liveRoom = liveRoom;
    
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openPreLive:(NSString *)roomId anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType {
    // TODO:主动邀请, 跳转过渡页
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 主动邀请], roomId : %@, anchorId : %@, roomType : %u )", roomId, anchorId, roomType);
    [[LiveGobalManager manager] dismissLiveRoomVC];
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomId = roomId;
    liveRoom.userId = anchorId;
    liveRoom.roomType = roomType;
    vc.liveRoom = liveRoom;
    
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openShow:(NSString *)showId anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType {
    // TODO:进入节目过渡页
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 进入节目], roomId : %@, anchorId : %@, roomType : %u )", showId, anchorId, roomType);
    
    InterimShowViewController *vc = [[InterimShowViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.showId = showId;
    liveRoom.userId = anchorId;
    liveRoom.roomType = roomType;
    vc.liveRoom = liveRoom;
    
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openInvited:(NSString *)anchorName anchorId:(NSString *)anchorId inviteId:(NSString *)inviteId {
    // TODO:收到通知进入应邀过渡页
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 应邀], anchorName : %@, anchorId : %@, inviteId : %@ )", anchorName, anchorId, inviteId);
    [[LiveGobalManager manager] dismissLiveRoomVC];
    LSInvitedToViewController *vc = [[LSInvitedToViewController alloc] init];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.userId = anchorId;
    liveRoom.userName = anchorName;
    vc.inviteId = inviteId;
    vc.liveRoom = liveRoom;
    
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openHangout:(NSString *)roomId anchorId:(NSString *)anchorId anchorName:(NSString *)anchorName hangoutAnchorId:(NSString *)hangoutAnchorId hangoutAnchorName:(NSString *)hangoutAnchorName {
    // TODO:收到通知进入多人互动直播间
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 进入多人互动直播间], roomId : %@, anchorId : %@, anchorName : %@ )", roomId, anchorId, anchorName);
    
    HangOutPreViewController *vc = [[HangOutPreViewController alloc] initWithNibName:nil bundle:nil];
    vc.roomId = roomId;
    vc.inviteAnchorId = anchorId;
    vc.inviteAnchorName = anchorName;
//    vc.hangoutAnchorId = hangoutAnchorId;
//    vc.hangoutAnchorName = hangoutAnchorName;
    
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBooking:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:收到通知进入新建预约页
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 新建预约页], anchorId : %@, anchorName : %@ )", anchorId, anchorName);
    [self reportScreenForce];
    
    BookPrivateBroadcastViewController *vc = [[BookPrivateBroadcastViewController alloc] initWithNibName:nil bundle:nil];
    vc.userId = anchorId;
    vc.userName = anchorName;
    
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBookingList:(LiveUrlBookingListType)bookListType {
    // TODO:收到通知进入预约列表页
    int index = 0;
    switch (bookListType) {
        case LiveUrlBookingListTypeWaitUser: {
            index = 0;
        } break;
        case LiveUrlBookingListTypeWaitAnchor: {
            index = 1;
        } break;
        case LiveUrlBookingListTypeConfirm: {
            index = 2;
        } break;
        case LiveUrlBookingListTypeHistory: {
            index = 3;
        } break;
        default:
            break;
    }
    
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 预约列表页], bookType : %d, index : %d )", bookListType, index);
    [[LiveGobalManager manager] popToRootVC];
    [self reportScreenForce];
    
    LSMyReservationsViewController *vc = [[LSMyReservationsViewController alloc] initWithNibName:nil bundle:nil];
    vc.curIndex = index;
    
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openBackpackList:(LiveUrlBackpackListType)backpackType {
    // TODO:收到通知进入背包列表页
    int index = 0;
    switch (backpackType) {
        case LiveUrlBackPackListTypePresent: {
            index = 2;
        } break;
        case LiveUrlBackPackListTypeVoucher: {
            index = 1;
        } break;
        case LiveUrlBackPackListTypeDrive: {
            index = 3;
        } break;
        case LiveUrlBackPackListTypePostStamp: {
            index = 0;
        } break;
        default:
            break;
    }
    
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 背包列表页], backpackType : %d, index : %d )", backpackType, index);
    [[LiveGobalManager manager] popToRootVC];
    [self reportScreenForce];
    
    MyBackpackViewController *vc = [[MyBackpackViewController alloc] initWithNibName:nil bundle:nil];
    vc.curIndex = index;
    
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandlerOpenAddCredit:(LiveUrlHandler *)handler {
    NSLog(@"LSMainViewController::liveUrlHandlerOpenMyLevel( [URL跳转, 买点] )");
    // TODO:收到通知进入买点
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandlerOpenMyLevel:(LiveUrlHandler *)handler {
    // TODO:收到通知进入我的等级
    NSLog(@"LSMainViewController::liveUrlHandlerOpenMyLevel( [URL跳转, 我的等级] )");
    [[LiveGobalManager manager] popToRootVC];
    [self reportScreenForce];
    
    MeLevelViewController *vc = [[MeLevelViewController alloc] initWithNibName:nil bundle:nil];
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandlerOpenChatList:(LiveUrlHandler *)handler {
    // TODO:收到通知进入私信列表
    NSLog(@"LSMainViewController::liveUrlHandlerOpenChatList( [URL跳转, 聊天列表] )");
    [[LiveGobalManager manager] popToRootVC];
    [self reportScreenForce];
    
    LSMessageViewController *vc = [[LSMessageViewController alloc] initWithNibName:nil bundle:nil];
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler openChatWithAnchor:(NSString *)anchorId anchorName:(NSString *)anchorName {
    // TODO:进入私信界面
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 聊天界面] )");
    LSChatViewController *vc = [LSChatViewController initChatVCWithAnchorId:anchorId];
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandlerOpenGreetMailList:(LiveUrlHandler *)handler {
    // TODO:进入意向信列表
    NSLog(@"LSMainViewController::liveUrlHandlerOpenGreetMailList( [URL跳转, 意向信列表] )");
    [[LiveGobalManager manager] popToRootVC];
    LSGreetingsViewController *vc = [[LSGreetingsViewController alloc] initWithNibName:nil bundle:nil];
    
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandlerOpenMailList:(LiveUrlHandler *)handler {
    // TODO:进入信件列表
    NSLog(@"LSMainViewController::liveUrlHandlerOpenMailList( [URL跳转, 信件列表] )");
    [[LiveGobalManager manager] popToRootVC];
    LSMailViewController *vc = [[LSMailViewController alloc] initWithNibName:nil bundle:nil];
    
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenYesNoDialogTitle:(NSString *)title msg:(NSString *)msg yesTitle:(NSString *)yesTitle noTitle:(NSString *)noTitle yesUrl:(NSString *)yesUrl {
    // TODO:弹出对话框
    NSLog(@"LSMainViewController::liveUrlHandler( [URL跳转, 弹出对话框] )");
    
    UIAlertController *yesNoAlertView = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    // 如果没有No的标题则不显示
    if (noTitle.length > 0) {
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:noTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             
                                                         }];
        [yesNoAlertView addAction:noAction];
    }
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:yesTitle
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          if (yesUrl.length > 0) {
                                                              BOOL bFlag = [[LiveModule module].serviceManager canOpenURL:[NSURL URLWithString:yesUrl]];
                                                              if (bFlag) {
                                                                  // 可以处理的内部模块链接
                                                                  [[LiveModule module].serviceManager handleOpenURL:[NSURL URLWithString:yesUrl]];
                                                              } else {
                                                                  // 通过WebView打开的Http链接
                                                                  LiveWebViewController *vc = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
                                                                  vc.url = yesUrl;
                                                                  [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
                                                              }
                                                          }
                                                      }];
    [yesNoAlertView addAction:yesAction];
    
    [self presentViewController:yesNoAlertView animated:NO completion:nil];
}


- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenLiveChatLady:(NSString *)anchorId anchorName:(NSString *)anchorName {
    QNChatViewController *vc = [[QNChatViewController alloc] initWithNibName:nil bundle:nil];
    vc.womanId = anchorId;
    vc.firstName = anchorName;
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
    
}


- (void)liveUrlHandlerOpenLiveChatList:(LiveUrlHandler *)handler {
    [[LiveGobalManager manager] popToRootVC];
    QNChatAndInvitationViewController *vc = [[QNChatAndInvitationViewController alloc] initWithNibName:nil bundle:nil];
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenSendMail:(NSString *)anchorId anchorName:(NSString *)anchorName {
    LSSendMailViewController *vc = [[LSSendMailViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = anchorId;
    vc.anchorName = anchorName;
    [[LiveGobalManager manager] pushVCWithCurrentNVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenHangoutRoom:(NSString *)anchorId anchorName:(NSString *)anchorName {
    
    HangOutPreViewController *vc = [[HangOutPreViewController alloc] initWithNibName:nil bundle:nil];
    vc.inviteAnchorId = anchorId;
    vc.inviteAnchorName = anchorName;
    
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self toVC:vc];
}

- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenHangoutDialog:(NSString *)anchorId anchorName:(NSString *)anchorName {
    
    HangoutDialogViewController *vc = [[HangoutDialogViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = anchorId;
    vc.anchorName = anchorName;
    [self.navigationController addChildViewController:vc];
    [self.navigationController.view addSubview:vc.view];
    [vc showhangoutView];
}

#pragma mark - 后台刷新
- (void)WillEnterForegroundReloadData {
    [self resetMainListLoad:YES];
    [self reloadVCData:NO];
}

#pragma mark - alertView回调
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AlertTypeUpdate) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[LiveModule module].updateStoreURL]];
        }
    }
}

#pragma mark - 本地推送逻辑

- (void)LadyListNotificationViewDidToChat:(LSLCLiveChatUserItemObject *)item {
    if (item.chatType == LC_CHATTYPE_INVITE) {
        [[LiveModule module].analyticsManager reportActionEvent:ClickLiveChatInvitation eventCategory:EventCategoryLiveChat];
    }else if (item.chatType == LC_CHATTYPE_IN_CHAT_USE_TRY_TICKET || LC_CHATTYPE_IN_CHAT_CHARGE) {
        [[LiveModule module].analyticsManager reportActionEvent:ClickLiveChatMessage eventCategory:EventCategoryLiveChat];
    }
    NSLog(@"点击浮窗进入聊天室 UserID:%@",item.userName);
    QNChatViewController * vc = [[QNChatViewController alloc]initWithNibName:nil bundle:nil];
    vc.womanId = item.userId;
    vc.photoURL = item.imageUrl;
    vc.firstName = item.userName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)mainNotificationManagerShowNotificaitonView {
    
    if (!self.mainNotificaitonView) {
        self.mainNotificaitonView = [[MainNotificaitonView alloc]initWithFrame:CGRectMake(-screenSize.width, self.view.frame.size.height - 78, screenSize.width, 68)];
        [self.view addSubview:self.mainNotificaitonView];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.mainNotificaitonView.frame;
            rect.origin.x = 0;
            self.mainNotificaitonView.frame = rect;
        }];
    }

    [self.mainNotificaitonView reloadData];
}

- (void)mainNotificationManagerHideNotificaitonView:(NSInteger)row {
    
    [self.mainNotificaitonView deleteCollectionViewRow:row];
}

- (void)mainNotificationManagerRemoveNotificaitonView {
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.mainNotificaitonView.frame;
        rect.origin.x = screenSize.width;
        self.mainNotificaitonView.frame = rect;
    }completion:^(BOOL finished) {
        [self.mainNotificaitonView removeFromSuperview];
        self.mainNotificaitonView = nil;
    }];
}

@end
