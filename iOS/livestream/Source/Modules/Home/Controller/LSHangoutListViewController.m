//
//  LSHangoutListViewController.m
//  livestream
//
//  Created by Calvin on 2019/1/16.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "LSHangoutListViewController.h"
#import "GetFollowListRequest.h"
#import "HomeVouchersManager.h"
#import "StartHangOutTipView.h"
#import "LSGetHangoutOnlineAnchorRequest.h"
#import "AnchorPersonalViewController.h"
#import "HangoutDialogViewController.h"
#import "LSHangoutListHeadView.h"
#import "LiveModule.h"
#import "LSAnchorCardViewController.h"
#import "LiveGobalManager.h"
#define PageSize 10

@interface LSHangoutListViewController () <UIScrollViewRefreshDelegate, LSHangoutTableViewDelegate, LSHangoutListHeadViewDelegate>

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
/**
 是否加载数据
 */
@property (nonatomic, assign) BOOL isLoadData;
/**
 是否第一次登录
 */
@property (nonatomic, assign) BOOL isFirstLogin;

@property (weak, nonatomic) IBOutlet UIImageView *noDataIcon;
@property (weak, nonatomic) IBOutlet UILabel *noDataTips;
@property (nonatomic, strong) LSHangoutListHeadView *headView;
@end

@implementation LSHangoutListViewController

- (void)dealloc {
    [self.tableView unInitPullRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.items = [NSArray array];
    self.sessionManager = [LSSessionRequestManager manager];
    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:NO];
    [self setupTableView];
    //    [self setupTableHeaderView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self viewDidAppearGetList:NO];
    //    [self setupTableHeaderView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setupTableHeaderView];
}

- (void)initCustomParam {
    [super initCustomParam];
    // 是否第一次登录
    self.isFirstLogin = NO;
    // 是否刷新数据
    self.isLoadData = NO;
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

- (void)setupTableView {
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.tableViewDelegate = self;
    self.tableView.delaysContentTouches = NO;
}

- (void)setupTableHeaderView {
    NSString *showHangoutListTips = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShowHangoutListTips"];

    if (!(showHangoutListTips && showHangoutListTips.length > 0)) {
        LSHangoutListHeadView *view = [[LSHangoutListHeadView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 110)];
        view.hangoutHeadDelegate = self;
        view.moreContentViewHeight.constant = 0;
        view.moreContentView.hidden = YES;
        self.tableView.tableHeaderView = view;
    }
}

- (void)LSHangoutListHeadViewDidShowMore:(LSHangoutListHeadView *)view {
    view.moreContentViewHeight.constant = 44;
    view.moreContentView.hidden = NO;
    view.frame = CGRectMake(0, 0, screenSize.width, 280);
    [self.tableView setTableHeaderView:view];
}

- (void)LSHangoutListHeadViewDidHideMore:(LSHangoutListHeadView *)view {
    view.moreContentViewHeight.constant = 0;
    view.moreContentView.hidden = YES;
    view.frame = CGRectMake(0, 0, screenSize.width, 110);
    [self.tableView setTableHeaderView:view];
}

- (void)LSHangoutListHeadViewDidGetTips:(LSHangoutListHeadView *)view {
    if (view.notShowBtn.selected == YES) {
        [[NSUserDefaults standardUserDefaults] setObject:@"show" forKey:@"ShowHangoutListTips"];
        [self.tableView setTableHeaderView:nil];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ShowHangoutListTips"];
        view.showMoreBtn.selected = NO;
        [self LSHangoutListHeadViewDidHideMore:view];
    }
}

// 显示没有数据页面
- (void)showTipsContent {
    self.noDataTips.hidden = NO;
    self.noDataIcon.hidden = NO;
}

- (void)hideNoDataTipsContent {
    self.noDataTips.hidden = YES;
    self.noDataIcon.hidden = YES;
}

- (void)lsListViewControllerDidClick:(UIButton *)sender {
    self.failView.hidden = YES;
    // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
    [self.tableView startPullDown:YES];
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

#pragma mark 数据逻辑
- (void)getListRequest {
    LSGetHangoutOnlineAnchorRequest *request = [[LSGetHangoutOnlineAnchorRequest alloc] init];
    [self hideNoDataTipsContent];
    // 调用接口
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSHangoutListItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSHangoutListViewController::getListRequest( [%@], count : %ld )", BOOL2SUCCESS(success), (long)array.count);

            if (success) {
                self.failView.hidden = YES;
                self.isLoadData = NO;
                self.items = array;
                if (self.items.count == 0) {
                    //显示没有数据页面
                    [self showTipsContent];
                }
            } else {
                self.items = [NSArray array];
                self.failView.hidden = NO;
                // 加载失败会自动刷新
                self.isLoadData = YES;
            }
            // 停止头部
            [self.tableView finishPullDown:NO];
            [self reloadData];
            self.view.userInteractionEnabled = YES;
        });
    };

    [self.sessionManager sendRequest:request];
}

- (void)reloadData {
    self.tableView.items = self.items;
    [self.tableView reloadData];
}

- (void)tableView:(LSHangoutTableView *)tableView didShowItem:(NSIndexPath *)index {
    // TODO: 主播资料页点击
    LSHangoutListItemObject *item = [self.items objectAtIndex:index.row];
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = item.anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)tableView:(LSHangoutTableView *)tableView didClickHangout:(LSHangoutListItemObject *)item {
    // TODO: 多人互动弹窗
    HangoutDialogViewController *vc = [[LiveGobalManager manager] addDialogVc];
    vc.item = item;
    vc.anchorId = item.anchorId;
    vc.anchorName = item.nickName;
    [vc showhangoutView];
}

- (void)tableView:(LSHangoutTableView *)tableView didClickHangoutFriendCardMsg:(LSFriendsInfoItemObject *)item {
    // 好友卡片弹窗
    LSAnchorCardViewController *vc = [[LSAnchorCardViewController alloc] initWithNibName:nil bundle:nil];
    vc.userId = item.anchorId;
    vc.nickName = item.nickName;
    [vc showAnchorCardView:self.navigationController];
}


@end
