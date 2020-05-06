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
#import "LSGetHangoutFriendsRequest.h"

#define PageSize 50

#define BUTTON_INVITE_ENABLE_COLOR COLOR_WITH_16BAND_RGB(0x05C775);
#define BUTTON_INVITE_DISABLE_COLOR COLOR_WITH_16BAND_RGB(0xBFBFBF);

@implementation HangoutInviteAnchor
@end

@interface HangoutInviteTableViewController () <UIScrollViewRefreshDelegate>
// 列表界面
@property (nonatomic, weak) IBOutlet LSTableView *tableView;
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

@end

@implementation HangoutInviteTableViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    self.isShowNavBar = NO;
    
    self.items = [NSMutableArray array];
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)dealloc {
    [self.tableView unSetupPullRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self showMaskView:YES showNolist:YES showRetry:YES];
    
    // 去除列表多余分割线
    self.tableView.tableFooterView = [[UIView alloc] init];
    // 初始化列表上下拉
    [self.tableView setupPullRefresh:self pullDown:YES pullUp:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    // 默认下拉刷新
    if (!self.viewDidAppearEver) {
        [self.tableView startLSPullDown:YES];
    }
    [super viewDidAppear:animated];
}

#pragma mark - 数据逻辑
- (void)reloadInviteList {
    if (self.viewIsAppear) {
        [self showMaskView:YES showNolist:YES showRetry:YES];
        // 清空列表
        [self.items removeAllObjects];
        // 刷新界面
        [self.tableView reloadData];
        [self.tableView startLSPullDown:YES];
    }
}

- (void)pullDownRefresh {
    // TODO:下拉刷新
    self.view.userInteractionEnabled = NO;
    [self getListRequest];
}

- (BOOL)getListRequest {
    BOOL bFlag = NO;
    LSGetHangoutFriendsRequest *request = [[LSGetHangoutFriendsRequest alloc] init];
    request.anchorId = self.anchorId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *anchorId, NSArray<LSHangoutAnchorItemObject *> *array) {
        NSLog(@"HangoutInviteTableViewController::LSGetHangoutFriendsRequest([获取主播好友列表] %@, errnum : %d, errmsg : %@, friends : %lu)",BOOL2SUCCESS(success), errnum, errmsg, (unsigned long)array.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            // 停止头部
            [self.tableView finishLSPullDown:NO];
            if (success) {
                // 清空列表
                [self.items removeAllObjects];
                // 增加列表
                if (array && array.count > 0) {
                    [self.items addObjectsFromArray:array];
                    [self showMaskView:YES showNolist:YES showRetry:YES];
                } else {
                    [self showMaskView:NO showNolist:NO showRetry:YES];
                }
                // 刷新界面
                [self.tableView reloadData];
                
            } else {
                // 显示请求失败
                [self showMaskView:NO showNolist:YES showRetry:NO];
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
        [cell.imageViewLoader loadImageFromCache:cell.imageViewHeader options:SDWebImageRefreshCached imageUrl:item.avatarImg placeholderImage:LADYDEFAULTIMG finishHandler:^(UIImage *image) {
        }];
        cell.labelName.text = item.nickName;
        cell.labelDesc.text = [NSString stringWithFormat:@"%dyrs / %@", item.age, item.country, nil];

        if (item.onlineStatus == ONLINE_STATUS_LIVE) {
            [cell.buttonInvite setBackgroundImage:[UIImage imageNamed:@"Home_hangoutBg"] forState:UIControlStateNormal];
            cell.buttonInvite.enabled = YES;
            cell.onlineView.hidden = NO;
        } else {
            // 主播不在线
            [cell.buttonInvite setBackgroundImage:[self createImageWithColor:COLOR_WITH_16BAND_RGB(0xbfbfbf)] forState:UIControlStateNormal];
            cell.buttonInvite.enabled = NO;
            cell.onlineView.hidden = YES;
        }
        
        cell.buttonInvite.tag = indexPath.row;
        [cell.buttonInvite removeTarget:self action:@selector(didHangoutInviteAnchor:) forControlEvents:UIControlEventTouchUpInside];
        [cell.buttonInvite addTarget:self action:@selector(didHangoutInviteAnchor:) forControlEvents:UIControlEventTouchUpInside];
    }

    return tableViewCell;
}

- (UIImage*)createImageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
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
            listItem.photoUrl = item.avatarImg;
            [self.inviteDelegate didHangoutInviteAnchor:listItem];
        }
    }
}

#pragma mark - 列表上下拉回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    [self pullDownRefresh];
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
