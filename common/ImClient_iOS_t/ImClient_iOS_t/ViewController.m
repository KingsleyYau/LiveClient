//
//  ViewController.m
//  ImClient_iOS_t
//
//  Created by  Samson on 27/05/2017.
//  Copyright © 2017 Samson. All rights reserved.
//

#import "ViewController.h"
#import "ImClientOC.h"
#include <sys/time.h>

@interface ViewController () <IMLiveRoomManagerDelegate>
@property (nonatomic, strong) ImClientOC* client;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* roomid;

- (IBAction)initAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)logoutAction:(id)sender;
- (IBAction)vRoomIn:(id)sender;
- (IBAction)vRoomOut:(id)sender;
- (IBAction)sendRoomMsg:(id)sender;

// for test
@property (nonatomic, strong) NSThread* loginProcThread;
- (void)loginProc;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.token = @"CMTS09975#uid#PWBU3AME_1517899662271";
    self.userId = @"17";
    self.roomid = @"208";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createAction:(id)sender {
    if (nil == self.client) {
        self.client = [[ImClientOC alloc] init];
        [self.client addDelegate:self];

    }
}

- (IBAction)releaseAction:(id)sender {
    if (nil != self.client) {
        [self.client removeDelegate:self];
        self.client = nil;
    }
}

- (IBAction)initAction:(id)sender {
    if (nil != self.client) {
        NSMutableArray<NSString*>* urls = [NSMutableArray array];
        //[urls addObject:@"ws://192.168.88.17:8816"];
        [urls addObject:@"ws://172.25.32.17:8816"];
        [self.client initClient:urls];
    }
}

- (IBAction)loginAction:(id)sender {
    if (nil != self.client) {
//        [self.client login:self.token pageName:PAGENAMETYPE_MOVEPAGE];
        
        if (nil == self.loginProcThread) {
            self.loginProcThread = [[NSThread alloc] initWithTarget:self selector:@selector(loginProc) object:nil];
            [self.loginProcThread start];
        }
    }
}

- (void)loginProc {
    int iTimes = 0;
    const int MAX_TIMES = 100;
    int waitTime = 0;
    _STRUCT_TIMEVAL time;
    gettimeofday(&time, NULL);
    srand((unsigned int)(time.tv_sec + time.tv_usec));
    
    _STRUCT_TIMEVAL begin;
    gettimeofday(&begin, NULL);
    
    for (iTimes = 0; iTimes < MAX_TIMES; iTimes++) {
        _STRUCT_TIMEVAL theTimeBegin;
        gettimeofday(&theTimeBegin, NULL);

        NSLog(@"ViewController::loginProc() login ----------------");
        [self.client login:self.token pageName:PAGENAMETYPE_HOMEPAGE];
        
//        waitTime = rand()%1000;
        waitTime = 300;
        usleep(waitTime * 1000);
        NSLog(@"ViewController::loginProc() logout");
        [self.client logout];
        
//        waitTime = rand()%1000;
        waitTime = 300;
        usleep(waitTime * 1000);
        
        _STRUCT_TIMEVAL theTimeEnd;
        gettimeofday(&theTimeEnd, NULL);
        NSLog(@"ViewController::loginProc() login test end, time:%ld.%d", theTimeEnd.tv_sec - theTimeBegin.tv_sec, theTimeEnd.tv_usec >= theTimeBegin.tv_usec ? theTimeEnd.tv_usec - theTimeBegin.tv_usec : 1000*1000 - theTimeBegin.tv_usec + theTimeEnd.tv_usec);
    }
    self.loginProcThread = nil;
    
    _STRUCT_TIMEVAL end;
    gettimeofday(&end, NULL);
    NSLog(@"ViewController::loginProc() login test finish ----------");
    NSLog(@"ViewController::loginProc() login test finish, time:%ld.%d", end.tv_sec - begin.tv_sec, end.tv_usec >= begin.tv_usec ? end.tv_usec - begin.tv_usec : 1000*1000 - begin.tv_usec + end.tv_usec);
}

- (IBAction)logoutAction:(id)sender {
    if (nil != self.client) {
        [self.client logout];
    }
}

- (IBAction)vRoomIn:(id)sender {
    if (nil != self.client) {
        SEQ_T reqId = [self.client getReqId];
        [self.client roomIn:reqId roomId:self.roomid];
    }
}

- (IBAction)vRoomOut:(id)sender {
    if (nil != self.client) {
        SEQ_T reqId = [self.client getReqId];
        [self.client roomOut:reqId roomId:self.roomid];
    }
}


- (IBAction)sendRoomMsg:(id)sender {
    if (nil != self.client) {
        SEQ_T reqId = [self.client getReqId];
        [self.client sendLiveChat:reqId roomId:self.roomid nickName:@"alex" msg:@"123456" at:nil];
    }
}

- (IBAction)sendGift:(id)sender {
    if (nil != self.client) {
        SEQ_T reqId = [self.client getReqId];
        [self.client sendGift:reqId roomId:self.roomid nickName:@"alex" giftId:@"123456" giftName:@"testGift" isBackPack:NO giftNum:2 multi_click:YES multi_click_start:2 multi_click_end:4 multi_click_id:1];
    }
}

- (IBAction)sendToast:(id)sender {
    if (nil != self.client) {
        SEQ_T reqId = [self.client getReqId];
        [self.client sendToast:reqId roomId:self.roomid nickName:@"alex" msg:@"852147"];
    }
}

- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg item:(ImLoginReturnObject* _Nonnull)item {
    NSLog(@"ViewController::onLogin() errType:%d, errMsg:%@", errType, errmsg);
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onLogout()");
}

- (void)onKickOff:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg
{
    NSLog(@"ViewController::onKickOff()");
}



- (void)onRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl videoUrls:(NSArray<NSString*>* _Nonnull)videoUrls roomType:(RoomType)roomType credit:(double)credit usedVoucher:(BOOL)usedVoucher fansNum:(int)fansNum emoTypeList:(NSArray<NSNumber *>* _Nonnull)emoTypeList loveLevel:(int)loveLevel rebateInfo:(RebateInfoObject* _Nonnull)rebateInfo favorite:(BOOL)favorite leftSeconds:(int)leftSeconds waitStart:(BOOL)waitStart manPushUrl:(NSArray<NSString*>* _Nonnull)manPushUrl manLevel:(int)manLevel roomPrice:(double)roomPrice manPushPrice:(double)manPushPrice manFansiNum:(int)manFansiNum {
    NSLog(@"ViewController::onRoomIn()");
}

- (void)onRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onRoomOut()");
}


- (void)onRecvRoomCloseNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onRecvRoomCloseNotice()");
}

- (void)onRecvEnterRoomNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl riderId:(NSString * _Nonnull)riderId riderName:(NSString * _Nonnull)riderName riderUrl:(NSString * _Nonnull)riderUrl fansNum:(int)fansNum{
    NSLog(@"ViewController::onRecvEnterRoomNotice()");
}

- (void)onRecvLeaveRoomNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl fansNum:(int)fansNum {
    NSLog(@"ViewController::onRecvLeaveRoomNotice()");
}

- (void)onRecvRebateInfoNotice:(NSString* _Nonnull)roomId rebateInfo:(RebateInfoObject* _Nonnull) rebateInfo {
    NSLog(@"ViewController::onRecvRebateInfoNotice()");
}

- (void)onRecvLeavingPublicRoomNotice:(NSString* _Nonnull)roomId reason:(NSString* _Nonnull)reason {
    NSLog(@"ViewController::onRecvLeavingPublicRoomNotice()");
}

- (void)onRecvRoomKickoffNotice:(NSString* _Nonnull)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString* _Nonnull)errmsg credit:(double)credit {
  NSLog(@"ViewController::onRecvRoomKickoffNotice()");
}

- (void)onRecvLackOfCreditNotice:(NSString* _Nonnull)roomId msg:(NSString* _Nonnull)msg credit:(double)credit {
  NSLog(@"ViewController::onRecvLackOfCreditNotice()");
}

- (void)onRecvCreditNotice:(NSString* _Nonnull)roomId credit:(double)credit {
  NSLog(@"ViewController::onRecvCreditNotice()");
}

- (void) onRecvWaitStartOverNotice:(NSString* _Nonnull)roomId leftSeconds:(int)leftSeconds {
    NSLog(@"ViewController::onRecvWaitStartOverNotice()");
}

- (void)onRecvChangeVideoUrl:(NSString* _Nonnull)roomId  isAnchor:(BOOL)isAnchor playUrl:(NSString* _Nonnull)playUrl {
    NSLog(@"ViewController::onRecvChangeVideoUrl()");
}

- (void)onSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"ViewController::onSendLiveChat()");
}

- (void)onRecvSendChatNotice:(NSString* _Nonnull)roomId level:(int)level fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg {
    NSLog(@"ViewController::OnRecvSendChatNotice()");
}

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"ViewController::onSendGift()");
}

- (void)onRecvSendGiftNotice:(NSString* _Nonnull)roomId fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName giftId:(NSString* _Nonnull)giftId giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id {
    NSLog(@"ViewController::onRecvSendGiftNotice()");
}

- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"ViewController::onSendToast()");
}

- (void)onRecvSendToastNotice:(NSString* _Nonnull)roomId fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg {
    NSLog(@"ViewController::onRecvSendToastNotice()");
}

- (void) onSendPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg invitationId:(NSString* _Nonnull)invitationId timeOut:(int)timeOut roomId:(NSString* _Nonnull)roomId {
    NSLog(@"ViewController::onSendPrivateLiveInvite()");
}

- (void)onSendCancelPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg roomId:(NSString* _Nonnull)roomId {
    NSLog(@"ViewController::onSendCancelPrivateLiveInvite()");
}

- (void)onRecvInstantInviteReplyNotice:(NSString* _Nonnull)inviteId replyType:(ReplyType)replyType roomId:(NSString* _Nonnull)roomId roomType:(RoomType)roomType anchorId:(NSString* _Nonnull)anchorId nickName:(NSString* _Nonnull)nickName avatarImg:(NSString* _Nonnull)avatarImg msg:(NSString* _Nonnull)msg {
    NSLog(@"ViewController::onRecvInstantInviteReplyNotice()");
}

- (void)onRecvInstantInviteUserNotice:(NSString* _Nonnull)logId anchorId:(NSString* _Nonnull)anchorId nickName:(NSString* _Nonnull)nickName avatarImg:(NSString* _Nonnull)avatarImg msg:(NSString* _Nonnull)msg {
     NSLog(@"ViewController::onRecvInstantInviteUserNotice()");
}

- (void)onRecvScheduledInviteUserNotice:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl bookTime:(NSInteger)bookTime inviteId:(NSString* _Nonnull)inviteId {
     NSLog(@"ViewController::OnRecvScheduledInviteUserNotice()");
}

- (void)onRecvSendBookingReplyNotice:(NSString* _Nonnull)inviteId replyType:(AnchorReplyType)replyType {
    NSLog(@"ViewController::onRecvSendBookingReplyNotice()");
}

- (void)onRecvBookingNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl  leftSeconds:(int)leftSeconds {
    NSLog(@"ViewController::onRecvBookingNotice()");
}

- (void)onSendTalent:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg {
    NSLog(@"ViewController::onSendTalent()");
}

- (void)onRecvSendTalentNotice:(NSString* _Nonnull)roomId talentInviteId:(NSString* _Nonnull)talentInviteId talentId:(NSString* _Nonnull)talentId name:(NSString* _Nonnull)name credit:(double) credit status:(TalentStatus)status {
    NSLog(@"ViewController::onRecvSendTalentNotice()");
}

- (void)onRecvLevelUpNotice:(int)level {
    NSLog(@"ViewController::onRecvLevelUpNotice()");
}

- (void)onRecvLoveLevelUpNotice:(int)loveLevel {
    NSLog(@"ViewController::onRecvLoveLevelUpNotice()");
}

- (void)onRecvBackpackUpdateNotice:(BackpackInfoObject * _Nonnull)item {
    NSLog(@"ViewController::onRecvBackpackUpdateNotice()");
}

@end
