//
//  LSChatListViewController.m
//  livestream
//
//  Created by test on 2018/11/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "QNChatListViewController.h"
#import "QNContactListTableView.h"
#import "QNContactManager.h"
#import "QNChatViewController.h"
#import "QNRiskControlManager.h"
@interface QNChatListViewController ()<QNContactManagerDelegate,QNContactListTableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet QNContactListTableView *tableView;
/**
 *  数据列表
 */
@property (nonatomic, strong) NSArray<LSLadyRecentContactObject *> *items;
@end

@implementation QNChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 清空列表
    self.items = [NSArray array];
    self.tableView.tableViewDelegate = self;
    [[QNContactManager manager] addDelegate:self];
    [self setupTableView];
    self.searchBtn.layer.cornerRadius = 18.0f;
    self.searchBtn.layer.masksToBounds = YES;
}


- (void)dealloc {
    [[QNContactManager manager] removeDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadContactList];
}
//设置列表底部
- (void)setupTableView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
}


#pragma mark - 数据逻辑
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
#pragma mark - 刷新联系人列表
- (void)reloadContactList {
    NSMutableArray<LSLadyRecentContactObject *> *itemsCopy = [NSMutableArray array];
    for (LSLadyRecentContactObject *item in [QNContactManager manager].recentItems) {
        [itemsCopy addObject:item];
    }
    self.items = itemsCopy;
    [self reloadData:YES];
    
}
#pragma mark - ContactManager回调

- (void)onChangeRecentContactStatus:(QNContactManager *)manager {
        [self reloadContactList];
}


- (void)manager:(QNContactManager *)manager onSyncRecentContactList:(LSLIVECHAT_LCC_ERR_TYPE)success items:(NSArray *)items  errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"QNContactManager onSyncRecentContactList: %@ count: %ld",BOOL2YES(success),(long)items.count);
        self.items = items;
        [self reloadData:YES];
    });
}

- (void)tableView:(QNContactListTableView *)tableView didSelectContact:(LSLadyRecentContactObject *)item {
    
    if (![[QNRiskControlManager manager]isRiskControlType:RiskType_livechat]) {
        NSLog(@"QNContactListTableView %s",__func__);
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
