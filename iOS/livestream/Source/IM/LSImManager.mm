//
//  LSImManager.m
//  livestream
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSImManager.h"

#import "LiveGobalManager.h"
#import "LSConfigManager.h"
#import "LSLoginManager.h"
#import "LSRoomUserInfoManager.h"
#import "LSSessionRequestManager.h"
#import "LiveFansListRequest.h"
#import "LiveModule.h"
#import "LSIMLoginManager.h"
@interface LSImManager () <IMLiveRoomManagerDelegate,LoginManagerDelegate>
@property (nonatomic, strong) NSMutableArray *delegates;
// Http登陆管理器
@property (nonatomic, strong) LSLoginManager *loginManager;
// Http接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 是否被踢
@property (nonatomic, assign) BOOL isKick;
// 被踢提示
@property (nonatomic, strong) NSString *kickMsg;
// 请求字典
@property (nonatomic, strong) NSMutableDictionary *requestDictionary;
// 上次发送返回的邀请
@property (nonatomic, strong) NSString *inviteId;
// 用户管理器
@property (nonatomic, strong) LSRoomUserInfoManager *roomUserInfoManager;

@end

static LSImManager *imManager = nil;
@implementation LSImManager
#pragma mark - 获取实例
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!imManager) {
            imManager = [[[self class] alloc] init];
        }
    });
    return imManager;
}

- (id)init {
    NSLog(@"LSImManager::init()");

    if (self = [super init]) {
        self.delegates = [NSMutableArray array];

        self.client = [[ImClientOC alloc] init];
        [self.client addDelegate:self];

        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
        
        self.sessionManager = [LSSessionRequestManager manager];

        self.roomUserInfoManager = [LSRoomUserInfoManager manager];
        
        self.requestDictionary = [NSMutableDictionary dictionary];
        self.isIMLogin = NO;
        self.isFirstLogin = YES;
        self.isKick = NO;
    }
    return self;
}

- (void)resetIMStatus {
    self.isIMLogin = NO;
    self.isFirstLogin = YES;
    self.isKick = NO;
}

- (void)dealloc {
    NSLog(@"LSImManager::dealloc()");

    [self.client removeDelegate:self];
}

- (BOOL)addDelegate:(id<IMManagerDelegate>)delegate {
    BOOL result = NO;

    NSLog(@"LSImManager::addDelegate( delegate : %@ )", delegate);

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

- (BOOL)removeDelegate:(id<IMManagerDelegate>)delegate {
    BOOL result = NO;

    NSLog(@"LSImManager::removeDelegate( delegate : %@ )", delegate);

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

- (void)login {
    NSLog(@"LSImManager::login( [IM登陆], token : %@ )", self.loginManager.loginItem.token);

    // 开始登录IM
    [self.client login:self.loginManager.loginItem.token pageName:PAGENAMETYPE_MOVEPAGE];
}

- (void)logout {
    NSLog(@"LSImManager::logout( [IM注销] )");

    // 开始注销IM
    [self.client logout];
}

#pragma mark - HTTP登录回调
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            // 获取同步配置的IM服务器地址
            [[LSConfigManager manager] synConfig:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, ConfigItemObject *item) {
                if (success) {
                    NSLog(@"LSImManager::onLogin( [HTTP登陆, 成功, 同步Im服务器地址], url : %@ )", item.imSvrUrl);

                    NSMutableArray<NSString *> *urls = [NSMutableArray array];
                    [urls addObject:item.imSvrUrl];
                    //[urls addObject:@"wss://174.129.224.73:443"];
                    [self.client initClient:urls];

                    // 开始登录IM
                    [self login];
                }
            }];
        }
    });
}

- (void)manager:(LSLoginManager *)manager onLogout:(LogoutType)type msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 注销IM
        NSLog(@"LSImManager::onLogout( [Http注销通知], type : %d )", type);
        [self logout];
    });
}

#pragma mark - IM登陆回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"LSImManager::onLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);

    if (errType == LCC_ERR_SUCCESS) {
        // IM登陆成功
        @synchronized(self) {

            // IM登录成功,同步用户本地Level
            [self.roomUserInfoManager getLiverInfo:self.loginManager.loginItem.userId
                                        finishHandler:^(LSUserInfoModel *item){

                                        }];

            // 标记IM登陆成功
            self.isIMLogin = YES;
            // 第一次IM登陆成功
            if (self.isFirstLogin) {
                self.isFirstLogin = NO;

                /*
                 * Mark by Max 2018/02/02
                 * deprecated
                 */
                //                // 处理是否在直播间中
                //                if (![self handleLoginRoomList:item.roomList]) {
                //                    // 处理是否在邀请中
                //                    if (![self handleLoginInviteList:item.inviteList]) {
                //                        // 不需要处理
                //                    }
                //                }

                // 处理预约
                [self handleLoginScheduleRoomList:item.scheduleRoomList];

            } else {
                // 断线重登陆

                // 查询邀请状态
                [self getInviteInfo:^(BOOL success, LCC_ERR_TYPE errType, NSString *errMsg, ImInviteIdItemObject *item, ImAuthorityItemObject *priv) {
                    if (success) {
                        // 成功获取到邀请状态
                        dispatch_async(dispatch_get_main_queue(), ^{
                            @synchronized (self.delegates) {
                                for (NSValue *value in self.delegates) {
                                    id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
                                    if ([delegate respondsToSelector:@selector(onRecvInviteReply:)]) {
                                        [delegate onRecvInviteReply:item];
                                    }
                                }
                            }
                        });
                    }
                }];
            }
        }

    } else if (errType == LCC_ERR_CONNECTFAIL) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // IM断线, 3秒后重连
            if ([LSIMLoginManager manager].status == LOGINED) {
                [self login];
            }
        });
    }
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"LSImManager::onLogout( [IM注销通知], errType : %d, errmsg : %@ )", errType, errmsg);

    @synchronized(self) {
        // 标记IM登陆未登陆
        self.isIMLogin = NO;
    }

    @synchronized(self) {
        if (!self.isKick) {
            if (self.loginManager.status == LOGINED) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    // IM断线, 10秒后重连
                    [self login];
                });
            }
        } else {
            // 被踢
            self.isKick = NO;

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loginManager logout:LogoutTypeKick msg:self.kickMsg];
                self.kickMsg = @"";
            });
        }
    }
}

- (void)onKickOff:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"LSImManager::onKickOff( [用户被挤掉线, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    @synchronized(self) {
        self.isKick = YES;
        self.kickMsg = errmsg;
    }
}

#pragma mark - 首次登陆处理
- (BOOL)handleLoginRoomList:(NSArray<ImLoginRoomObject *> *)roomList {
    BOOL bFlag = NO;

    if (roomList.count > 0) {
        ImLoginRoomObject *roomObj = [roomList objectAtIndex:0];
        if (roomObj.roomId.length > 0) {
            bFlag = YES;

            @synchronized (self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onHandleLoginRoom:userId:userName:)]) {
                        [delegate onHandleLoginRoom:roomObj.roomId userId:roomObj.anchorId userName:roomObj.nickName];
                    }
                }
            }
        }
    }

    return bFlag;
}

- (BOOL)handleLoginInviteList:(NSArray<ImInviteIdItemObject *> *)inviteList {
    BOOL bFlag = NO;

    ImInviteIdItemObject *inviteItem = nil;
    if (inviteList.count > 0) {
        inviteItem = [inviteList objectAtIndex:0];

        if (inviteItem) {
            bFlag = YES;

            @synchronized (self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onHandleLoginInvite:)]) {
                        [delegate onHandleLoginInvite:inviteItem];
                    }
                }
            }
        }
    }

    return bFlag;
}

- (BOOL)handleLoginScheduleRoomList:(NSArray<ImScheduleRoomObject *> *)scheduleRoomList {
    BOOL bFlag = YES;

    @synchronized (self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onHandleLoginSchedule:)]) {
                [delegate onHandleLoginSchedule:scheduleRoomList];
            }
        }
    }

    return bFlag;
}

- (BOOL)handleLoginOnGingShowList:(NSArray<IMOngoingShowItemObject *> *)ongoingShowList {
    BOOL bFlag = YES;

    @synchronized (self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onHandleLoginOnGingShowList:)]) {
                [delegate onHandleLoginOnGingShowList:ongoingShowList];
            }
        }
    }

    return bFlag;
}

- (BOOL)handleRecommendHangoutFriend:(IMRecommendHangoutItemObject *)firendItem {
    BOOL bFlag = YES;

    @synchronized (self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onHandleRecommendHangoutFriend:)]) {
                [delegate onHandleRecommendHangoutFriend:firendItem];
            }
        }
    }

    return bFlag;
}

- (BOOL)handleKnockRequest:(IMKnockRequestItemObject *)knockItem {
    BOOL bFlag = YES;

    @synchronized (self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onHandleKnockRequest:)]) {
                [delegate onHandleKnockRequest:knockItem];
            }
        }
    }

    return bFlag;
}

- (BOOL)handleEnterHangoutCountDown:(NSString *)roomId anchorId:(NSString *)anchorId leftSecond:(int)leftSecond {
    BOOL bFlag = YES;

    @synchronized (self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onHandleEnterHangoutCountDown:anchorId:leftSecond:)]) {
                [delegate onHandleEnterHangoutCountDown:roomId anchorId:anchorId leftSecond:leftSecond];
            }
        }
    }

    return bFlag;
}

#pragma mark - 直播间状态
- (BOOL)enterRoom:(NSString *)roomId finishHandler:(EnterRoomHandler)finishHandler {
    NSLog(@"LSImManager::enterRoom( [发送观众进入直播间], roomId : %@ )", roomId);
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client roomIn:reqId roomId:roomId];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }

    return bFlag;
}

- (void)onRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLiveRoomObject *)item priv:(ImAuthorityItemObject* _Nonnull)priv {
    NSLog(@"LSImManager::onRoomIn( [发送观众进入直播间, %@], reqId : %u, errType : %d, errmsg : %@ isHasTalent:%d)", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", reqId, errType, errmsg, item.isHasTalent);

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        EnterRoomHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, errType, errmsg, item, priv);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)leaveRoom:(LiveRoom *)liveRoom {
    NSLog(@"LSImManager::leaveRoom( [发送观众退出直播间], roomId : %@ )", liveRoom.roomId);

    BOOL bFlag = NO;
    if (liveRoom.roomId.length > 0) {
        @synchronized(self) {
            if (self.isIMLogin) {
                SEQ_T reqId = [self.client getReqId];
                NSString *roomId = liveRoom.roomId;
                bFlag = [self.client roomOut:reqId roomId:roomId];
            }
        }

        // 标记直播间为已经退出
        liveRoom.active = NO;
    }
    
    // 修改全局直播间
    [LiveGobalManager manager].liveRoom = nil;

    return bFlag;
}

- (void)onRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"LSImManager::onRoomOut( [发送观众退出直播间, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
}

#pragma mark - 直播间状态通知
- (BOOL)enterPublicRoom:(NSString *)userId finishHandler:(EnterPublicRoomHandler)finishHandler {
    NSLog(@"LSImManager::enterPublicRoom( [发送观众进入公开直播间], userId : %@ )", userId);
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client publicRoomIn:reqId userId:userId];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }

    return bFlag;
}

- (void)onPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg item:(ImLiveRoomObject *)item priv:(ImAuthorityItemObject* _Nonnull)priv {
    NSLog(@"LSImManager::onPublicRoomIn( [发送观众进入公开直播间, %@], errType : %d, errmsg : %@, reqId : %u )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, reqId);

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        EnterPublicRoomHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, item, priv);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

//3.3.接收直播间关闭通知(观众)回调 （LCC_ERR_NO_CREDIT_CLOSE_LIVE // 余额不足）
- (void)onRecvRoomCloseNotice:(NSString *)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg priv:(ImAuthorityItemObject * _Nonnull)priv{
    NSLog(@"LSImManager::onRecvRoomCloseNotice( [接收直播间关闭通知], roomId : %@, errType : %d, errMsg : %@, isHasOneOnOneAuth : %d, isHasOneOnOneAuth : %d )", roomId, errType, errmsg, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
}

- (void)onRecvEnterRoomNotice:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName photoUrl:(NSString *)photoUrl riderId:(NSString *)riderId riderName:(NSString *)riderName riderUrl:(NSString *)riderUrl fansNum:(int)fansNum honorImg:(NSString *)honorImg isHasTicket:(BOOL)isHasTicket {
    NSLog(@"LSImManager::onRecvEnterRoomNotice( [接收观众进入直播间通知], roomId : %@, userId : %@, nickName : %@ )", roomId, userId, nickName);
}

- (void)onRecvLeaveRoomNotice:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName photoUrl:(NSString *)photoUrl fansNum:(int)fansNum {
    NSLog(@"LSImManager::onRecvLeaveRoomNotice( [接收观众退出直播间通知], roomId : %@, userId : %@, nickName : %@ )", roomId, userId, nickName);
}

- (void)onRecvRebateInfoNotice:(NSString *)roomId rebateInfo:(RebateInfoObject *)rebateInfo {
    NSLog(@"LSImManager::onRecvRebateInfoNotice( [接收返点通知] )");
}

- (void)onRecvLeavingPublicRoomNotice:(NSString *)roomId leftSeconds:(int)leftSeconds err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg priv:(ImAuthorityItemObject * _Nonnull)priv{
    NSLog(@"LSImManager::onRecvLeavingPublicRoomNotice( [接收关闭直播间倒数通知] )");
}

- (void)onRecvRoomKickoffNotice:(NSString *)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString *)errmsg credit:(double)credit priv:(ImAuthorityItemObject * _Nonnull)priv {
    NSLog(@"LSImManager::onRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@ , isHasOneOnOneAuth : %d, isHasOneOnOneAuth : %d )", roomId, priv.isHasOneOnOneAuth, priv.isHasBookingAuth);
}

- (void)onRecvCreditNotice:(NSString *)roomId credit:(double)credit {
    NSLog(@"LSImManager::onRecvCreditNotice( [接收定时扣费通知] )");
}

- (void)onRecvWaitStartOverNotice:(ImStartOverRoomObject *)item {
    NSLog(@"LSImManager::onRecvWaitStartOverNotice( [接收主播进入直播间通知], roomId : %@ )", item.roomId);
}

- (void)onRecvChangeVideoUrl:(NSString *)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString *> *)playUrl userId:(NSString *)userId {
    NSLog(@"LSImManager::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知], roomId : %@, playUrl : %@, userId : %@ )", roomId, playUrl, userId);
}

#pragma mark - 私密直播间
- (BOOL)invitePrivateLive:(NSString *)userId logId:(NSString *)logId force:(BOOL)force finishHandler:(InviteHandler)finishHandler {
    NSLog(@"LSImManager::invitePrivateLive( [发送私密邀请], userId : %@, logId : %@ )", userId, logId);
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client sendPrivateLiveInvite:reqId userId:userId logId:logId force:force];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }

    return bFlag;
}

- (void)onSendPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg invitationId:(NSString *)invitationId timeOut:(int)timeOut roomId:(NSString *)roomId inviteErr:(ImInviteErrItemObject *)inviteErr {
    NSLog(@"LSImManager::onSendPrivateLiveInvite( [发送私密邀请, %@], err : %d, errMsg : %@ chatOnlineStatus : %d)", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, inviteErr.status);

    @synchronized(self) {
        if (success) {
            // 记录邀请Id
            self.inviteId = invitationId;
        }

        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        InviteHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, invitationId, timeOut, roomId, inviteErr);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)cancelPrivateLive:(CancelInviteHandler)finishHandler {
    NSLog(@"LSImManager::cancelPrivateLive( [发送私密邀请(取消)], inviteId : %@ )", self.inviteId);
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            if (self.inviteId) {
                SEQ_T reqId = [self.client getReqId];
                bFlag = [self.client sendCancelPrivateLiveInvite:reqId inviteId:self.inviteId];
                if (bFlag && finishHandler) {
                    [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
                }
                // 清空邀请Id
                self.inviteId = nil;
            }
        }
    }

    return bFlag;
}

- (void)onSendCancelPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg roomId:(NSString *)roomId {
    NSLog(@"LSImManager::onSendCancelPrivateLiveInvite( [发送私密邀请(取消), %@], err : %d, errMsg : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        CancelInviteHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, roomId);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)InstantInviteUserReport:(NSString *)inviteId isShow:(BOOL)isShow finishHandler:(InstantInviteUserReportHandler)finishHandler {
    NSLog(@"LSImManager::InstantInviteUserReport( [观众端是否显示主播立即私密邀请 ], inviteId : %@ )", self.inviteId);
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            if (inviteId) {
                SEQ_T reqId = [self.client getReqId];
                bFlag = [self.client sendInstantInviteUserReport:reqId inviteId:inviteId isShow:isShow];
                if (bFlag && finishHandler) {
                    [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
                }
            }
        }
    }

    return bFlag;
}

- (void)onSendInstantInviteUserReport:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg {
    NSLog(@"LSImManager::onSendInstantInviteUserReport( [观众端是否显示主播立即私密邀请, %@], err : %d, errMsg : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        InstantInviteUserReportHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)getInviteInfo:(GetIMInviteInfoHandler)finishHandler {

    NSLog(@"LSImManager::getInviteInfo( [获取指定立即私密邀请信息], inviteId : %@ )", self.inviteId);
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            if (self.inviteId.length > 0) {
                SEQ_T reqId = [self.client getReqId];
                bFlag = [self.client getInviteInfo:reqId invitationId:self.inviteId];
                if (bFlag && finishHandler) {
                    [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
                }
                //                // 清空邀请Id
                //                self.inviteId = nil;
            }
        }
    }

    return bFlag;
}

- (BOOL)sendHandleSchedule:(ImScheduleRoomInfoObject *_Nonnull)item {
    NSLog(@"LSImManager::sendHandleSchedule( [观众通知服务器对预约操作（操作为发送、接受、拒绝预约）] )");
    BOOL bFlag = NO;

    @synchronized(self) {
        if (self.isIMLogin) {
            //if (self.inviteId.length > 0) {
                SEQ_T reqId = [self.client getReqId];
                bFlag = [self.client sendHandleSchedule:reqId item:item];
;
           // }
        }
    }

    return bFlag;
}

- (void)onGetInviteInfo:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg item:(ImInviteIdItemObject *)item priv:(ImAuthorityItemObject* )priv{
    NSLog(@"LSImManager::onGetInviteInfo( [获取指定立即私密邀请信息, %@], errType : %d, errmsg : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        GetIMInviteInfoHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, item, priv);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

#pragma mark - 私密直播间通知
- (void)onRecvInstantInviteReplyNotice:(ImInviteReplyItemObject* _Nonnull)replyItem {
    NSLog(@"LSImManager::onRecvInstantInviteReplyNotice( [接收立即私密邀请回复通知], roomId : %@, inviteId : %@, msg : %@ chatOnlineStatus : %d)", replyItem.roomId, replyItem.inviteId, replyItem.msg, replyItem.status);

    @synchronized(self) {
        if ([self.inviteId isEqualToString:replyItem.inviteId]) {
            // 清空邀请Id
            self.inviteId = nil;
        }
    }
}

- (void)onRecvInstantInviteUserNotice:(NSString *)inviteId anchorId:(NSString *)anchorId nickName:(NSString *)nickName avatarImg:(NSString *)avatarImg msg:(NSString *)msg {
    NSLog(@"LSImManager::onRecvInstantInviteUserNotice( [接收主播立即私密邀请通知], inviteId : %@, userId : %@, userName : %@, msg : %@ )", inviteId, anchorId, nickName, msg);
}

- (void)onRecvScheduledInviteUserNotice:(NSString *)inviteId anchorId:(NSString *)anchorId nickName:(NSString *)nickName avatarImg:(NSString *)avatarImg msg:(NSString *)msg {
    NSLog(@"LSImManager::onRecvScheduledInviteUserNotice( [接收主播预约私密邀请通知], inviteId : %@, userId : %@, userName : %@, msg : %@ )", inviteId, anchorId, nickName, msg);
}

- (void)onRecvSendBookingReplyNotice:(ImBookingReplyObject *)item {
    NSLog(@"LSImManager::onRecvSendBookingReplyNotice( [接收预约私密邀请回复通知] )");
}

- (void)onRecvBookingNotice:(NSString *)roomId userId:(NSString *)userId nickName:(NSString *)nickName avatarImg:(NSString *)avatarImg leftSeconds:(int)leftSeconds {
    NSLog(@"LSImManager::onRecvBookingNotice( [接收预约开始倒数通知] )");
}

- (void)onSendHandleSchedule:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg {
     NSLog(@"LSImManager::onSendHandleSchedule( [7.9.观众通知服务器对预约操作（操作为发送、接受、拒绝预约）] )");
}

- (void)onRecvHandleScheduleNotice:(ImScheduleRoomInfoObject* _Nonnull)item {
     NSLog(@"LSImManager::onRecvHandleScheduleNotice( [接收预约开始倒数通知] )");
}

- (void)onRecvScheduleBeforeStartNotice:(ImScheduleStartInfoObject* _Nonnull)item {
    NSLog(@"LSImManager::onRecvScheduleBeforeStartNotice( [接收预付费即将开始] )");
}

- (void)onRecvScheduleStartNotice:(ImScheduleStartInfoObject* _Nonnull)item {
    NSLog(@"LSImManager::onRecvScheduleStartNotice( [接收预付费开始] )");
}

#pragma mark - 才艺点播
- (BOOL)sendTalent:(NSString *)roomId talentId:(NSString *)talentId {
    NSLog(@"LSImManager::sendTalent( [观众端接收到预约操作通知], roomId : %@ )", roomId);
    BOOL bFlag = NO;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client sendTalent:reqId roomId:roomId talentId:talentId];
            if (bFlag) {
            }
        }
    }
    return bFlag;
}

- (void)onSendTalent:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg talentInviteId:(NSString *)talentInviteId talentId:(NSString *)talentId {
    NSLog(@"LSImManager::onSendTalent( [发送直播间才艺点播邀请, %@], errType : %d, errmsg : %@ talentInviteId:%@ talentId:%@)", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, talentInviteId, talentId);
}

#pragma mark - 才艺点播通知
- (void)onRecvSendTalentNotice:(ImTalentReplyObject *)item {
    NSLog(@"LSImManager::onRecvSendTalentNotice( [接收直播间才艺点播回复通知] )");
}

- (void)onRecvTalentPromptNotice:(NSString *)roomId introduction:(NSString *)introduction {
    NSLog(@"LSImManager::onRecvTalentPromptNotice( [8.3.接收直播间才艺点播提示公告通知] roomId:%@ introduction:%@)", roomId, introduction);
}

#pragma mark - 视频互动
- (BOOL)controlManPush:(NSString *)roomId control:(IMControlType)control finishHandler:(ControlManPushHandler)finishHandler {
    NSLog(@"LSImManager::controlManPush( [发送视频互动], roomId : %@, control : %d )", roomId, control);
    BOOL bFlag = NO;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client controlManPush:reqId roomId:roomId control:control];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }
    return bFlag;
}

//    处理错误码为 LCC_ERR_NO_CREDIT_DOUBLE_VIDEO : 私密直播间开始双向视频时，信用点不足(用于3.14.观众开始/结束视频互动 接口)
- (void)onControlManPush:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg manPushUrl:(NSArray<NSString *> *)manPushUrl {
    NSLog(@"LSImManager::onControlManPush( [发送视频互动, %@], errType : %d, errmsg : %@ manPushUrl.count : %lu )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, (unsigned long)manPushUrl.count);

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        ControlManPushHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, manPushUrl);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

#pragma mark - 消息和礼物
- (BOOL)sendLiveChat:(NSString *)roomId nickName:(NSString *)nickName msg:(NSString *)msg at:(NSArray<NSString *> *)at {
    NSLog(@"LSImManager::sendLiveChat( [发送直播间文本消息], roomId : %@, nickName : %@, msg : %@ )", roomId, nickName, msg);
    BOOL bFlag = NO;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client sendLiveChat:reqId roomId:roomId nickName:nickName msg:msg at:at];
            if (bFlag) {
            }
        }
    }
    return bFlag;
}

- (void)onSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"LSImManager::onSendLiveChat( [发送直播间文本消息, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
}

- (BOOL)sendToast:(NSString *)roomId nickName:(NSString *)nickName msg:(NSString *)msg {
    NSLog(@"LSImManager::sendToast( [发送直播间弹幕消息], roomId : %@, nickName : %@, msg : %@ )", roomId, nickName, msg);
    BOOL bFlag = NO;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client sendToast:reqId roomId:roomId nickName:nickName msg:msg];
            if (bFlag) {
            }
        }
    }
    return bFlag;
}

- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LSImManager::onSendToast( [发送直播间弹幕消息, %@], errmsg : %@, credit : %f, rebateCredit : %f )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errmsg, credit, rebateCredit);
}

- (BOOL)sendGift:(NSString *)roomId nickName:(NSString *)nickName giftId:(NSString *)giftId giftName:(NSString *)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id finishHandler:(SendGiftHandler)finishHandler {
    NSLog(@"LSImManager::sendGift( [发送直播间礼物消息], roomId : %@, nickName : %@, giftId : %@ )", roomId, nickName, giftId);
    BOOL bFlag = NO;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client sendGift:reqId roomId:roomId nickName:nickName giftId:giftId giftName:giftName isBackPack:isBackPack giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }
    return bFlag;
}

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LSImManager::onSendGift( [发送直播间礼物消息], errmsg : %@, credit : %f, rebateCredit : %f )", errmsg, credit, rebateCredit);

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        SendGiftHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, errType, errmsg, credit, rebateCredit);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

#pragma mark - 消息和礼物通知
- (void)onRecvSendChatNotice:(NSString *)roomId level:(int)level fromId:(NSString *)fromId nickName:(NSString *)nickName msg:(NSString *)msg honorUrl:(NSString *)honorUrl avatarImg:(NSString * _Nonnull)avatarImg{
    NSLog(@"LSImManager::onRecvSendChatNotice( [接收直播间文本消息通知], roomId : %@, nickName : %@, msg : %@, honorUrl : %@, photoUrl : %@)", roomId, nickName, msg, honorUrl, avatarImg);
}

- (void)onRecvSendSystemNotice:(NSString *)roomId msg:(NSString *)msg link:(NSString *)link type:(IMSystemType)type {
    NSLog(@"LSImManager::onRecvSendSystemNotice( [接收直播间公告消息], roomId : %@, msg : %@, link: %@, type : %d)", roomId, msg, link, type);
}

- (void)onRecvSendToastNotice:(NSString *)roomId fromId:(NSString *)fromId nickName:(NSString *)nickName msg:(NSString *)msg honorUrl:(NSString *)honorUrl  avatarImg:(NSString* _Nonnull)avatarImg {
    NSLog(@"LSImManager::onRecvSendToastNotice( [接收直播间弹幕通知], roomId : %@, fromId : %@, nickName : %@, msg : %@, honorUrl:%@, avatarImg:%@)", roomId, fromId, nickName, msg, honorUrl, avatarImg);
}

- (void)onRecvSendGiftNotice:(NSString *)roomId fromId:(NSString *)fromId nickName:(NSString *)nickName giftId:(NSString *)giftId giftName:(NSString *)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(NSString *)honorUrl photoUrl:(NSString * _Nonnull)photoUrl{
    NSLog(@"LSImManager::onRecvSendGiftNotice( [接收直播间礼物通知], roomId : %@, fromId : %@, nickName : %@, honorUrl : %@, photoUrl : %@)", roomId, fromId, nickName, honorUrl, photoUrl);
}

#pragma mark - 公共
- (void)onRecvLevelUpNotice:(int)level {
    NSLog(@"LSImManager::onRecvLevelUpNotice( [接收观众等级升级通知], level : %d )", level);
    // 更新本地用户等级
    self.loginManager.loginItem.level = level;
}

- (void)onRecvLoveLevelUpNotice:(IMLoveLevelItemObject *)loveLevelItem {
    NSLog(@"LSImManager::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知], loveLevel : %d, anchorId: %@, anchorName: %@ )", loveLevelItem.loveLevel, loveLevelItem.anchorId, loveLevelItem.anchorName);
}

- (void)onRecvBackpackUpdateNotice:(BackpackInfoObject *)item {
    NSLog(@"LSImManager::onRecvBackpackUpdateNotice( [接收背包更新通知] )");
}

- (void)onRecvGetHonorNotice:(NSString *)honorId honorUrl:(NSString *)honorUrl {
    NSLog(@"LSImManager::onRecvGetHonorNotice( [观众勋章升级通知] )");
}

#pragma mark - 多人互动
- (BOOL)enterHangoutRoom:(NSString *)roomId isCreateOnly:(BOOL)isCreateOnly finishHandler:(EnterHangoutRoomHandler)finishHandler {
    NSLog(@"LSImManager::enterHangoutRoom( [发送多人互动, 进入直播间], roomId : %@, isCreateOnly : %@ )", roomId, BOOL2YES(isCreateOnly));
    BOOL bFlag = NO;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client enterHangoutRoom:reqId roomId:roomId isCreateOnly:isCreateOnly];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }
    return bFlag;
}

- (void)onEnterHangoutRoom:(SEQ_T)reqId succes:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg item:(IMHangoutRoomItemObject *)item {
    NSLog(@"LSImManager::onEnterHangoutRoom( [发送多人互动, 进入直播间, %@], errMsg : %@, roomId : %@ )", BOOL2SUCCESS(err == LCC_ERR_SUCCESS), errMsg, item.roomId);
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        EnterHangoutRoomHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, item);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)leaveHangoutRoom:(NSString *)roomId finishHandler:(LeaveHangoutRoomHandler)finishHandler {
    NSLog(@"LSImManager::leaveHangoutRoom( [发送多人互动, 退出直播间], roomId : %@ )", roomId);
    BOOL bFlag = NO;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client leaveHangoutRoom:reqId roomId:roomId];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }
    
    // 修改全局直播间
    [LiveGobalManager manager].liveRoom = nil;
    
    return bFlag;
}

- (void)onLeaveHangoutRoom:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg {
    NSLog(@"LSImManager::onLeaveHangoutRoom( [发送多人互动, 退出直播间, %@], errMsg : %@ )", BOOL2SUCCESS(err == LCC_ERR_SUCCESS), errMsg);
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        LeaveHangoutRoomHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)sendHangoutGift:(NSString *)roomId nickName:(NSString *)nickName toUid:(NSString *)toUid giftId:(NSString *)giftId giftName:(NSString *)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum isMultiClick:(BOOL)isMultiClick multiClickStart:(int)multiClickStart multiClickEnd:(int)multiClickEnd multiClickId:(int)multiClickId isPrivate:(BOOL)isPrivate finishHandler:(SendHangoutGiftHandler)finishHandler {
    NSLog(@"LSImManager::sendHangoutGift( [发送多人互动, 直播间礼物消息], roomId : %@, nickName : %@, giftId : %@ )", roomId, nickName, giftId);
    BOOL bFlag = NO;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client sendHangoutGift:reqId roomId:roomId nickName:nickName toUid:toUid giftId:giftId giftName:giftName isBackPack:isBackPack giftNum:giftNum isMultiClick:isMultiClick multiClickStart:multiClickStart multiClickEnd:multiClickEnd multiClickId:multiClickId isPrivate:isPrivate];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }
    return bFlag;
}

- (void)onSendHangoutGift:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg credit:(double)credit {
    NSLog(@"LSImManager::onSendHangoutGift( [发送多人互动, 直播间礼物消息, %@], errMsg : %@ credit : %f )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errMsg, credit);
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        SendHangoutGiftHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, credit);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)controlManPushHangout:(NSString *)roomId control:(IMControlType)control finishHandler:(ControlManPushHangoutHandler)finishHandler {
    NSLog(@"LSImManager::controlManPushHangout( [发送多人互动, 观众开始/结束视频互动], roomId : %@, control : %d )", roomId, control);
    BOOL bFlag = NO;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client controlManPushHangout:reqId roomId:roomId control:control];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }
    return bFlag;
}

//    处理错误码为 LCC_ERR_NO_CREDIT_HANGOUT_DOUBLE_VIDEO : Hangout直播间开始双向视频时，信用点不足(用于10.11.多人互动观众开始/结束视频互动 接口)
- (void)onControlManPushHangout:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg manPushUrl:(NSArray<NSString *> *)manPushUrl {
    NSLog(@"LSImManager::onControlManPushHangout( [发送多人互动, 观众开始/结束视频互动, %@], errType : %d, errmsg : %@ manPushUrl.count : %lu )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, (unsigned long)manPushUrl.count);

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        ControlManPushHangoutHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, manPushUrl);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)sendHangoutLiveChat:(NSString *)roomId nickName:(NSString *)nickName msg:(NSString *)msg at:(NSArray<NSString *> *)at {
    NSLog(@"LSImManager::sendHangoutLiveChat( [发送多人互动, 直播间文本消息], roomId : %@, nickName : %@, msg : %@ )", roomId, nickName, msg);
    BOOL bFlag = NO;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            [self.client SendHangoutLiveChat:reqId roomId:roomId nickName:nickName msg:msg at:at];
            if (bFlag) {
            }
        }
    }
    return bFlag;
}

- (void)onSendHangoutLiveChat:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *)errMsg {
    NSLog(@"LSImManager::onSendHangoutLiveChat( [发送多人互动, 直播间文本消息, %@], errType : %d, errmsg : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);
}

#pragma mark - 多人互动通知
- (void)onRecvRecommendHangoutNotice:(IMRecommendHangoutItemObject *)item {
    NSLog(@"LSImManager::onRecvRecommendHangoutNotice( [接收多人互动, 主播推荐好友通知], roomId : %@, anchorId : %@, nickName : %@, friendId : %@, friendNickName : %@ )", item.roomId, item.anchorId, item.nickName, item.friendId, item.friendNickName);
    [self handleRecommendHangoutFriend:item];
}

- (void)onRecvDealInviteHangoutNotice:(IMRecvDealInviteItemObject *)item {
    NSLog(@"LSImManager::onRecvDealInviteHangoutNotice( [接收多人互动, 主播回复观众邀请通知], roomId : %@, anchorId : %@, nickName : %@, inviteId : %@ )", item.roomId, item.anchorId, item.nickName, item.inviteId);
}

- (void)onRecvEnterHangoutRoomNotice:(IMRecvEnterRoomItemObject *)item {
    NSLog(@"LSImManager::onRecvEnterHangoutRoomNotice( [接收多人互动, %@进入直播间通知], roomId : %@, userId : %@, nickName : %@ )", item.isAnchor ? @"主播" : @"观众", item.roomId, item.userId, item.nickName);
}

- (void)onRecvLeaveHangoutRoomNotice:(IMRecvLeaveRoomItemObject *)item {
    NSLog(@"LSImManager::onRecvLeaveHangoutRoomNotice( [接收多人互动, %@退出直播间通知, roomId : %@, userId : %@, nickName : %@ )", item.isAnchor ? @"主播" : @"观众", item.roomId, item.userId, item.nickName);
}

- (void)onRecvKnockRequestNotice:(IMKnockRequestItemObject *)item {
    NSLog(@"LSImManager::onRecvKnockRequestNotice( [接收多人互动, 主播敲门通知], roomId : %@, anchorId : %@, nickName : %@ )", item.roomId, item.anchorId, item.nickName);
    [self handleKnockRequest:item];
}

- (void)onRecvLackCreditHangoutNotice:(IMLackCreditHangoutItemObject *)item {
    NSLog(@"LSImManager::onRecvLackCreditHangoutNotice( [接收多人互动, 余额不足导致主播将要离开的通知], roomId : %@, anchorId : %@, nickName : %@ )", item.roomId, item.anchorId, item.nickName);
}

- (void)onRecvHangoutGiftNotice:(IMRecvHangoutGiftItemObject * )item {
    NSLog(@"LSImManager::onRecvHangoutGiftNotice( [接收多人互动, 直播间礼物通知], roomId : %@, fromId : %@, toUid : %@, giftId : %@ )", item.roomId, item.fromId, item.toUid, item.giftId);
}

- (void)onRecvHangoutChatNotice:(IMRecvHangoutChatItemObject * )item {
    NSLog(@"LSImManager::onRecvHangoutChatNotice( [接收多人互动, 直播间文本消息通知], roomId : %@, level : %d, fromId : %@, nickName : %@, msg : %@, honorUrl : %@ )", item.roomId, item.level, item.fromId, item.nickName, item.msg, item.honorUrl);
}

- (void)onRecvAnchorCountDownEnterHangoutRoomNotice:(NSString * )roomId anchorId:(NSString * )anchorId leftSecond:(int)leftSecond {
    NSLog(@"LSImManager::onRecvAnchorCountDownEnterHangoutRoomNotice( [接收进入多人互动, 直播间倒数通知], roomId : %@, anchorId : %@, leftSecond : %d)", roomId, anchorId, leftSecond);
    [self handleEnterHangoutCountDown:roomId anchorId:anchorId leftSecond:leftSecond];
}

- (void)onRecvHandoutInviteNotice:(IMHangoutInviteItemObject * _Nonnull)item {
    NSLog(@"LSImManager::onRecvHandoutInviteNotice( 接收主播Hang-out邀请通知)");
    
    @synchronized (self.delegates) {
        for (NSValue *value in self.delegates) {
            id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvHandoutInviteNotice:)]) {
                [delegate onRecvHandoutInviteNotice:item];
            }
        }
    }
}

- (void)onRecvHangoutCreditRunningOutNotice:(NSString * _Nonnull)roomId err:(LCC_ERR_TYPE)err errMsg:(NSString * _Nonnull)errMsg {
    NSLog(@"LSImManager::onRecvHangoutCreditRunningOutNotice( 接收Hangout直播间男士信用点不足两个周期通知) roomId : %@, err : %d, errMsg : %@", roomId, err, errMsg);
}

#pragma mark - 节目通知
- (void)onRecvProgramPlayNotice:(IMProgramItemObject *)item type:(IMProgramNoticeType)type msg:(NSString * )msg {
    NSLog(@"LSImManager::onRecvProgramPlayNotice( [接收节目, 开播通知], showLiveId : %@, anchorId : %@, nickName : %@, type : %d )", item.showLiveId, item.anchorId, item.anchorNickName, type);
}

- (void)onRecvCancelProgramNotice:(IMProgramItemObject *)item {
    NSLog(@"LSImManager::onRecvCancelProgramNotice( [接收节目, 已取消通知], showLiveId : %@, anchorId : %@, nickName : %@ )", item.showLiveId, item.anchorId, item.anchorNickName);
}

- (void)onRecvRetTicketNotice:(IMProgramItemObject *)item leftCredit:(double)leftCredit {
    NSLog(@"LSImManager::onRecvRetTicketNotice( [接收节目, 已退票通知], showLiveId : %@, anchorId : %@, nickName : %@, leftCredit : %f )", item.showLiveId, item.anchorId, item.anchorNickName, leftCredit);
}

#pragma mark - 信件
- (void)onRecvLoiNotice:(NSString * )anchorId loiId:(NSString * )loiId {
    NSLog(@"LSImManager::onRecvLoiNotice( [13.1.接收意向信通知], anchorId : %@, loiId : %@)", anchorId, loiId);
}

- (void)onRecvEMFNotice:(NSString * )anchorId emfId:(NSString * )emfId {
    NSLog(@"LSImManager::onRecvEMFNotice( [13.2.接收EMF通知], anchorId : %@, emfId : %@)", anchorId, emfId);
}

@end
