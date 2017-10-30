//
//  LSUserInfoListViewController.m
//  livestream
//
//  Created by Calvin on 17/10/9.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSUserInfoListViewController.h"
#import "LSLoginManager.h"
#import "UserInfoListCell.h"
#import "LSUserUnreadCountManager.h"
#import "LSMyReservationsViewController.h"
#import "MyBackpackViewController.h"
#import "MeLevelViewController.h"
@interface LSUserInfoListViewController ()<UITableViewDelegate,UITableViewDataSource,LSUserUnreadCountManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, strong) LSUserUnreadCountManager* unreadCountManager;
@property (nonatomic, assign) int myReservationsCount;
@property (nonatomic, assign) int myBackpackCount;
@end

@implementation LSUserInfoListViewController

- (void)dealloc
{
    [self.unreadCountManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.title = [LSLoginManager manager].loginItem.nickName;
    
    self.unreadCountManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadCountManager addDelegate:self];
    
    self.titleArray = @[@{@"title":@"My Reservations",@"icon":@"MyReservations_icon"},@{@"title":@"My Backpack",@"icon":@"MyBackpack_icon"},@{@"title":@"My Level",@"icon":@"MyLevel_icon"}];
    
    self.tableView.separatorColor = COLOR_WITH_16BAND_RGB(0xdb96ff);
    
    [self.tableView setTableFooterView:[UIView new]];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.unreadCountManager getResevationsUnredCount];
    [self.unreadCountManager getBackpackUnreadCount];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)onGetResevationsUnredCount:(BookingUnreadUnhandleNumItemObject *)item
{
    self.myReservationsCount = item.totalNoReadNum;
    [self.tableView reloadData];
}

- (void)onGetBackpackUnreadCount:(GetBackPackUnreadNumItemObject *)item
{
    self.myBackpackCount = item.total;
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableViewDeletage

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UserInfoListCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserInfoListCell *result = nil;
    UserInfoListCell * cell = [UserInfoListCell getUITableViewCell:tableView];
    result = cell;
    
    cell.titleLabel.text = [[self.titleArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.titleIcon.image = [UIImage imageNamed:[[self.titleArray objectAtIndex:indexPath.row] objectForKey:@"icon"]];
    [cell.levelBtn setTitle:[NSString stringWithFormat:@"%d",[LSLoginManager manager].loginItem.level] forState:UIControlStateNormal];
    
    switch (indexPath.row) {
        case 0:
            cell.unread.hidden = self.myReservationsCount > 0?NO:YES;
            if (!cell.unread.hidden) {
                cell.unread.text =self.myReservationsCount>99?@"N":[NSString stringWithFormat:@"%d",self.myReservationsCount];
            }
            cell.levelBtn.hidden = YES;
            cell.unIcon.hidden = YES;
            break;
        case 1:
            cell.unread.hidden = YES;
            cell.levelBtn.hidden = YES;
            cell.unIcon.hidden = self.myBackpackCount > 0?NO:YES;
            break;
        case 2:
            cell.unread.hidden = YES;
            cell.levelBtn.hidden = NO;
            cell.unIcon.hidden = YES;
            break;
        default:
            break;
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        LSMyReservationsViewController * vc = [[LSMyReservationsViewController alloc]initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 1)
    {
        MyBackpackViewController * vc = [[MyBackpackViewController alloc]initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        //TODO:进入我的等级界面
        MeLevelViewController *level = [[MeLevelViewController alloc]initWithNibName:nil bundle:nil];
        //[self.navigationController presentViewController:level animated:YES completion:nil];
        [self.navigationController pushViewController:level animated:YES];
    }
    
}

@end
