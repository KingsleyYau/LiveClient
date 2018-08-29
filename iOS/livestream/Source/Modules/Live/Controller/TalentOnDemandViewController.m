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
#import "LiveRoomCreditRebateManager.h"
#import "LiveModule.h"
#import "PushAnimator.h"
#import "TalentMsgInfoManager.h"
#import "LSGiftManager.h"
#import "TalentDetailViewController.h"
@interface TalentOnDemandViewController () <UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource, TalentOnDemandManagerDelegate, IMLiveRoomManagerDelegate,TalentDetailVCDelegate,LSGiftManagerDelegate>

#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;
@property (nonatomic, strong) TalentOnDemandManager *talentOnDemandManager;
@property (nonatomic, strong) LSImManager *iMManager;
@property (nonatomic, strong) NSArray *data;

@property (nonatomic, copy) NSString *checkedTalentId;
@property (nonatomic, copy) NSString *checkedTalentName;
@property (nonatomic, copy) NSString *talentInviteId;

@property (nonatomic, copy) NSString *roomId;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIButton *talentShowBtn;
@property (weak, nonatomic) IBOutlet UILabel *talentInfoLabel;

@property (strong) DialogOK *dialogOK;
@property (strong) DialogTip *dialogTipView;

@property (nonatomic, assign) NSInteger oldRow;
@property (nonatomic, assign) BOOL isSelected;
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
    
    [LSGiftManager manager].delegate = self;
}

- (void)dealloc {
    NSLog(@"TalentOnDemandViewController::dealloc()");
    
    if (self.dialogOK) {
        [self.dialogOK removeFromSuperview];
    }
    if (self.dialogTipView) {
        [self.dialogTipView removeFromSuperview];
    }
    [self.iMManager.client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.data = [NSMutableArray array];
    
    self.dialogTipView = [DialogTip dialogTip];
    
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    lineView.backgroundColor = COLOR_WITH_16BAND_RGB(0x535353);
    lineView.alpha = 0.6;
    [self.view addSubview:lineView];
    
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationController.delegate = self;
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
    [self.view addSubview:effectView];
    [self.view sendSubviewToBack:effectView];
    
    //1.调整(iOS7以上)表格分隔线边距
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    //2.调整(iOS8以上)view边距(或者在cell中设置preservesSuperviewLayoutMargins,二者等效)
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName : [UIFont boldSystemFontOfSize:15],
       NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    UIBarButtonItem * closeButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"TalentClose_btn_white"] style:UIBarButtonItemStylePlain target:self action:@selector(closeBtnDid)];
    self.navigationItem.rightBarButtonItem = closeButtonItem;
    
    self.title = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Talent_Title"),self.liveRoom.userName];
    
    self.talentInfoLabel.attributedText = [TalentMsgInfoManager showTitleString:self.talentInfoLabel.text Andunderline:NSLocalizedStringFromSelf(@"Details")];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)showNoListView:(NSString *)errmsg {
    self.talentShowBtn.hidden = YES;
    self.talentInfoLabel.hidden = YES;
    self.tableView.hidden = YES;
    self.failedView.hidden = NO;
    self.tipLabel.text = errmsg;
}

- (void)reloadData {
    self.isSelected = NO;
    self.oldRow = 0;
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
}

#pragma mark 请求才艺点播列表
- (void)getTalentList:(NSString *)roomId {
    [self reloadData];
    if (self.data.count == 0) {
        self.roomId = roomId;
        [self.talentOnDemandManager getTalentList:self.roomId];
    }
}

#pragma mark 才艺点播列表数据回调
- (void)onGetTalentListSuccess:(BOOL)success Data:(NSArray<GetTalentItemObject *> *)array errMsg:(NSString *)errMsg errNum:(HTTP_LCC_ERR_TYPE)errnum {
    if (success) {
        if (array.count) {
            self.tableView.hidden = NO;
            self.failedView.hidden = YES;
            self.talentShowBtn.hidden = NO;
            self.talentInfoLabel.hidden = NO;
            self.data = array;
            [self.tableView reloadData];
        } else {
            [self showNoListView:NSLocalizedStringFromSelf(@"Fail_To_load")];
        }
    } else {
        if (errnum == HTTP_LCC_ERR_CONNECTFAIL) {
            [self showNoListView:NSLocalizedStringFromSelf(@"Talent_NoNetwork")];
        }
        else
        {
            [self showNoListView:errMsg];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 隐藏界面事件
- (void)closeBtnDid {
    if ([self.delegate respondsToSelector:@selector(talentOnDemandVCCancelButtonDid)]) {
        [self.delegate talentOnDemandVCCancelButtonDid];
    }
}

- (IBAction)detailTap:(UITapGestureRecognizer *)sender {
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromSelf(@"Note") message:NSLocalizedStringFromSelf(@"Talent_Detail_Msg") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark 重新请求按钮事件
- (IBAction)reloadBtnDid:(id)sender {
    
    self.tableView.hidden = NO;
    self.failedView.hidden = YES;
    self.talentShowBtn.hidden = NO;
    self.talentInfoLabel.hidden = NO;
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
    NSString * str = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Talent_SubTitle"),obj.giftName];
    LSGiftManagerItem * gift = [[LSGiftManager manager] getGiftItemWithId:obj.giftId];
    cell.subLabel.attributedText = [TalentMsgInfoManager showImageString:obj.giftName AndTitle:str andTitleFont:cell.titleLabel.font inMaxWidth:SCREEN_WIDTH - 100 giftImage:gift.infoItem.smallImgUrl isShowGift:obj.giftId.length > 0?YES:NO];
    
    cell.detialsBtn.tag = indexPath.row + 88;
    [cell.detialsBtn addTarget:self action:@selector(talentOnDemandCellBtnDid:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.isSelected && indexPath.row == self.oldRow) {
        [cell.detialsBtn setBackgroundImage:[UIImage imageNamed:@"Talent_Detials_Btn_Cell_Selected"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.detialsBtn setBackgroundImage:[UIImage imageNamed:@"Talent_Detials_Btn"] forState:UIControlStateNormal];
    }
    
    //3.调整(iOS8以上)view边距
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.isSelected = YES;
    TalentOnDemandCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.oldRow inSection:0]];
    [oldCell.detialsBtn setBackgroundImage:[UIImage imageNamed:@"Talent_Detials_Btn"] forState:UIControlStateNormal];
    self.oldRow = indexPath.row;
    TalentOnDemandCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.detialsBtn setBackgroundImage:[UIImage imageNamed:@"Talent_Detials_Btn_Cell_Selected"] forState:UIControlStateNormal];
}

#pragma mark 列表点击事件
- (void)talentOnDemandCellBtnDid:(UIButton *)btn {
    GetTalentItemObject *item = [self.data objectAtIndex:btn.tag - 88];
    TalentDetailViewController * vc = [[TalentDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.item = item;
    vc.liveRoom = self.liveRoom;
    vc.delegates = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)talentShowRequest:(UIButton *)sender {
    
    if (!self.isSelected) {
        [self showDialog:NSLocalizedStringFromSelf(@"CANT_REPEAT_TIP")];
    }
    else
    {
        //信用点是否足够
        GetTalentItemObject *obj = [self.data objectAtIndex:self.oldRow];
        [self sendTalentShowRequest:obj];
    }
}

- (void)sendTalentShowRequest:(GetTalentItemObject *)item {
    
    if (self.creditRebateManager.mCredit < item.credit) {
        
        if (self.dialogOK) {
            [self.dialogOK removeFromSuperview];
            self.dialogOK = nil;
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
        
        BOOL bFlag = [self.iMManager sendTalent:self.roomId talentId:item.talentId];
        if (!bFlag) {
            [self showDialog:NSLocalizedStringFromSelf(@"SEND_TALENT_FAILED")];
        }
        [self closeBtnDid];
    }
}

#pragma mark 显示DialogTip 3秒隐藏
- (void)showDialog:(NSString *)message {
    [self.dialogTipView showDialogTip:self.liveRoom.superView tipText:message];
}

#pragma mark 才艺点播回调
- (void)onSendTalent:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg talentInviteId:(NSString *)talentInviteId talentId:(NSString * _Nonnull)talentId {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"TalentOnDemandViewController::onSendTalent( [发送直播间才艺点播邀请, %@], errType : %d, errmsg : %@ talentInviteId:%@ talentId:%@)", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, talentInviteId, talentId);
        if (err != LCC_ERR_SUCCESS) {
            //信用点不足
            if (err == LCC_ERR_NO_CREDIT) {
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
            else  {
                [self showDialog:errMsg];
            }
            
        } else {
            
            self.talentInviteId = talentInviteId;
            for (GetTalentItemObject *item in self.data) {
                if ([item.talentId isEqualToString:talentId]) {
                    self.checkedTalentName = item.name;
                    self.checkedTalentId = item.talentId;
                    
                    //发送成功
                    NSString *message = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SEND_TALENT_SUCCESS"), self.checkedTalentName];
                    [self sendTalentMessage:message];
                    break;
                }
            }
        }
    });
}

- (void)onRecvSendTalentNotice:(ImTalentReplyObject *)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"TalentOnDemandViewController::onRecvSendTalentNotice( [接收直播间才艺点播回复通知] )");
        
        NSString *message = @"";
        //接受
        if (item.status == TALENTSTATUS_AGREE) {
            message = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ACCEPT_YOUR_REQUEST"), self.liveRoom.userName, item.name];
            [self sendTalentMessage:message];
        }
        //拒绝
        else if (item.status == TALENTSTATUS_REJECT) {
            message = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DECLINED_YOUR_REQUEST"), self.liveRoom.userName, item.name];
            [self sendTalentMessage:message];
        } else //其他
        {
            
        }
    });
}


- (void)sendTalentMessage:(NSString *)message {
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:message];
    [attString addAttributes:@{
                               NSFontAttributeName : [UIFont boldSystemFontOfSize:16],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               }
                       range:NSMakeRange(0, attString.length)];
    
    if ([self.delegate respondsToSelector:@selector(onSendtalentOnDemandMessage:)]) {
        [self.delegate onSendtalentOnDemandMessage:attString];
    }
}

- (void)onRecvSendChatNotice:(NSString *_Nonnull)roomId level:(int)level fromId:(NSString *_Nonnull)fromId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg honorUrl:(NSString *_Nonnull)honorUrl {
    self.talentInviteId = @"";
    self.checkedTalentName = @"";
}

#pragma mark 直播重连回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errType == LCC_ERR_SUCCESS) {
            if (self.talentInviteId.length > 0) {
                //获取才艺点播状态
                [self.talentOnDemandManager getTalentStatusRoomId:self.roomId talentId:self.talentInviteId];
            }
        }
    });
}

#pragma mark 获取才艺点播状态
- (void)onGetTalentStatus:(GetTalentStatusItemObject *)statusItemObject
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.talentInviteId.length > 0) {
            if (statusItemObject.status == HTTPTALENTSTATUS_ACCEPT) {
                //同意
                NSString *message = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"ACCEPT_YOUR_REQUEST"), self.liveRoom.userName,statusItemObject.name];
                [self sendTalentMessage:message];
            }
            else if (statusItemObject.status == HTTPTALENTSTATUS_REJECT)
            {
                //拒绝
                NSString *message = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"DECLINED_YOUR_REQUEST"), self.liveRoom.userName, statusItemObject.name];
                [self sendTalentMessage:message];
            }
            else
            {
                self.talentInviteId = nil;
            }
        }
    });
}

#pragma mark - push动画
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush)
        return [[PushAnimator alloc] init];
    if (operation == UINavigationControllerOperationPop)
        return [[PopAnimator alloc] init];
    return nil;
}

- (void)giftDownloadManagerStateChange:(LSGiftManagerItem *)LSGiftManagerItem index:(NSInteger)index
{
    [self.tableView reloadData];
}
#pragma makr 详情界面点击
- (void)talentDetailVCButtonDid:(GetTalentItemObject *)item
{
    [self sendTalentShowRequest:item];
}
@end
