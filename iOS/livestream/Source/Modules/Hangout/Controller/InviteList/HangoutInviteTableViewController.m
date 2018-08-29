//
//  HangoutInviteTableViewController.m
//  livestream
//
//  Created by Max on 2018/5/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangoutInviteTableViewController.h"
#import "HangoutInviteTableViewCell.h"

#import "LSSessionRequestManager.h"
#import "LSGetCanHangoutAnchorListRequest.h"

#define PageSize 50

#define BUTTON_INVITE_ENABLE_COLOR COLOR_WITH_16BAND_RGB(0x05C775);
#define BUTTON_INVITE_DISABLE_COLOR COLOR_WITH_16BAND_RGB(0xBFBFBF);

@implementation HangoutInviteAnchor
@end

@interface HangoutInviteTableViewController () <UIScrollViewRefreshDelegate>
// 列表界面
@property (nonatomic, weak) IBOutlet UITableView *tableView;
// 提示界面
@property (weak, nonatomic) IBOutlet UIView *maskView;
// 空列表控件
@property (weak, nonatomic) IBOutlet UIButton *noListBtn;
// 请求失败控件
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
// 列表数据
@property (nonatomic, strong) NSMutableArray *items;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 当前页数
@property (nonatomic, assign) NSInteger pageIndex;
// 能否上拉获取更多
@property (nonatomic, assign) BOOL canMore;
@end

@implementation HangoutInviteTableViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    self.items = [NSMutableArray array];
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)dealloc {
    [self.tableView unInitPullRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self showMaskView:YES showNolist:YES showRetry:YES];
    
    // 去除列表多余分割线
    self.tableView.tableFooterView = [[UIView alloc] init];
    // 初始化列表上下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.viewDidAppearEver) {
        // 默认下拉刷新
        [self.tableView startPullDown:YES];
    }

    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数据逻辑
- (void)reloadInviteList {
    [self showMaskView:YES showNolist:YES showRetry:YES];
    // 清空列表
    [self.items removeAllObjects];
    // 刷新界面
    [self.tableView reloadData];
    [self.tableView startPullDown:YES];
}

- (void)pullDownRefresh {
    // TODO:下拉刷新
    self.canMore = YES;
    self.view.userInteractionEnabled = NO;
    [self getListRequest:NO];
}

- (void)pullUpRefresh {
    // TODO:上拉更多
    self.view.userInteractionEnabled = NO;
    [self getListRequest:YES];
}

- (BOOL)getListRequest:(BOOL)loadMore {
    NSLog(@"HangoutInviteTableViewController::getListRequest( loadMore : %@, type : %ld, anchorId : %@ )", BOOL2YES(loadMore), (long)self.inviteType, self.anchorId);
    BOOL bFlag = NO;

    LSGetCanHangoutAnchorListRequest *request = [[LSGetCanHangoutAnchorListRequest alloc] init];
    if (!loadMore) {
        // 刷最新
        self.pageIndex = 0;
    } else {
        // 刷更多
    }

    // 邀请类型
    request.type = self.inviteType;
    request.anchorId = self.anchorId ? self.anchorId : @"";
    // 每页最大纪录数
    request.start = (int)(self.pageIndex * PageSize);
    request.step = (int)PageSize;

    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<LSHangoutAnchorItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"HangoutInviteTableViewController::getListRequest( [获取邀请列表, %@], loadMore : %@, type : %ld, anchorId : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)self.inviteType, self.anchorId, (long)array.count);
            if (success) {
                // 增加页数
                self.pageIndex++;

                // 禁止上拉
                if (!array || array.count < PageSize) {
                    self.canMore = NO;
                }

                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:NO];
                    // 清空列表
                    [self.items removeAllObjects];
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                }

                // 增加列表
                if (array && array.count > 0) {
                    [self.items addObjectsFromArray:array];
                    [self showMaskView:YES showNolist:YES showRetry:YES];
                } else {
                    // 显示无列表
                    if (!loadMore) {
                        [self showMaskView:NO showNolist:NO showRetry:YES];
                    }
                }

                // 刷新界面
                [self.tableView reloadData];

            } else {
                if (!loadMore) {
                    // 停止头部
                    [self.tableView finishPullDown:NO];
                    
                    // 显示请求失败
                    [self showMaskView:NO showNolist:YES showRetry:NO];
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                }
            }

            self.view.userInteractionEnabled = YES;
        });
    };

    bFlag = [self.sessionManager sendRequest:request];

    return bFlag;
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    switch (section) {
        case 0: {
            if (self.items.count > 0) {
                number = self.items.count;
            }
        }
        default:
            break;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [HangoutInviteTableViewCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = nil;

    HangoutInviteTableViewCell *cell = [HangoutInviteTableViewCell cell:tableView];
    tableViewCell = cell;

    if (indexPath.row < self.items.count) {
        LSHangoutAnchorItemObject *item = [self.items objectAtIndex:indexPath.row];
        [cell.imageViewLoader refreshCachedImage:cell.imageViewHeader options:SDWebImageRefreshCached imageUrl:item.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
        cell.labelName.text = item.nickName;
        cell.labelDesc.text = [NSString stringWithFormat:@"%dyrs / %@", item.age, item.country, nil];

        if (item.onlineStatus == ONLINE_STATUS_LIVE) {
            cell.buttonInvite.backgroundColor = BUTTON_INVITE_ENABLE_COLOR;
            cell.buttonInvite.enabled = YES;
        } else {
            // 主播不在线
            cell.buttonInvite.backgroundColor = BUTTON_INVITE_DISABLE_COLOR;
            cell.buttonInvite.enabled = NO;
        }
        
        cell.buttonInvite.tag = indexPath.row;
        [cell.buttonInvite removeTarget:self action:@selector(didHangoutInviteAnchor:) forControlEvents:UIControlEventTouchUpInside];
        [cell.buttonInvite addTarget:self action:@selector(didHangoutInviteAnchor:) forControlEvents:UIControlEventTouchUpInside];
    }

    return tableViewCell;
}

- (void)didHangoutInviteAnchor:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger row = button.tag;

    if (row < self.items.count) {
        if ([self.inviteDelegate respondsToSelector:@selector(didHangoutInviteAnchor:)]) {
            LSHangoutAnchorItemObject *item = [self.items objectAtIndex:row];

            HangoutInviteAnchor *listItem = [[HangoutInviteAnchor alloc] init];
            listItem.anchorId = item.anchorId;
            listItem.anchorName = item.nickName;
            listItem.photoUrl = item.photoUrl;
            [self.inviteDelegate didHangoutInviteAnchor:listItem];
        }
    }
}

#pragma mark - 列表上下拉回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    [self pullDownRefresh];
}

- (void)pullUpRefresh:(UIScrollView *)scrollView {
    [self pullUpRefresh];
}

- (void)showMaskView:(BOOL)isShow showNolist:(BOOL)showNolist showRetry:(BOOL)showRetry {
    self.maskView.hidden = isShow;
    self.noListBtn.hidden = showNolist;
    self.retryBtn.hidden = showRetry;
}

#pragma mark - 界面事件
- (IBAction)nolistAciton:(id)sender {
    [self reloadInviteList];
}

- (IBAction)retryAction:(id)sender {
    [self reloadInviteList];
}


@end
