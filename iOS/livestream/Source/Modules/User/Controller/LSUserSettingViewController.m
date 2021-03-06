//
//  LSUserSettingViewController.m
//  livestream
//
//  Created by Calvin on 2018/9/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSUserSettingViewController.h"
#import "LSUserSettingHeadView.h"
#import "LSUserSettingFollowCell.h"
#import "GetFollowListRequest.h"
#import "LiveUrlHandler.h"
#import "LSSettingInfoCell.h"
#import "LiveRoomCreditRebateManager.h"
#import "AnchorPersonalViewController.h"
#import "LSUserSetUpViewController.h"
#import "MyBackpackViewController.h"
#import "LSAddCreditsViewController.h"
#import "LSManProfileViewController.h"
#import "LiveModule.h"
#import "LSGetMyProfileRequest.h"
#import "LSLoginManager.h"
#import "LSProfilePhotoViewController.h"
#import "LSProfilePhotoActionViewController.h"

@interface LSUserSettingViewController () <LSUserSettingHeadViewDelegate, UITableViewDelegate, UITableViewDataSource, LSUserSettingFollowCellDelegate>
@property (nonatomic, strong) LSUserSettingHeadView *headView;

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) LSDomainSessionRequestManager *domainSessionManager;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, copy) NSString *creditStr;

@property (nonatomic, copy) NSString *vouchersStr;

@property (nonatomic, strong) LSPersonalProfileItemObject *personalItem;
@end

@implementation LSUserSettingViewController

- (void)dealloc {
    NSLog(@"LSUserSettingViewController dealloc");
}

- (void)initCustomParam {
    [super initCustomParam];

    self.isShowNavBar = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.sessionManager = [LSSessionRequestManager manager];
    self.domainSessionManager = [LSDomainSessionRequestManager manager];

    self.items = [NSArray array];

    self.creditStr = [NSString stringWithFormat:@"%0.2f", [LiveRoomCreditRebateManager creditRebateManager].mCredit];
    self.vouchersStr = [NSString stringWithFormat:@"%d", [LiveRoomCreditRebateManager creditRebateManager].mCoupon];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self setTableHeadView];

    [self getFollowData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getPersonalProfile];
    [self getCredit];

    if (!self.viewDidAppearEver) {
        if (@available(iOS 11, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setTableHeadView {
    CGFloat headH = 220;
    CGFloat topH = 20;
    //iPhoneX兼容
    if (IS_IPHONE_X) {
        headH = headH;
        topH = 44;
    }

    if (!self.headView) {
        self.headView = [[LSUserSettingHeadView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, headH)];
        self.headView.delegate = self;
    }

    [self.tableView setTableHeaderView:self.headView];

    //    [self.tableView setContentInset:UIEdgeInsetsMake(-topH, 0, 0, 0)];

    [self.tableView setTableFooterView:[UIView new]];

    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [self.tableView reloadData];
}

- (void)settingHeadViewBackDid {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 接口
- (BOOL)getPersonalProfile {
    LSGetMyProfileRequest *request = [[LSGetMyProfileRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, LSPersonalProfileItemObject *_Nullable userInfoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.headView.nameLabel.text = [NSString stringWithFormat:@"%@ %@", userInfoItem.firstname, userInfoItem.lastname];
                self.headView.editBtn.hidden = ![userInfoItem canUpdatePhoto];
                self.personalItem = userInfoItem;
                [self.headView reloadHeadImage:self.personalItem.photoUrl];

                [self saveUserData:userInfoItem];
            }
        });
    };
    return [self.domainSessionManager sendRequest:request];
}

#pragma mark 获取Follow数据
- (void)getFollowData {

    GetFollowListRequest *request = [[GetFollowListRequest alloc] init];
    request.start = 0;
    request.step = 10;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<FollowItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSUserSettingViewController::getFollowData( [%@], count : %d )", BOOL2SUCCESS(success), (int)array.count);
            if (success) {

                self.items = array;

                [self.tableView reloadData];
            }
        });

    };

    [self.sessionManager sendRequest:request];
}

- (void)getCredit {
    __weak typeof(self) weakSelf = self;
    [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        if (success) {
            weakSelf.creditStr = [NSString stringWithFormat:@"%.2f", credit];
            weakSelf.vouchersStr = [NSString stringWithFormat:@"%d", coupon];
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 3;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 10)];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        return self.items.count > 0 ? [LSUserSettingFollowCell cellHeight] : 50;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;

    if (indexPath.section == 0) {
        LSUserSettingFollowCell *cell = [LSUserSettingFollowCell getUITableViewCell:tableView];
        cell.cellDelegate = self;
        result = cell;

        if (self.items.count > 0) {
            [cell loadFollowData:self.items];
        }
    } else {
        LSSettingInfoCell *cell = [LSSettingInfoCell getUITableViewCell:tableView];
        result = cell;

        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.titleLabel.text = @"Profile Details";
              
            } else if (indexPath.row == 1) {
                cell.titleLabel.text = @"Credit Balance";
                cell.numLabel.text = self.creditStr;
                cell.arrowIcon.hidden = YES;
            }
            else {
                cell.titleLabel.text = @"My Vouchers";
                cell.numLabel.text = self.vouchersStr;
                cell.arrowIcon.hidden = YES;
            }
            
        } else {
            cell.arrowIcon.hidden = NO;
            cell.titleLabel.text = @"Settings";
            cell.numLabel.text = @"";
        }
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    if (indexPath.section == 0) {
        [self.navigationController popViewControllerAnimated:NO];
        NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHomePage:LiveUrlMainListUrlTypeFollow];
        [[LiveUrlHandler shareInstance] handleOpenURL:url];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self settingBackgroundDid];
        } else if (indexPath.row == 1) {
            [[LiveModule module].analyticsManager reportActionEvent:ClickCredit eventCategory:EventCategoryCredit];
            LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            MyBackpackViewController *vc = [[MyBackpackViewController alloc] initWithNibName:nil bundle:nil];
            vc.curIndex = 1;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        LSUserSetUpViewController *vc = [[LSUserSetUpViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)pushFollowLadyDetails:(NSString *)userId {
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = userId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)settingBackgroundDid {
    LSManProfileViewController *vc = [[LSManProfileViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)settingHeadImageDid {
    if ([self.personalItem noPhotoStatus]) {
        return;
    }
    LSProfilePhotoViewController *vc = [[LSProfilePhotoViewController alloc] initWithNibName:nil bundle:nil];
    vc.isInReview = ![self.personalItem canUpdatePhoto];
    vc.headImage = self.headView.headImage;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)settingHeadEditDid {
    LSProfilePhotoActionViewController *vc = [[LSProfilePhotoActionViewController alloc] initWithNibName:nil bundle:nil];
    [vc showPhotoAction:self];
}

// 保存男士资料信息
- (void)saveUserData:(LSPersonalProfileItemObject *)item {
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSString *key = [LSLoginManager manager].loginItem.userId;
    NSString *manKey = [NSString stringWithFormat:@"LSManProfile_%@", key];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
    [userData setObject:data forKey:manKey];
    [userData synchronize];
}

@end
