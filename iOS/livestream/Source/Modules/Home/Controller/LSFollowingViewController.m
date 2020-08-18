//
//  LSFollowingViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSFollowingViewController.h"
#import "FollowListItemObject.h"
#import "LSSessionRequestManager.h"
#import "GetFollowListRequest.h"
#import "IntroduceViewController.h"
#import "PreLiveViewController.h"
#import "BookPrivateBroadcastViewController.h"
#import "LiveModule.h"
#import "AnchorPersonalViewController.h"
#import "HomeVouchersManager.h"
#import "InterimShowViewController.h"
#import "LiveGobalManager.h"
#import "QNChatViewController.h"
#import "LSSendMailViewController.h"
#import "LSSendSayHiViewController.h"
#import "SetFavoriteRequest.h"
#import "DialogTip.h"
#import "QNRiskControlManager.h"
#import "LSShadowView.h"
#import "LiveUrlHandler.h"
#define PageSize 10

@interface LSFollowingViewController () <UIScrollViewRefreshDelegate, LSHomeCollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;

/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (weak, nonatomic) IBOutlet UIImageView *noDataImageView;
@property (weak, nonatomic) IBOutlet UILabel *noDataTips;
@property (weak, nonatomic) IBOutlet UIButton *viewHotBtn;

/**
 是否加载数据
 */
@property (nonatomic, assign) BOOL isLoadData;
/**
 是否第一次登录
 */
@property (nonatomic, assign) BOOL isFirstLogin;
// 正在下拉
@property (nonatomic, assign) BOOL pullDowning;
// 正在上拉
@property (nonatomic, assign) BOOL pullUping;
@end

@implementation LSFollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始化主播列表
    [self setupTableView];

    self.viewHotBtn.layer.cornerRadius = 8.0f;
    self.viewHotBtn.layer.masksToBounds = YES;
    LSShadowView * view = [[LSShadowView alloc]init];
    [view showShadowAddView:self.viewHotBtn];
}

- (void)initCustomParam {
    [super initCustomParam];
    self.items = [NSMutableArray array];

    // Items for tab
    LSUITabBarItem *tabBarItem = [[LSUITabBarItem alloc] init];
    self.tabBarItem = tabBarItem;
    self.tabBarItem.title = @"Follow";
    self.tabBarItem.image = [[UIImage imageNamed:@"TabBarFollow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"TabBarFollow-Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSDictionary *normalColor = [NSDictionary dictionaryWithObject:Color(51, 51, 51, 1) forKey:NSForegroundColorAttributeName];
    NSDictionary *selectedColor = [NSDictionary dictionaryWithObject:Color(52, 120, 247, 1) forKey:NSForegroundColorAttributeName];
    [self.tabBarItem setTitleTextAttributes:normalColor forState:UIControlStateNormal];
    [self.tabBarItem setTitleTextAttributes:selectedColor forState:UIControlStateSelected];

    self.sessionManager = [LSSessionRequestManager manager];

    // 是否第一次登录
    self.isFirstLogin = NO;
    // 是否刷新数据
    self.isLoadData = NO;
    
    self.pullDowning = NO;
    
    self.pullUping = NO;
}

- (void)dealloc {
    [self.collectionView unSetupPullRefresh];
}

- (void)setupContainView {
    [super setupContainView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.viewDidAppearEver) {
        [self showTipsContent];
    }
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

- (void)setupTableView {
    // 初始化下拉
    [self.collectionView setupPullRefresh:self pullDown:YES pullUp:YES];
    self.collectionView.pullScrollEnabled = YES;
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.backgroundColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0xE7E8EE) orDark:COLOR_WITH_16BAND_RGB(0x666666)];
}

#pragma mark banner点击事件
// 显示没有数据页面
- (void)showTipsContent {
    self.noDataTips.hidden = NO;
    self.noDataImageView.hidden = NO;
    self.viewHotBtn.hidden = NO;
}

- (void)hideNoDataTipsContent {
    self.noDataTips.hidden = YES;
    self.noDataImageView.hidden = YES;
    self.viewHotBtn.hidden = YES;
}

- (void)lsListViewControllerDidClick:(UIButton *)sender {
    [super lsListViewControllerDidClick:sender];
    [self reloadBtnClickAction:sender];
}
- (IBAction)viewHotlistDidClick:(id)sender {
    [self BrowseToHotAction:sender];
}

- (void)hideTipsContent {
    self.failView.hidden = YES;
}

- (void)showFailTipsContent {
    self.failView.hidden = NO;
}

#pragma mark - 数据逻辑

- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    if (isReloadView) {
        self.collectionView.items = self.items;
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
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    if (!self.pullUping && !self.pullDowning) {
        [self getListRequest:NO];
    }
    self.pullDowning = YES;
}

- (void)pullUpRefresh {
    // 没有数据取消上拉操作
    if (self.items.count > 0) {
        if (!self.pullDowning && !self.pullUping) {
            [self getListRequest:YES];
        }
        self.pullUping = YES;
    } else {
        [self.collectionView finishLSPullUp:YES];
    }
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
    NSLog(@"LSFollowingViewController::getListRequest( loadMore : %@ )", BOOL2YES(loadMore));

    BOOL bFlag = NO;

    GetFollowListRequest *request = [[GetFollowListRequest alloc] init];

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

    // 隐藏没有数据内容
    [self hideNoDataTipsContent];
    // 调用接口
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<FollowItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSFollowingViewController::getListRequest( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            if (success) {

                [[HomeVouchersManager manager] getVouchersData:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, LSVoucherAvailableInfoItemObject *_Nonnull item) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"LSFollowingViewController::getVouchersData( [请求试聊券], %@ )", BOOL2SUCCESS(success));
                        self.failView.hidden = YES;
                        if (self.pullDowning) {
                            [self.collectionView finishLSPullDown:YES];
                            self.pullDowning = NO;
                        }
                        if (self.pullUping) {
                            [self.collectionView finishLSPullUp:YES];
                            self.pullUping = NO;
                        }
                        
                        if (!loadMore) {
                            // 清空列表
                            [self.items removeAllObjects];
                            self.isLoadData = NO;
                        }

                        for (FollowItemObject *item in array) {
                            LiveRoomInfoItemObject *itemInfo = [[LiveRoomInfoItemObject alloc] init];
                            itemInfo.photoUrl = item.photoUrl;
                            itemInfo.nickName = item.nickName;
                            itemInfo.userId = item.userId;
                            itemInfo.onlineStatus = item.onlineStatus;
                            itemInfo.roomPhotoUrl = item.roomPhotoUrl;
                            itemInfo.loveLevel = item.loveLevel;
                            itemInfo.addDate = item.addDate;
                            itemInfo.interest = item.interest;
                            itemInfo.anchorType = item.anchorType;
                            itemInfo.roomType = item.roomType;
                            itemInfo.showInfo = item.showInfo;
                            itemInfo.priv.isHasBookingAuth = item.priv.isHasBookingAuth;
                            itemInfo.priv.isHasOneOnOneAuth = item.priv.isHasOneOnOneAuth;
                            itemInfo.chatOnlineStatus = item.chatOnlineStatus;
                            itemInfo.isFollow = item.isFollow;
                            [self.items addObject:itemInfo];
                        }

                        if (self.items.count == 0) {
                            [self showTipsContent];
                        }

                        [self reloadData:YES];

                        if (!loadMore) {
                            if (self.items.count > 0) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                    // 拉到最顶
                                    [self.collectionView scrollsToTop];
                                });
                            }
                        } else {
//                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                                if (self.items.count > PageSize) {
//                                    // 拉到下一页
//                                    UITableViewCell *cell = [self.tableView visibleCells].firstObject;
//                                    NSIndexPath *index = [self.tableView indexPathForCell:cell];
//                                    NSInteger row = index.row;
//                                    NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:row + 1 inSection:0];
//                                    [self.tableView scrollToRowAtIndexPath:nextIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
//                                }
//                            });
                        }
                    });
                }];
            } else {
                if (!loadMore) {
                    [self.items removeAllObjects];
                    [self showFailTipsContent];
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

- (IBAction)reloadBtnClick:(id)sender {
    self.failView.hidden = YES;
    // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
    [self.collectionView startLSPullDown:YES];
}

- (void)BrowseToHotAction:(id)sender {
    [self hideTipsContent];
    //    [self.homePageVC.pagingScrollView displayPagingViewAtIndex:0 animated:YES];
    [self.followVCDelegate followingVCBrowseToHot];
}
- (IBAction)reloadBtnClickAction:(id)sender {
    [self hideTipsContent];
    [self getListRequest:NO];
}

#pragma mark - 瀑布流点击回调
//进入女士详情页
- (void)waterfallView:(UICollectionView *)waterfallView didSelectItem:(LiveRoomInfoItemObject *)item {
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = item.userId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
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
    if (![[QNRiskControlManager manager]isRiskControlType:RiskType_livechat withController:self]) {
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

- (void)waterfallView:(UICollectionView *)waterfallView homeListCellFocusBtnDid:(LiveRoomInfoItemObject *)item{
    SetFavoriteRequest *request = [[SetFavoriteRequest alloc] init];
    request.userId = item.userId;
    request.isFav = !item.isFollow;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSFollowingViewController::didFocusBtn( success : %d, errnum : %ld, errmsg : %@ )", success, (long)errnum, errmsg);
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
    LSSendSayHiViewController * vc = [[LSSendSayHiViewController alloc]initWithNibName:nil bundle:nil];
    vc.anchorId = item.userId;
    vc.anchorName = item.nickName;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
