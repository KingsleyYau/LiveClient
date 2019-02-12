//
//  LSHomeSettingViewController.m
//  livestream
//
//  Created by Calvin on 2018/7/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSHomeSettingViewController.h"

#import "LSMessageViewController.h"
#import "LiveWebViewController.h"
#import "MyTicketPageViewController.h"
#import "LSMyReservationsViewController.h"
#import "MyBackpackViewController.h"
#import "MeLevelViewController.h"
#import "LSUserSettingViewController.h"
#import "LiveSettingLineCell.h"
#import "LSHomeSettingCell.h"
#import "LSUserUnreadCountManager.h"
#import "LiveModule.h"
#import "LSConfigManager.h"
#import "LSAddCreditsViewController.h"
#import "LSUserSetUpViewController.h"
#import "QNChatAndInvitationViewController.h"
#import "LSGreetingsViewController.h"
#import "LSMailViewController.h"
#import "LiveUrlHandler.h"
#define HeadViewH 252

@interface LSHomeSettingViewController ()<UITableViewDelegate,UITableViewDataSource, LSHomeSettingHaedViewDelegate,                  LSUserUnreadCountManagerDelegate>
@property (nonatomic, strong) NSArray * iconArray;
@property (nonatomic, strong) NSArray * titleArray;

@property (nonatomic, strong) NSArray * imageArray;
@property (nonatomic, strong) NSArray * headArray;

@property (nonatomic, strong) LSUserUnreadCountManager *unreadManager;

@property (nonatomic, strong) LSHomeSettingHaedView *headView;
// 选站对话框
@property (nonatomic, strong) UIViewController *siteDialogVC;
@end

@implementation LSHomeSettingViewController

- (void)dealloc {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.unreadManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.unreadManager = [LSUserUnreadCountManager shareInstance];
    [self.unreadManager addDelegate:self];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.bgView.alpha = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewswipe:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipe];
    
    [self setTableHeadView];
    
    self.iconArray = @[@"Setting_Message_Icon",@"Setting_Mail_Icon",@"Setting_Greetings_Icon",@"Setting_Greetings_Icon"];
    self.titleArray = @[@"Chat",@"Mail",@"Greeting Mail",@"Hang-out"];
    
    self.imageArray = @[@"Setting_Ticket_Icon",@"Setting_Bookings_Icon",@"Setting_BackPack_Icon"];
    self.headArray = @[@"My Show Tickets",@"My Bookings",@"My Backpack"];
    
    // 背景单击收起事件
    UITapGestureRecognizer *bgClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSettingView)];
    [self.bgView addGestureRecognizer:bgClick];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 如果存在选站对话框, 则移除
    [[LiveModule module].siteManager closeViewController:self.siteDialogVC];
}

- (void)setTableHeadView {
    
    self.headView = [[LSHomeSettingHaedView alloc] init];
    self.headView.delegate = self;
    [self.view addSubview:self.headView];
    [self.headView updateUserInfo];
}


//点击背景隐藏侧滑栏
- (IBAction)bgViewTap:(UITapGestureRecognizer *)sender {
    [self hideSettingView];
}

//滑动手势隐藏侧滑栏
- (void)bgViewswipe:(UISwipeGestureRecognizer *)sender {
    
    if(sender.direction==UISwipeGestureRecognizerDirectionLeft) {
        [self hideSettingView];
    }
}

//显示侧滑栏
- (void)showSettingView
{
    // 在消失动画前禁止主界面的操作防止动画没结束点击了界面事件,防止导航栏错乱问题
    [LiveModule module].moduleVC.navigationController.view.userInteractionEnabled = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    self.headView.frame = CGRectMake(-screenSize.width, 0, screenSize.width - 70, HeadViewH);
    self.tableView.frame = CGRectMake(-screenSize.width, HeadViewH, screenSize.width - 70, screenSize.height - HeadViewH);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0.5;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect tableRect = self.tableView.frame;
            tableRect.origin.x = 0;
            self.tableView.frame = tableRect;
            [self.tableView reloadData];
            
            
            CGRect headRect = self.headView.frame;
            headRect.origin.x = 0;
            headRect.size.width = tableRect.size.width;
            headRect.size.height = HeadViewH;
            self.headView.frame = headRect;
            // 在消失动画前禁止主界面的操作防止动画没结束点击了界面事件,防止导航栏错乱问题
            [LiveModule module].moduleVC.navigationController.view.userInteractionEnabled = YES;
        }];
    }];
}

//隐藏侧滑栏
- (void)hideSettingView
{
    // 在消失动画前禁止主界面的操作防止动画没结束点击了界面事件,防止导航栏错乱问题
    [LiveModule module].moduleVC.navigationController.view.userInteractionEnabled = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = CGRectMake(-screenSize.width, HeadViewH, screenSize.width - 70, screenSize.height -HeadViewH);
        self.headView.frame = CGRectMake(-screenSize.width, 0, screenSize.width - 70, HeadViewH);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bgView.alpha = 0;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = CGRectMake(-screenSize.width, 0, screenSize.width, screenSize.height);
            }completion:^(BOOL finished) {
                [self removeHomeSettingVC];
                // 在消失动画完成需恢复主界面的操作,防止导航栏不能点击的问题
                [LiveModule module].moduleVC.navigationController.view.userInteractionEnabled = YES;
            }];
        }];
    }];
}

- (void)removeHomeSettingVC {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.bgView.alpha = 0;
    if ([self.homeDelegate respondsToSelector:@selector(lsHomeSettingViewControllerDidRemoveVC:)]) {
        [self.homeDelegate lsHomeSettingViewControllerDidRemoveVC:self];
    }
}

#pragma mark - UnreadNumManagerDelegate
- (void)reloadUnreadView:(TotalUnreadNumObject *)model {
    [self.tableView reloadData];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 1) {
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
        view.backgroundColor = Color(224, 224, 224, 1);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 30)];
        titleLabel.text = @"Switch to our family sites";
        titleLabel.textColor = Color(102, 102, 102, 1);
        [view addSubview:titleLabel];
        return view;
    }
    else if (section == 0) {
        UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.tableView.frame.size.width, 1)];
        lineView.backgroundColor = COLOR_WITH_16BAND_RGB(0xC7D2E3);
        return lineView;
    }
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    CGFloat height = 1;
    if (section == 1) {
        height = 30;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [LSHomeSettingCell cellHeight];
    switch (indexPath.section) {
        case 0:{
            height = [LSHomeSettingCell cellHeight];
        }break;
            
        case 1:{
            height = [LSHomeSettingCell cellHeight];
        }break;
            
        case 2:{
            height = [[LiveModule module].siteManager siteTableHeight];
        }break;
            
        default:{
            height = 0;
        }break;
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 1;
    switch (section) {
        case 0:{
            count = self.titleArray.count;
        }break;
            
        case 1:{
            count = self.headArray.count;
        }break;
        default:{
        }break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch (indexPath.section) {
        case 0:{
            LSHomeSettingCell *setCell = [LSHomeSettingCell  getUITableViewCell:tableView];
            setCell.settingIcon.image = [UIImage imageNamed:[self.iconArray objectAtIndex:indexPath.row]];
            setCell.contentLabel.text = [self.titleArray objectAtIndex:indexPath.row];
            NSInteger type = indexPath.row;
            if (type == LSUnreadType_Private_Chat) {
                [setCell showChatListUnreadNum:[self.unreadManager getUnreadNum:(LSUnreadType)type]];
            }else {
                [setCell showUnreadNum:[self.unreadManager getUnreadNum:(LSUnreadType)type]];
            }

            cell = setCell;
        }break;
        case 1:{
            LSHomeSettingCell *myCell = [LSHomeSettingCell getUITableViewCell:tableView];
            myCell.settingIcon.image = [UIImage imageNamed:[self.imageArray objectAtIndex:indexPath.row]];
            myCell.contentLabel.text = [self.headArray objectAtIndex:indexPath.row];
            NSInteger type = indexPath.row + self.titleArray.count;
            [myCell showUnreadPoint:[self.unreadManager getUnreadNum:(LSUnreadType)type]];
            cell = myCell;
        }break;
            
        case 2:{
            __weak typeof(self) weakSelf = self;
            static NSString *cellName = @"siteCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                [[LiveModule module].siteManager showTableInViewController:self view:cell handler:^{
                    [weakSelf removeHomeSettingVC];
                }];
            }
        }break;
        default:{
        }break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    [self removeHomeSettingVC];
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:
                {
                    QNChatAndInvitationViewController *vc = [[QNChatAndInvitationViewController alloc] initWithNibName:nil bundle:nil];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                case 1:{
                    LSMailViewController *vc = [[LSMailViewController alloc] initWithNibName:nil bundle:nil];
                    [self.navigationController pushViewController:vc animated:YES];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                    
                case 2:{
                    LSGreetingsViewController *vc = [[LSGreetingsViewController alloc] initWithNibName:nil bundle:nil];
                    [self.navigationController pushViewController:vc animated:YES];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                case 3:{
                    [self removeHomeSettingVC];
                    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHomePage:LiveUrlMainListUrlTypeHangout];
                    [[LiveUrlHandler shareInstance] handleOpenURL:url];
                }break;
                    
                default:
                    break;
            }
        }break;
        case 1:{
            switch (indexPath.row) {
                case 0:{
                    MyTicketPageViewController * vc = [[MyTicketPageViewController alloc] initWithNibName:nil bundle:nil];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                    
                case 1:{
                    LSMyReservationsViewController *vc = [[LSMyReservationsViewController alloc] initWithNibName:nil bundle:nil];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                case 2:{
                    MyBackpackViewController *vc = [[MyBackpackViewController alloc] initWithNibName:nil bundle:nil];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                default:
                    break;
            }
        }break;
            
        default:{
        }break;
    }
}

- (void)onGetChatlistUnreadCount:(int)count {
    [self.tableView reloadData];
}

#pragma mark - LSHomeSettingHaedViewDelegate
- (void)didChangeSiteClick {
    self.siteDialogVC = [[LiveModule module].siteManager showDialogInViewController:[LiveModule module].moduleVC.navigationController handler:nil];
}

- (void)didOpenPersonalCenter {
    [self removeHomeSettingVC];
    LSUserSettingViewController * vc = [[LSUserSettingViewController alloc]initWithNibName:nil bundle:nil];
    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
}

- (void)didOpenLevelExplain {
    [self removeHomeSettingVC];
    MeLevelViewController *level = [[MeLevelViewController alloc] initWithNibName:nil bundle:nil];
    [[LiveModule module].moduleVC.navigationController pushViewController:level animated:YES];
}

- (void)pushToCreditsVC {
    [self removeHomeSettingVC];
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
}

- (void)pushSettingInfoVC {
    [self removeHomeSettingVC];
    LSUserSetUpViewController * vc = [[LSUserSetUpViewController alloc]initWithNibName:nil bundle:nil];
    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
}

@end
