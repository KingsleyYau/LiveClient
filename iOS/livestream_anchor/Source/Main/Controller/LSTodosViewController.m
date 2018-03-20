//
//  LSTudosViewController.m
//  livestream_anchor
//
//  Created by test on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSTodosViewController.h"
#import "LSTodosTableViewCell.h"
#import "LSMyReservationsPageViewController.h"

@interface LSTodosViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation LSTodosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupTableFooterView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


- (void)reloadData:(BOOL)isReload {
    if (isReload) {
        [self.tableView reloadData];
    }
}


- (void)setupTableFooterView {
    UIView *vc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 1)];
    self.tableView.tableFooterView = vc;
}


#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 1;
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [LSTodosTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = nil;
    LSTodosTableViewCell *cell = [LSTodosTableViewCell getUITableViewCell:tableView];
    NSString *titleText = @"Bookings";
    NSString *detailText = @"Upcoming One-on-One bookings";
    cell.titleLabel.text = titleText;
    cell.detailLabel.text = detailText;
    [cell setTextW:titleText];
    [cell setDetailTextW:detailText];
    if (self.unReadBookingCount == 0) {
        cell.redLabel.hidden = YES;
    }
    [cell updateRedLabelW:self.unReadBookingCount];
    cell.settingImageView.image = [UIImage imageNamed:@"Main_Booking"];
    tableViewCell = cell;

    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        LSMyReservationsPageViewController *vc = [[LSMyReservationsPageViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
