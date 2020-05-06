//
//  LSMainViewController.m
//  livestream
//
//  Created by Max on 2017/5/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSMainViewController.h"
#pragma mark 公共模块
#import "Masonry.h"
#import "LiveModule.h"
#import "LiveMutexService.h"
#pragma mark 单例管理器
#import "LiveGobalManager.h"
#import "LSLoginManager.h"
#import "LiveUrlHandler.h"
#import "LSConfigManager.h"
#import "LSImManager.h"
#import "LSUserUnreadCountManager.h"
#import "LSBackgroudReloadManager.h"
#import "LSMainNotificationManager.h"
#import "LSMainOpenURLManager.h"
#import "LSMinLiveManager.h"
#import "LSPrePaidManager.h"
#pragma mark 界面
#import "LSHotViewController.h"
#import "LSFollowingViewController.h"
#import "LSHangoutListViewController.h"
#import "ShowListViewController.h"
#import "HangOutPreViewController.h"
#import "LSTestViewController.h"
#pragma mark 浮层view
#import "ShowTipView.h"
#import "StartHangOutTipView.h"
#import "LiveHeaderScrollview.h"
#import "HomeSegmentControl.h"
#import "LSPZPagingScrollView.h"
#import "MainNotificaitonView.h"
#import "LSLiveAdView.h"
#pragma mark 接口
#import "LSRetrieveBannerRequest.h"
#import "LSCheckDiscountRequest.h"

#define MainPageOverView 3

typedef enum AlertType {
    AlertTypeUpdate = 9001,
} AlertType;

@interface LSMainViewController () <LoginManagerDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate, LSFollowingViewControllerDelegate, LSPZPagingScrollViewDelegate, StartHangOutTipViewDelegate, LiveHeaderScrollviewDelegate, LSUserUnreadCountManagerDelegate, UIGestureRecognizerDelegate, LSBackgroudReloadManagerDelegate, ShowListViewControllerDelegate, LSHomeSettingViewControllerDelegate, LiveModuleDelegate, LSMainNotificationManagerDelegate, LiveAdViewDelegate, LSMinLiveManagerDelegate>

/**
 内容页
 */
@property (nonatomic, strong) NSArray<LSGoogleAnalyticsViewController *> *viewControllers;

/**
 *  Login管理器
 */
@property (nonatomic, strong) LSLoginManager *loginManager;

// IM管理器
@property (nonatomic, strong) LSImManager *imManager;

@property (nonatomic, strong) LiveHeaderScrollview *liveHeaderScrollview;

@property (nonatomic, strong) HomeSegmentControl *segment;

@property (nonatomic, strong) StartHangOutTipView *hangoutTipView;

@property (nonatomic, strong) UIButton *closeHangoutTipBtn;

@property (nonatomic, strong) LSUserUnreadCountManager *unreadManager;

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

@property (nonatomic, strong) MainNotificaitonView *mainNotificaitonView;

@property (nonatomic, strong) NSMutableArray *notifiArray;

@property (nonatomic, strong) LSLiveAdView *liveAdV;

@property (nonatomic, strong) LSMainOpenURLManager *openUrlManagr;
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
    self.canPopWithGesture = NO;

    // 监听登录事件
    self.loginManager = [LSLoginManager manager];
    [self.loginManager addDelegate:self];

    self.openUrlManagr = [[LSMainOpenURLManager alloc] init];

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

    [self.openUrlManagr removeMainVC];

    [[LSMinLiveManager manager] removeVC];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.curIndex = 0;

    // 主播Hot列表
    LSHotViewController *vcHot = [[LSHotViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:vcHot];

    // 主播Follow列表
    LSFollowingViewController *vcFollow = [[LSFollowingViewController alloc] initWithNibName:nil bundle:nil];
    vcFollow.followVCDelegate = self;
    [self addChildViewController:vcFollow];

    ShowListViewController *vcShowList = [[ShowListViewController alloc] initWithNibName:nil bundle:nil];
    vcShowList.showDelegate = self;
    [self addChildViewController:vcShowList];

    if (![LSLoginManager manager].loginItem.userPriv.hangoutPriv.isHangoutPriv) {
        self.viewControllers = [NSArray arrayWithObjects:vcHot, vcFollow, vcShowList, nil];
    } else {

        //多人互动列表
        LSHangoutListViewController *hangoutVC = [[LSHangoutListViewController alloc] initWithNibName:nil bundle:nil];
        [self addChildViewController:hangoutVC];

        self.viewControllers = [NSArray arrayWithObjects:vcHot, hangoutVC, vcFollow, vcShowList, nil];
    }

    self.pagingScrollView.pagingViewDelegate = self;
    self.pagingScrollView.delaysContentTouches = NO;

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

    if ([LSPrePaidManager manager].countriesArray.count == 0) {
        [[LSPrePaidManager manager] getCountryData];
    }

    //获取鲜花礼品折扣
    [self getStoreDiscount];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeSettingView];
    [self.liveAdV removeFromSuperview];
    self.liveAdV = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewDidAppearEver) {
        // 选中默认页, 第一次进入
        if ([LiveModule module].isUpdate) {
            // 存在可以升级的版本
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Update_Title", nil) message:[LiveModule module].updateDesc preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Not_Now", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *_Nonnull action) {
                                                                 [self loadADRequset];
                                                             }];
            UIAlertAction *updateAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Update", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *_Nonnull action) {
                                                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[LiveModule module].updateStoreURL]];
                                                             }];
            [alertVC addAction:cancelAC];
            [alertVC addAction:updateAC];
            [self presentViewController:alertVC animated:YES completion:nil];
        } else {
            [self loadADRequset];
        }

        [[LSMinLiveManager manager] setMinViewAddVC:self];
        [LSMinLiveManager manager].delegate = self;
    }

    [super viewDidAppear:animated];

    [self.view addGestureRecognizer:self.swipe];

    self.openUrlManagr.mainVC = self;
    // 登录成功后判断是否有内部链接未打开，有则跳转
    [[LiveUrlHandler shareInstance] openURL];

    [self.pagingScrollView layoutIfNeeded];
    [self.pagingScrollView displayPagingViewAtIndex:self.curIndex animated:NO];

    // 判断登录状态显示loading
    [self showLoadingForStatus];

    [LiveGobalManager manager].isInMainView = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [LiveGobalManager manager].isInMainView = NO;
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(backAction:) image:[UIImage imageNamed:@"Home_Me_Btn"]];
    self.liveHeaderScrollview = [[LiveHeaderScrollview alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 45, 44)];
    self.liveHeaderScrollview.delegate = self;
    self.liveHeaderScrollview.dataSource = [NSArray arrayWithArray:[self setUpDataSource]];
    self.navigationItem.titleView = self.liveHeaderScrollview;
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
    if ([otherGestureRecognizer.view isKindOfClass:[UICollectionView class]] || [otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"LSMinLiveView")]) {
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
        [self.unreadManager getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel){
        }];
        [self getStoreDiscount];
        [self.settingVC showSettingView];
        [self.settingVC viewWillAppear:NO];
        [self reportDidShowPage:MainPageOverView];
    }
}

- (void)lsHomeSettingViewControllerDidRemoveVC:(LSHomeSettingViewController *)homeSettingVC {
    [homeSettingVC.view removeFromSuperview];
    [homeSettingVC removeFromParentViewController];
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
    [self reportDidShowPage:self.curIndex];
    LSHotViewController *hotVC = (LSHotViewController *)self.viewControllers.firstObject;
    [hotVC setCanDidpush:YES];
}

- (void)removeSettingView {
    [self.settingVC removeHomeSettingVC];
    [self.settingVC viewWillDisappear:NO];
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

- (NSArray *)setUpDataSource {
    NSArray *title = [NSArray array];
    if (![LSLoginManager manager].loginItem.userPriv.hangoutPriv.isHangoutPriv) {
        title = @[ @"DISCOVER", @"FOLLOW", @"CALENDAR" ];
    } else {
        title = @[ @"DISCOVER", @"HANG-OUT", @"FOLLOW", @"CALENDAR" ];
    }
    return title;
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
            NSLog(@"LSMainViewController::onLogin( sessionErrorMsg : %@, errmsg : %@ )", sessionErrorMsg, errmsg);
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
            NSLog(@"LSMainViewController::onLogout( type : %d, errmsg : %@ )", type, msg);
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

#pragma mark - Hangout
- (void)removeHangoutTip:(id)sender {
    self.closeHangoutTipBtn.hidden = YES;
    self.hangoutTipView.hidden = YES;
}

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

#pragma mark - 后台刷新
- (void)WillEnterForegroundReloadData {
    [self resetMainListLoad:YES];
    [self reloadVCData:NO];
}

#pragma mark - 本地推送逻辑
- (void)mainNotificationManagerShowNotificaitonView:(LSMainNotificaitonModel *)model {

    if (!self.mainNotificaitonView) {
        self.mainNotificaitonView = [[MainNotificaitonView alloc] initWithFrame:CGRectMake(-screenSize.width, self.view.frame.size.height - 95, screenSize.width, 90)];
        [self.view addSubview:self.mainNotificaitonView];

        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect rect = self.mainNotificaitonView.frame;
                             rect.origin.x = 0;
                             self.mainNotificaitonView.frame = rect;
                         }];

        [self.notifiArray removeAllObjects];
        self.notifiArray = [NSMutableArray array];
    }
    [self.notifiArray insertObject:model atIndex:0];
    self.mainNotificaitonView.items = self.notifiArray;
    [self.mainNotificaitonView reloadData];
}

- (void)mainNotificationManagerHideNotificaitonView:(LSMainNotificaitonModel *)model {
    [self.notifiArray removeObject:model];
    self.mainNotificaitonView.items = self.notifiArray;
    [self.mainNotificaitonView deleteCollectionViewRow];
}

- (void)mainNotificationManagerRemoveNotificaitonView {
    [UIView animateWithDuration:0.3
        animations:^{
            CGRect rect = self.mainNotificaitonView.frame;
            rect.origin.x = screenSize.width;
            self.mainNotificaitonView.frame = rect;
        }
        completion:^(BOOL finished) {
            [self.mainNotificaitonView removeFromSuperview];
            self.mainNotificaitonView = nil;
        }];
}

#pragma mark - 广告逻辑
- (void)loadADRequset {
    LSRetrieveBannerRequest *request = [[LSRetrieveBannerRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *htmUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && htmUrl.length > 0) {
                NSLog(@"LSMainViewController::loadADRequset( [首页广告], htmUrl.length : %lu )", htmUrl.length);
                self.liveAdV = [[LSLiveAdView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                self.liveAdV.delegate = self;
                [self.view.window addSubview:self.liveAdV];
                [self.liveAdV loadHTmlStr:htmUrl baseUrl:nil];
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

- (void)liveAdViewDidClose:(LSLiveAdView *)adView {
    [self.liveAdV removeFromSuperview];
    self.liveAdV = nil;
}

- (void)liveAdViewRedirectURL:(NSURL *)url {
    // 打开重定向URL
    NSLog(@"LSMainViewController::liveAdViewRedirectURL( [打开重定向广告], url : %@ )", url);
    if (url) {
        [[LiveUrlHandler shareInstance] handleOpenURL:url];
    }
}

#pragma mark - 最小化处理(LSMinManagerDelegate)
- (void)pushMaxLive {
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self toVC:[LSMinLiveManager manager].liveVC];
    [[LSMinLiveManager manager] hidenMinLive];
}

#pragma mark - 鲜花礼品折扣
- (void)getStoreDiscount {
    LSCheckDiscountRequest *request = [[LSCheckDiscountRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSCheckDiscountItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && item.imgUrl > 0) {
                NSLog(@"LSMainViewController::getStoreDiscount success : %@, errnum : %d, errmsg : %@, imgUrl : %@", BOOL2SUCCESS(success),errnum,errmsg,item.imgUrl);
                [LiveModule module].flowersGift = item.imgUrl;
            }
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}
@end
