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
#import "LSMyReservationsPageViewController.h"
#import "MyBackpackViewController.h"
#import "MeLevelViewController.h"
@interface LSUserInfoListViewController () <UITableViewDelegate, UITableViewDataSource, LSUserUnreadCountManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) LSUserUnreadCountManager *unreadCountManager;
@property (nonatomic, assign) int myReservationsCount;
@property (nonatomic, assign) int myBackpackCount;
#pragma mark - 用户信息管理器
@property (nonatomic, strong) UserInfoManager *userInfoManager;
@property (nonatomic, strong) LSLoginManager *loginManager;
@end

@implementation LSUserInfoListViewController
- (void)initCustomParam {
    [super initCustomParam];

    // Items for tab
    LSUITabBarItem *tabBarItem = [[LSUITabBarItem alloc] init];
    self.tabBarItem = tabBarItem;
//    self.tabBarItem.title = @"Me";
    self.tabBarItem.image = [[UIImage imageNamed:@"TabBarMe"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"TabBarMe-Selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSDictionary *normalColor = [NSDictionary dictionaryWithObject:Color(51, 51, 51, 1) forKey:NSForegroundColorAttributeName];
    NSDictionary *selectedColor = [NSDictionary dictionaryWithObject:Color(52, 120, 247, 1) forKey:NSForegroundColorAttributeName];
    [self.tabBarItem setTitleTextAttributes:normalColor forState:UIControlStateNormal];
    [self.tabBarItem setTitleTextAttributes:selectedColor forState:UIControlStateSelected];
    
    UIBarButtonItem * btnItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromSelf(@"Logout") style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    btnItem.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = btnItem;
}

- (void)dealloc {
    [self.unreadCountManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    //    self.navigationItem.title = [LSLoginManager manager].loginItem.nickName;

    self.unreadCountManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadCountManager addDelegate:self];
    self.userInfoManager = [UserInfoManager manager];
    self.loginManager = [LSLoginManager manager];
    
    self.titleArray = @[
        @{ @"title" : NSLocalizedStringFromSelf(@"My Reservations"),
           @"icon" : @"MyReservations_icon" },
        @{ @"title" : NSLocalizedStringFromSelf(@"My Backpack"),
           @"icon" : @"MyBackpack_icon" },
        @{ @"title" : NSLocalizedStringFromSelf(@"My Level"),
           @"icon" : @"MyLevel_icon" }
    ];

    [self.tableView setTableFooterView:[UIView new]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.unreadCountManager getResevationsUnredCount];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self hideNavgationBarBottomLine:NO];
}

- (void)logout
{
    UIAlertController * alertView = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Logout_msg") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.loginManager logout:YES msg:@""];
    }];
    [alertView addAction:cancelAction];
    [alertView addAction:okAction];
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)onGetResevationsUnredCount:(BookingUnreadUnhandleNumItemObject *)item {
    self.myReservationsCount = item.totalNoReadNum;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableViewDeletage

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UserInfoListCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfoListCell *result = nil;
    UserInfoListCell *cell = [UserInfoListCell getUITableViewCell:tableView];
    result = cell;

    cell.titleLabel.text = [[self.titleArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.titleIcon.image = [UIImage imageNamed:[[self.titleArray objectAtIndex:indexPath.row] objectForKey:@"icon"]];
    
    if (self.loginManager.status == LOGINED) {
       // [cell updateLevel:[LSLoginManager manager].loginItem.level];
        __block UserInfoListCell *blockCell = cell;
        switch (indexPath.row) {
            case 0:
                [cell updateCount:self.myReservationsCount];
                cell.levelBtn.hidden = YES;
                cell.unIcon.hidden = YES;
                break;
            case 1:
                cell.unread.hidden = YES;
                cell.levelBtn.hidden = YES;
                cell.unIcon.hidden = self.myBackpackCount > 0 ? NO : YES;
                break;
            case 2:
                cell.unread.hidden = YES;
                cell.levelBtn.hidden = NO;
                cell.unIcon.hidden = YES;
                break;
            default:
                break;
        }
    }
 
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        LSMyReservationsPageViewController *vc = [[LSMyReservationsPageViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
        MyBackpackViewController *vc = [[MyBackpackViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        //TODO:进入我的等级界面
        MeLevelViewController *level = [[MeLevelViewController alloc] initWithNibName:nil bundle:nil];
        //[self.navigationController presentViewController:level animated:YES completion:nil];
        [self.navigationController pushViewController:level animated:YES];
    }
    
}

@end

