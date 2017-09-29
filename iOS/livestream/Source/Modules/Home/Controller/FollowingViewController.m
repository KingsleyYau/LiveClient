//
//  FollowingViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "FollowingViewController.h"
#import "FollowListItemObject.h"
#import "SessionRequestManager.h"
#import "GetFollowListRequest.h"
#import "IntroduceViewController.h"
#import "PreLiveViewController.h"
#import "BookPrivateBroadcastViewController.h"

#define PageSize 10

@interface FollowingViewController () <UIScrollViewRefreshDelegate, FollowViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;

/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager *sessionManager;

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

    self.sessionManager = [SessionRequestManager manager];
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

    UIView *vc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 100)];
    vc.backgroundColor = [UIColor cyanColor];

    //    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    UIButton *btn = [[UIButton alloc] initWithFrame:vc.frame];
    //    btn.center = vc.center;
    [btn setBackgroundImage:[UIImage imageNamed:@"Home_HotAndFollow_TableViewHeader_Banner"] forState:UIControlStateNormal];
    [vc addSubview:btn];

    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.tableView setTableHeaderView:vc];
    [self.tableView.tableHeaderView setHidden:YES];

    self.tableView.tableViewDelegate = self;
}

- (void)showTipsContent {

    self.failView.hidden = NO;
    self.failTipsText = @"No following performers";
    self.failBtnText = @"Watch Hot Live";
    self.delegateSelect = @selector(BrowseToHotAction:);
    [self reloadFailViewContent];
}

- (void)hideTipsContent {
    self.failView.hidden = YES;
}

- (void)showFailTipsContent {

    self.failView.hidden = NO;
    self.failTipsText = @"Faild to load";
    self.failBtnText = @"Reload";
    self.delegateSelect = @selector(reloadBtnClickAction:);
    [self reloadFailViewContent];
}

#pragma mark - 数据逻辑

- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    if (isReloadView) {

        NSMutableSet *set = [NSMutableSet set];
        NSPredicate *duplicate = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bind) {

            LiveRoomInfoItemObject *objItem = (LiveRoomInfoItemObject *)obj;

            BOOL seen = [set containsObject:objItem.userId];

            if (!seen) {
                [set addObject:objItem.userId];
            }

            return !seen;

        }];

        NSArray *noRepeatArray = [NSMutableArray arrayWithArray:[self.items filteredArrayUsingPredicate:duplicate]];

        self.tableView.items = noRepeatArray;

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

//- (void)tableView:(HotTableView *)tableView didSelectItem:(LiveRoomInfoItemObject *)item {
//    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
//    LiveRoom *liveRoom = [[LiveRoom alloc] init];
//    liveRoom.roomType = LiveRoomType_Public;
//    liveRoom.httpLiveRoom = item;
//    vc.liveRoom = liveRoom;
//    [self.navigationController pushViewController:vc animated:YES];
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

    int start = 1;
    if (!loadMore) {
        // 刷最新
        start = 1;

    } else {
        // 刷更多
        start = self.items ? ((int)self.items.count + 1) : 1;
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

                for (LiveRoomInfoItemObject *item in array) {
                    [self addItemIfNotExist:item];
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
                }

            } else {
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    self.items = nil;
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

- (void)btnClick:(UIButton *)btn {
    IntroduceViewController *introduceVc = [[IntroduceViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:introduceVc animated:YES];
    NSLog(@"%s", __func__);
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
/** 免费的公开直播间 */
- (void)tableView:(FollowTableView *)tableView didPublicViewFreeBroadcast:(NSInteger)index {
    // TODO:点击立即免费公开
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Public;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;

    KKNavigationController *nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

/** 付费的公开直播间 */
- (void)tableView:(FollowTableView *)tableView didPublicViewVipFeeBroadcast:(NSInteger)index {
    // TODO:点击立即付费公开
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Public_VIP;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;

    KKNavigationController *nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

/** 普通的私密直播间 */
- (void)tableView:(FollowTableView *)tableView didPrivateStartBroadcast:(NSInteger)index {
    // TODO:点击立即付费私密
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Private;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;

    KKNavigationController *nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}
/** 豪华的私密直播间 */
- (void)tableView:(FollowTableView *)tableView didStartVipPrivteBroadcast:(NSInteger)index {
    // TODO:点击立即付费豪华私密
    PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
    LiveRoom *liveRoom = [[LiveRoom alloc] init];
    liveRoom.roomType = LiveRoomType_Private;
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    liveRoom.httpLiveRoom = item;
    vc.liveRoom = liveRoom;

    KKNavigationController *nvc = [[KKNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

/** 预约的私密直播间 */
- (void)tableView:(FollowTableView *)tableView didBookPrivateBroadcast:(NSInteger)index {
    // TODO:预约的私密直播间
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:index];
    BookPrivateBroadcastViewController * vc = [[BookPrivateBroadcastViewController alloc]initWithNibName:nil bundle:nil];
    vc.userId = item.userId;
    vc.userName = item.nickName;
     [self.navigationController pushViewController:vc animated:YES];
}

@end
