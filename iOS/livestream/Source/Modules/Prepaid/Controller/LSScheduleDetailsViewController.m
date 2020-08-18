//
//  LSScheduleDetailsViewController.m
//  livestream
//
//  Created by Calvin on 2020/4/20.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleDetailsViewController.h"
#import "LSAddCreditsViewController.h"

#import "DialogTip.h"
#import "LSChooseDialog.h"
#import "LSOtherOptionView.h"
#import "LSPrepaidInfoView.h"
#import "LSPrePaidPickerView.h"
#import "LSPurchaseCreditsView.h"
#import "LSScheduleDetailsHeadView.h"
#import "LSScheduleDetailsBottomView.h"
#import "LSScheduleActionCell.h"
#import "LSAcceptDiaglog.h"
#import "LSDecelineDialog.h"

#import "LiveModule.h"
#import "LSTimer.h"
#import "LiveUrlHandler.h"
#import "LSPrePaidManager.h"
#import "LSUserInfoManager.h"
#import "LiveRoomCreditRebateManager.h"

@interface LSScheduleDetailsViewController () <UITableViewDelegate, UITableViewDataSource, LSScheduleDetailsHeadViewDelegate, LSScheduleDetailsBottomViewDelegate, LSScheduleActionCellDelegate, LSOtherOptionViewDelegate, LSPrePaidPickerViewDelegate, LSPrePaidManagerDelegate, LSPurchaseCreditsViewDelegate, LSDecelineDialogDelegate, LSAcceptDiaglogDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) LSScheduleDetailsHeadView *headView;

@property (nonatomic, strong) LSScheduleDetailsBottomView *bottomView;

@property (nonatomic, strong) LSOtherOptionView *otherOptionView;

@property (nonatomic, strong) LSPrepaidInfoView *perpaidInfoView;

@property (nonatomic, strong) LSPrePaidPickerView *pickerView;

@property (nonatomic, strong) LSPurchaseCreditsView *purchaseCreditView;

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) LSPrePaidManager *paidManager;

@property (nonatomic, assign) BOOL isReplyMail;

@property (nonatomic, assign) BOOL isAccept;

@property (nonatomic, assign) BOOL isUpdata;
@end

@implementation LSScheduleDetailsViewController

- (void)dealloc {
}

- (void)initCustomParam {
    [super initCustomParam];

    self.isReplyMail = NO;
    self.isAccept = NO;

    self.array = [NSMutableArray array];

    self.paidManager = [LSPrePaidManager manager];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Schedule One-on-One Request";

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.headView = [[LSScheduleDetailsHeadView alloc] init];
    self.headView.delegate = self;
    [self.tableView setTableHeaderView:self.headView];

    self.bottomView = [[LSScheduleDetailsBottomView alloc] init];
    self.bottomView.delegate = self;
    [self.tableView setTableFooterView:self.bottomView];

    [self realoadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.paidManager addDelegate:self];

    [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg){
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.paidManager removeDelegate:self];

    if ([DialogTip dialogTip].isShow) {
        [[DialogTip dialogTip] removeShow];
    }
    self.isAccept = NO;
    self.isReplyMail = NO;

    [self.purchaseCreditView removeShowCreditView];
}

- (void)setupTableHeadFootViewHeight:(LSScheduleInviteDetailItemObject *)item {
    CGFloat height = 0;
    switch (item.status) {
        case LSSCHEDULEINVITESTATUS_PENDING: // Pending
            if (item.sendFlag == LSSCHEDULESENDFLAGTYPE_ANCHOR) {
                height = 399;
            } else {
                height = 372;
            }
            break;
        case LSSCHEDULEINVITESTATUS_CONFIRMED: // Confirmed
            height = 502;
            break;
        default:
            height = 372;
            break;
    }
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = height;
    self.tableView.tableHeaderView.frame = frame;

    CGRect rect = self.tableView.tableFooterView.frame;
    rect.size.height = [LSScheduleDetailsBottomView viewHeight];
    self.tableView.tableFooterView.frame = rect;
}

- (void)setupContainView {
    [super setupContainView];

    [self setupPurchaseCreditView];
}

- (void)setupPurchaseCreditView {
    self.purchaseCreditView = [[LSPurchaseCreditsView alloc] init];
    self.purchaseCreditView.delegate = self;
    [self.purchaseCreditView setupCreditView:self.listItem.anchorInfo.avatarImg];
}

- (void)showPurchaseCreditView {
    [self.purchaseCreditView setupCreditTipIsAccept:YES name:self.listItem.anchorInfo.nickName credit:[LiveRoomCreditRebateManager creditRebateManager].mCredit];
    [self.purchaseCreditView showLSCreditViewInView:self.navigationController.view];
}

#pragma mark - LSListViewController
- (void)lsListViewControllerDidClick:(UIButton *)sender {
    [super lsListViewControllerDidClick:sender];
    [self realoadData];
}

#pragma mark - 获取预付费详情
- (void)realoadData {
    if (self.listItem) {
        self.inviteId = self.listItem.inviteId;
        self.refId = self.listItem.refId;
        self.anchorId = self.listItem.anchorInfo.anchorId;
        // 更新头部UI
        [self.headView updateUI:self.listItem];
        // 请求预付费详情
        [self getScheduleDetail:NO];
    } else {
        if (self.anchorId.length > 0) {
            [self showLoading];
            [[LSUserInfoManager manager] getUserInfoWithRequest:self.anchorId
                                                  finishHandler:^(LSUserInfoModel *item) {
                                                      [self hideLoading];
                                                      if (item) {
                                                          self.tableView.hidden = NO;
                                                          self.listItem = [[LSScheduleInviteListItemObject alloc] init];
                                                          self.listItem.inviteId = self.inviteId;
                                                          LSScheduleAnchorInfoItemObject *infoItem = [[LSScheduleAnchorInfoItemObject alloc] init];
                                                          infoItem.anchorId = self.anchorId;
                                                          infoItem.nickName = item.nickName;
                                                          infoItem.age = item.age;
                                                          infoItem.country = item.country;
                                                          infoItem.avatarImg = item.photoUrl;
                                                          if (item.isOnline) {
                                                              infoItem.onlineStatus = ONLINE_STATUS_LIVE;
                                                          } else {
                                                              infoItem.onlineStatus = ONLINE_STATUS_OFFLINE;
                                                          }
                                                          self.listItem.anchorInfo = infoItem;
                                                          // 更新头部UI
                                                          [self.headView updateUI:self.listItem];
                                                          // 请求预付费详情
                                                          [self getScheduleDetail:NO];
                                                      } else {
                                                          self.failView.hidden = NO;
                                                          self.tableView.hidden = YES;
                                                      }
                                                  }];
        }
    }
}

- (void)getScheduleDetail:(BOOL)isUpdata {
    self.isUpdata = isUpdata;
    [self showLoading];
    [self.paidManager getScheduleDetail:self.inviteId];
}

#pragma mark - LSScheduleDetailsHeadViewDelegate
- (void)scheduleDetailsHeadViewDidHeadAndNameBtn {
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToAnchorDetail:self.anchorId];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

- (void)scheduleDetailsHeadViewDidCancelBtn {
    [self showNoReadTip:NSLocalizedStringFromSelf(@"CANCEL_TIP")
                  message:NSLocalizedStringFromSelf(@"CANCEL_MSG")
                 enterStr:NSLocalizedStringFromSelf(@"YES")
                cancelStr:NSLocalizedStringFromSelf(@"NO")
        completionHandler:^{
            [self.paidManager sendCancelScheduleInvite:self.inviteId];
        }];
}

- (void)scheduleDetailsHeadViewDidGfitBtn {
    NSURL *url = [[LiveUrlHandler shareInstance] createFlowerGightByAnchorId:self.anchorId];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

- (void)scheduleDetailsHeadViewDidMailBtn {
    [self sendMailAction];
}

- (void)scheduleDetailsHeadViewDidChatBtn {
    NSURL *url = [[LiveUrlHandler shareInstance] createLiveChatByanchorId:self.anchorId anchorName:self.listItem.anchorInfo.nickName];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

- (void)scheduleDetailsHeadViewDidDurationBtn {
    LSScheduleInviteDetailItemObject *item = self.array.firstObject;
    NSInteger selectRow = 0;
    for (int i = 0; i < [LSPrePaidManager manager].creditsArray.count; i++) {
        LSScheduleDurationItemObject *cItem = [LSPrePaidManager manager].creditsArray[i];
        if (cItem.duration == item.duration) {
            selectRow = i;
            break;
        }
    }

    self.pickerView = [[LSPrePaidPickerView alloc] init];
    self.pickerView.delegate = self;
    [self.view.window addSubview:self.pickerView];
    self.pickerView.selectTimeRow = selectRow;
    self.pickerView.items = [self.paidManager getCreditArray];
    [self.pickerView reloadData];
}

#pragma mark - LSScheduleDetailsBottomViewDelegate
- (void)didHowWorkAction {
    [self chatPrepaidViewDidHowWork];
}

- (void)chatPrepaidViewDidHowWork {
    self.perpaidInfoView = nil;
    [self.perpaidInfoView removeFromSuperview];
    self.perpaidInfoView = [[LSPrepaidInfoView alloc] init];
    [self.view addSubview:self.perpaidInfoView];
    [self.view bringSubviewToFront:self.perpaidInfoView];
    [self.perpaidInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma talbeViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 40;
    LSScheduleInviteDetailItemObject *item = self.array[indexPath.row];
    if (item.status == LSSCHEDULEINVITESTATUS_PENDING && item.sendFlag == LSSCHEDULESENDFLAGTYPE_ANCHOR) {
        height = [LSScheduleActionCell cellTotalHeight];
    } else if (item.status == LSSCHEDULEINVITESTATUS_CONFIRMED) {
        if (!item.isActive && item.startTime - [[NSDate date] timeIntervalSince1970] < 0) {
            height = [LSScheduleActionCell cellOneBtnHeight];
        }
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSScheduleInviteDetailItemObject *item = self.array[indexPath.row];
    LSScheduleActionCell *cell = [LSScheduleActionCell getUITableViewCell:tableView];
    cell.anchorName = self.listItem.anchorInfo.nickName;
    [cell updateScheduelDetailUI:item];
    cell.actionDelegate = self;
    return cell;
}

#pragma mark - UISCrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.otherOptionView removeFromSuperview];
    self.otherOptionView = nil;
}

#pragma mark - LSScheduleActionCellDelegate
- (void)lsScheduleActionCell:(LSScheduleActionCell *)cell didClickOther:(UIButton *)btn {
    // 获取中心点
    CGPoint buttonCenter = CGPointMake(btn.bounds.origin.x + btn.bounds.size.width / 2,
                                       btn.bounds.origin.y + btn.bounds.size.height / 2);
    // 获取在tableview上的相对位置
    CGPoint btnOrigin1 = [btn convertPoint:buttonCenter toView:self.tableView];

    // 在tableview上弹出对应弹层
    if (!self.otherOptionView) {
        LSOtherOptionView *otherOptionView = [LSOtherOptionView ohterOptionWithDelegate:self];
        [otherOptionView setDetailDeclineBtnTitle];
        CGRect frame = otherOptionView.frame;
        frame.origin.y = btnOrigin1.y - otherOptionView.frame.size.height;
        otherOptionView.frame = frame;
        [self.tableView addSubview:otherOptionView];
        CGPoint center = otherOptionView.center;
        center.x = self.view.center.x;
        otherOptionView.center = center;
        self.otherOptionView = otherOptionView;

        [self addSingleTap];
    }
}

- (void)lsScheduleActionCell:(LSScheduleActionCell *)cell didAcceptSchedule:(UIButton *)btn {
    self.isAccept = YES;
    LSScheduleInviteDetailItemObject *item = self.array.firstObject;
    [self showLoading];
    [self.paidManager sendAcceptScheduleInvite:item.inviteId duration:item.duration infoObj:nil];
}

- (void)lsScheduleActionCell:(LSScheduleActionCell *)cell didAcceptScheduleByReplyMail:(UIButton *)btn {
    self.isReplyMail = YES;
    [self showLoading];
    LSScheduleInviteDetailItemObject *item = self.array.firstObject;
    [self.paidManager sendAcceptScheduleInvite:item.inviteId duration:item.duration infoObj:nil];
}

#pragma mark - LSOtherOptionViewDelegate
- (void)lsOtherOptionView:(LSOtherOptionView *)ohterOptionView sendMail:(UIButton *)sendMailBtn {
    self.otherOptionView = nil;
    [self sendMailAction];
}

- (void)lsOtherOptionView:(LSOtherOptionView *)ohterOptionView decline:(UIButton *)declineBtn {
    self.otherOptionView = nil;
    [[LSChooseDialog dialog] showDialog:self.navigationController.view
        cancelBlock:^{

        }
        actionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.paidManager sendDeclinedScheduleInvite:self.inviteId];
            });
        }];
}

- (void)lsOtherOptionView:(LSOtherOptionView *)ohterOptionView declineAndSendMail:(UIButton *)declineAndSendMailbtn {
    self.otherOptionView = nil;
    // 拒绝并发邮件
    self.isReplyMail = YES;
    [[LSChooseDialog dialog] showDialog:self.navigationController.view
        cancelBlock:^{

        }
        actionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.paidManager sendDeclinedScheduleInvite:self.inviteId];
            });
        }];
}

- (void)sendMailAction {
    NSURL *url = [[LiveUrlHandler shareInstance] createSendmailByanchorId:self.anchorId anchorName:self.listItem.anchorInfo.nickName emfiId:self.refId];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

#pragma mark - 输入控件管理
- (void)addSingleTap {
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeOtherOptionView)];
        [self.tableView addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if (self.singleTap) {
        [self.tableView removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}

- (void)closeOtherOptionView {
    [self removeSingleTap];
    [self.otherOptionView removeFromSuperview];
    self.otherOptionView = nil;
}

#pragma mark - PrePaidPickerViewDelegate
- (void)removePrePaidPickerView {
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
}

- (void)prepaidPickerViewSelectedRow:(NSInteger)row {
    LSScheduleInviteDetailItemObject *detail = self.array.firstObject;
    [self removePrePaidPickerView];
    LSScheduleDurationItemObject *item = [[LSPrePaidManager manager].creditsArray objectAtIndex:row];
    if (detail.duration != item.duration) {
        detail.duration = item.duration;
        [self.headView updateSentTime:detail];
    }
}

#pragma mark - LSPurchaseCreditsViewDelegate
- (void)purchaseDidAction {
    [self.purchaseCreditView removeShowCreditView];
    LSAddCreditsViewController *addVC = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - LSAcceptDiaglogDelegate
- (void)lsAcceptDiaglogAccept:(LSAcceptDiaglog *)view {
    [self sendMailAction];
}

#pragma mark - LSDecelineDialogDelegate
- (void)lsDecelineDialogDecline:(LSDecelineDialog *)view {
    [self sendMailAction];
}

#pragma mark - LSPrePaidManagerDelegate
- (void)onRecvGetScheduleDetail:(HTTP_LCC_ERR_TYPE)errnum item:(LSScheduleInviteDetailItemObject *)item {
    [self hideLoading];
    [self.array removeAllObjects];
    if (errnum == HTTP_LCC_ERR_SUCCESS) {
        self.tableView.hidden = NO;
        [self setupTableHeadFootViewHeight:item];
        [self.headView updateSentTime:item];
        [self.bottomView setupPrompt:self.listItem.anchorInfo.nickName startTime:item.startTime isSummerTime:item.isSummerTime];
        [self.array addObject:item];
        [self.tableView reloadData];
        if (self.isUpdata) {
            if (self.isReplyMail) {
                [self sendMailAction];
            } else {
                // 接受和拒绝弹窗
                if (self.isAccept) {
                    LSAcceptDiaglog *acceptDialog = [LSAcceptDiaglog dialog];
                    acceptDialog.acceptDelegate = self;
                    [acceptDialog showAcceptDiaglog:self.navigationController.view];
                } else {
                    LSDecelineDialog *decelineDialog = [LSDecelineDialog dialog];
                    decelineDialog.decilineDelegate = self;
                    [decelineDialog showDecelineDialog:self.navigationController.view];
                }
            }
        }
    } else {
        self.failView.hidden = NO;
        self.tableView.hidden = YES;
    }
}

- (void)onRecvSendScheduleInviteCancel:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    [self hideLoading];
    if (errnum == HTTP_LCC_ERR_SUCCESS) {
        [self getScheduleDetail:NO];
    } else {
        [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
    }
}

- (void)onRecvSendAcceptSchedule:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg statusUpdateTime:(NSInteger)statusUpdateTime scheduleInviteId:(NSString *)inviteId duration:(int)duration roomInfoItem:(ImScheduleRoomInfoObject *)roomInfoItem {
    [self hideLoading];
    switch (errnum) {
        case HTTP_LCC_ERR_SUCCESS: {
            if (self.isReplyMail) {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"Accept_Schedule")];
            }
            [self getScheduleDetail:YES];
        } break;

        case HTTP_LCC_ERR_SCHEDULE_HAS_ACCEPTED: {
            [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            [self getScheduleDetail:YES];
        } break;

        case HTTP_LCC_ERR_SCHEDULE_HAS_DECLINED: {
            [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            [self getScheduleDetail:YES];
        } break;

        case HTTP_LCC_ERR_SCHEDULE_NO_READ_BEFORE: {
            self.isAccept = NO;
            self.isReplyMail = NO;
            WeakObject(self, weakSelf);
            [self showNoReadTip:errmsg
                          message:nil
                         enterStr:NSLocalizedStringFromSelf(@"Read")
                        cancelStr:NSLocalizedStringFromSelf(@"Later")
                completionHandler:^{
                    [weakSelf showNoReadTip:NSLocalizedStringFromSelf(@"Emf_Tip")
                                    message:nil
                                   enterStr:NSLocalizedStringFromSelf(@"Continue")
                                  cancelStr:NSLocalizedStringFromSelf(@"Later")
                          completionHandler:^{
                              NSURL *url = [[LiveUrlHandler shareInstance] createScheduleMailDetail:self.refId anchorName:self.listItem.anchorInfo.nickName type:LiveUrlScheduleMailDetailTypeInbox];
                              [[LiveModule module].serviceManager handleOpenURL:url];
                          }];
                }];
        } break;

        case HTTP_LCC_ERR_SCHEDULE_NO_CREDIT: {
            self.isAccept = NO;
            self.isReplyMail = NO;
            [self showPurchaseCreditView];
        } break;

        default: {
            self.isAccept = NO;
            self.isReplyMail = NO;
            [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
        } break;
    }
}

- (void)onRecvSendDeclinedSchedule:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg statusUpdateTime:(NSInteger)statusUpdateTime {
    [self hideLoading];
    switch (errnum) {
        case HTTP_LCC_ERR_SUCCESS: {
            if (self.isReplyMail) {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"DECLINED_SUCCESS")];
                LSTimer *timer = [[LSTimer alloc] init];
                WeakObject(self, weakSelf);
                [timer startTimer:dispatch_get_main_queue()
                     timeInterval:1.0 * NSEC_PER_SEC
                          starNow:NO
                           action:^{
                               [weakSelf getScheduleDetail:YES];
                               [timer stopTimer];
                           }];
            } else {
                [self getScheduleDetail:YES];
            }
        } break;

        case HTTP_LCC_ERR_SCHEDULE_HAS_ACCEPTED: {
            [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            [self getScheduleDetail:YES];
        } break;

        case HTTP_LCC_ERR_SCHEDULE_HAS_DECLINED: {
            [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            [self getScheduleDetail:YES];
        } break;

        case HTTP_LCC_ERR_SCHEDULE_NO_READ_BEFORE: {
            self.isAccept = NO;
            self.isReplyMail = NO;
            WeakObject(self, weakSelf);
            [self showNoReadTip:errmsg
                          message:nil
                         enterStr:NSLocalizedStringFromSelf(@"Read")
                        cancelStr:NSLocalizedStringFromSelf(@"Later")
                completionHandler:^{
                    [weakSelf showNoReadTip:NSLocalizedStringFromSelf(@"Emf_Tip")
                                    message:nil
                                   enterStr:NSLocalizedStringFromSelf(@"Continue")
                                  cancelStr:NSLocalizedStringFromSelf(@"Later")
                          completionHandler:^{
                              NSURL *url = [[LiveUrlHandler shareInstance] createScheduleMailDetail:self.refId anchorName:self.listItem.anchorInfo.nickName type:LiveUrlScheduleMailDetailTypeInbox];
                              [[LiveModule module].serviceManager handleOpenURL:url];
                          }];
                }];
        } break;

        case HTTP_LCC_ERR_SCHEDULE_NO_CREDIT: {
            self.isAccept = NO;
            self.isReplyMail = NO;
            [self showPurchaseCreditView];
        } break;

        default: {
            self.isAccept = NO;
            self.isReplyMail = NO;
            [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
        } break;
    }
}

- (void)showNoReadTip:(NSString *)title message:(NSString *)message enterStr:(NSString *)enterStr cancelStr:(NSString *)cancelStr completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelStr
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action){

                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:enterStr
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
