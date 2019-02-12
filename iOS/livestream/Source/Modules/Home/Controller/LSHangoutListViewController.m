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
#import "StartHangOutWithFriendView.h"
#import "LSGetHangoutOnlineAnchorRequest.h"
#import "AnchorPersonalViewController.h"
#import "HangoutDialogViewController.h"
#import "LSHangoutListHeadView.h"
#import "LiveModule.h"
#define PageSize 10

@interface LSHangoutListViewController () <UIScrollViewRefreshDelegate, LSHangoutTableViewDelegate,LSHangoutListHeadViewDelegate>

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

@property (nonatomic, strong) LSHangoutListHeadView *headView;
@end

@implementation LSHangoutListViewController

- (void)dealloc {
    [self.tableView unInitPullRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = [NSArray array];
    self.sessionManager = [LSSessionRequestManager manager];
    
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self viewDidAppearGetList:NO];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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
    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:NO];
    
//    LSHangoutListHeadView *view = [[LSHangoutListHeadView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 90)];
//    view.hangoutHeadDelegate = self;
//    self.tableView.tableHeaderView = view;
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    self.tableView.tableViewDelegate = self;
}

//- (void)LSHangoutListHeadViewDidShowMore:(LSHangoutListHeadView *)view {
//    view.moreContentViewHeight.constant = 30;
//    view.moreContentView.hidden = NO;
//    view.frame = CGRectMake(0, 0, screenSize.width, 180);
//    [self.tableView setTableHeaderView:view];
//}

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
    // 调用接口
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSHangoutListItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSFollowingViewController::getListRequest( [%@], count : %ld )", BOOL2SUCCESS(success), (long)array.count);
                if (success) {
                    self.failView.hidden = YES;
                    self.isLoadData = NO;
                    self.items = array;
                    if (self.items.count == 0) {
                        //显示没有数据页面
                    }
                } else {
                    self.failView.hidden = NO;
                    self.isLoadData = YES;
                }
                 // 停止头部
                 [self.tableView finishPullDown:YES];
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
    
    LSHangoutListItemObject * item = [self.items objectAtIndex:index.row];
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = item.anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)tableView:(LSHangoutTableView *)tableView didClickHangout:(LSHangoutListItemObject *)item {
    HangoutDialogViewController *vc = [[HangoutDialogViewController alloc] initWithNibName:nil bundle:nil];
    vc.item = item;
    vc.anchorId = item.anchorId;
    vc.anchorName = item.nickName;
    UIViewController *topVc = [LiveModule module].moduleVC.navigationController.topViewController;
    [topVc addChildViewController:vc];
    [topVc.view addSubview:vc.view];
//    [self.navigationController addChildViewController:vc];
//    [self.navigationController.view addSubview:vc.view];
    [vc showhangoutView];
//    StartHangOutWithFriendView *view = [[StartHangOutWithFriendView alloc] init];
//    view.item = item;
//    [view showMainHangoutTip:self.navigationController.view];
//
//    [view reloadFriendView];
}
@end
