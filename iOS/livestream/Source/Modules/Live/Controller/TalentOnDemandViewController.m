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
#import "IMManager.h"
#import "Dialog.h"
#import "DialogOK.h"
#import "TalentTipView.h"
@interface TalentOnDemandViewController ()<UITableViewDelegate,UITableViewDataSource,TalentOnDemandManagerDelegate,IMLiveRoomManagerDelegate>

@property (nonatomic, strong) TalentOnDemandManager * talentOnDemandManager;
@property (nonatomic, strong) IMManager * iMManager;
@property (nonatomic, strong) NSArray * data;
@property (nonatomic, copy) NSString * checkedTalentId;
@property (nonatomic, copy) NSString * checkedTalentName;
@property (nonatomic, assign) BOOL isSendTalent;//是否发送过才艺点播
@property (nonatomic, copy) NSString * roomId;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;
@property (nonatomic, strong) Dialog * dialog;
@property (nonatomic, strong) TalentTipView * tipView;

@end

@implementation TalentOnDemandViewController

- (void)dealloc
{
    [self.iMManager.client removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.data = [NSMutableArray array];
    
    self.iMManager = [IMManager manager];
    [self.iMManager.client addDelegate:self];
    
    self.talentOnDemandManager = [TalentOnDemandManager manager];
    self.talentOnDemandManager.delegate = self;
    
    self.reloadBtn.layer.cornerRadius = 5;
    self.reloadBtn.layer.masksToBounds = YES;
}

#pragma mark 请求才艺点播列表
- (void)getTalentList:(NSString *)roomId
{
    self.roomId = roomId;
  [self.talentOnDemandManager getTalentList:self.roomId];
}

#pragma mark 才艺点播列表数据回调
- (void)onGetTalentListSuccess:(BOOL)success Data:(NSArray<GetTalentItemObject *> *)array errMsg:(NSString *)errMsg errNum:(NSInteger)errnum
{
    if (success) {
        self.tableView.hidden = NO;
        self.failedView.hidden = YES;
        self.data = array;
        [self.tableView reloadData];
    }
    else
    {
        self.tableView.hidden = YES;
        self.failedView.hidden = NO;
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TalentOnDemandCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *result = nil;
    TalentOnDemandCell * cell = [TalentOnDemandCell getUITableViewCell:tableView];
    result = cell;
    
    GetTalentItemObject * obj = [self.data objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = obj.name;
    cell.subLabel.text = [NSString stringWithFormat:@"%0.1f credits",obj.credit];
    
    cell.requestBtn.tag = indexPath.row + 88;
    [cell.requestBtn addTarget:self action:@selector(requestBtnDid:) forControlEvents:UIControlEventTouchUpInside];
    
    return result;
}

#pragma mark 列表点击事件
- (void)requestBtnDid:(UIButton *)button
{
    if (self.isSendTalent) {
        [self showDialog:@"Sorry. Can not send duplicated performance requests in a row"];
    }
    else
    {
        //信用点是否足够
        BOOL isCredit = NO;
        if (isCredit) {
            NSString * message = @"Oops! Your don't have enough credits to request this talent.";

            DialogOK * dialogOK = [DialogOK dialog];
            dialogOK.tipsLabel.text = message;
            [dialogOK showDialog:self.view actionBlock:^{
                 NSLog(@"跳转到充值界面");
            }];
        }
        else
        {
            GetTalentItemObject * obj = [self.data objectAtIndex:button.tag - 88];
            self.checkedTalentId = obj.talentId;
            self.checkedTalentName = obj.name;
            self.tipView = [[TalentTipView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 294/2, SCREEN_HEIGHT/2 - 170/2, 294, 170)];
            [self.tipView setTalentName:obj.name];
            [self.tipView setPriceNum:[NSString stringWithFormat:@"%0.2f credits",obj.credit]];
            [self.view.window addSubview:self.tipView];
            self.view.userInteractionEnabled = NO;
            [self.tipView.closeBtn addTarget:self action:@selector(tipViewCloseBtn) forControlEvents:UIControlEventTouchUpInside];
            [self.tipView.cancelBtn addTarget:self action:@selector(tipViewCloseBtn) forControlEvents:UIControlEventTouchUpInside];
            [self.tipView.requstBtn addTarget:self action:@selector(tipViewrequstBtn) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

#pragma mark 显示Dialog
- (void)showDialog:(NSString *)message
{
    self.dialog = [Dialog dialog];
    self.dialog.tipsLabel.text = message;
    [self.dialog showDialog:self.view actionBlock:nil];
    [self performSelector:@selector(hideDialog) withObject:self afterDelay:2];
}
#pragma mark 隐藏Dialog
- (void)hideDialog
{
    [UIView animateWithDuration:1 animations:^{
        self.dialog.alpha = 0;
    }completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        [self.dialog removeFromSuperview];
    }];
}
#pragma mark TipView点击事件
- (void)tipViewCloseBtn
{
    self.view.userInteractionEnabled = YES;
    [self.tipView removeFromSuperview];
    self.tipView = nil;
}

- (void)tipViewrequstBtn
{
    [self tipViewCloseBtn];
    [self.iMManager sendTalent:self.roomId talentId:self.checkedTalentId];
    self.isSendTalent = YES;
}

#pragma mark 才艺点播回调
- (void)onSendTalent:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg talentInviteId:(NSString *)talentInviteId {
    
     dispatch_async(dispatch_get_main_queue(), ^{
         NSLog(@"TalentOnDemandViewController::onSendTalent( [发送直播间才艺点播邀请, %@], errType : %d, errmsg : %@ talentInviteId:%@)", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, talentInviteId);
         self.isSendTalent = NO;
         
         if (err != LCC_ERR_SUCCESS) {
             [self showDialog:@"Failed to send talent request.Please try again later."];
         }
         else
         {
             //发送成功
             NSString * message = [NSString stringWithFormat:@"Your talent request \"%@\" has been sent successfully. Please wait for response.",self.checkedTalentName];
             NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:message];
             [self sendTalentMessage:attString];
         }
     });
}

- (void)onRecvSendTalentNotice:(ImTalentReplyObject *)item {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"TalentOnDemandViewController::onRecvSendTalentNotice( [接收直播间才艺点播回复通知] )");
            self.isSendTalent = NO;
            
            NSString * message = @"No response from the broadcaster";
            //接受
            if (item.status == TALENTSTATUS_AGREE) {
                message = [NSString stringWithFormat:@"%@ has accepted your request \"%@\"",self.liveRoom.userName,self.checkedTalentName];
            }
            //拒绝
            else if (item.status == TALENTSTATUS_REJECT)
            {
                 message = [NSString stringWithFormat:@"%@ has declined your request  \"%@\"",self.liveRoom.userName,self.checkedTalentName];
            }
            else//其他
            {
                
            }
            
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:message];
            [self sendTalentMessage:attString];
        });
}

- (void)sendTalentMessage:(NSAttributedString *)message
{
    if ([self.delegate respondsToSelector:@selector(onSendtalentOnDemandMessage:)]) {
        [self.delegate onSendtalentOnDemandMessage:message];
    }
}

#pragma mark 直播重连回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString*)errmsg item:(ImLoginReturnObject*)item
{
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
