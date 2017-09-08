//
//  IMManager.m
//  livestream
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "IMManager.h"

#import "LoginManager.h"
#import "SessionRequestManager.h"

@interface IMManager () <IMLiveRoomManagerDelegate, LoginManagerDelegate>
@property (nonatomic, strong) NSMutableArray *delegates;
// Http登陆管理器
@property (nonatomic, strong) LoginManager *loginManager;
// Http接口管理器
@property (nonatomic, strong) SessionRequestManager *sessionManager;
// 是否第一次IM登陆
@property (nonatomic, assign) BOOL isFirstLogin;
// 是否已经登陆
@property (nonatomic, assign) BOOL isIMLogin;
// 请求字典
@property (nonatomic, strong) NSMutableDictionary *requestDictionary;
// 上次发送返回的邀请
@property (nonatomic, strong) NSString *inviteId;
@end

static IMManager *gManager = nil;
@implementation IMManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if (self = [super init]) {
        self.delegates = [NSMutableArray array];

        self.client = [[ImClientOC alloc] init];
        [self.client addDelegate:self];

        self.loginManager = [LoginManager manager];
        [self.loginManager addDelegate:self];

        self.sessionManager = [SessionRequestManager manager];

        self.requestDictionary = [NSMutableDictionary dictionary];
        self.isIMLogin = NO;
        self.isFirstLogin = YES;
    }
    return self;
}

- (void)dealloc {
    [self.client removeDelegate:self];

    [self.loginManager removeDelegate:self];
}

- (BOOL)addDelegate:(id<IMManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;

    @synchronized(self.delegates) {
        // 查找是否已存在
        for (NSValue *value in self.delegates) {
            id<IMManagerDelegate> item = (id<IMManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                result = YES;
                break;
            }
        }

        // 未存在则添加
        if (!result) {
            [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
            result = YES;
        }
    }

    return result;
}

- (BOOL)removeDelegate:(id<IMManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMManagerDelegate> item = (id<IMManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                result = YES;
                break;
            }
        }
    }

    return result;
}

#pragma mark - HTTP登录回调
- (void)manager:(LoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject *_Nullable)loginItem errnum:(NSInteger)errnum errmsg:(NSString *_Nonnull)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            // 获取同步配置的IM服务器地址
            NSMutableArray<NSString *> *urls = [NSMutableArray array];
            [urls addObject:@"ws://172.25.32.17:3106"];
            [self.client initClient:urls];

            // 开始登录IM
            [self.client login:loginItem.token pageName:PAGENAMETYPE_MOVEPAGE];
        }
    });
}

- (void)manager:(LoginManager *_Nonnull)manager onLogout:(BOOL)kick {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 注销IM
        [self.client logout];
    });
}

#pragma mark - IM登陆回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg item:(ImLoginReturnObject*_Nonnull)item {
    NSLog(@"IMManager::onLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);

    if (errType == LCC_ERR_SUCCESS) {
        // IM登陆成功
        @synchronized(self) {
            // 标记IM登陆成功
            self.isIMLogin = YES;

            // 第一次IM登陆成功
            if (self.isFirstLogin) {
                self.isFirstLogin = NO;
                
                // 处理是否在直播间中
                if( ![self handleLoginRoomList:item.roomList] ) {
                    // 处理是否在邀请中
                    if( ![self handleLoginInviteList:item.inviteList] ) {
                        // 不需要处理
                    }
                }
                
                // 处理预约
                [self handleLoginScheduleRoomList:item.scheduleRoomList];
                
            } else {
                // 断线重登陆
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 查询邀请状态
                    [self getInviteInfo];
                });
            }
        }

    } else if (errType == LCC_ERR_CONNECTFAIL) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // IM断线, 3秒后重连
            if (self.loginManager.status == LOGINED) {
                [self.client login:self.loginManager.loginItem.token pageName:PAGENAMETYPE_MOVEPAGE];
            }
        });
    }
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
    NSLog(@"IMManager::onLogout( [IM注销通知], errType : %d, errmsg : %@ )", errType, errmsg);

    @synchronized(self) {
        // 标记IM登陆未登陆
        self.isIMLogin = NO;
    }

    //    if (errType == LCC_ERR_CONNECTFAIL) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        // IM断线, 3秒后重连
        if (self.loginManager.status == LOGINED) {
            [self.client login:self.loginManager.loginItem.token pageName:PAGENAMETYPE_MOVEPAGE];
        }
    });
    //    }
}

- (void)onKickOff:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
    NSLog(@"IMManager::onKickOff( [用户被挤掉线, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
}

#pragma mark - 首次登陆处理
- (BOOL)handleLoginRoomList:(NSArray<NSString *> *)roomList {
    BOOL bFlag = NO;
    
    NSString *roomId = nil;
    if( roomList.count > 0 ) {
        roomId = [roomList objectAtIndex:0];
        
        if( roomId.length > 0 ) {
            bFlag = YES;
            
            for (NSValue *value in self.delegates) {
                id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(onHandleLoginRoom:)]) {
                    [delegate onHandleLoginRoom:roomId];
                }
            }
        }

    }
    
    return bFlag;
}

- (BOOL)handleLoginInviteList:(NSArray<ImInviteIdItemObject *> *)inviteList {
    BOOL bFlag = NO;
    
    ImInviteIdItemObject *inviteItem = nil;
    if( inviteList.count > 0 ) {
        inviteItem = [inviteList objectAtIndex:0];
        
        if( inviteItem ) {
            bFlag = YES;
            
            for (NSValue *value in self.delegates) {
                id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(onHandleLoginInvite:)]) {
                    [delegate onHandleLoginInvite:inviteItem];
                }
            }
        }
        
    }
    
    return bFlag;
}

- (BOOL)handleLoginScheduleRoomList:(NSArray<ImScheduleRoomObject*> *)scheduleRoomList {
    BOOL bFlag = YES;
    
    for (NSValue *value in self.delegates) {
        id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(onHandleLoginSchedule:)]) {
            [delegate onHandleLoginSchedule:scheduleRoomList];
        }
    }
    
    return bFlag;
}

#pragma mark - 直播间状态
- (BOOL)enterRoom:(NSString *_Nonnull)roomId finishHandler:(EnterRoomHandler _Nullable)finishHandler {
    NSLog(@"IMManager::enterRoom( [发送观众进入直播间], roomId : %@ )", roomId);
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            BOOL bFlag = [self.client roomIn:reqId roomId:roomId];
            if (bFlag) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }

    return bFlag;
}

- (void)onRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg item:(ImLiveRoomObject *_Nonnull)item {
    NSLog(@"IMManager::onRoomIn( [发送观众进入直播间, %@], reqId : %u, errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", reqId, errType, errmsg);

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        EnterRoomHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            //            ImLiveRoom *item = [[ImLiveRoom alloc] initWithUserId:item.userId
            //                                                         nickName:item.nickName
            //                                                         photoUrl:item.photoUrl
            //                                                        videoUrls:item.videoUrls
            //                                                         roomType:item.roomType
            //                                                           credit:item.credit
            //                                                      usedVoucher:item.usedVoucher
            //                                                          fansNum:item.fansNum
            //                                                      emoTypeList:item.emoTypeList
            //                                                        loveLevel:item.loveLevel
            //                                                       rebateInfo:item.rebateInfo
            //                                                         favorite:item.favorite
            //                                                      leftSeconds:item.leftSeconds
            //                                                        waitStart:item.waitStart
            //                                                       manPushUrl:item.manPushUrl
            //                                                         manLevel:item.manLevel
            //                                                        roomPrice:item.roomPrice
            //                                                     manPushPrice:item.manPushPrice
            //                                                      maxFansiNum:item.maxFansiNum];
            finishHandler(success, errType, errmsg, item);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)leaveRoom:(NSString *)roomId {
    NSLog(@"IMManager::leaveRoom( [发送观众退出直播间], roomId : %@ )", roomId);
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client roomOut:reqId roomId:roomId];
        }
    }

    return bFlag;
}

- (void)onRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
    NSLog(@"IMManager::onFansRoomOut( [发送观众退出直播间, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
}

- (BOOL)enterPublicRoom:(NSString *_Nonnull)anchorId finishHandler:(EnterPublicRoomHandler _Nullable)finishHandler {
    NSLog(@"IMManager::enterPublicRoom( [发送观众进入公开直播间], anchorId : %@ )", anchorId);
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            BOOL bFlag = [self.client publicRoomIn:reqId anchorId:anchorId];
            if (bFlag) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }

    return bFlag;
}

- (void)onPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg item:(ImLiveRoomObject *_Nonnull)item {
    NSLog(@"IMManager::onPublicRoomIn( [发送观众进入公开直播间, %@], errType : %d, errmsg : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        EnterRoomHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            //            ImLiveRoom *roomItem = [[ImLiveRoom alloc] initWithUserId:item.userId
            //                                                             nickName:item.nickName
            //                                                             photoUrl:item.photoUrl
            //                                                            videoUrls:item.videoUrls
            //                                                             roomType:item.roomType
            //                                                               credit:item.credit
            //                                                          usedVoucher:item.usedVoucher
            //                                                              fansNum:item.fansNum
            //                                                          emoTypeList:item.emoTypeList
            //                                                            loveLevel:item.loveLevel
            //                                                           rebateInfo:item.rebateInfo
            //                                                             favorite:item.favorite
            //                                                          leftSeconds:item.leftSeconds
            //                                                            waitStart:item.waitStart
            //                                                           manPushUrl:item.manPushUrl
            //                                                             manLevel:item.manLevel
            //                                                            roomPrice:item.roomPrice
            //                                                         manPushPrice:item.manPushPrice
            //                                                          manFansiNum:item.manFansiNum];
            finishHandler(success, err, errMsg, item);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (void)onControlManPush:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg manPushUrl:(NSArray<NSString *> *_Nonnull)manPushUrl {
    NSLog(@"IMManager::onControlManPush( [观众开始／结束视频互动, %@], errType : %d, errmsg : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);
}

- (void)onRecvRoomCloseNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
    NSLog(@"IMManager::onRecvRoomCloseNotice( [接收直播间关闭通知] )");
}

- (void)onRecvEnterRoomNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName photoUrl:(NSString *_Nonnull)photoUrl riderId:(NSString *_Nonnull)riderId riderName:(NSString *_Nonnull)riderName riderUrl:(NSString *_Nonnull)riderUrl fansNum:(int)fansNum {
    NSLog(@"IMManager::onRecvEnterRoomNotice( [接收观众进入直播间通知] )");
}

- (void)onRecvLeaveRoomNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName photoUrl:(NSString *_Nonnull)photoUrl fansNum:(int)fansNum {
    NSLog(@"IMManager::onRecvLeaveRoomNotice( [接收观众退出直播间通知] )");
}

- (void)onRecvRebateInfoNotice:(NSString *_Nonnull)roomId rebateInfo:(RebateInfoObject *_Nonnull)rebateInfo {
    NSLog(@"IMManager::onRecvRebateInfoNotice( [接收返点通知] )");
}

- (void)onRecvLeavingPublicRoomNotice:(NSString *_Nonnull)roomId err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg {
    NSLog(@"IMManager::onRecvLeavingPublicRoomNotice( [接收关闭直播间倒数通知] )");
}

- (void)onRecvRoomKickoffNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString *_Nonnull)errmsg credit:(double)credit {
    NSLog(@"IMManager::onRecvRoomKickoffNotice( [接收直播间禁言通知] )");
}

- (void)onRecvCreditNotice:(NSString *_Nonnull)roomId credit:(double)credit {
    NSLog(@"IMManager::onRecvCreditNotice( [接收定时扣费通知] )");
}

- (void)onRecvWaitStartOverNotice:(NSString *_Nonnull)roomId leftSeconds:(int)leftSeconds {
    NSLog(@"IMManager::onRecvWaitStartOverNotice( [直播间开播通知] )");
}

- (void)onRecvChangeVideoUrl:(NSString *_Nonnull)roomId isAnchor:(BOOL)isAnchor playUrl:(NSString *_Nonnull)playUrl {
    NSLog(@"IMManager::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知] )");
}

#pragma mark - 私密直播间
- (BOOL)invitePrivateLive:(NSString *_Nonnull)userId logId:(NSString *_Nonnull)logId force:(BOOL)force finishHandler:(InviteHandler _Nullable)finishHandler {
    NSLog(@"IMManager::invitePrivateLive( [发送私密邀请], userId : %@, logId : %@ )", userId, logId);
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            BOOL bFlag = [self.client sendPrivateLiveInvite:reqId userId:userId logId:logId force:force];
            if (bFlag) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }

    return bFlag;
}

- (void)onSendPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg invitationId:(NSString *_Nonnull)invitationId timeOut:(int)timeOut roomId:(NSString *_Nonnull)roomId {
    NSLog(@"IMManager::onSendPrivateLiveInvite( [发送私密邀请, %@] )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败");

    @synchronized(self) {
        if (success) {
            // 记录邀请Id
            self.inviteId = invitationId;
        }

        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        InviteHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, invitationId, timeOut, roomId);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)cancelPrivateLive:(CancelInviteHandler _Nullable)finishHandler {
    NSLog(@"IMManager::cancelPrivateLive( [发送私密邀请(取消)], inviteId : %@ )", self.inviteId);
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            if (self.inviteId) {
                SEQ_T reqId = [self.client getReqId];
                BOOL bFlag = [self.client sendCancelPrivateLiveInvite:reqId inviteId:self.inviteId];
                if (bFlag) {
                    [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
                }
                // 清空邀请Id
                self.inviteId = nil;
            }
        }
    }

    return bFlag;
}

- (void)onSendCancelPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg roomId:(NSString *_Nonnull)roomId {
    NSLog(@"IMManager::onSendCancelPrivateLiveInvite( [发送私密邀请(取消), %@] )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败");

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        CancelInviteHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, roomId);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (void)getInviteInfo {
    if (self.inviteId) {
        NSLog(@"IMManager::getInviteInfo( [查询邀请状态], inviteId : %@ )", self.inviteId);
        
        GetInviteInfoRequest *request = [[GetInviteInfoRequest alloc] init];
        request.inviteId = self.inviteId;
        request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg, InviteIdItemObject *_Nonnull item) {
            NSLog(@"IMManager::getInviteInfo( [查询邀请状态, %@], inviteId : %@ )", success ? @"成功" : @"失败", self.inviteId);
            if (success) {
                for (NSValue *value in self.delegates) {
                    id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onRecvInviteReply:)]) {
                        [delegate onRecvInviteReply:item];
                    }
                }
            }
        };
        [self.sessionManager sendRequest:request];
    }
}

- (void)onRecvInstantInviteReplyNotice:(NSString *_Nonnull)inviteId replyType:(ReplyType)replyType roomId:(NSString *_Nonnull)roomId roomType:(RoomType)roomType anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    NSLog(@"IMManager::onRecvInstantInviteReplyNotice( [接收立即私密邀请回复通知], roomId : %@, inviteId : %@, msg : %@ )", roomId, inviteId, msg);
}

- (void)onRecvInstantInviteUserNotice:(NSString *_Nonnull)logId anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    NSLog(@"IMManager::onRecvInstantInviteReplyNotice( [接收主播立即私密邀请通知] )");
}

- (void)onRecvScheduledInviteUserNotice:(NSString *_Nonnull)inviteId anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    NSLog(@"IMManager::onRecvScheduledInviteUserNotice( [接收主播预约私密邀请通知] )");
}

- (void)onRecvSendBookingReplyNotice:(NSString *_Nonnull)inviteId replyType:(AnchorReplyType)replyType {
    NSLog(@"IMManager::onRecvSendBookingReplyNotice( [接收预约私密邀请回复通知] )");
}

- (void)onRecvBookingNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName photoUrl:(NSString *_Nonnull)photoUrl leftSeconds:(int)leftSeconds {
    NSLog(@"IMManager::onRecvBookingNotice( [接收预约开始倒数通知] )");
}

#pragma mark - 才艺点播
- (NSInteger)sendTalent:(NSString *_Nonnull)roomId talentId:(NSString *_Nonnull)talentId {
    NSLog(@"IMManager::sendTalent( [发送直播间才艺点播邀请], roomId : %@ )", roomId);
    NSInteger requestId = INVALID_REQUEST_ID;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            BOOL bFlag = [self.client sendTalent:reqId roomId:roomId talentId:talentId];
            if (bFlag) {
                requestId = reqId;
            }
        }
    }
    return requestId;
}

- (void)onSendTalent:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg talentInviteId:(NSString *_Nonnull)talentInviteId {
    NSLog(@"IMManager::onSendTalent( [发送直播间才艺点播邀请, %@], errType : %d, errmsg : %@ talentInviteId:%@)", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, talentInviteId);
}

- (void)onRecvSendTalentNotice:(NSString *_Nonnull)roomId talentInviteId:(NSString *_Nonnull)talentInviteId talentId:(NSString *_Nonnull)talentId name:(NSString *_Nonnull)name credit:(double)credit status:(TalentStatus)status {
    NSLog(@"IMManager::onRecvSendTalentNotice( [接收直播间才艺点播回复通知] )");
}

#pragma mark - 消息和礼物
- (NSInteger)sendLiveChat:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at {
    NSLog(@"IMManager::sendLiveChat( [发送直播间文本消息], roomId : %@, nickName : %@, msg : %@ )", roomId, nickName, msg);
    NSInteger requestId = INVALID_REQUEST_ID;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            BOOL bFlag = [self.client sendLiveChat:reqId roomId:roomId nickName:nickName msg:msg at:at];
            if (bFlag) {
                requestId = reqId;
            }
        }
    }
    return requestId;
}

- (void)onSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
    NSLog(@"IMManager::onSendLiveChat( [发送直播间文本消息, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
}

- (void)onRecvSendChatNotice:(NSString *_Nonnull)roomId level:(int)level fromId:(NSString *_Nonnull)fromId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg {
    NSLog(@"IMManager::onRecvSendChatNotice( [接收直播间文本消息通知], roomId : %@, nickName : %@, msg : %@ )", roomId, nickName, msg);
}

- (void)onRecvSendSystemNotice:(NSString *_Nonnull)roomId msg:(NSString *_Nonnull)msg link:(NSString *_Nonnull)link {
    NSLog(@"IMManager::onRecvSendSystemNotice( [接收直播间公告消息], roomId : %@, msg : %@ link: %@)", roomId, msg, link);
}

- (NSInteger)sendToast:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg {
    NSLog(@"IMManager::sendToast( [发送直播间弹幕消息], roomId : %@, nickName : %@, msg : %@ )", roomId, nickName, msg);
    NSInteger requestId = INVALID_REQUEST_ID;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            BOOL bFlag = [self.client sendToast:reqId roomId:roomId nickName:nickName msg:msg];
            if (bFlag) {
                requestId = reqId;
            }
        }
    }
    return requestId;
}

- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"IMManager::onSendToast( [发送直播间弹幕消息, %@], errmsg : %@, credit : %f, rebateCredit : %f )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errmsg, credit, rebateCredit);
}

- (void)onRecvSendToastNotice:(NSString *_Nonnull)roomId fromId:(NSString *_Nonnull)fromId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg {
    NSLog(@"IMManager::onRecvSendToastNotice( [接收直播间弹幕通知], roomId : %@, fromId : %@, nickName : %@, msg : %@ )", roomId, fromId, nickName, msg);
}

- (NSInteger)sendGift:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName giftId:(NSString *_Nonnull)giftId giftName:(NSString *_Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id {
    NSLog(@"IMManager::sendGift( [发送直播间弹幕消息], roomId : %@, nickName : %@, giftId : %@ )", roomId, nickName, giftId);
    NSInteger requestId = INVALID_REQUEST_ID;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            BOOL bFlag = [self.client sendGift:reqId roomId:roomId nickName:nickName giftId:giftId giftName:giftName isBackPack:isBackPack giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id];
            if (bFlag) {
                requestId = reqId;
            }
        }
    }
    return requestId;
}

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"IMManager::onSendGift( [发送直播间礼物消息], errmsg : %@, credit : %f, rebateCredit : %f )", errmsg, credit, rebateCredit);
}

- (void)onRecvSendGiftNotice:(NSString* _Nonnull)roomId fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName giftId:(NSString* _Nonnull)giftId giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id {
    NSLog(@"IMManager::onRecvSendGiftNotice( [接收直播间礼物通知], roomId : %@, fromId : %@, nickName : %@ )", roomId, fromId, nickName);
}

#pragma mark - 公共
- (void)onRecvLevelUpNotice:(int)level {
    NSLog(@"IMManager::onRecvLevelUpNotice( [接收观众等级升级通知] )");
}

- (void)onRecvLoveLevelUpNotice:(int)loveLevel {
    NSLog(@"IMManager::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知] )");
}

- (void)onRecvBackpackUpdateNotice:(BackpackInfoObject * _Nonnull)item {
    NSLog(@"IMManager::onRecvBackpackUpdateNotice( [接收背包更新通知] )");
}

@end
