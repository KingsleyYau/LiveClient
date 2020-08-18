//
//  LSDeliveryListViewController.m
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSDeliveryListViewController.h"
#import "LSShadowView.h"
#import "LSGetDeliveryListRequest.h"
#import "DeliveryStatusView.h"
#import "LiveUrlHandler.h"
#import "LSStoreDetailViewController.h"
#import "AnchorPersonalViewController.h"

@interface LSDeliveryListViewController ()<LSDeliveryTableViewDelegate>

@property (strong, nonatomic)  LSSessionRequestManager *sessionManager;
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation LSDeliveryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBtn.layer.cornerRadius = 4;
    self.searchBtn.layer.masksToBounds = YES;
    
    LSShadowView *shadow = [[LSShadowView alloc] init];
    [shadow showShadowAddView:self.searchBtn];
    
    self.sessionManager= [LSSessionRequestManager manager];
    
    self.tableView.tableViewDelegate = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.viewDidAppearEver) {
        [self getDeliveryList];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

//设置列表底部
- (void)setupTableView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
}


#pragma mark - 获取列表
- (void)getDeliveryList {
    LSGetDeliveryListRequest *request = [[LSGetDeliveryListRequest alloc] init];
    [self showLoading];
    self.failView.hidden = YES;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSDeliveryItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSDeliveryListViewController::getDeliveryList( [%@], count : %ld )", BOOL2SUCCESS(success),  (long)array.count);
            [self hideLoading];
            if (success) {
                self.tableView.items = array;
                [self reloadTableView];
            }else {
                self.failView.hidden = NO;
            }
        });
    };
    [self.sessionManager sendRequest:request];
}


- (void)lsListViewControllerDidClick:(UIButton *)sender {
    [super lsListViewControllerDidClick:sender];
    [self getDeliveryList];
}

- (void)reloadTableView {

    self.tableView.hidden = self.tableView.items.count > 0 ? NO : YES;
     [self.tableView reloadData];
}


#pragma mark - 列表方法回调
- (void)lsDeliveryTableViewDidClickStatusAction:(LSDeliveryTableView *)tableView {
    DeliveryStatusView *statusView = [DeliveryStatusView deliveryStatusView];
    [statusView showDeliveryStatusView:self.view];
}

- (void)lsDeliveryTableView:(LSDeliveryTableView *)tableView didClickGiftInfo:(LSFlowerGiftBaseInfoItemObject *)item {
    // TODO:跳转鲜花礼品详情页
    LSStoreDetailViewController * vc = [[LSStoreDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.giftId = item.giftId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)lsDeliveryTableView:(LSDeliveryTableView *)tableView DidClickAchorIcon:(LSDeliveryItemObject *)item {
    AnchorPersonalViewController *vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = item.anchorId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goToStoreListAction:(id)sender {
    // TODO:跳转商店页
    if ([self.deliveryDelegate respondsToSelector:@selector(lsDeliveryListViewControllerDidShowGiftStore:)]) {
        [self.deliveryDelegate lsDeliveryListViewControllerDidShowGiftStore:self];
    }
}

@end
