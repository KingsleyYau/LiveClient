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
#import "LiveMutexService.h"
#import "LiveUrlHandler.h"
#import "LSAddCreditsViewController.h"
#import "LSShadowView.h"
#import "LiveGobalManager.h"
#import "LiveModule.h"

#define MAXNum 20

@interface LSMyReservationsPageViewController () <UITableViewDelegate, UITableViewDataSource, NewInvitesCellDelegate, UIScrollViewRefreshDelegate>

@property (weak, nonatomic) IBOutlet LSTableView *tableView;
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, assign) int page;
@property (nonatomic, assign) BOOL isReload;
@property (nonatomic, strong) DialogTip *dialogTipView;
@property (strong) DialogOK *dialogReservationAddCredit;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isShowStartNowBtn;
@property (nonatomic, assign) BOOL isRequstData;
@property (nonatomic, strong) NSTimer *loadtimer;
/** 搜索按钮 */
@property (nonatomic, strong) UIButton *searchBtn;
@end

@implementation LSMyReservationsPageViewController
- (void)dealloc {
    if (self.dialogReservationAddCredit) {
        [self.dialogReservationAddCredit removeFromSuperview];
    }
    [self.tableView unSetupPullRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setTableFooterView:[UIView new]];
    self.sessionManager = [LSSessionRequestManager manager];
    self.data = [NSMutableArray array];
    self.dialogTipView = [DialogTip dialogTip];
    [self.tableView setupPullRefresh:self pullDown:YES pullUp:YES];
}

- (void)showNoDataView {
    [super showNoDataView];
    
    CGRect rect = self.noDataIcon.frame;
    rect.origin.y = (SCREEN_HEIGHT/2 - 114) - rect.size.height;
    self.noDataIcon.frame = rect;
    
    CGRect tipRect = self.noDataTip.frame;
    tipRect.origin.y = self.noDataIcon.tx_bottom + 20;
    self.noDataTip.frame = tipRect;
    
    CGFloat searchY = CGRectGetMaxY(self.noDataTip.frame) + 30;
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.searchBtn = searchBtn;
    [self.searchBtn setFrame:CGRectMake(0, searchY, 200, 44)];
    [self.searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    CGPoint searchBtnCenter = searchBtn.center;
    searchBtnCenter.x = self.noDataIcon.center.x;
    self.searchBtn.center = searchBtnCenter;
    [self.searchBtn setTitle:@"Search" forState:UIControlStateNormal];
    self.searchBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.searchBtn.layer.cornerRadius = 6.0f;
    self.searchBtn.layer.masksToBounds = YES;
    
    self.searchBtn.backgroundColor = [UIColor colorWithRed:41.0 / 255.0 green:122.0 / 255.0 blue:243.0 / 255.0 alpha:1];
    self.searchBtn.layer.cornerRadius = 6.0f;
    self.searchBtn.layer.masksToBounds = YES;
    
    [self.searchBtn addTarget:self action:@selector(searchActionClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.searchBtn];
   
    [self.view insertSubview:self.noDataTip aboveSubview:self.tableView];
    [self.view insertSubview:self.noDataIcon aboveSubview:self.tableView];
    [self.view insertSubview:self.searchBtn aboveSubview:self.tableView];
    
    self.searchBtn.hidden = NO;
}

- (void)hideNoDataView {
    [super hideNoDataView];
    self.searchBtn.hidden = YES;
    [self.searchBtn removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.type == BOOKINGLISTTYPE_WAITANCHORHANDLEING ||
        self.type == BOOKINGLISTTYPE_COMFIRMED) {
        self.isRequstData = YES;
        self.loadtimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadData) userInfo:nil repeats:NO];
    } else {
        //       [self getListDataIsLoadMore:NO];
        // 没有数据时候执行下拉刷新,隐藏提示信息view lance motify
        if (self.data.count == 0) {
            [self.tableView startLSPullDown:YES];
        } else {
            [self getListDataIsLoadMore:NO];
        }
    }
}

- (void)loadData {
    [self.loadtimer invalidate];
    self.loadtimer = nil;
    if (self.isRequstData) {
        //       [self getListDataIsLoadMore:NO];
        // 没有数据时候执行下拉刷新,隐藏提示信息view lance motify
        if (self.data.count == 0) {

            [self.tableView startLSPullDown:YES];
        } else {
            [self getListDataIsLoadMore:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isRequstData = NO;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)countdown {
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
        [self.tableView finishLSPullUp:NO];
    }
}

- (void)getListDataIsLoadMore:(BOOL)isLoadMore {
    [self hideNoDataView];
    self.failView.hidden = YES;
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
                [self.tableView finishLSPullUp:YES];
                
            } else {
                [self.tableView finishLSPullDown:YES];
                [self.mainVC getunreadCount];
            }
            
            if (success) {
                if (!isLoadMore) {
                    [self.data removeAllObjects];
                }
                self.page = self.page + (int)item.list.count;
                
                if (self.type == BOOKINGLISTTYPE_COMFIRMED) {
                    if (!self.timer) {
                        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
                    }
                    
                    NSMutableArray *list = item.list;
                    NSMutableArray *array = [NSMutableArray array];
                    for (BookingPrivateInviteItemObject *obj in list) {
                        
                        if (obj.bookTime + 180 > [[NSDate new] timeIntervalSince1970]) {
                            [array addObject:obj];
                        }
                    }
                    
                    [self.data addObjectsFromArray:array];
                } else {
                    
                    [self.data addObjectsFromArray:item.list];
                }
                
                if (self.data.count == 0) {
                    [self showNoDataView];
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
                    self.noDataTip.text = message;
                }
            } else {
                if (self.data.count == 0) {
                    self.failView.hidden = NO;
                } else {
                    [self showDialog:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")];
                }
            }
            
            [self.tableView reloadData];
        });
    };
    
    [self.sessionManager sendRequest:request];
}



- (void)lsListViewControllerDidClick:(UIButton *)sender {
    self.failView.hidden = YES;
    [self getListDataIsLoadMore:NO];
}

- (void)searchActionClick:(UIButton *)searchBtn {
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHomePage:LiveUrlMainListTypeHot];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
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
        
        [cell.imageViewLoader loadImageWithImageView:cell.headImage options:SDWebImageRefreshCached imageUrl:obj.oppositePhotoUrl placeholderImage:LADYDEFAULTIMG finishHandler:nil];
        
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
                cell.historyLabel.textColor = COLOR_WITH_16BAND_RGB(0x9d9d9d);
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
- (void)myReservationsHeadDidForRow:(NSInteger)row {
    if (self.data.count > 0) {
        //进入女士详情
        BookingPrivateInviteItemObject *obj = self.data[row];
        NSString *userId = @"";
        if ([[LSLoginManager manager].loginItem.userId isEqualToString:obj.fromId]) {
            userId = obj.toId;
        } else {
            userId = obj.fromId;
        }
        AnchorPersonalViewController *vc = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
        vc.anchorId = userId;
        vc.enterRoom = 1;
        [self.mainVC.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark 点击进入直播
- (void)myReservationsStartNowDidForRow:(NSInteger)row {
    if (self.data.count > 0) {
        BookingPrivateInviteItemObject *obj = self.data[row];
        NSString * userId = [LSLoginManager manager].loginItem.userId;
        if ([obj.fromId isEqualToString:userId]) {
            userId = obj.toId;
        }else {
            userId = obj.fromId;
        }
        NSURL * url = [[LiveUrlHandler shareInstance]createUrlToInviteByRoomId:obj.roomId anchorName:@"" anchorId:userId roomType:LiveRoomType_Private];
         [[LiveModule module].serviceManager handleOpenURL:url];
    }
}

#pragma mark 倒计时完成
- (void)myReservationsCountdownEnd {
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
                    WeakObject(self, weakSelf);
                    self.dialogReservationAddCredit = [DialogOK dialog];
                    self.dialogReservationAddCredit.tipsLabel.text = NSLocalizedStringFromSelf(@"PRELIVE_ERR_ADD_CREDIT");
                    [self.dialogReservationAddCredit showDialog:self.view
                                                    actionBlock:^{
                                                        NSLog(@"跳转到充值界面");
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
                                                            LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
                                                            [weakSelf.navigationController pushViewController:vc animated:YES];
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
- (void)showDialog:(NSString *)message {
    [self.dialogTipView showDialogTip:self.view tipText:message];
}

@end
