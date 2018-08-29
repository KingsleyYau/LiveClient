//
//  LSImManager.m
//  livestream
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSImManager.h"

#import "LSConfigManager.h"
#import "LSLoginManager.h"
#import "UserInfoManager.h"
#import "LSSessionRequestManager.h"
#import "LiveFansListRequest.h"

@interface LSImManager () <IMLiveRoomManagerDelegate, LoginManagerDelegate>
@property (nonatomic, strong) NSMutableArray *delegates;
// Http登陆管理器
@property (nonatomic, strong) LSLoginManager *loginManager;
// Http接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 是否第一次IM登陆
@property (nonatomic, assign) BOOL isFirstLogin;
// 是否已经登陆
@property (nonatomic, assign) BOOL isIMLogin;
// 是否被踢
@property (nonatomic, assign) BOOL isKick;
// 请求字典
@property (nonatomic, strong) NSMutableDictionary *requestDictionary;
// 上次发送返回的邀请
@property (nonatomic, strong) NSString *inviteId;

@end

static LSImManager *gManager = nil;
@implementation LSImManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
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

        self.requestDictionary = [NSMutableDictionary dictionary];
        self.isIMLogin = NO;
        self.isFirstLogin = YES;
        self.isKick = NO;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"LSImManager::dealloc()");

    [self.client removeDelegate:self];
    [self.loginManager removeDelegate:self];
}

- (BOOL)addDelegate:(id<IMManagerDelegate> _Nonnull)delegate {
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

- (BOOL)removeDelegate:(id<IMManagerDelegate> _Nonnull)delegate {
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
- (void)manager:(LSLoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *_Nullable)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *_Nonnull)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            // 获取同步配置的IM服务器地址
            [[LSConfigManager manager] synConfig:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, ConfigItemObject *_Nullable item) {
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

- (void)manager:(LSLoginManager * _Nonnull)manager onLogout:(LogoutType)type msg:(NSString * _Nullable)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 注销IM
        NSLog(@"LSImManager::onLogout( [Http注销通知], type : %d )", type);
        [self logout];
    });
}

#pragma mark - IM登陆回调
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg item:(ImLoginReturnObject *_Nonnull)item {
    NSLog(@"LSImManager::onLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);

    if (errType == LCC_ERR_SUCCESS) {
        // IM登陆成功
        @synchronized(self) {

            // IM登录成功,同步用户本地Level
            [[UserInfoManager manager] getLiverInfo:self.loginManager.loginItem.userId
                                      finishHandler:^(LSUserInfoModel *_Nonnull item){

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
                [self getInviteInfo:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, ImInviteIdItemObject *_Nonnull Item) {
                    if (success) {
                        // 成功获取到邀请状态
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (NSValue *value in self.delegates) {
                                id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
                                if ([delegate respondsToSelector:@selector(onRecvInviteReply:)]) {
                                    [delegate onRecvInviteReply:Item];
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
            if (self.loginManager.status == LOGINED) {
                [self login];
            }
        });
    }
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
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
                [self.loginManager logout:LogoutTypeKick msg:NSLocalizedString(@"ACCOUNT_HAS_LOAD", @"ACCOUNT_HAS_LOAD")];
            });
        }
    }
}

- (void)onKickOff:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
    NSLog(@"LSImManager::onKickOff( [用户被挤掉线, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    @synchronized(self) {
        self.isKick = YES;
    }
}

#pragma mark - 首次登陆处理
- (BOOL)handleLoginRoomList:(NSArray<ImLoginRoomObject *> *)roomList {
    BOOL bFlag = NO;

    if (roomList.count > 0) {
        ImLoginRoomObject *roomObj = [roomList objectAtIndex:0];
        if (roomObj.roomId.length > 0) {
            bFlag = YES;

            for (NSValue *value in self.delegates) {
                id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(onHandleLoginRoom:userId:userName:)]) {
                    [delegate onHandleLoginRoom:roomObj.roomId userId:roomObj.anchorId userName:roomObj.nickName];
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

- (BOOL)handleLoginScheduleRoomList:(NSArray<ImScheduleRoomObject *> *)scheduleRoomList {
    BOOL bFlag = YES;

    for (NSValue *value in self.delegates) {
        id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(onHandleLoginSchedule:)]) {
            [delegate onHandleLoginSchedule:scheduleRoomList];
        }
    }

    return bFlag;
}

- (BOOL)handleLoginOnGingShowList:(NSArray<IMOngoingShowItemObject *> *)ongoingShowList {
    BOOL bFlag = YES;

    for (NSValue *value in self.delegates) {
        id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(onHandleLoginOnGingShowList:)]) {
            [delegate onHandleLoginOnGingShowList:ongoingShowList];
        }
    }

    return bFlag;
}

- (BOOL)handleRecommendHangoutFriend:(IMRecommendHangoutItemObject *)firendItem {
    BOOL bFlag = YES;
    
    for (NSValue *value in self.delegates) {
        id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(onHandleRecommendHangoutFriend:)]) {
            [delegate onHandleRecommendHangoutFriend:firendItem];
        }
    }
    
    return bFlag;
}

- (BOOL)handleKnockRequest:(IMKnockRequestItemObject *)knockItem {
    BOOL bFlag = YES;
    
    for (NSValue *value in self.delegates) {
        id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(onHandleKnockRequest:)]) {
            [delegate onHandleKnockRequest:knockItem];
        }
    }
    
    return bFlag;
}

- (BOOL)handleEnterHangoutCountDown:(NSString* _Nonnull)roomId anchorId:(NSString* _Nonnull)anchorId leftSecond:(int)leftSecond {
    BOOL bFlag = YES;
    
    for (NSValue *value in self.delegates) {
        id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(onHandleEnterHangoutCountDown:anchorId:leftSecond:)]) {
            [delegate onHandleEnterHangoutCountDown:roomId anchorId:anchorId leftSecond:leftSecond];
        }
    }
    
    return bFlag;
}



#pragma mark - 直播间状态
- (BOOL)enterRoom:(NSString *_Nonnull)roomId finishHandler:(EnterRoomHandler _Nullable)finishHandler {
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

- (void)onRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg item:(ImLiveRoomObject *_Nonnull)item {
    NSLog(@"LSImManager::onRoomIn( [发送观众进入直播间, %@], reqId : %u, errType : %d, errmsg : %@ isHasTalent:%d)", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", reqId, errType, errmsg, item.isHasTalent);

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        EnterRoomHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, errType, errmsg, item);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)leaveRoom:(NSString *)roomId {
    NSLog(@"LSImManager::leaveRoom( [发送观众退出直播间], roomId : %@ )", roomId);
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
    NSLog(@"LSImManager::onRoomOut( [发送观众退出直播间, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
}

#pragma mark - 直播间状态通知
- (BOOL)enterPublicRoom:(NSString *_Nonnull)userId finishHandler:(EnterPublicRoomHandler _Nullable)finishHandler {
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

- (void)onPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg item:(ImLiveRoomObject *_Nonnull)item {
    NSLog(@"LSImManager::onPublicRoomIn( [发送观众进入公开直播间, %@], errType : %d, errmsg : %@, reqId : %u )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, reqId);

    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        EnterRoomHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, item);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (void)onRecvRoomCloseNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
    NSLog(@"LSImManager::onRecvRoomCloseNotice( [接收直播间关闭通知], roomId : %@, errType : %d, errMsg : %@ )", roomId, errType, errmsg);
}

- (void)onRecvEnterRoomNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName photoUrl:(NSString *_Nonnull)photoUrl riderId:(NSString *_Nonnull)riderId riderName:(NSString *_Nonnull)riderName riderUrl:(NSString *_Nonnull)riderUrl fansNum:(int)fansNum honorImg:(NSString *_Nonnull)honorImg isHasTicket:(BOOL)isHasTicket {
    NSLog(@"LSImManager::onRecvEnterRoomNotice( [接收观众进入直播间通知], roomId : %@, userId : %@, nickName : %@ )", roomId, userId, nickName);
}

- (void)onRecvLeaveRoomNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName photoUrl:(NSString *_Nonnull)photoUrl fansNum:(int)fansNum {
    NSLog(@"LSImManager::onRecvLeaveRoomNotice( [接收观众退出直播间通知], roomId : %@, userId : %@, nickName : %@ )", roomId, userId, nickName);
}

- (void)onRecvRebateInfoNotice:(NSString *_Nonnull)roomId rebateInfo:(RebateInfoObject *_Nonnull)rebateInfo {
    NSLog(@"LSImManager::onRecvRebateInfoNotice( [接收返点通知] )");
}

- (void)onRecvLeavingPublicRoomNotice:(NSString *_Nonnull)roomId leftSeconds:(int)leftSeconds err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg {
    NSLog(@"LSImManager::onRecvLeavingPublicRoomNotice( [接收关闭直播间倒数通知] )");
}

- (void)onRecvRoomKickoffNotice:(NSString *_Nonnull)roomId errType:(LCC_ERR_TYPE)errType errmsg:(NSString *_Nonnull)errmsg credit:(double)credit {
    NSLog(@"LSImManager::onRecvRoomKickoffNotice( [接收踢出直播间通知], roomId : %@ )", roomId);
}

- (void)onRecvCreditNotice:(NSString *_Nonnull)roomId credit:(double)credit {
    NSLog(@"LSImManager::onRecvCreditNotice( [接收定时扣费通知] )");
}

- (void)onRecvWaitStartOverNotice:(ImStartOverRoomObject *_Nonnull)item {
    NSLog(@"LSImManager::onRecvWaitStartOverNotice( [接收主播进入直播间通知], roomId : %@ )", item.roomId);
}

- (void)onRecvChangeVideoUrl:(NSString *_Nonnull)roomId isAnchor:(BOOL)isAnchor playUrl:(NSArray<NSString *> *_Nonnull)playUrl userId:(NSString *_Nonnull)userId {
    NSLog(@"LSImManager::onRecvChangeVideoUrl( [接收观众／主播切换视频流通知], roomId : %@, playUrl : %@, userId : %@ )", roomId, playUrl, userId);
}

#pragma mark - 私密直播间
- (BOOL)invitePrivateLive:(NSString *_Nonnull)userId logId:(NSString *_Nonnull)logId force:(BOOL)force finishHandler:(InviteHandler _Nullable)finishHandler {
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

- (void)onSendPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg invitationId:(NSString *_Nonnull)invitationId timeOut:(int)timeOut roomId:(NSString *_Nonnull)roomId {
    NSLog(@"LSImManager::onSendPrivateLiveInvite( [发送私密邀请, %@], err : %d, errMsg : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);

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

- (void)onSendCancelPrivateLiveInvite:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg roomId:(NSString *_Nonnull)roomId {
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

- (BOOL)InstantInviteUserReport:(NSString *_Nonnull)inviteId isShow:(BOOL)isShow finishHandler:(InstantInviteUserReportHandler _Nullable)finishHandler {
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
                // 清空邀请Id
                self.inviteId = nil;
            }
        }
    }

    return bFlag;
}

- (void)onSendInstantInviteUserReport:(BOOL)success reqId:(SEQ_T)reqId err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg {
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

- (BOOL)getInviteInfo:(GetIMInviteInfoHandler _Nullable)finishHandler {

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

- (void)onGetInviteInfo:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg item:(ImInviteIdItemObject *_Nonnull)item {
    NSLog(@"LSImManager::onGetInviteInfo( [获取指定立即私密邀请信息, %@], errType : %d, errmsg : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        GetIMInviteInfoHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, item);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

#pragma mark - 私密直播间通知
- (void)onRecvInstantInviteReplyNotice:(NSString *_Nonnull)inviteId replyType:(ReplyType)replyType roomId:(NSString *_Nonnull)roomId roomType:(RoomType)roomType anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    NSLog(@"LSImManager::onRecvInstantInviteReplyNotice( [接收立即私密邀请回复通知], roomId : %@, inviteId : %@, msg : %@ )", roomId, inviteId, msg);

    @synchronized(self) {
        if ([self.inviteId isEqualToString:inviteId]) {
            // 清空邀请Id
            self.inviteId = nil;
        }
    }
}

- (void)onRecvInstantInviteUserNotice:(NSString *_Nonnull)inviteId anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    NSLog(@"LSImManager::onRecvInstantInviteUserNotice( [接收主播立即私密邀请通知], inviteId : %@, userId : %@, userName : %@, msg : %@ )", inviteId, anchorId, nickName, msg);
}

- (void)onRecvScheduledInviteUserNotice:(NSString *_Nonnull)inviteId anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    NSLog(@"LSImManager::onRecvScheduledInviteUserNotice( [接收主播预约私密邀请通知], inviteId : %@, userId : %@, userName : %@, msg : %@ )", inviteId, anchorId, nickName, msg);
}

- (void)onRecvSendBookingReplyNotice:(ImBookingReplyObject *_Nonnull)item {
    NSLog(@"LSImManager::onRecvSendBookingReplyNotice( [接收预约私密邀请回复通知] )");
}

- (void)onRecvBookingNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg leftSeconds:(int)leftSeconds {
    NSLog(@"LSImManager::onRecvBookingNotice( [接收预约开始倒数通知] )");
}

#pragma mark - 才艺点播
- (BOOL)sendTalent:(NSString *_Nonnull)roomId talentId:(NSString *_Nonnull)talentId {
    NSLog(@"LSImManager::sendTalent( [发送直播间才艺点播邀请], roomId : %@ )", roomId);
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

- (void)onSendTalent:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg talentInviteId:(NSString *_Nonnull)talentInviteId talentId:(NSString * _Nonnull)talentId{
    NSLog(@"LSImManager::onSendTalent( [发送直播间才艺点播邀请, %@], errType : %d, errmsg : %@ talentInviteId:%@ talentId:%@)", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, talentInviteId, talentId);

}

#pragma mark - 才艺点播通知
- (void)onRecvSendTalentNotice:(ImTalentReplyObject *_Nonnull)item {
    NSLog(@"LSImManager::onRecvSendTalentNotice( [接收直播间才艺点播回复通知] )");

}

- (void)onRecvTalentPromptNotice:(NSString* _Nonnull)roomId introduction:(NSString* _Nonnull)introduction {
    NSLog(@"LSImManager::onRecvTalentPromptNotice( [8.3.接收直播间才艺点播提示公告通知] roomId:%@ introduction:%@)", roomId, introduction);
}

#pragma mark - 视频互动
- (BOOL)controlManPush:(NSString *_Nonnull)roomId control:(IMControlType)control finishHandler:(ControlManPushHandler)finishHandler {
    NSLog(@"LSImManager::sendTalent( [发送视频互动], roomId : %@, control : %d )", roomId, control);
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

- (void)onControlManPush:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg manPushUrl:(NSArray<NSString *> *_Nonnull)manPushUrl {
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
- (BOOL)sendLiveChat:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at {
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

- (void)onSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg {
    NSLog(@"LSImManager::onSendLiveChat( [发送直播间文本消息, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
}

- (BOOL)sendToast:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg {
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

- (void)onSendToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    NSLog(@"LSImManager::onSendToast( [发送直播间弹幕消息, %@], errmsg : %@, credit : %f, rebateCredit : %f )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errmsg, credit, rebateCredit);
}

- (BOOL)sendGift:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName giftId:(NSString *_Nonnull)giftId giftName:(NSString *_Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id finishHandler:(SendGiftHandler _Nullable)finishHandler {
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

- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
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
- (void)onRecvSendChatNotice:(NSString *_Nonnull)roomId level:(int)level fromId:(NSString *_Nonnull)fromId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg honorUrl:(NSString *_Nonnull)honorUrl {
    NSLog(@"LSImManager::onRecvSendChatNotice( [接收直播间文本消息通知], roomId : %@, nickName : %@, msg : %@, honorUrl : %@ )", roomId, nickName, msg, honorUrl);
}

- (void)onRecvSendSystemNotice:(NSString *_Nonnull)roomId msg:(NSString *_Nonnull)msg link:(NSString *_Nonnull)link type:(IMSystemType)type {
    NSLog(@"LSImManager::onRecvSendSystemNotice( [接收直播间公告消息], roomId : %@, msg : %@, link: %@, type : %d)", roomId, msg, link, type);
}

- (void)onRecvSendToastNotice:(NSString *_Nonnull)roomId fromId:(NSString *_Nonnull)fromId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg honorUrl:(NSString *_Nonnull)honorUrl {
    NSLog(@"LSImManager::onRecvSendToastNotice( [接收直播间弹幕通知], roomId : %@, fromId : %@, nickName : %@, msg : %@, honorUrl:%@)", roomId, fromId, nickName, msg, honorUrl);
}

- (void)onRecvSendGiftNotice:(NSString *_Nonnull)roomId fromId:(NSString *_Nonnull)fromId nickName:(NSString *_Nonnull)nickName giftId:(NSString *_Nonnull)giftId giftName:(NSString *_Nonnull)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(NSString *_Nonnull)honorUrl {
    NSLog(@"LSImManager::onRecvSendGiftNotice( [接收直播间礼物通知], roomId : %@, fromId : %@, nickName : %@, honorUrl : %@)", roomId, fromId, nickName, honorUrl);
}

#pragma mark - 公共
- (void)onRecvLevelUpNotice:(int)level {
    NSLog(@"LSImManager::onRecvLevelUpNotice( [接收观众等级升级通知], level : %d )", level);
    // 更新本地用户等级
    self.loginManager.loginItem.level = level;
}

- (void)onRecvLoveLevelUpNotice:(IMLoveLevelItemObject *  _Nonnull)loveLevelItem {
    NSLog(@"LSImManager::onRecvLoveLevelUpNotice( [接收观众亲密度升级通知], loveLevel : %d, anchorId: %@, anchorName: %@ )", loveLevelItem.loveLevel, loveLevelItem.anchorId, loveLevelItem.anchorName);
}

- (void)onRecvBackpackUpdateNotice:(BackpackInfoObject *_Nonnull)item {
    NSLog(@"LSImManager::onRecvBackpackUpdateNotice( [接收背包更新通知] )");
}

- (void)onRecvGetHonorNotice:(NSString *_Nonnull)honorId honorUrl:(NSString *_Nonnull)honorUrl {
    NSLog(@"LSImManager::onRecvGetHonorNotice( [观众勋章升级通知] )");
}

#pragma mark - 多人互动
- (BOOL)enterHangoutRoom:(NSString *_Nonnull)roomId finishHandler:(EnterHangoutRoomHandler _Nullable)finishHandler {
    NSLog(@"LSImManager::enterHangoutRoom( [发送多人互动, 进入直播间], roomId : %@ )", roomId);
    BOOL bFlag = NO;

    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client enterHangoutRoom:reqId roomId:roomId];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }
    return bFlag;
}

- (void)onEnterHangoutRoom:(SEQ_T)reqId succes:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg item:(IMHangoutRoomItemObject *_Nonnull)item {
    NSLog(@"LSImManager::onEnterHangoutRoom( [发送多人互动, 进入直播间, %@], errMsg : %@, roomId : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errMsg, item.roomId);
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        EnterHangoutRoomHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, item);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)leaveHangoutRoom:(NSString *_Nonnull)roomId finishHandler:(LeaveHangoutRoomHandler _Nullable)finishHandler {
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
    return bFlag;
}

- (void)onLeaveHangoutRoom:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg {
    NSLog(@"LSImManager::onLeaveHangoutRoom( [发送多人互动, 退出直播间, %@], errMsg : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errMsg);
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        LeaveHangoutRoomHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (BOOL)sendHangoutGift:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName toUid:(NSString *_Nonnull)toUid giftId:(NSString *_Nonnull)giftId giftName:(NSString *_Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum isMultiClick:(BOOL)isMultiClick multiClickStart:(int)multiClickStart multiClickEnd:(int)multiClickEnd multiClickId:(int)multiClickId isPrivate:(BOOL)isPrivate finishHandler:(SendHangoutGiftHandler _Nullable)finishHandler {
    NSLog(@"LSImManager::sendGift( [发送多人互动, 直播间礼物消息], roomId : %@, nickName : %@, giftId : %@ )", roomId, nickName, giftId);
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

- (void)onSendHangoutGift:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(NSString *_Nonnull)errMsg credit:(double)credit{
    NSLog(@"LSImManager::onSendHangoutGift( [发送多人互动, 直播间礼物消息, %@], errMsg : %@ credit:%f)", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errMsg, credit);
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        SendHangoutGiftHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, credit);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}


-(BOOL)controlManPushHangout:(NSString *_Nonnull)roomId control:(IMControlType)control finishHandler:(ControlManPushHangoutHandler _Nullable )finishHandler {
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

- (void)onControlManPushHangout:(SEQ_T)reqId success:(bool)success err:(LCC_ERR_TYPE)err errMsg:(NSString * _Nonnull)errMsg manPushUrl:(NSArray<NSString*>* _Nonnull)manPushUrl {
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

- (BOOL)sendHangoutLiveChat:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at {
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

- (void)onSendHangoutLiveChat:(SEQ_T)reqId success:(BOOL)success err:(LCC_ERR_TYPE)err errMsg:(NSString * _Nonnull)errMsg {
    NSLog(@"LSImManager::onSendHangoutLiveChat( [发送多人互动, 直播间文本消息, %@], errType : %d, errmsg : %@ )", (err == LCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);
}

#pragma mark - 多人互动通知
- (void)onRecvRecommendHangoutNotice:(IMRecommendHangoutItemObject *_Nonnull)item {
    NSLog(@"LSImManager::onRecvRecommendHangoutNotice( [接收多人互动, 主播推荐好友通知], roomId : %@, anchorId : %@, nickName : %@, friendId : %@, friendNickName : %@ )", item.roomId, item.anchorId, item.nickName, item.friendId, item.friendNickName);
    [self handleRecommendHangoutFriend:item];
}

- (void)onRecvDealInviteHangoutNotice:(IMRecvDealInviteItemObject *_Nonnull)item {
    NSLog(@"LSImManager::onRecvDealInviteHangoutNotice( [接收多人互动, 主播回复观众邀请通知], roomId : %@, anchorId : %@, nickName : %@, inviteId : %@ )", item.roomId, item.anchorId, item.nickName, item.inviteId);
}

- (void)onRecvEnterHangoutRoomNotice:(IMRecvEnterRoomItemObject *_Nonnull)item {
    NSLog(@"LSImManager::onRecvEnterHangoutRoomNotice( [接收多人互动, %@进入直播间通知], roomId : %@, userId : %@, nickName : %@ )", item.isAnchor?@"主播":@"观众", item.roomId, item.userId, item.nickName);
}

- (void)onRecvLeaveHangoutRoomNotice:(IMRecvLeaveRoomItemObject *_Nonnull)item {
    NSLog(@"LSImManager::onRecvLeaveHangoutRoomNotice( [接收多人互动, %@退出直播间通知, roomId : %@, userId : %@, nickName : %@ )", item.isAnchor?@"主播":@"观众", item.roomId, item.userId, item.nickName);
}

- (void)onRecvKnockRequestNotice:(IMKnockRequestItemObject * _Nonnull)item {
    NSLog(@"LSImManager::onRecvKnockRequestNotice( [接收多人互动, 主播敲门通知], roomId : %@, anchorId : %@, nickName : %@ )", item.roomId, item.anchorId, item.nickName);
    [self handleKnockRequest:item];
}

- (void)onRecvLackCreditHangoutNotice:(IMLackCreditHangoutItemObject * _Nonnull)item {
    NSLog(@"LSImManager::onRecvLackCreditHangoutNotice( [接收多人互动, 余额不足导致主播将要离开的通知], roomId : %@, anchorId : %@, nickName : %@ )", item.roomId, item.anchorId, item.nickName);
}

- (void)onRecvHangoutGiftNotice:(IMRecvHangoutGiftItemObject * _Nonnull)item {
    NSLog(@"LSImManager::onRecvHangoutGiftNotice( [接收多人互动, 直播间礼物通知], roomId : %@, fromId : %@, toUid : %@, giftId : %@ )", item.roomId, item.fromId, item.toUid, item.giftId);
}

- (void)onRecvHangoutChatNotice:(IMRecvHangoutChatItemObject * _Nonnull)item {
    NSLog(@"LSImManager::onRecvHangoutChatNotice( [接收多人互动, 直播间文本消息通知], roomId : %@, level : %d, fromId : %@, nickName : %@, msg : %@, honorUrl : %@ )", item.roomId, item.level, item.fromId, item.nickName, item.msg, item.honorUrl);
}

- (void)onRecvAnchorCountDownEnterHangoutRoomNotice:(NSString * _Nonnull)roomId anchorId:(NSString * _Nonnull)anchorId leftSecond:(int)leftSecond {
    NSLog(@"LSImManager::onRecvAnchorCountDownEnterHangoutRoomNotice( [接收进入多人互动, 直播间倒数通知], roomId : %@, anchorId : %@, leftSecond : %d)", roomId, anchorId, leftSecond);
    [self handleEnterHangoutCountDown:roomId anchorId:anchorId leftSecond:leftSecond];
}

#pragma mark - 节目通知
- (void)onRecvProgramPlayNotice:(IMProgramItemObject *_Nonnull)item type:(IMProgramNoticeType)type msg:(NSString * _Nonnull)msg {
    NSLog(@"LSImManager::onRecvProgramPlayNotice( [接收节目, 开播通知], showLiveId : %@, anchorId : %@, nickName : %@, type : %d )", item.showLiveId, item.anchorId, item.anchorNickName, type);
}

- (void)onRecvCancelProgramNotice:(IMProgramItemObject *_Nonnull)item {
    NSLog(@"LSImManager::onRecvCancelProgramNotice( [接收节目, 已取消通知], showLiveId : %@, anchorId : %@, nickName : %@ )", item.showLiveId, item.anchorId, item.anchorNickName);
}

- (void)onRecvRetTicketNotice:(IMProgramItemObject *_Nonnull)item leftCredit:(double)leftCredit {
    NSLog(@"LSImManager::onRecvRetTicketNotice( [接收节目, 已退票通知], showLiveId : %@, anchorId : %@, nickName : %@, leftCredit : %f )", item.showLiveId, item.anchorId, item.anchorNickName, leftCredit);
}

#pragma mark - 信件
- (void)onRecvLoiNotice:(NSString * _Nonnull)anchorId loiId:(NSString * _Nonnull)loiId {
    NSLog(@"LSImManager::onRecvLoiNotice( [13.1.接收意向信通知], anchorId : %@, loiId : %@)", anchorId, loiId);
}

- (void)onRecvEMFNotice:(NSString * _Nonnull)anchorId emfId:(NSString * _Nonnull)emfId {
    NSLog(@"LSImManager::onRecvEMFNotice( [13.2.接收EMF通知], anchorId : %@, emfId : %@)", anchorId, emfId);
}

@end
