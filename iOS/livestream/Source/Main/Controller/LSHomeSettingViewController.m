//
//  LSHomeSettingViewController.m
//  livestream
//
//  Created by Calvin on 2018/7/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSHomeSettingViewController.h"

#import "LiveModule.h"
#import "LSUserUnreadCountManager.h"
#import "LSConfigManager.h"
#import "LiveUrlHandler.h"
#import "QNRiskControlManager.h"
#import "LSHomeSetItemObject.h"

#import "LiveSettingLineCell.h"
#import "LSHomeSettingCell.h"

#import "LSMessageViewController.h"
#import "LiveWebViewController.h"
#import "MyTicketPageViewController.h"
#import "LSMyReservationsViewController.h"
#import "MyBackpackViewController.h"
#import "MeLevelViewController.h"
#import "LSUserSettingViewController.h"
#import "LSAddCreditsViewController.h"
#import "LSUserSetUpViewController.h"
#import "QNChatAndInvitationViewController.h"
#import "LSGreetingsViewController.h"
#import "LSMailViewController.h"
#import "LSSayHiListViewController.h"
#import "LSMyContactsViewController.h"
#import "LSStoreMainViewController.h"
#define HeadViewH 252

@interface LSHomeSettingViewController ()<UITableViewDelegate,UITableViewDataSource, LSHomeSettingHaedViewDelegate,                  LSUserUnreadCountManagerDelegate>
@property (nonatomic, strong) NSArray * oneArray;
@property (nonatomic, strong) NSArray * twoArray;
@property (nonatomic, strong) NSArray * threeArray;
@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, strong) LSUserUnreadCountManager *unreadManager;

@property (nonatomic, strong) LSHomeSettingHaedView *headView;
// 选站对话框
@property (nonatomic, strong) UIViewController *siteDialogVC;
@end

@implementation LSHomeSettingViewController

- (void)dealloc {
    [self.unreadManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleArray = @[@"Services",@"Broadcasters",@"Others",@"Switch to our family sites"];
    
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
    
    [self loadSettingData];
    
    // 背景单击收起事件
    UITapGestureRecognizer *bgClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSettingView)];
    [self.bgView addGestureRecognizer:bgClick];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}


- (void)loadSettingData {

    NSMutableArray *sectionFirstArray = [NSMutableArray array];

    if ([LSLoginManager manager].loginItem.userPriv.isSayHiPriv) {
        LSHomeSetItemObject *item2 = [[LSHomeSetItemObject alloc] init];
        item2.iconName = @"Setting_SayHi_Icon";
        item2.titleName = @"SayHi";
        item2.firstType = SettingFirstTypeSayHi;
        [sectionFirstArray addObject:item2];
    }
    
    LSHomeSetItemObject *item3 = [[LSHomeSetItemObject alloc] init];
    item3.iconName = @"Setting_Greetings_Icon";
    item3.titleName = @"Greeting Mail";
    item3.firstType = SettingFirstTypeGreeting;
    [sectionFirstArray addObject:item3];
    
    LSHomeSetItemObject *item1 = [[LSHomeSetItemObject alloc] init];
    item1.iconName = @"Setting_Mail_Icon";
    item1.titleName = @"Mail";
    item1.firstType = SettingFirstTypeMail;
    [sectionFirstArray addObject:item1];
    
    LSHomeSetItemObject *item = [[LSHomeSetItemObject alloc] init];
    item.iconName = @"Setting_Message_Icon";
    item.titleName = @"Chat";
    item.firstType = SettingFirstTypeChat;
    [sectionFirstArray addObject:item];
    
    if ([LSLoginManager manager].loginItem.userPriv.isGiftFlowerPriv && [LSLoginManager manager].loginItem.isGiftFlowerSwitch) {
        LSHomeSetItemObject *item4 = [[LSHomeSetItemObject alloc] init];
        item4.iconName = @"LS_Setting_Stroe";
        item4.titleName = @"Gifts & Flowers";
        item4.firstType = SettingFirstTypeStroe;
        [sectionFirstArray addObject:item4];
    }
    
    self.oneArray = sectionFirstArray;
    
    NSMutableArray *sectionSecondArray = [NSMutableArray array];
    
    if ([LSLoginManager manager].loginItem.userPriv.hangoutPriv.isHangoutPriv) {
        LSHomeSetItemObject *item4 = [[LSHomeSetItemObject alloc] init];
        item4.iconName = @"LS_Setting_HangOut_Icon";
        item4.titleName = @"Hang-out";
        item4.secondType = SettingSecondTypeHangout;
        [sectionSecondArray addObject:item4];
    }
    
    LSHomeSetItemObject *sectionSecondItem = [[LSHomeSetItemObject alloc] init];
    sectionSecondItem.iconName = @"LS_Setting_MyContact";
    sectionSecondItem.titleName = @"My Contacts";
    sectionSecondItem.secondType = SettingSecondTypeMyContacts;
    [sectionSecondArray addObject:sectionSecondItem];
    
    self.twoArray = sectionSecondArray;
    
     NSMutableArray *sectionThreeArray = [NSMutableArray array];
    
    LSHomeSetItemObject *sectionSecondItem1 = [[LSHomeSetItemObject alloc] init];
    sectionSecondItem1.iconName = @"Setting_Bookings_Icon";
    sectionSecondItem1.titleName = @"My Bookings";
    sectionSecondItem1.thirdType = SettingThirdTypeBooks;
    [sectionThreeArray addObject:sectionSecondItem1];
    
    
    LSHomeSetItemObject *sectionSecondItem2 = [[LSHomeSetItemObject alloc] init];
    sectionSecondItem2.iconName = @"Setting_Ticket_Icon";
    sectionSecondItem2.titleName = @"My Show Tickets";
    sectionSecondItem2.thirdType = SettingThirdTypeShow;
    [sectionThreeArray addObject:sectionSecondItem2];
    
    LSHomeSetItemObject *sectionSecondItem3 = [[LSHomeSetItemObject alloc] init];
    sectionSecondItem3.iconName = @"Setting_BackPack_Icon";
    sectionSecondItem3.titleName = @"My Backpack";
    sectionSecondItem3.thirdType = SettingThirdTypeBackpack;
    [sectionThreeArray addObject:sectionSecondItem3];
    
    self.threeArray = sectionThreeArray;
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
//显示侧滑栏
- (void)showSettingView
{
    // 在消失动画前禁止主界面的操作防止动画没结束点击了界面事件,防止导航栏错乱问题
    [LiveModule module].moduleVC.navigationController.view.userInteractionEnabled = NO;
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
    self.bgView.alpha = 0;
    if ([self.homeDelegate respondsToSelector:@selector(lsHomeSettingViewControllerDidRemoveVC:)]) {
        [self.homeDelegate lsHomeSettingViewControllerDidRemoveVC:self];
    }
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    
}




#pragma mark - UnreadNumManagerDelegate
- (void)reloadUnreadView:(TotalUnreadNumObject *)model {
    [self.tableView reloadData];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 3) {
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 49)];
        view.backgroundColor = COLOR_WITH_16BAND_RGB(0xECEDF1);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 200, 49)];
        titleLabel.text = [self.titleArray objectAtIndex:section];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = COLOR_WITH_16BAND_RGB(0x999999);
        [view addSubview:titleLabel];
        return view;
    }
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    view.backgroundColor = COLOR_WITH_16BAND_RGB(0xECEDF1);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 200, 30)];
    titleLabel.text = [self.titleArray objectAtIndex:section];;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = COLOR_WITH_16BAND_RGB(0x999999);
    [view addSubview:titleLabel];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 30;
    if (section == 3) {
        height = 49;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
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
            height = [LSHomeSettingCell cellHeight];
        }break;
        case 3:{
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
            count = self.oneArray.count;
        }break;
        case 1:{
            count = self.twoArray.count;
        }break;
        case 2:{
            count = self.threeArray.count;
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
            if (indexPath.row < self.oneArray.count) {
                LSHomeSetItemObject *item = [self.oneArray objectAtIndex:indexPath.row];
                setCell.settingIcon.image = [UIImage imageNamed:item.iconName];
                setCell.contentLabel.text = item.titleName;
                setCell.offIcon.hidden = YES;
                switch (item.firstType) {
                    case SettingFirstTypeChat:{
                        [setCell showChatListUnreadNum:[self.unreadManager getUnreadNum:LSUnreadType_Private_Chat]];
                    }break;
                    case SettingFirstTypeMail:{
                           [setCell showUnreadNum:[self.unreadManager getUnreadNum:LSUnreadType_EMF]];
                    }break;
                    case SettingFirstTypeSayHi:{
                           [setCell showUnreadNum:[self.unreadManager getUnreadNum:LSUnreadType_SayHi]];
                    }break;
                    case SettingFirstTypeGreeting:{
                           [setCell showUnreadNum:[self.unreadManager getUnreadNum:LSUnreadType_Loi]];
                    }break;
                        case SettingFirstTypeStroe:{
                            
                            if ([LSConfigManager manager].item.flowersGift > 0) {
                               setCell.offIcon.hidden = NO;
                                setCell.offLabel.text = [NSString stringWithFormat:@"$%d OFF",[LSConfigManager manager].item.flowersGift];
                            }
                        
                    }break;
                    default:
                        break;
                }
            }

            cell = setCell;
        }break;
        case 1:{
            LSHomeSettingCell *myCell = [LSHomeSettingCell getUITableViewCell:tableView];
            if (indexPath.row < self.twoArray.count) {
                LSHomeSetItemObject *item = [self.twoArray objectAtIndex:indexPath.row];
                myCell.settingIcon.image = [UIImage imageNamed:item.iconName];
                myCell.contentLabel.text = item.titleName;
                switch (item.secondType) {
                    case SettingSecondTypeHangout:{
                        [myCell showUnreadNum:[self.unreadManager getUnreadNum:LSUnreadType_Hangout]];
                    }break;
                    case SettingSecondTypeMyContacts: {
                        
                    }break;
                    default:
                        break;
                }
                cell = myCell;
            }
       
        }break;
        case 2: {
            LSHomeSettingCell *setCell = [LSHomeSettingCell  getUITableViewCell:tableView];
            if (indexPath.row < self.threeArray.count) {
            LSHomeSetItemObject *item = [self.threeArray objectAtIndex:indexPath.row];
                setCell.settingIcon.image = [UIImage imageNamed:item.iconName];
                setCell.contentLabel.text = item.titleName;
                switch (item.thirdType) {
                    case SettingThirdTypeShow:{
                        [setCell showUnreadPoint:[self.unreadManager getUnreadNum:LSUnreadType_Ticket]];
                    }break;
                    case SettingThirdTypeBooks:{
                        [setCell showUnreadPoint:[self.unreadManager getUnreadNum:LSUnreadType_Booking]];
                    }break;
                    case SettingThirdTypeBackpack:{
                        [setCell showUnreadPoint:[self.unreadManager getUnreadNum:LSUnreadType_Backpack]];
                    }break;
                    default:
                        break;
                }
                cell = setCell;
            }
        }break;
        case 3:{
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
            LSHomeSetItemObject *item = [self.oneArray objectAtIndex:indexPath.row];
            switch (item.firstType) {
                case SettingFirstTypeChat:{
                    if (![[QNRiskControlManager manager]isRiskControlType:RiskType_livechat withController:[LiveModule module].moduleVC.navigationController]) {
                        QNChatAndInvitationViewController *vc = [[QNChatAndInvitationViewController alloc] initWithNibName:nil bundle:nil];
                        [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                    }
                }break;
                case SettingFirstTypeMail:{
                    LSMailViewController *vc = [[LSMailViewController alloc] initWithNibName:nil bundle:nil];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                case SettingFirstTypeSayHi:{
                    // TODO: sayhi界面
                    LSSayHiListViewController *vc = [[LSSayHiListViewController alloc] initWithNibName:nil bundle:nil];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                    
                }break;
                case SettingFirstTypeGreeting:{
                    LSGreetingsViewController *vc = [[LSGreetingsViewController alloc] initWithNibName:nil bundle:nil];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                case SettingFirstTypeStroe:{
                    LSStoreMainViewController * vc = [[LSStoreMainViewController alloc]initWithNibName:nil bundle:nil];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                default:
                    break;

            }
        }break;
        case 1:{
            LSHomeSetItemObject *item = [self.twoArray objectAtIndex:indexPath.row];
            switch (item.secondType) {
                case SettingSecondTypeHangout:{
                    [self removeHomeSettingVC];
                    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHomePage:LiveUrlMainListUrlTypeHangout];
                    [[LiveUrlHandler shareInstance] handleOpenURL:url];
                }break;
                case SettingSecondTypeMyContacts: {
                    LSMyContactsViewController * vc = [[LSMyContactsViewController alloc]initWithNibName:nil bundle:nil];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                default:
                    break;
            }
        }break;
        case 2:{
            LSHomeSetItemObject * item = [self.threeArray objectAtIndex:indexPath.row];
            switch (item.thirdType) {
                case SettingThirdTypeShow:{
                    MyTicketPageViewController * vc = [[MyTicketPageViewController alloc] initWithNibName:nil bundle:nil];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                case SettingThirdTypeBooks:{
                    LSMyReservationsViewController *vc = [[LSMyReservationsViewController alloc] initWithNibName:nil bundle:nil];
                    [[LiveModule module].moduleVC.navigationController pushViewController:vc animated:YES];
                }break;
                case SettingThirdTypeBackpack:{
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
