//
//  FollowingViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "FollowingViewController.h"
#import "FollowListItemObject.h"
#import "LSSessionRequestManager.h"
#import "GetFollowListRequest.h"
#import "IntroduceViewController.h"
#import "PreLiveViewController.h"
#import "BookPrivateBroadcastViewController.h"
#import "LiveADView.h"
#import "LiveModule.h"
#import "AnchorPersonalViewController.h"
#define PageSize 10

@interface FollowingViewController () <UIScrollViewRefreshDelegate, HotTableViewDelegate,LiveADViewDelegate,LSListViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *items;

/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
/** 广告banner */
@property (nonatomic, strong) LiveADView* adView;

@end

@implementation FollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCustomParam {
    [super initCustomParam];
    self.items = [NSMutableArray array];

    self.sessionManager = [LSSessionRequestManager manager];
    
    self.delegate = self;
}

- (void)dealloc {
}

- (void)setupContainView {
    [super setupContainView];

    //    [self setupCollectionView];

    // 初始化主播列表
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.items.count == 0) {
        // 第一次进来已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
        [self getListRequest:NO];
    }
}

- (void)setupCollectionView {
    //    UIView *vc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 414, 100)];
    //    vc.backgroundColor = [UIColor cyanColor];
    //
    //    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    //    btn.center = vc.center;
    //    [vc addSubview: btn];
    //
    //    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupTableView {
    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];

    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];


    LiveADView * adView = [[LiveADView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    adView.delegate = self;
    self.adView = adView;
    [self.tableView setTableHeaderView:adView];
 
    
    if (self.items.count > 0) {
        [self.tableView.tableHeaderView setHidden:NO];
    }else {
        [self.tableView.tableHeaderView setHidden:YES];
    }

    self.tableView.tableViewDelegate = self;
}

#pragma mark banner点击事件
- (void)liveADViewBannerURL:(NSString *)url title:(NSString *)title
{
   IntroduceViewController *introduceVc = [[IntroduceViewController alloc] initWithNibName:nil bundle:nil];
    introduceVc.bannerUrl = url;
    introduceVc.titleStr = title;
    [self.navigationController pushViewController:introduceVc animated:YES];
}

- (void)showTipsContent {

    self.failView.hidden = NO;
    self.failTipsText = NSLocalizedStringFromSelf(@"NO_FOLLOW_PERFORMER");
    self.failBtnText = NSLocalizedStringFromSelf(@"WATCH_HOT_LIVE");
//    self.delegateSelect = @selector(BrowseToHotAction:);
    [self reloadFailViewContent];
}

- (void)lsListViewController:(LSListViewController *)listView didClick:(UIButton *)sender {
    NSLog(@"%s",__func__);
    if ([listView.failBtnText isEqualToString:@"View Hot Broadcasts"]) {
        [self BrowseToHotAction:sender];
    }else if ([listView.failBtnText isEqualToString:@"Reload"]) {
        [self reloadBtnClickAction:sender];
    }
    
}

- (void)hideTipsContent {
    self.failView.hidden = YES;
}

- (void)showFailTipsContent {

    self.failView.hidden = NO;
    self.failTipsText = NSLocalizedString(@"List_FailTips",@"List_FailTips");
    self.failBtnText = NSLocalizedString(@"List_Reload",@"List_Reload");
//    self.delegateSelect = @selector(reloadBtnClickAction:);
    [self reloadFailViewContent];
}

#pragma mark - 数据逻辑

- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    if (isReloadView) {
        
        
        self.tableView.items = self.items;

        [self.tableView reloadData];

        //        UITableViewCell* cell = [self.tableView visibleCells].firstObject;
        //        NSIndexPath *index = [self.tableView indexPathForCell:cell];
        //        NSInteger row = index.row;
        //
        //        if( self.items.count > 0) {
        //            if( row < self.items.count ) {
        //                NSIndexPath* nextLadyIndex = [NSIndexPath indexPathForRow:row inSection:0];
        //                [self.tableView scrollToRowAtIndexPath:nextLadyIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        //            }
        //        }
    }
}

//- (void)followTableView:(FollowTableView *)tableView didSelectItem:(LiveRoomInfoItemObject *)item {
//    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] init];
//    listViewController.anchorId = item.userId;
//    [self.navigationController pushViewController:listViewController animated:YES];
//}

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

    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg, NSArray<FollowItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"HotViewController::getListRequest( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            if (success) {
                [self.tableView.tableHeaderView setHidden:NO];
                self.failView.hidden = YES;
                if (!loadMore) {

                    // 停止头部
                    [self.tableView finishPullDown:YES];

                    // 清空列表
                    [self.items removeAllObjects];
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                }
                // 排重
//                for (LiveRoomInfoItemObject *item in array) {
//                    [self addItemIfNotExist:item];
//                }
                
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
                            //                            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                            //                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
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

            } else {
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                     [self.items removeAllObjects];
                    [self showFailTipsContent];
                    [self.tableView.tableHeaderView setHidden:YES];

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


//- (void)reloadData:(BOOL)isReloadView {
//    // 数据填充
//    if( isReloadView ) {
//        self.collectionView.items = self.items;
//        [self.collectionView reloadData];
//    }
//}

- (void)BrowseToHotAction:(id)sender {
    //    [self initTestData];
    [self hideTipsContent];
    [self.homePageVC.pagingScrollView displayPagingViewAtIndex:0 animated:YES];

    //    [self reloadData:YES];
}
- (IBAction)reloadBtnClickAction:(id)sender {
    [self hideTipsContent];
    [self getListRequest:NO];
}

#pragma mark - 免费公开直播间
///** 免费的公开直播间 */
//- (void)tableView:(FollowTableView *)tableView didPublicViewFreeBroadcast:(NSInteger)index {
//    // TODO:点击立即免费公开
//        [[LiveModule module].analyticsManager reportActionEvent:EventCategoryenterBroadcast eventCategory:EventCategoryenterBroadcast];
//    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
//    LiveRoom *liveRoom = [[LiveRoom alloc] init];
//    liveRoom.roomType = LiveRoomType_Public;
//    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
//    liveRoom.httpLiveRoom = item;
//    vc.liveRoom = liveRoom;
//
//    [self navgationControllerPresent:vc];
//}
//
///** 付费的公开直播间 */
//- (void)tableView:(FollowTableView *)tableView didPublicViewVipFeeBroadcast:(NSInteger)index {
//    // TODO:点击立即付费公开
//     [[LiveModule module].analyticsManager reportActionEvent:EnterVipBroadcast eventCategory:EventCategoryenterBroadcast];
//    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
//    LiveRoom *liveRoom = [[LiveRoom alloc] init];
//    liveRoom.roomType = LiveRoomType_Public_VIP;
//    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
//    liveRoom.httpLiveRoom = item;
//    vc.liveRoom = liveRoom;
//
//    [self navgationControllerPresent:vc];
//}
//
///** 普通的私密直播间 */
//- (void)tableView:(FollowTableView *)tableView didPrivateStartBroadcast:(NSInteger)index {
//    // TODO:点击立即付费私密
//    [[LiveModule module].analyticsManager reportActionEvent:EnterPrivateBroadcast eventCategory:EventCategoryenterBroadcast];
//    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
//    LiveRoom *liveRoom = [[LiveRoom alloc] init];
//    liveRoom.roomType = LiveRoomType_Private;
//    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
//    liveRoom.httpLiveRoom = item;
//    vc.liveRoom = liveRoom;
//
//    [self navgationControllerPresent:vc];
//}
///** 豪华的私密直播间 */
//- (void)tableView:(FollowTableView *)tableView didStartVipPrivteBroadcast:(NSInteger)index {
//    // TODO:点击立即付费豪华私密
//    [[LiveModule module].analyticsManager reportActionEvent:EnterVipPrivateBroadcast eventCategory:EventCategoryenterBroadcast];
//    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
//    LiveRoom *liveRoom = [[LiveRoom alloc] init];
//    liveRoom.roomType = LiveRoomType_Private;
//    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
//    liveRoom.httpLiveRoom = item;
//    vc.liveRoom = liveRoom;
//
//    [self navgationControllerPresent:vc];
//}
//
//- (void)navgationControllerPresent:(UIViewController *)controller {
//    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:controller];
//    nvc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
//    nvc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
//    nvc.navigationBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
//    [nvc.navigationBar setTitleTextAttributes:attributes];
//    [nvc.navigationItem setHidesBackButton:YES];
//    [self.navigationController presentViewController:nvc animated:YES completion:nil];
//}
//
///** 预约的私密直播间 */
//- (void)tableView:(FollowTableView *)tableView didBookPrivateBroadcast:(NSInteger)index {
//    // TODO:预约的私密直播间
//      [[LiveModule module].analyticsManager reportActionEvent:SendRequestBooking eventCategory:EventCategoryenterBroadcast];
//    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
//    BookPrivateBroadcastViewController * vc = [[BookPrivateBroadcastViewController alloc]initWithNibName:nil bundle:nil];
//    vc.userId = item.userId;
//    vc.userName = item.nickName;
//     [self.navigationController pushViewController:vc animated:YES];
//}


/** 免费的公开直播间 */
- (void)tableView:(HotTableView *)tableView didPublicViewFreeBroadcast:(NSInteger)index {
    // TODO:点击立即免费公开
    [[LiveModule module].analyticsManager reportActionEvent:EnterPublicBroadcast eventCategory:EventCategoryenterBroadcast];
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Public;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
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
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
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
    liveRoom.roomType = LiveRoomType_Private;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;
    // 继承导航栏控制器
    [self navgationControllerPresent:vc];
}

- (void)navgationControllerPresent:(UIViewController *)controller {
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:controller];
    nvc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    nvc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    nvc.navigationBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
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


/** 点击女士 */
- (void)tableView:(HotTableView *)tableView didSelectItem:(LiveRoomInfoItemObject *)item {
    
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] init];
    listViewController.anchorId = item.userId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

@end
