//
//  LSInvitationListViewController.m
//  livestream
//
//  Created by test on 2018/11/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "QNInvitationListViewController.h"
#import "QNInviteListTableView.h"
#import "QNContactManager.h"
#import "QNChatViewController.h"
#import "QNRiskControlManager.h"
@interface QNInvitationListViewController ()<QNContactManagerDelegate,QNInviteListTableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet QNInviteListTableView *tableView;
/**
 *  数据列表
 */
@property (nonatomic, strong) NSArray<LSLadyRecentContactObject *> *items;

@end

@implementation QNInvitationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[QNContactManager manager] addDelegate:self];
    self.tableView.tableViewDelegate = self;
    self.searchBtn.layer.cornerRadius = 18.0f;
    self.searchBtn.layer.masksToBounds = YES;
    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[QNContactManager manager] removeDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 刷新邀请
    [self reloadInviteList];
}

//设置列表底部
- (void)setupTableView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
}


#pragma mark 刷新邀请列表数据
- (void)reloadInviteList {
    self.items = [QNContactManager manager].inviteItems;
    [self reloadData:YES];
}

- (void)reloadData:(BOOL)isReloadView {
    self.tableView.items = self.items;
    if (self.items.count == 0) {
        self.noDataView.hidden = NO;
    } else {
        self.noDataView.hidden = YES;
    }
    
    if (isReloadView) {
        [self.tableView reloadData];
    }
}

- (void)onChangeInviteList:(QNContactManager *)manager {
    [self reloadInviteList];
}

- (void)tableView:(QNInviteListTableView *)tableView didSelectContact:(LSLadyRecentContactObject *)item {
    if (![[QNRiskControlManager manager]isRiskControlType:RiskType_livechat withController:self]) {
        NSLog(@"QNInviteListTableView %s",__func__);
        QNChatViewController* vc = [[QNChatViewController alloc] initWithNibName:nil bundle:nil];
        vc.firstName = item.firstname;
        vc.womanId = item.womanId;
        vc.photoURL = item.photoURL;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)searchAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
