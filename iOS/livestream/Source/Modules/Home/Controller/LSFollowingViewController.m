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
#define PageSize 10

@interface LSFollowingViewController () <UIScrollViewRefreshDelegate, HotTableViewDelegate>

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
@end

@implementation LSFollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化主播列表
    [self setupTableView];
    
    self.viewHotBtn.layer.cornerRadius = 18.0f;
    self.viewHotBtn.layer.masksToBounds = YES;
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
}

- (void)dealloc {
    [self.tableView unInitPullRefresh];
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
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)updateTableViewVouchersData
{
    [[HomeVouchersManager manager] getVouchersData:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSVoucherAvailableInfoItemObject * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [HomeVouchersManager manager].item = item;
                [self.tableView reloadData];
            }
        });
    }];
}

- (void)setupTableView {
    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    
    self.tableView.tableViewDelegate = self;
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
    NSLog(@"%s",__func__);
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
        self.tableView.items = self.items;
        [self.tableView reloadData];
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
            [self.tableView startPullDown:YES];
            self.isFirstLogin = NO;
        }
    }
}

- (void)reloadUnreadNum {
    
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest:NO];
}

- (void)pullUpRefresh {
    // 没有数据取消上拉操作
    if (self.items.count > 0) {
        self.view.userInteractionEnabled = NO;
        [self getListRequest:YES];
    } else {
        [self.tableView finishPullUp:YES];
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
                
                [[HomeVouchersManager manager] getVouchersData:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSVoucherAvailableInfoItemObject * _Nonnull item) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"LSFollowingViewController::getVouchersData(请求试聊券:[%@])", BOOL2SUCCESS(success));
                        self.failView.hidden = YES;
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
                                    [self.tableView scrollsToTop];
                                });
                            }
                        }else {
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
                    [self showFailTipsContent];
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

- (IBAction)reloadBtnClick:(id)sender {
    self.failView.hidden = YES;
    // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
    [self.tableView startPullDown:YES];
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

#pragma mark - 免费公开直播间
/** 免费的公开直播间 */
- (void)tableView:(HotTableView *)tableView didPublicViewFreeBroadcast:(NSInteger)index {
    
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
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

/** 付费的公开直播间 */
- (void)tableView:(HotTableView *)tableView didPublicViewVipFeeBroadcast:(NSInteger)index {
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
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
    liveRoom.roomType = LiveRoomType_Private_VIP;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;
    // 继承导航栏控制器
    [self navgationControllerPresent:vc];
}

- (void)navgationControllerPresent:(UIViewController *)vc {
    [[LiveGobalManager manager] presentLiveRoomVCFromVC:self toVC:vc];
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


/** 点击女士 */
- (void)tableView:(HotTableView *)tableView didSelectItem:(LiveRoomInfoItemObject *)item {
    
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = item.userId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}


- (void)tableView:(HotTableView *)tableView didChatNowWithAnchor:(NSInteger)index {
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    QNChatViewController *vc = [[QNChatViewController alloc] initWithNibName:nil bundle:nil];
    vc.womanId = item.userId;
    vc.firstName = item.nickName;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)tableView:(HotTableView *)tableView diddidSendMailToAnchor:(NSInteger)index {
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    LSSendMailViewController *vc = [[LSSendMailViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = item.userId;
    vc.anchorName = item.nickName;
    vc.photoUrl = item.photoUrl;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
