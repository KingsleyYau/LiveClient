//
//  LSMyReservationsPageViewController.m
//  livestream
//
//  Created by Calvin on 17/10/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSMyReservationsPageViewController.h"
#import "DialogTip.h"
#import "DialogOK.h"
#import "ScheduledCell.h"
#import "LSFileCacheManager.h"
#import "JDAlertView.h"
#import "AnchorPersonalViewController.h"
#import "LiveModule.h"
#import "LSLoginManager.h"
#import "PreLiveViewController.h"
#import "LiveService.h"
#import "ZBLSRequestManager.h"
#define MAXNum 20

@interface LSMyReservationsPageViewController () <UITableViewDelegate, UITableViewDataSource,UIScrollViewRefreshDelegate,ScheduledCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, assign) int page;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, assign) BOOL isReload;
@property (nonatomic, strong) DialogTip *dialogTipView;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) BOOL isShowStartNowBtn;
@property (nonatomic, strong) NSTimer * loadtimer;
@end

@implementation LSMyReservationsPageViewController
- (void)dealloc {
    [self.tableView unInitPullRefresh];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedStringFromSelf(@"MY_TITLE");
    
    [self.tableView setTableFooterView:[UIView new]];
 
    self.data = [NSMutableArray array];
    self.dialogTipView = [DialogTip dialogTip];
 
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView startPullDown:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)countdown
{
    [self.tableView reloadData];
}

//下拉刷新
- (void)pullDownRefresh {

    [self getListDataIsLoadMore:NO];
}

//上拉更多
- (void)pullUpRefresh {
    [self getListDataIsLoadMore:YES];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

- (void)pullUpRefresh:(UIScrollView *)scrollView {
    // 上拉更多回调
    if (self.data.count >= MAXNum) {
        [self pullUpRefresh];
    } else {
        // 停止底部
        [self.tableView finishPullUp:NO];
    }
}

- (void)getListDataIsLoadMore:(BOOL)isLoadMore {
    [self hideInfoView];
    //[self showLoading];
    if (!isLoadMore) {
        self.isShowStartNowBtn = NO;
        self.page = 0;
    }
    
    [[ZBLSRequestManager manager] anchorManHandleBookingList:ZBBOOKINGLISTTYPE_COMFIRMED start:self.page step:MAXNum finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBBookingPrivateInviteListObject * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{

            if (isLoadMore) {
                [self.tableView finishPullUp:YES];
                
            } else {
                [self.tableView finishPullDown:YES];
            }
            
            if (success) {
                if (!isLoadMore) {
                    [self.data removeAllObjects];
                }
                self.page = self.page + (int)item.list.count;
                
                if (!self.timer) {
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
                }
                
                NSMutableArray * list = item.list;
                NSMutableArray * array = [NSMutableArray array];
                for (ZBBookingPrivateInviteItemObject * obj in list) {
                    
                    if (obj.bookTime + 180 > [[NSDate new]timeIntervalSince1970])
                    {
                        [array addObject:obj];
                    }
                }
                
                [self.data addObjectsFromArray:array];
                
                if (self.data.count == 0) {
                    [self showInfoViewIsReload:NO];
                }
            } else {
                if (self.data.count == 0) {
                    [self showInfoViewIsReload:YES];
                }
                else
                {
                    [self showDialog:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
                }
            }
            
            [self.tableView reloadData];
        });
    }];
}

- (void)showInfoViewIsReload:(BOOL)isReload {
    self.isReload = isReload;
    self.infoView.hidden = NO;
    if (isReload) {
        self.infoLabel.text = NSLocalizedStringFromSelf(@"Failed_Message");
    } else {
        NSString *message = NSLocalizedStringFromSelf(@"NoData_Tip_1");
        self.infoLabel.text = message;
    }
}

- (void)hideInfoView {
    self.infoView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ScheduledCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScheduledCell *result = nil;
    ScheduledCell *cell = [ScheduledCell getUITableViewCell:tableView forRow:indexPath.row];
    result = cell;
    cell.delegate = self;
    
    if (self.data.count > 0) {
        BookingPrivateInviteItemObject *obj = self.data[indexPath.row];
        
        cell.nameLabel.text = obj.oppositeNickName;
        
        [cell.imageViewLoader stop];
        if (!cell.imageViewLoader) {
            cell.imageViewLoader = [LSImageViewLoader loader];
        }
        
        [cell.imageViewLoader refreshCachedImage:cell.headImage options:SDWebImageRefreshCached imageUrl:obj.oppositePhotoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
        
        if (SCREEN_WIDTH == 320) {
            cell.subLabel.font = [UIFont systemFontOfSize:10];
        } else {
            cell.subLabel.font = [UIFont systemFontOfSize:12];
        }
        cell.subLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromSelf(@"Reservation_Time"), [cell getTime:obj.bookTime]];
        
        cell.redIcon.hidden = obj.read;
        
        NSString *timeStr = [cell compareCurrentTime:obj.bookTime];
        NSArray *array = [timeStr componentsSeparatedByString:@" "];
        if (array.count > 1) {
            cell.scheduledTimeView.hidden = YES;
            cell.historyLabel.hidden = NO;
            [cell setTimeStr:timeStr];
        } else {
            
            if (!self.isShowStartNowBtn) {
                self.isShowStartNowBtn = YES;
            }
            cell.scheduledTimeView.hidden = NO;
            cell.historyLabel.hidden = YES;
            [cell startCountdown:obj.bookTime];
        }
    }
    return result;
}

#pragma mark 点击进入女士详情
- (void)myReservationsHeadDidForRow:(NSInteger)row
{
    if (self.data.count > 0) {
        //进入女士详情
        BookingPrivateInviteItemObject *obj = self.data[row];
        NSString * userId = @"";
        if ([[LSLoginManager manager].loginItem.userId isEqualToString:obj.fromId])
        {
            userId = obj.toId;
        }
        else
        {
            userId = obj.fromId;
        }
        AnchorPersonalViewController *vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
        vc.anchorId = userId;
        vc.enterRoom = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)scheduledHeadDidForRow:(NSInteger)row
{
    if (self.data.count > 0) {
        //进入女士详情
        BookingPrivateInviteItemObject *obj = self.data[row];
        NSString * userId = @"";
        if ([[LSLoginManager manager].loginItem.userId isEqualToString:obj.fromId])
        {
            userId = obj.toId;
        }
        else
        {
            userId = obj.fromId;
        }
        AnchorPersonalViewController *vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
        vc.anchorId = userId;
        vc.enterRoom = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark 点击进入直播
- (void)scheduledStartNowDidForRow:(NSInteger)row
{
    if (self.data.count > 0) {
        BookingPrivateInviteItemObject *obj = self.data[row];
        
        PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
        LiveRoom *liveRoom = [[LiveRoom alloc] init];
        liveRoom.roomId = obj.roomId;
        vc.liveRoom = liveRoom;
        [self navgationControllerPresent:vc];
        
        NSLog(@"点击进入预约直播%@",obj.roomId);
    }
}

#pragma mark 倒计时完成
- (void)scheduledCountdownEnd
{
    [self getListDataIsLoadMore:NO];
}

#pragma mark 显示浮窗提示
- (void)showDialog:(NSString *)message
{
    [self.dialogTipView showDialogTip:self.view tipText:message];
}

- (void)navgationControllerPresent:(UIViewController *)controller {
    LSNavigationController *nvc = [[LSNavigationController alloc] initWithRootViewController:controller];
    nvc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    nvc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    nvc.navigationBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,nil];
    [nvc.navigationBar setTitleTextAttributes:attributes];
    [nvc.navigationItem setHidesBackButton:YES];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

@end
