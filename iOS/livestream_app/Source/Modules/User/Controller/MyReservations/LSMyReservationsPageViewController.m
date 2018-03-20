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
#import "NewInvitesCell.h"
#import "LSFileCacheManager.h"
#import "JDAlertView.h"
#import "AnchorPersonalViewController.h"
#import "LiveModule.h"
#import "LSLoginManager.h"
#import "PreLiveViewController.h"
#import "LiveRoomCreditRebateManager.h"
#import "LiveService.h"
#import "LSMyCoinViewController.h"
#import "LSAnalyticsManager.h"

#define MAXNum 20

@interface LSMyReservationsPageViewController () <UITableViewDelegate, UITableViewDataSource, NewInvitesCellDelegate, UIScrollViewRefreshDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, assign) int page;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (nonatomic, assign) BOOL isReload;
@property (nonatomic, strong) DialogTip *dialogTipView;
@property (strong) DialogOK *dialogReservationAddCredit;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) BOOL isShowStartNowBtn;
@property (nonatomic, assign) BOOL isRequstData;
@property (nonatomic, strong) NSTimer * loadtimer;

@end

@implementation LSMyReservationsPageViewController
- (void)dealloc {
    if (self.dialogReservationAddCredit) {
        [self.dialogReservationAddCredit removeFromSuperview];
    }
        [self.tableView unInitPullRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView setTableFooterView:[UIView new]];
    self.sessionManager = [LSSessionRequestManager manager];
    self.infoBtn.layer.cornerRadius = 5;
    self.infoBtn.layer.masksToBounds = YES;
    self.data = [NSMutableArray array];

    self.dialogTipView = [DialogTip dialogTip];

    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.type == BOOKINGLISTTYPE_WAITANCHORHANDLEING ||
        self.type == BOOKINGLISTTYPE_COMFIRMED) {
        self.isRequstData = YES;
        self.loadtimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadData) userInfo:nil repeats:NO];
    }
    else
    {
       [self getListDataIsLoadMore:NO];
    }
}

- (void)loadData
{
    [self.loadtimer invalidate];
    self.loadtimer = nil;
    if (self.isRequstData) {
       [self getListDataIsLoadMore:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isRequstData = NO;
    [self.timer invalidate];
    self.timer = nil;
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

    //self.mainVC.view.userInteractionEnabled = NO;
    ManHandleBookingListRequest *request = [[ManHandleBookingListRequest alloc] init];
    request.type = self.type;
    request.start = self.page;
    request.step = MAXNum;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, BookingPrivateInviteListObject *_Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self hideLoading];
           // self.mainVC.view.userInteractionEnabled = YES;
            
            if (isLoadMore) {
                [self.tableView finishPullUp:YES];

            } else {
                [self.tableView finishPullDown:YES];
                [self.mainVC getunreadCount];
            }

            if (success) {
                if (!isLoadMore) {
                    [self.data removeAllObjects];
                }
                self.page = self.page + (int)item.list.count;

                if (self.type == BOOKINGLISTTYPE_COMFIRMED ) {
                    if (!self.timer) {
                        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
                    }
                    
                    NSMutableArray * list = item.list;
                    NSMutableArray * array = [NSMutableArray array];
                    for (BookingPrivateInviteItemObject * obj in list) {
                        
                        if (obj.bookTime + 180 > [[NSDate new]timeIntervalSince1970])
                        {
                            [array addObject:obj];
                        }
                    }
                    
                    [self.data addObjectsFromArray:array];
                }
                else
                {
                    
                    [self.data addObjectsFromArray:item.list];
                }
                
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
    };

    [self.sessionManager sendRequest:request];
}

- (void)showInfoViewIsReload:(BOOL)isReload {
    self.isReload = isReload;
    self.infoView.hidden = NO;
    if (isReload) {
        self.infoLabel.text = NSLocalizedStringFromSelf(@"Failed_Message");
        [self.infoBtn setTitle:NSLocalizedStringFromSelf(@"Reload") forState:UIControlStateNormal];
    } else {
        NSString *message = @"";
        if (self.type == BOOKINGLISTTYPE_WAITFANSHANDLEING) {
            message = NSLocalizedStringFromSelf(@"NoData_Tip_1");
        } else if (self.type == BOOKINGLISTTYPE_WAITANCHORHANDLEING) {
            message = NSLocalizedStringFromSelf(@"NoData_Tip_2");
        } else if (self.type == BOOKINGLISTTYPE_COMFIRMED) {
            message = NSLocalizedStringFromSelf(@"NoData_Tip_3");
        } else {
            message = NSLocalizedStringFromSelf(@"NoData_Tip_4");
        }

        self.infoLabel.text = message;
        [self.infoBtn setTitle:NSLocalizedStringFromSelf(@"Hot_Broadcasters") forState:UIControlStateNormal];
    }
}

- (void)hideInfoView {
    self.infoView.hidden = YES;
}

- (IBAction)infoBtnDid:(UIButton *)sender {

    if (self.isReload) {
        [self getListDataIsLoadMore:NO];
    } else {

         NSURL *url = [NSURL URLWithString:@"qpidnetwork://app/open?site:4&service=live&module=main"];
        [LiveUrlHandler shareInstance].url = url;
        [[LiveUrlHandler shareInstance]handleOpenURL];
    }
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
    return [NewInvitesCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewInvitesCell *result = nil;
    NewInvitesCell *cell = [NewInvitesCell getUITableViewCell:tableView forRow:indexPath.row];
    result = cell;
    cell.delegate = self;

    if (self.data.count > 0) {
        BookingPrivateInviteItemObject *obj = self.data[indexPath.row];

        cell.nameLabel.text = obj.oppositeNickName;

        [cell.imageViewLoader stop];
        if (!cell.imageViewLoader) {
            cell.imageViewLoader = [LSImageViewLoader loader];
        }
//        cell.imageViewLoader.url = obj.oppositePhotoUrl;
//        cell.imageViewLoader.path = [[LSFileCacheManager manager] imageCachePathWithUrl:cell.imageViewLoader.url];
//        cell.imageViewLoader.view = cell.headImage;
//        [cell.imageViewLoader loadImage];
        [cell.imageViewLoader sdWebImageLoadView:cell.headImage options:0 imageUrl:obj.oppositePhotoUrl placeholderImage:nil finishHandler:nil];

        if (SCREEN_WIDTH == 320) {
            cell.subLabel.font = [UIFont systemFontOfSize:10];
        } else {
           cell.subLabel.font = [UIFont systemFontOfSize:12];
        }
        cell.subLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromSelf(@"Reservation_Time"), [cell getTime:obj.bookTime]];

        cell.redIcon.hidden = obj.read;

        if (self.type == BOOKINGLISTTYPE_WAITFANSHANDLEING) {
            cell.comfirmBtn.hidden = NO;
            cell.declineBtn.hidden = NO;
            cell.cancelBtn.hidden = YES;
            cell.scheduledTimeView.hidden = YES;
            cell.historyLabel.hidden = YES;
        } else if (self.type == BOOKINGLISTTYPE_WAITANCHORHANDLEING) {
            cell.comfirmBtn.hidden = YES;
            cell.declineBtn.hidden = YES;
            cell.cancelBtn.hidden = NO;
            cell.scheduledTimeView.hidden = YES;
            cell.historyLabel.hidden = YES;
            cell.redIcon.hidden = YES;
        } else if (self.type == BOOKINGLISTTYPE_COMFIRMED) {
            cell.comfirmBtn.hidden = YES;
            cell.declineBtn.hidden = YES;
            cell.cancelBtn.hidden = YES;

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
        } else {
            cell.comfirmBtn.hidden = YES;
            cell.declineBtn.hidden = YES;
            cell.cancelBtn.hidden = YES;
            cell.scheduledTimeView.hidden = YES;
            cell.historyLabel.hidden = NO;

            //状态（1:待确定 2:已接受 3:已拒绝 4:超时 5:取消 6:主播缺席 7:观众缺席 8:已完成）
            if (obj.replyType == 3) {
                cell.historyLabel.textColor = COLOR_WITH_16BAND_RGB(0x9d9d9d);
                cell.historyLabel.text = NSLocalizedStringFromSelf(@"History_Msg_1");
            }
            if (obj.replyType == 7) {
                cell.historyLabel.textColor = COLOR_WITH_16BAND_RGB(0x9d9d9d);
                cell.historyLabel.text = NSLocalizedStringFromSelf(@"History_Msg_2");
            }
            if (obj.replyType == 6) {
                cell.historyLabel.textColor = COLOR_WITH_16BAND_RGB(0x9d9d9d);
                cell.historyLabel.text = NSLocalizedStringFromSelf(@"History_Msg_3");
            }
            if (obj.replyType == 4) {
                cell.historyLabel.textColor = COLOR_WITH_16BAND_RGB(0x9d9d9d);
                cell.historyLabel.text = NSLocalizedStringFromSelf(@"History_Msg_4");
            }
            if (obj.replyType == 8) {
                cell.historyLabel.textColor = COLOR_WITH_16BAND_RGB(0x3c3c3c);
                cell.historyLabel.text = NSLocalizedStringFromSelf(@"History_Msg_5");
            }
            if (obj.replyType == 5) {
                cell.historyLabel.textColor = COLOR_WITH_16BAND_RGB(0x9d9d9d);
                cell.historyLabel.text = NSLocalizedStringFromSelf(@"History_Msg_6");
            }
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
        [self.mainVC.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark 点击进入直播
- (void)myReservationsStartNowDidForRow:(NSInteger)row
{
    if (self.data.count > 0) {
        BookingPrivateInviteItemObject *obj = self.data[row];
        
        PreLiveViewController *vc = [[PreLiveViewController alloc] initWithNibName:nil bundle:nil];
        LiveRoom *liveRoom = [[LiveRoom alloc] init];
        liveRoom.roomId = obj.roomId;
        liveRoom.photoUrl = obj.oppositePhotoUrl;
        liveRoom.userName = obj.oppositeNickName;
        vc.liveRoom = liveRoom;
        [self navgationControllerPresent:vc];
        
        NSLog(@"点击进入预约直播%@",obj.roomId);
    }
}

#pragma mark 倒计时完成
- (void)myReservationsCountdownEnd
{
    [self getListDataIsLoadMore:NO];
}

#pragma mark 同意/拒绝 预约
- (void)myReservationsComfirmBtnDidForRow:(NSInteger)row {
    if (self.data.count > 0) {
        BookingPrivateInviteItemObject *obj = self.data[row];
        [self getMyReservationsInvites:YES forInviteId:obj.invitationId];
    }
}

- (void)myReservationsDeclineBtnDidForRow:(NSInteger)row {
 
    if (self.data.count > 0) {
        BookingPrivateInviteItemObject *obj = self.data[row];
        
        JDAlertView *alertView = [[JDAlertView alloc] initWithMessage:NSLocalizedStringFromSelf(@"Decline_Reservation")
                                                        noButtonTitle:NSLocalizedStringFromSelf(@"NO")
                                                       yesButtonTitle:NSLocalizedStringFromSelf(@"YES")
                                                              onBlock:nil
                                                             yesBlock:^{
                                                                 
                                                                 [self getMyReservationsInvites:NO forInviteId:obj.invitationId];
                                                             }];
        [alertView show];
    }
}

- (void)getMyReservationsInvites:(BOOL)isComfirm forInviteId:(NSString *)inviteId {
    [self showLoading];
    HandleBookingRequest *request = [[HandleBookingRequest alloc] init];
    request.inviteId = inviteId;
    request.isConfirm = isComfirm;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];

            if (success) {
                [self getListDataIsLoadMore:NO];
                NSString *message = isComfirm ? NSLocalizedStringFromSelf(@"Comfirm_Success") : NSLocalizedStringFromSelf(@"Decline_Success");

                [self showDialog:message];
            } else {
                if (errnum == HTTP_LCC_ERR_NO_CREDIT) {

                    if (self.dialogReservationAddCredit) {
                        [self.dialogReservationAddCredit removeFromSuperview];
                    }
                    
                    self.dialogReservationAddCredit = [DialogOK dialog];
                    self.dialogReservationAddCredit.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_ERR_ADD_COINS");
                    [self.dialogReservationAddCredit showDialog:self.view
                                                    actionBlock:^{
                                                        NSLog(@"跳转到充值界面");
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [[LSAnalyticsManager manager] reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
                                                            LSMyCoinViewController *myCoin = [[LSMyCoinViewController alloc] initWithNibName:nil bundle:nil];
                                                            [self.navigationController pushViewController:myCoin animated:YES];
                                                        });
                                                    }];
                } else {
                    [self showDialog:errmsg];

                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma 取消预约
- (void)myReservationsCancelBtnDidForRow:(NSInteger)row {
    if (self.data.count > 0) {
        BookingPrivateInviteItemObject *obj = self.data[row];
        
        JDAlertView *alertView = [[JDAlertView alloc] initWithMessage:NSLocalizedStringFromSelf(@"Cancel_Reservation")
                                                        noButtonTitle:NSLocalizedStringFromSelf(@"NO")
                                                       yesButtonTitle:NSLocalizedStringFromSelf(@"YES")
                                                              onBlock:nil
                                                             yesBlock:^{
                                                                 
                                                                 [self getCancelPrivate:obj.invitationId];
                                                             }];
        [alertView show];
    }
}

- (void)getCancelPrivate:(NSString *)invitationId {
    [self showLoading];
    CancelPrivateRequest *request = [[CancelPrivateRequest alloc] init];
    request.invitationId = invitationId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];

            if (success) {
                [self getListDataIsLoadMore:NO];

                [self showDialog:NSLocalizedStringFromSelf(@"CANCELED_RESERVATION_SUCCESS")];

            } else {
                [self showDialog:errmsg];
            }
        });

    };
    [self.sessionManager sendRequest:request];
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
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
    [nvc.navigationBar setTitleTextAttributes:attributes];
    [nvc.navigationItem setHidesBackButton:YES];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

@end
