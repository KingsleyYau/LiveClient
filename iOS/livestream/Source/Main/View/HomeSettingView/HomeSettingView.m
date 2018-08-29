//
//  SettingView.m
//  dating
//
//  Created by Calvin on 17/7/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "HomeSettingView.h"
#import "LSHomeSettingCell.h"
#import "LSHomeSettingCreditCell.h"
#import "LiveSettingLineCell.h"
#import "LSHomeSettingHaedView.h"
#import "LSLoginManager.h"
#import "UnreadNumManager.h"

@interface HomeSettingView () <LSHomeSettingHaedViewDelegate>
@property (nonatomic, strong) NSArray * iconArray;
@property (nonatomic, strong) NSArray * titleArray;

@property (nonatomic, strong) NSArray * imageArray;
@property (nonatomic, strong) NSArray * headArray;

@property (nonatomic, strong) UnreadNumManager *unreadManager;
@end

@implementation HomeSettingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"HomeSettingView" owner:self options:nil].firstObject;
        self.unreadManager = [UnreadNumManager manager];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.bgView.alpha = 0;
    self.tableView.frame = CGRectMake(-screenSize.width, 0, screenSize.width - 70, screenSize.height);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewswipe:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:swipe];

    [self setTableHeadView];
    [self setTableFooterView];
    
    self.iconArray = @[@"Setting_Message_Icon",@"Setting_Mail_Icon",@"Setting_Greetings_Icon"];
    self.titleArray = @[@"Message",@"Mail",@"Greeting Mail"];
   
    self.imageArray = @[@"Setting_Ticket_Icon",@"Setting_Bookings_Icon",@"Setting_BackPack_Icon"];
    self.headArray = @[@"My Show Tickets",@"My Bookings",@"My Backpack"];
}


- (void)setTableHeadView
{
    CGFloat headH = 166;
    CGFloat topH = 0;
    //iPhoneX兼容
    if (screenSize.height == 812) {
        headH = headH + 44;
        topH = 44;
    }
    
    LSHomeSettingHaedView *headView = [[LSHomeSettingHaedView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, headH)];
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0.5;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = CGRectMake(0, 0, screenSize.width - 70, screenSize.height);
        }];
    }];
    self.isShowSettingView = YES;
}

//隐藏侧滑栏
- (void)hideSettingView
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [UIView animateWithDuration:0.3 animations:^{
    self.tableView.frame = CGRectMake(-screenSize.width, 0, screenSize.width - 70, screenSize.height);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bgView.alpha = 0;
        }completion:^(BOOL finished) {
            self.frame = CGRectMake(-screenSize.width, 0, screenSize.width, screenSize.height);
        }];
    }];
    
    self.isShowSettingView = NO;
    
    if ([self.delegate respondsToSelector:@selector(settingViewWillHide)]) {
        [self.delegate settingViewWillHide];
    }
}

////更新数据
//- (void)updateSetting:(PersonalProfile *)profile
//{
//
//    self.item = profile;
//    [self.headView setUserName:self.item.firstname];
//    if (self.item.photoUrl.length > 0) {
//        [self.headView loadHeadPhoto:self.item.photoUrl];
//    }
//    [self.tableView reloadData];
//}

#pragma mark TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            height = [LSHomeSettingCell cellHeight];
            NSInteger index = self.headArray.count - 1;
            if (indexPath.row > index) {
                height = [LiveSettingLineCell cellHeight];
            }
        }break;
            
        default:{
            height = [LSHomeSettingCell cellHeight];
        }break;
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 1;
    switch (section) {
        case 0:{
            count = 2;
        }break;
            
        case 1:{
            count = self.titleArray.count + 1;
        }break;
            
        default:{
            count = self.headArray.count;
        }break;
    }
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row) {
                LiveSettingLineCell *setCell = [LiveSettingLineCell getUITableViewCell:tableView];
                cell = setCell;
            } else {
                LSHomeSettingCreditCell *addCell = [LSHomeSettingCreditCell getUITableViewCell:tableView];
                [addCell showMyCredits];
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
                [setCell showUnreadNum:[self.unreadManager getUnreadNum:(UnreadType)indexPath.row]];
                cell = setCell;
            }
        }break;
            
        default:{
            LSHomeSettingCell *myCell = [LSHomeSettingCell getUITableViewCell:tableView];
            myCell.settingIcon.image = [UIImage imageNamed:[self.imageArray objectAtIndex:indexPath.row]];
            myCell.contentLabel.text = [self.headArray objectAtIndex:indexPath.row];
            NSInteger type = indexPath.row + 3;
            [myCell showUnreadPoint:[self.unreadManager getUnreadNum:(UnreadType)type]];
            cell = myCell;
        }break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    [self hideSettingView];
    //TODO :进入详情
    if ([self.delegate respondsToSelector:@selector(homeSettingViewPushVCIndex:)]) {
        [self.delegate homeSettingViewPushVCIndex:indexPath];
    }
}

#pragma mark - LSHomeSettingHaedViewDelegate
- (void)didChangeSiteClick {
    if ([self.delegate respondsToSelector:@selector(settingViewChangeSiteClick)]) {
        [self.delegate settingViewChangeSiteClick];
    }
}

- (void)didOpenProfileClick {
    if ([self.delegate respondsToSelector:@selector(settingViewOpenProfileClick)]) {
        [self.delegate settingViewOpenProfileClick];
    }
}

- (void)didOpenLevelExplain {
    if ([self.delegate respondsToSelector:@selector(settingViewOpenLevelExplain)]) {
        [self.delegate settingViewOpenLevelExplain];
    }
}

@end
