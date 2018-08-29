//
//  LSHomeSettingViewController.m
//  livestream
//
//  Created by Calvin on 2018/7/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSHomeSettingViewController.h"

#import "LiveWebViewController.h"
#import "MyTicketPageViewController.h"
#import "LSMyReservationsViewController.h"
#import "MyBackpackViewController.h"
#import "MeLevelViewController.h"

#import "LiveSettingLineCell.h"
#import "LSHomeSettingCell.h"
#import "LSHomeSettingCreditCell.h"
#import "UnreadNumManager.h"
#import "LiveModule.h"
#import "LSConfigManager.h"
@interface LSHomeSettingViewController ()<UITableViewDelegate,UITableViewDataSource, LSHomeSettingHaedViewDelegate,                 LSHomeSettingCreditCellDelegate, UnreadNumManagerDelegate>
@property (nonatomic, strong) NSArray * iconArray;
@property (nonatomic, strong) NSArray * titleArray;

@property (nonatomic, strong) NSArray * imageArray;
@property (nonatomic, strong) NSArray * headArray;

@property (nonatomic, strong) UnreadNumManager *unreadManager;

// 选站对话框
@property (nonatomic, strong) UIViewController *siteDialogVC;
@end

@implementation LSHomeSettingViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self.unreadManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.unreadManager = [UnreadNumManager manager];
    [self.unreadManager addDelegate:self];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.bgView.alpha = 0;
    self.tableView.frame = CGRectMake(-screenSize.width, 0, screenSize.width - self.tableView.frame.size.width, screenSize.height);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewswipe:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipe];
    
    [self setTableHeadView];
//    [self setTableFooterView];
    
    self.iconArray = @[@"Setting_Mail_Icon",@"Setting_Greetings_Icon"];
    self.titleArray = @[@"Mail",@"Greeting Mail"];
    
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
    CGFloat headH = 166;
    CGFloat topH = 0;
    //iPhoneX兼容
    if ([LSDevice iPhoneXStyle]) {
        topH = 44;
        headH = headH + topH;
    }
    
    LSHomeSettingHaedView *headView = [[LSHomeSettingHaedView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, headH)];
    headView.delegate = self;
    [self.tableView setTableHeaderView:headView];
    [headView updateUserInfo];
    [self.tableView setContentInset:UIEdgeInsetsMake(-topH, 0, 0, 0)];
}

- (void)setTableFooterView {
    
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"Back to CharmDate" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    backBtn.frame = CGRectMake(15, SCREEN_HEIGHT - 20, 150, 20);
    [backBtn addTarget:self action:@selector(backButtonDid) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:backBtn];
}

- (void)backButtonDid {
    [self hideSettingView];
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
    self.mainVC.navigationController.view.userInteractionEnabled = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0.5;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = CGRectMake(0, 0, screenSize.width - 70, screenSize.height);
            // 在消失动画前禁止主界面的操作防止动画没结束点击了界面事件,防止导航栏错乱问题
            self.mainVC.navigationController.view.userInteractionEnabled = YES;
        }];
    }];
}

//隐藏侧滑栏
- (void)hideSettingView
{
    // 在消失动画前禁止主界面的操作防止动画没结束点击了界面事件,防止导航栏错乱问题
    self.mainVC.navigationController.view.userInteractionEnabled = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.frame = CGRectMake(-screenSize.width, 0, screenSize.width - 70, screenSize.height);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bgView.alpha = 0;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = CGRectMake(-screenSize.width, 0, screenSize.width, screenSize.height);
            }completion:^(BOOL finished) {
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
                // 在消失动画完成需恢复主界面的操作,防止导航栏不能点击的问题
                self.mainVC.navigationController.view.userInteractionEnabled = YES;
            }];
        }];
    }];
}

- (void)removeHomeSettingVC {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - UnreadNumManagerDelegate
- (void)reloadUnreadView:(TotalUnreadNumObject *)model {
    [self.tableView reloadData];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 3) {
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
        view.backgroundColor = Color(224, 224, 224, 1);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 30)];
        titleLabel.text = @"Switch to our family sites";
        titleLabel.textColor = Color(102, 102, 102, 1);
        [view addSubview:titleLabel];
        return view;
        
    }
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    CGFloat height = 0;
    if (section == 3) {
        height = 30;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [LSHomeSettingCell cellHeight];
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row) {
                height = [LiveSettingLineCell cellHeight];
            } else {
                height = [LSHomeSettingCreditCell cellHeight];
            }
        }break;
            
        case 1:{
            if (indexPath.row == self.iconArray.count) {
                height = [LiveSettingLineCell cellHeight];
            } else {
                height = [LSHomeSettingCell cellHeight];
            }
        }break;
            
        case 2:{
            height = [LSHomeSettingCell cellHeight];
        }break;
            
        case 4:{
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
            count = 2;
        }break;
            
        case 1:{
            count = self.titleArray.count + 1;
        }break;
            
        case 2:{
            count = self.headArray.count;
        }break;
            
        case 4:{
            count = 1;
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
            if (indexPath.row) {
                LiveSettingLineCell *setCell = [LiveSettingLineCell getUITableViewCell:tableView];
                cell = setCell;
            } else {
                LSHomeSettingCreditCell *addCell = [LSHomeSettingCreditCell getUITableViewCell:tableView];
                [addCell showMyCredits];
                addCell.delegate = self;
                cell = addCell;
            }
        }break;
            
        case 1:{
            NSInteger index = self.titleArray.count - 1;
            if (indexPath.row > index) {
                LiveSettingLineCell *setCell = [LiveSettingLineCell getUITableViewCell:tableView];
                cell = setCell;
            } else {
                LSHomeSettingCell *setCell = [LSHomeSettingCell  getUITableViewCell:tableView];
                setCell.settingIcon.image = [UIImage imageNamed:[self.iconArray objectAtIndex:indexPath.row]];
                setCell.contentLabel.text = [self.titleArray objectAtIndex:indexPath.row];
                NSInteger type = indexPath.row + indexPath.section;
                [setCell showUnreadNum:[self.unreadManager getUnreadNum:(UnreadType)type]];
                cell = setCell;
            }
        }break;
            
        case 2:{
            LSHomeSettingCell *myCell = [LSHomeSettingCell getUITableViewCell:tableView];
            myCell.settingIcon.image = [UIImage imageNamed:[self.imageArray objectAtIndex:indexPath.row]];
            myCell.contentLabel.text = [self.headArray objectAtIndex:indexPath.row];
            NSInteger type = indexPath.row + indexPath.section + 1;
            [myCell showUnreadPoint:[self.unreadManager getUnreadNum:(UnreadType)type]];
            cell = myCell;
        }break;
            
        case 4:{
            static NSString *cellName = @"siteCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
                [[LiveModule module].siteManager showTableInViewController:self view:cell handler:^{
                    [self removeHomeSettingVC];
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
    
    switch (indexPath.section) {
        case 1:{
            [self removeHomeSettingVC];
            switch (indexPath.row) {
                case 0:{
                    LiveWebViewController *vc = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
                    vc.isIntimacy = NO;
                    vc.isUserProtocol = YES;
                    vc.url = [LSConfigManager manager].item.emfH5Url;
                    vc.title = NSLocalizedString(@"MAIL", nil);
                    vc.gaScreenName = NSLocalizedString(@"MAIL", nil);
                    [self.mainVC.navigationController pushViewController:vc animated:YES];
                }break;
                    
                case 1:{
                    LiveWebViewController *vc = [[LiveWebViewController alloc] initWithNibName:nil bundle:nil];
                    vc.isIntimacy = NO;
                    vc.isUserProtocol = YES;
                    vc.url = [LSConfigManager manager].item.loiH5Url;
                    vc.gaScreenName =  NSLocalizedString(@"GREETING", nil);
                    vc.title =  NSLocalizedString(@"GREETING", nil);
                    [self.mainVC.navigationController pushViewController:vc animated:YES];
                }break;
                    
                default:{
                }break;
            }
        }break;
            
        case 2:{
            [self removeHomeSettingVC];
            switch (indexPath.row) {
                case 0:{
                    MyTicketPageViewController * vc = [[MyTicketPageViewController alloc] initWithNibName:nil bundle:nil];
                    [self.mainVC.navigationController pushViewController:vc animated:YES];
                }break;
                    
                case 1:{
                    LSMyReservationsViewController *vc = [[LSMyReservationsViewController alloc] initWithNibName:nil bundle:nil];
                    [self.mainVC.navigationController pushViewController:vc animated:YES];
                }break;
                    
                default:{
                    MyBackpackViewController *vc = [[MyBackpackViewController alloc] initWithNibName:nil bundle:nil];
                    [self.mainVC.navigationController pushViewController:vc animated:YES];
                }break;
            }
        }break;
            
        default:{
        }break;
    }
}

#pragma mark - LSHomeSettingHaedViewDelegate
- (void)didChangeSiteClick {
    [self removeHomeSettingVC];
    self.siteDialogVC = [[LiveModule module].siteManager showDialogInViewController:self.mainVC.navigationController];
}

- (void)didOpenProfileClick {
    [self removeHomeSettingVC];
    [self.mainVC.navigationController pushViewController:[LiveModule module].qnProfileVC animated:YES];
}

- (void)didOpenLevelExplain {
    [self removeHomeSettingVC];
    MeLevelViewController *level = [[MeLevelViewController alloc] initWithNibName:nil bundle:nil];
    [self.mainVC.navigationController pushViewController:level animated:YES];
}

#pragma mark - LSHomeSettingCreditCellDelegate
- (void)pushToCreditsVC {
    [self removeHomeSettingVC];
    [self.mainVC.navigationController pushViewController:[LiveModule module].addCreditVc animated:YES];
}

@end
