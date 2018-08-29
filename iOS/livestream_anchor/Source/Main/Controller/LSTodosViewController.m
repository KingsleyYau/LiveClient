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
#import "MyTicketPageViewController.h"
@interface LSTodosViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *titleArray;
@end

@implementation LSTodosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupTableFooterView];
   
    self.titleArray = @[
                        @{ @"title" :  NSLocalizedStringFromSelf(@"Book"),
                           @"icon" : @"Main_Booking",
                           @"detail": NSLocalizedStringFromSelf(@"Book_Detail")},
                        @{ @"title" :  NSLocalizedStringFromSelf(@"Show"),
                           @"icon" : @"Main_Show",
                            @"detail":NSLocalizedStringFromSelf(@"Show_Detail")}
                        ];
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
    NSInteger number = self.titleArray.count;
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [LSTodosTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = nil;
    LSTodosTableViewCell *cell = [LSTodosTableViewCell getUITableViewCell:tableView];
    cell.titleLabel.text = [[self.titleArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.detailLabel.text = [[self.titleArray objectAtIndex:indexPath.row] objectForKey:@"detail"];
    cell.settingImageView.image = [UIImage imageNamed:[[self.titleArray objectAtIndex:indexPath.row] objectForKey:@"icon"]];
    [cell setTextW:cell.titleLabel.text];
    [cell setDetailTextW:cell.detailLabel.text];

    switch (indexPath.row) {
        case 0:{
            if (self.unReadBookingCount == 0) {
                cell.redLabel.hidden = YES;
            }
            [cell updateRedLabelW:self.unReadBookingCount];
            
        }break;
        case 1:{
            if (self.unReadShowCount == 0) {
                cell.redLabel.hidden = YES;
            }
            [cell updateRedLabelW:self.unReadShowCount];
        }break;
            
        default:
            break;
    }


    tableViewCell = cell;

    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        LSMyReservationsPageViewController *vc = [[LSMyReservationsPageViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1) {
        MyTicketPageViewController * vc = [[MyTicketPageViewController alloc]initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
