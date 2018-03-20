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
#import "UserInfoManager.h"
#import "LSLoginManager.h"
#import "LSMyReservationsViewController.h"
#import "MyBackpackViewController.h"
#import "MeLevelViewController.h"
#import "UserListHeadView.h"
#import "LSMyCoinViewController.h"
#import "LSSettingViewController.h"
#import "LiveRoomCreditRebateManager.h"
#import "LSProfileViewController.h"
#import "UserInfoManager.h"
@interface LSUserInfoListViewController ()<UITableViewDelegate,UITableViewDataSource,LSUserUnreadCountManagerDelegate,UserListHeadViewDelegate,LiveRoomCreditRebateManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, strong) LSUserUnreadCountManager* unreadCountManager;
@property (nonatomic, assign) int myReservationsCount;
@property (nonatomic, assign) int myBackpackCount;
#pragma mark - 用户信息管理器
@property (nonatomic, strong) UserInfoManager *userInfoManager;
@property (nonatomic, strong) LSLoginManager *loginManager;
@property (nonatomic, strong) LiveRoomCreditRebateManager * creditManager;
@property (nonatomic, assign) double credit;
/** 头部view */
@property (nonatomic, strong) UserListHeadView* headerView;
@end

@implementation LSUserInfoListViewController

- (void)dealloc
{
    [self.unreadCountManager removeDelegate:self];
    [self.creditManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.unreadCountManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadCountManager addDelegate:self];
    self.userInfoManager = [UserInfoManager manager];
    self.loginManager = [LSLoginManager manager];
    self.creditManager = [LiveRoomCreditRebateManager creditRebateManager];
   [self.creditManager addDelegate:self];
        self.titleArray = @[
      @{@"title":NSLocalizedStringFromSelf(@"My Coins"),@"icon":@"Coins_icon"},
      @{@"title":NSLocalizedStringFromSelf(@"My Reservations"),@"icon":@"MyReservations_icon"},
      @{@"title":NSLocalizedStringFromSelf(@"My Backpack"),@"icon":@"MyBackpack_icon"},
      @{@"title":NSLocalizedStringFromSelf(@"My Level"),@"icon":@"MyLevel_icon"},
     @{@"title":NSLocalizedStringFromSelf(@"Setting"),
       @"icon":@"Setting_icon"}];
    
    self.tableView.separatorColor = COLOR_WITH_16BAND_RGB(0xdb96ff);
    
    [self.tableView setTableFooterView:[UIView new]];
    
    [self setTableViewHeadView];
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
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.creditManager getLeftCreditRequest];
    
     self.title = [LSLoginManager manager].loginItem.nickName;
    
    [self getUserInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
   
}

- (void)getUserInfo
{
    [self.userInfoManager getMyProfileInfoFinishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSManBaseInfoItemObject * _Nonnull infoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [LSLoginManager manager].loginItem = infoItem;
                self.title = infoItem.nickName;
                [self.headerView reloadHeaderView];
                [self.tableView reloadData];
            }
        });
    }];
}

#pragma mark 设置头部界面
- (void)setTableViewHeadView
{
    CGFloat topH = 20;
    //iPhoneX兼容
    if (screenSize.height == 812) {
        topH = 44;
    }
    self.headerView = [[UserListHeadView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    self.headerView.delegate = self;
    [self.tableView setTableHeaderView:self.headerView];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(-topH, 0, 0, 0)];
}

#pragma mark 头部点击方法
- (void)headViewBackBtnDid
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)headViewEditBtnDid
{
    LSProfileViewController *vc = [[LSProfileViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 获取余额
- (void)updataCredit:(double)credit
{
    self.credit = credit;
    [self.tableView reloadData];
}
#pragma mark 未读数回调
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
    
    switch (indexPath.row) {
        case 0:
            cell.unread.hidden = YES;
            cell.unIcon.hidden = YES;
            cell.coinsLabel.hidden = NO;
            cell.coinsLabel.text = self.credit>0?[NSString stringWithFormat:@"%0.0f",self.credit]:@"Add";
            break;
        case 1:
            [cell updateCount:self.myReservationsCount];
            cell.unIcon.hidden = YES;
            cell.coinsLabel.hidden = YES;
            break;
        case 2:
            cell.unread.hidden = YES;
            cell.coinsLabel.hidden = YES;
            cell.unIcon.hidden = self.myBackpackCount > 0?NO:YES;
            break;
        case 3:
            cell.unread.hidden = YES;
            cell.unIcon.hidden = YES;
            cell.coinsLabel.hidden = YES;
            break;
        case 4:
            cell.unread.hidden = YES;
            cell.unIcon.hidden = YES;
            cell.coinsLabel.hidden = YES;
            break;
        default:
            break;
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        LSMyCoinViewController *vc = [[LSMyCoinViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 1) {
        LSMyReservationsViewController * vc = [[LSMyReservationsViewController alloc]initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2)
    {
        MyBackpackViewController * vc = [[MyBackpackViewController alloc]initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 3)
    {
        //TODO:进入我的等级界面
        MeLevelViewController *level = [[MeLevelViewController alloc]initWithNibName:nil bundle:nil];
        //[self.navigationController presentViewController:level animated:YES completion:nil];
        [self.navigationController pushViewController:level animated:YES];
    }
    else
    {
        LSSettingViewController *vc = [[LSSettingViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
