//
//  TalentOnDemandViewController.m
//  livestream
//
//  Created by Calvin on 17/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "TalentOnDemandViewController.h"
#import "TalentOnDemandManager.h"
#import "TalentOnDemandCell.h"
#import "LSImManager.h"
#import "DialogTip.h"
#import "DialogOK.h"
#import "TalentTipView.h"
#import "LiveRoomCreditRebateManager.h"
#import "LiveModule.h"
@interface TalentOnDemandViewController () <UITableViewDelegate, UITableViewDataSource, TalentOnDemandManagerDelegate, IMLiveRoomManagerDelegate>

#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;
@property (nonatomic, strong) TalentOnDemandManager *talentOnDemandManager;
@property (nonatomic, strong) LSImManager *iMManager;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, copy) NSString *checkedTalentId;
@property (nonatomic, copy) NSString *checkedTalentName;
@property (nonatomic, assign) BOOL isSendTalent; //是否发送过才艺点播
@property (nonatomic, copy) NSString *roomId;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconTopOffset;

@property (strong) TalentTipView *tipView;
@property (strong) DialogOK *dialogOK;
@property (strong) DialogTip *dialogTipView;

@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, assign) NSInteger time;
@end

@implementation TalentOnDemandViewController
- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"TalentOnDemandViewController::initCustomParam()");

    self.iMManager = [LSImManager manager];
    [self.iMManager.client addDelegate:self];

    self.talentOnDemandManager = [TalentOnDemandManager manager];
    self.talentOnDemandManager.delegate = self;
    
    // 初始化余额及返点信息管理器
    self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
}

- (void)dealloc {
    NSLog(@"TalentOnDemandViewController::dealloc()");

    if (self.dialogOK) {
        [self.dialogOK removeFromSuperview];
    }
    if (self.dialogTipView) {
        [self.dialogTipView removeFromSuperview];
    }
    if (self.tipView) {
        [self.tipView removeFromSuperview];
    }

    [self.iMManager.client removeDelegate:self];
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];

    self.data = [NSMutableArray array];

    self.reloadBtn.layer.cornerRadius = 6;
    self.reloadBtn.layer.masksToBounds = YES;

    self.dialogTipView = [DialogTip dialogTip];
}

- (void)showFalieView {
    self.tableView.hidden = YES;
    self.iconTopOffset.constant = 20;
    self.failedView.hidden = NO;
    self.reloadBtn.hidden = NO;
    self.tipLabel.text = NSLocalizedStringFromSelf(@"2dn-Se-Mia.text");
}

- (void)showNoListView {
    self.tableView.hidden = YES;
    self.iconTopOffset.constant = 40;
    self.failedView.hidden = NO;
    self.reloadBtn.hidden = YES;
    self.tipLabel.text = NSLocalizedStringFromSelf(@"NO_TALENT_LIST");
}

#pragma mark 请求才艺点播列表
- (void)getTalentList:(NSString *)roomId {
    self.roomId = roomId;
    [self.talentOnDemandManager getTalentList:self.roomId];
}

#pragma mark 才艺点播列表数据回调
- (void)onGetTalentListSuccess:(BOOL)success Data:(NSArray<GetTalentItemObject *> *)array errMsg:(NSString *)errMsg errNum:(HTTP_LCC_ERR_TYPE)errnum {
    if (success) {
        if (array.count) {
            self.tableView.hidden = NO;
            self.failedView.hidden = YES;
            self.data = array;
            [self.tableView reloadData];
        } else {
            [self showNoListView];
        }

    } else {
        [self showFalieView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 隐藏界面事件
- (IBAction)closeBtnDid:(UIButton *)sender {

    if ([self.delegate respondsToSelector:@selector(talentOnDemandVCCancelButtonDid)]) {
        [self.delegate talentOnDemandVCCancelButtonDid];
    }
}

#pragma mark 重新请求按钮事件
- (IBAction)reloadBtnDid:(UIButton *)sender {

    self.tableView.hidden = NO;
    self.failedView.hidden = YES;
    [self.talentOnDemandManager getTalentList:self.roomId];
}

#pragma mark tableView Delegate / DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TalentOnDemandCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    TalentOnDemandCell *cell = [TalentOnDemandCell getUITableViewCell:tableView];
    result = cell;

    GetTalentItemObject *obj = [self.data objectAtIndex:indexPath.row];

    cell.titleLabel.text = obj.name;
    cell.subLabel.text = [NSString stringWithFormat:@"%0.1f %@", obj.credit, NSLocalizedString(@"CREDITS", @"CREDITS")];

    cell.requestBtn.tag = indexPath.row + 88;
    [cell.requestBtn addTarget:self action:@selector(requestBtnDid:) forControlEvents:UIControlEventTouchUpInside];

    return result;
}

#pragma mark 列表点击事件
- (void)requestBtnDid:(UIButton *)button {
    if (self.isSendTalent) {
        [self showDialog:NSLocalizedStringFromSelf(@"CANT_REPEAT_TIP")];
    } else {
        //信用点是否足够
        GetTalentItemObject *obj = [self.data objectAtIndex:button.tag - 88];
        if (self.creditRebateManager.mCredit < obj.credit) {

            if (self.dialogOK) {
                [self.dialogOK removeFromSuperview];
            }
            WeakObject(self, weakSelf);
            self.dialogOK = [DialogOK dialog];
            self.dialogOK.tipsLabel.text = NSLocalizedStringFromSelf(@"TALENT_ERR_ADD_CREDIT");
            [self.dialogOK showDialog:self.liveRoom.superView
                          actionBlock:^{
                              NSLog(@"跳转到充值界面");
                              [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
                              if ([weakSelf.delegate respondsToSelector:@selector(pushToRechargeCredit)]) {
                                  [weakSelf.delegate pushToRechargeCredit];
                              }
                          }];

        } else {
            self.checkedTalentId = obj.talentId;
            self.checkedTalentName = obj.name;
            self.tipView = [[TalentTipView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 294 / 2, SCREEN_HEIGHT / 2 - 170 / 2, 294, 170)];
            [self.tipView setTalentName:obj.name];
            [self.tipView setPriceNum:[NSString stringWithFormat:@"%0.2f %@", obj.credit, NSLocalizedString(@"CREDITS", @"CREDITS")]];
            [self.view.window addSubview:self.tipView];
            self.view.userInteractionEnabled = NO;
            [self.tipView.closeBtn addTarget:self action:@selector(tipViewCloseBtn) forControlEvents:UIControlEventTouchUpInside];
            [self.tipView.cancelBtn addTarget:self action:@selector(tipViewCloseBtn) forControlEvents:UIControlEventTouchUpInside];
            [self.tipView.requstBtn addTarget:self action:@selector(tipViewrequstBtn) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

#pragma mark 显示DialogTip 3秒隐藏
- (void)showDialog:(NSString *)message {
    [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:message];
}

#pragma mark TipView点击事件
- (void)tipViewCloseBtn {
    self.view.userInteractionEnabled = YES;
    [self.tipView removeFromSuperview];
    self.tipView = nil;
}

- (void)tipViewrequstBtn {
    [self tipViewCloseBtn];
    BOOL bFlag = [self.iMManager sendTalent:self.roomId talentId:self.checkedTalentId];
    if (bFlag) {
        self.isSendTalent = YES;
    } else {
        self.isSendTalent = NO;
        [self showDialog:NSLocalizedStringFromSelf(@"SEND_TALENT_FAILED")];
    }
}

- (void)countDown
{
    self.time++;
    if (self.time > 60) {
        self.isSendTalent = NO;
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark 才艺点播回调
- (void)onSendTalent:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg talentInviteId:(NSString *)talentInviteId {

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"TalentOnDemandViewController::onSendTalent( [发送直播间才艺点播邀请, %@], errType : %d, errmsg : %@ talentInviteId:%@)", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, talentInviteId);

        if (err != LCC_ERR_SUCCESS) {
            self.isSendTalent = NO;
            //进入房间失败 or 房间已经关闭
            if (err == LCC_ERR_NOT_FOUND_ROOM || err == LCC_ERR_ROOM_CLOSE) {
                [self showDialog:NSLocalizedStringFromSelf(@"SEND_TALENT_ERROR")];
            }
            //信用点不足
            else if (err == LCC_ERR_NO_CREDIT) {
                if (self.dialogOK) {
                    [self.dialogOK removeFromSuperview];
                }
                WeakObject(self, weakSelf);
                self.dialogOK = [DialogOK dialog];
                self.dialogOK.tipsLabel.text = NSLocalizedStringFromSelf(@"TALENT_ERR_ADD_CREDIT");
                [self.dialogOK showDialog:self.liveRoom.superView
                              actionBlock:^{
                                  NSLog(@"跳转到充值界面");
                                  [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
                                  if ([weakSelf.delegate respondsToSelector:@selector(pushToRechargeCredit)]) {
                                      [weakSelf.delegate pushToRechargeCredit];
                                  }
                              }];
            }
            //重复发送
            else if (err == LCC_ERR_REPEAT_INVITEING_TALENT) {
                [self showDialog:NSLocalizedStringFromSelf(@"CANT_REPEAT_TIP")];
            } else {
                [self showDialog:NSLocalizedStringFromSelf(@"SEND_TALENT_FAILED")];
            }

        } else {
            //发送成功
            NSString *message = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SEND_TALENT_SUCCESS"), self.checkedTalentName];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:message];
            [attString addAttributes:@{
                NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
                NSForegroundColorAttributeName : [UIColor whiteColor]
            }
                               range:NSMakeRange(0, attString.length)];
            [self sendTalentMessage:attString];

            [self.timer invalidate];
            self.timer = nil;
            self.time = 0;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
            
            // 发送成功收起列表
            if ([self.delegate respondsToSelector:@selector(talentOnDemandVCCancelButtonDid)]) {
                [self.delegate talentOnDemandVCCancelButtonDid];
            }
        }
    });
}

- (void)onRecvSendTalentNotice:(ImTalentReplyObject *)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"TalentOnDemandViewController::onRecvSendTalentNotice( [接收直播间才艺点播回复通知] )");
        self.isSendTalent = NO;
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        
        NSString *message = NSLocalizedStringFromSelf(@"NO_RESPONE_FROM");
        //接受
        if (item.status == TALENTSTATUS_AGREE) {
            message = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ACCEPT_YOUR_REQUEST"), self.liveRoom.userName, self.checkedTalentName];
        }
        //拒绝
        else if (item.status == TALENTSTATUS_REJECT) {
            message = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DECLINED_YOUR_REQUEST"), self.liveRoom.userName, self.checkedTalentName];
        } else //其他
        {
        }

        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:message];
        [attString addAttributes:@{
            NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
            NSForegroundColorAttributeName : [UIColor whiteColor]
        }
                           range:NSMakeRange(0, attString.length)];
        [self sendTalentMessage:attString];
    });
}

- (void)sendTalentMessage:(NSAttributedString *)message {
    if ([self.delegate respondsToSelector:@selector(onSendtalentOnDemandMessage:)]) {
        [self.delegate onSendtalentOnDemandMessage:message];
    }
}

#pragma mark 直播重连回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errType == LCC_ERR_SUCCESS) {
            if (self.checkedTalentId.length > 0) {
                //获取才艺点播状态
                [self.talentOnDemandManager getTalentStatusRoomId:self.roomId talentId:self.checkedTalentId];
            }
        }
    });
}

#pragma mark 获取才艺点播状态
- (void)onGetTalentStatus:(GetTalentStatusItemObject *)statusItemObject
{
    if (statusItemObject.status != HTTPTALENTSTATUS_UNREPLY) {
        self.isSendTalent = NO;
    }
}
@end
