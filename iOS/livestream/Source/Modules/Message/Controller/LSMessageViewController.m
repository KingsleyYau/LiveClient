//
//  LSMessageViewController.m
//  livestream
//
//  Created by Calvin on 2018/6/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMessageViewController.h"
#import "LSMessageCell.h"
#import "LSChatViewController.h"
#import "LSPrivateMessageManager.h"
#import "LiveUrlHandler.h"

@interface LSMessageViewController ()<UITableViewDataSource,UITableViewDelegate,LMMessageManagerDelegate,UIScrollViewRefreshDelegate>
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * data;
@property (nonatomic, strong) LSPrivateMessageManager *messageManager;
@end

@implementation LSMessageViewController

- (void)dealloc {
    NSLog(@"LSMessageViewController::dealloc()");
    [self.tableView unInitPullRefresh];
    [self.messageManager.client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Private Message";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.data = [NSArray array];
    
    self.searchBtn.layer.cornerRadius = self.searchBtn.frame.size.height * 0.5;
    self.searchBtn.layer.masksToBounds = YES;
    
    [self.tableView registerClass:[LSMessageCell class] forCellReuseIdentifier:[LSMessageCell cellIdentifier]];
    
    // 初始化信息管理器
    self.messageManager = [LSPrivateMessageManager manager];
    [self.messageManager.client addDelegate:self];
    
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView initPullRefresh:self pullDown:YES pullUp:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showLoading];
    // 获取本地联系人列表
    [self getLocalPrivateMessageList];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (IBAction)searchClick:(id)sender {
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHomePage:LiveUrlMainListTypeHot];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}

// 获取本地联系人列表
- (void)getLocalPrivateMessageList {
    [self.messageManager getLocalPrivateMsgFriendList:^(NSArray<LMPrivateMsgContactObject *> * _Nullable list) {
        [self hideLoading];
        self.data = list;
        if (!list.count) {
            self.noDataView.hidden = NO;
        } else {
            self.noDataView.hidden = YES;
        }
        [self.tableView reloadData];
        // 请求私信联系人列表
        [self getPrivateMessageList];
    }];
}

// 请求私信联系人列表
- (void)getPrivateMessageList {
    [self.messageManager getPrivateMsgFriendList];
}

#pragma mark - LMMessageManagerDelegate
- (void)onUpdateFriendListNotice:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"LSMessageViewController::onUpdateFriendListNotice([私信联系人列表改动 success : %d, errType : %d, errmsg : %@])", success, errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView finishPullDown:YES];
        if (success) {
            [self.messageManager getLocalPrivateMsgFriendList:^(NSArray<LMPrivateMsgContactObject *> * _Nullable list) {
                self.data = list;
                if (!list.count) {
                    self.noDataView.hidden = NO;
                } else {
                    self.noDataView.hidden = YES;
                }
                [self.tableView reloadData];
            }];
        }
    });
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self getPrivateMessageList];
}

#pragma mark tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LSMessageCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LMPrivateMsgContactObject *obj = self.data[indexPath.row];
    
    LSMessageCell *result = nil;
    LSMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:[LSMessageCell cellIdentifier]];
    [cell setCellPattern:obj];
    result = cell;
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LMPrivateMsgContactObject *obj = self.data[indexPath.row];
    
    LSChatViewController *vc = [LSChatViewController initChatVCWithAnchorId:obj.userId];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
