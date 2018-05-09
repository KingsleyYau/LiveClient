//
//  LSAnchorImManager.m
//  livestream
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSAnchorImManager.h"

#import "LSConfigManager.h"
#import "LSLoginManager.h"
#import "UserInfoManager.h"
//#import "LSSessionRequestManager.h"
#import "LSAnchorRequestManager.h"

@interface LSAnchorImManager () <ZBIMLiveRoomManagerDelegate, LoginManagerDelegate>
@property (nonatomic, strong) NSMutableArray *delegates;
// Http登陆管理器
@property (nonatomic, strong) LSLoginManager *loginManager;
//// Http接口管理器
//@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
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

@property (nonatomic, copy) NSString * KickOffMsg;
@end

static LSAnchorImManager *gManager = nil;
@implementation LSAnchorImManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    NSLog(@"LSAnchorImManager::init()");
    
    if (self = [super init]) {
        self.delegates = [NSMutableArray array];
        
        self.client = [[ZBImClientOC alloc] init];
        [self.client addDelegate:self];
        
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
        
        //        self.sessionManager = [LSSessionRequestManager manager];
        
        self.requestDictionary = [NSMutableDictionary dictionary];
        self.isIMLogin = NO;
        self.isFirstLogin = YES;
        self.isKick = NO;
    }
    return self;
}

// 将c的直播间类型转OC中的直播类型
- (LiveRoomType)roomTypeToLiveRoomType:(ZBRoomType)type {
    LiveRoomType roomType = LiveRoomType_Unknow;
    if (type == ZBROOMTYPE_NOLIVEROOM || type == ZBROOMTYPE_UNKNOW) {
        roomType = LiveRoomType_Unknow;
    } else if (type == ZBROOMTYPE_FREEPUBLICLIVEROOM) {
        roomType = LiveRoomType_Public;
    } else if (type == ZBROOMTYPE_COMMONPRIVATELIVEROOM) {
        roomType = LiveRoomType_Public_VIP;
    } else if (type == ZBROOMTYPE_CHARGEPUBLICLIVEROOM) {
        roomType = LiveRoomType_Private;
    } else if (type == ZBROOMTYPE_LUXURYPRIVATELIVEROOM) {
        roomType = LiveRoomType_Private_VIP;
    }
    
    return roomType;
}

- (void)dealloc {
    NSLog(@"LSAnchorImManager::dealloc()");
    
    [self.client removeDelegate:self];
    [self.loginManager removeDelegate:self];
}

- (BOOL)addDelegate:(id<ZBIMManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;
    
    NSLog(@"LSAnchorImManager::addDelegate( delegate : %@ )", delegate);
    
    @synchronized(self.delegates) {
        // 查找是否已存在
        for (NSValue *value in self.delegates) {
            id<ZBIMManagerDelegate> item = (id<ZBIMManagerDelegate>)value.nonretainedObjectValue;
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

- (BOOL)removeDelegate:(id<ZBIMManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;
    
    NSLog(@"LSAnchorImManager::removeDelegate( delegate : %@ )", delegate);
    
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<ZBIMManagerDelegate> item = (id<ZBIMManagerDelegate>)value.nonretainedObjectValue;
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
    NSLog(@"LSAnchorImManager::login( [IM登陆], token : %@ )", self.loginManager.loginItem.token);
    
    // 开始登录IM
    //[self.client login:self.loginManager.loginItem.token pageName:PAGENAMETYPE_MOVEPAGE];
    [self.client anchorLogin:self.loginManager.loginItem.token pageName:ZBPAGENAMETYPE_MOVEPAGE];
}

- (void)logout {
    NSLog(@"LSAnchorImManager::logout( [IM注销] )");
    
    // 开始注销IM
    //[self.client logout];
    [self.client anchorLogout];
}

#pragma mark - HTTP登录回调
- (void)manager:(LSLoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(ZBLSLoginItemObject *_Nullable)loginItem errnum:(ZBHTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *_Nonnull)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            // 获取同步配置的IM服务器地址
            [[LSConfigManager manager] synConfig:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, ZBConfigItemObject * _Nullable item) {
                if( success ) {
                    NSLog(@"LSAnchorImManager::onLogin( [IM登陆, 同步Im服务器地址], url : %@ )", item.imSvrUrl);
                    
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

- (void)manager:(LSLoginManager *_Nonnull)manager onLogout:(BOOL)kick msg:(NSString * _Nullable)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 注销IM
        NSLog(@"LSAnchorImManager::onLogout( [注销IM], kick : %@ )", BOOL2YES(kick));
        [self logout];
    });
}

#pragma mark - IM登陆回调
- (void)onZBLogin:(ZBLCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg item:(ZBImLoginReturnObject* _Nonnull)item {
    NSLog(@"LSAnchorImManager::onZBLogin( [IM登录, %@], errType : %d, errmsg : %@ )", (errType == ZBLCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    
    if (errType == ZBLCC_ERR_SUCCESS) {
        // IM登陆成功
        @synchronized(self) {
            
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
                
                if(item.scheduleRoomList.count > 0) {
                    // 处理预约
                    [self handleLoginScheduleRoomList:item.scheduleRoomList];
                }
                
                
            } else {
                //                // 断线重登陆
                //
                //                // 查询邀请状态
                //                [self getInviteInfo:^(BOOL success, LCC_ERR_TYPE errType, NSString * _Nonnull errMsg, ImInviteIdItemObject * _Nonnull Item) {
                //                    if( success ) {
                //                        // 成功获取到邀请状态
                //                        dispatch_async(dispatch_get_main_queue(), ^{
                //                            for (NSValue *value in self.delegates) {
                //                                id<IMManagerDelegate> delegate = (id<IMManagerDelegate>)value.nonretainedObjectValue;
                //                                if ([delegate respondsToSelector:@selector(onRecvInviteReply:)]) {
                //                                    [delegate onRecvInviteReply:Item];
                //                                }
                //                            }
                //                        });
                //                    }
                //                }];
                
            }
        }
        
    } else if (errType == ZBLCC_ERR_CONNECTFAIL) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // IM断线, 3秒后重连
            if (self.loginManager.status == LOGINED) {
                [self login];
            }
        });
    }
    else
    {
        NSString * logoutMsg = errmsg.length>0?errmsg:NSLocalizedString(@"ACCOUNT_HAS_LOAD", @"ACCOUNT_HAS_LOAD");
        [self.loginManager logout:YES msg:logoutMsg];
    }
}

- (void)onZBLogout:(ZBLCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"LSAnchorImManager::onZBLogout( [IM注销通知], errType : %d, errmsg : %@ )", errType, errmsg);
    
    @synchronized(self) {
        // 标记IM登陆未登陆
        self.isIMLogin = NO;
    }
    
    @synchronized (self) {
        if( !self.isKick ) {
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
                NSString * logoutMsg = self.KickOffMsg.length>0?errmsg:NSLocalizedString(@"ACCOUNT_HAS_LOAD", @"ACCOUNT_HAS_LOAD");
                [self.loginManager logout:YES msg:logoutMsg];
            });
        }
    }
}

- (void)onZBKickOff:(ZBLCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"LSAnchorImManager::onKickOff( [用户被挤掉线, %@], errType : %d, errmsg : %@ )", (errType == ZBLCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    @synchronized (self) {
        self.isKick = YES;
        self.KickOffMsg = errmsg;
    }
}

#pragma mark - 首次登陆处理
- (BOOL)handleLoginRoomList:(NSArray<ZBImLoginRoomObject*> * )roomList {
    BOOL bFlag = NO;
    
    if (roomList.count > 0) {
        ZBImLoginRoomObject* roomObj = [roomList objectAtIndex:0];
        if (roomObj.roomId.length > 0) {
            bFlag = YES;
            
            for (NSValue *value in self.delegates) {
                id<ZBIMManagerDelegate> delegate = (id<ZBIMManagerDelegate>)value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(onZBHandleLoginRoom:roomType:)]) {
                    [delegate onZBHandleLoginRoom:roomObj.roomId roomType:[self roomTypeToLiveRoomType:roomObj.roomType]];
                }
            }
        }
    }
    
    return bFlag;
}

- (BOOL)handleLoginInviteList:(NSArray<ZBImInviteIdItemObject *> *)inviteList {
    BOOL bFlag = NO;
    
    ZBImInviteIdItemObject *inviteItem = nil;
    if (inviteList.count > 0) {
        inviteItem = [inviteList objectAtIndex:0];
        
        if (inviteItem) {
            bFlag = YES;
            
            for (NSValue *value in self.delegates) {
                id<ZBIMManagerDelegate> delegate = (id<ZBIMManagerDelegate>)value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(onZBHandleLoginInvite:)]) {
                    [delegate onZBHandleLoginInvite:inviteItem];
                }
            }
        }
    }
    
    return bFlag;
}

- (BOOL)handleLoginScheduleRoomList:(NSArray<ZBImScheduleRoomObject *> *)scheduleRoomList {
    BOOL bFlag = YES;
    
    for (NSValue *value in self.delegates) {
        id<ZBIMManagerDelegate> delegate = (id<ZBIMManagerDelegate>)value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(onZBHandleLoginSchedule:)]) {
            [delegate onZBHandleLoginSchedule:scheduleRoomList];
        }
    }
    
    return bFlag;
}

#pragma mark - 直播间状态
- (BOOL)enterRoom:(NSString *_Nonnull)roomId finishHandler:(EnterRoomHandler _Nullable)finishHandler {
    NSLog(@"LSAnchorImManager::enterRoom( [发送观众进入直播间], roomId : %@ )", roomId);
    BOOL bFlag = NO;
    
    @synchronized(self) {
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            //bFlag = [self.client roomIn:reqId roomId:roomId];
            bFlag = [self.client anchorRoomIn:reqId roomId:roomId];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }
    
    return bFlag;
}

- (void)onZBRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg item:(ZBImLiveRoomObject* _Nonnull)item {
    NSLog(@"LSAnchorImManager::onRoomIn( [发送观众进入直播间, %@], reqId : %u, errType : %d, errmsg : %@, reqId : %u )", (errType == ZBLCC_ERR_SUCCESS) ? @"成功" : @"失败", reqId, errType, errmsg, reqId);
    
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
    NSLog(@"LSAnchorImManager::leaveRoom( [发送观众退出直播间], roomId : %@ )", roomId);
    BOOL bFlag = NO;
    
    @synchronized(self) {
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            //bFlag = [self.client roomOut:reqId roomId:roomId];
            bFlag = [self.client anchorRoomOut:reqId roomId:roomId];
        }
    }
    
    return bFlag;
}

- (void)onZBRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"LSAnchorImManager::onRoomOut( [发送观众退出直播间, %@], errType : %d, errmsg : %@ )", (errType == ZBLCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
}

- (BOOL)enterPublicRoom:(EnterPublicRoomHandler _Nullable)finishHandler {
    NSLog(@"LSAnchorImManager::enterPublicRoom( [发送观众进入公开直播间] )");
    BOOL bFlag = NO;
    
    @synchronized(self) {
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            //bFlag = [self.client publicRoomIn:reqId userId:userId];
            bFlag = [self.client anchorPublicRoomIn:reqId];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }
    
    return bFlag;
}

- (void)onZBPublicRoomIn:(SEQ_T)reqId success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg item:(ZBImLiveRoomObject* _Nonnull)item {
    NSLog(@"LSAnchorImManager::onPublicRoomIn( [发送观众进入公开直播间, %@], errType : %d, errmsg : %@, reqId : %u )", (err == ZBLCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg, reqId);
    
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        EnterPublicRoomHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, item);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}
/**
 *  3.4.接收直播间关闭通知(观众)回调
 *
 *  @param roomId      直播间ID
 *
 */- (void)onZBRecvRoomCloseNotice:(NSString* _Nonnull)roomId errType:(ZBLCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
     NSLog(@"LSAnchorImManager::onRecvRoomCloseNotice( [接收直播间关闭通知], roomId : %@, errType : %d, errMsg : %@ )", roomId, errType, errmsg);
 }

/**
 *  3.6.接收观众进入直播间通知回调
 *
 *  @param roomId      直播间ID
 *  @param userId      观众ID
 *  @param nickName    观众昵称
 *  @param photoUrl    观众头像url
 *  @param riderId     座驾ID
 *  @param riderName   座驾名称
 *  @param riderUrl    座驾图片url
 *  @param fansNum     观众人数
 *  @param isHasTicket 是否已购票
 *
 */
- (void)onZBRecvEnterRoomNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl riderId:(NSString* _Nonnull)riderId riderName:(NSString* _Nonnull)riderName riderUrl:(NSString* _Nonnull)riderUrl fansNum:(int)fansNum isHasTicket:(BOOL)isHasTicket{
    NSLog(@"LSAnchorImManager::onRecvEnterRoomNotice( [接收观众进入直播间通知], roomId : %@, userId : %@, nickName : %@ )", roomId, userId, nickName);
}

/**
 *  3.7.接收观众退出直播间通知回调
 *
 *  @param roomId      直播间ID
 *  @param userId      观众ID
 *  @param nickName    观众昵称
 *  @param photoUrl    观众头像url
 *  @param fansNum     观众人数
 *
 */
- (void)onZBRecvLeaveRoomNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl fansNum:(int)fansNum {
    NSLog(@"LSAnchorImManager::onRecvLeaveRoomNotice( [接收观众退出直播间通知], roomId : %@, userId : %@, nickName : %@ )", roomId, userId, nickName);
}

/**
 *  3.8.接收关闭直播间倒数通知回调
 *
 *  @param roomId      直播间ID
 *  @param leftSeconds 关闭直播间倒数秒数（整型）（可无，无或0表示立即关闭）
 *  @param err         错误码
 *  @param errMsg      错误描述
 *
 */
- (void)onZBRecvLeavingPublicRoomNotice:(NSString* _Nonnull)roomId leftSeconds:(int)leftSeconds err:(ZBLCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg {
    NSLog(@"LSAnchorImManager::onZBRecvLeavingPublicRoomNotice( [接收观众退出直播间通知], roomId : %@, leftSeconds : %d )", roomId, leftSeconds);
}

/**
 *  3.9.接收主播退出直播间通知回调
 *
 *  @param roomId       直播间ID
 *  @param anchorId     退出直播间的主播ID
 *
 */
- (void)onRecvAnchorLeaveRoomNotice:(NSString* _Nonnull)roomId anchorId:(NSString* _Nonnull)anchorId {
    NSLog(@"LSAnchorImManager::onRecvAnchorLeaveRoomNotice( [接收主播退出直播间通知], roomId : %@, anchorId : %@ )", roomId, anchorId);
}

#pragma mark - 私密直播间
- (BOOL)anchorSendImmediatePrivateInvite:(NSString *_Nonnull)userId finishHandler:(SendImmediatePrivateInviteHandler _Nullable)finishHandler {
    NSLog(@"LSAnchorImManager::anchorSendImmediatePrivateInvite( [发送私密邀请], userId : %@)", userId);
    BOOL bFlag = NO;
    
    @synchronized(self) {
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            bFlag = [self.client anchorSendImmediatePrivateInvite:reqId userId:userId];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }
    
    return bFlag;
}

- (void)onZBSendImmediatePrivateInvite:(BOOL)success reqId:(SEQ_T)reqId err:(ZBLCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg invitationId:(NSString* _Nonnull)invitationId timeOut:(int)timeOut roomId:(NSString* _Nonnull)roomId {
    NSLog(@"LSAnchorImManager::onZBSendImmediatePrivateInvite( [发送私密邀请, %@], err : %d, errMsg : %@ )", (err == ZBLCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);
    
    @synchronized(self) {
        if (success) {
            // 记录邀请Id
            self.inviteId = invitationId;
        }
        
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        SendImmediatePrivateInviteHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, invitationId, timeOut, roomId);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}


-(BOOL)anchorGetInviteInfo:(NSString *_Nonnull)invitationId finishHandler:(GetInviteInfoHandler _Nullable)finishHandler {
    
    NSLog(@"LSAnchorImManager::anchorGetInviteInfo( [获取指定立即私密邀请信息], inviteId : %@ )", invitationId);
    BOOL bFlag = NO;
    
    @synchronized(self) {
        if (self.isIMLogin) {
            if (self.inviteId.length > 0) {
                SEQ_T reqId = [self.client getReqId];
                bFlag = [self.client anchorGetInviteInfo:reqId invitationId:self.inviteId];
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
/**
 *  9.5.获取指定立即私密邀请信息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *  @param item             立即私密邀请
 *
 */
- (void)onZBGetInviteInfo:(SEQ_T)reqId success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg item:(ZBImInviteIdItemObject *_Nonnull)item {
    NSLog(@"LSAnchorImManager::onGetInviteInfo( [获取指定立即私密邀请信息, %@], errType : %d, errmsg : %@ )", (err == ZBLCC_ERR_SUCCESS) ? @"成功" : @"失败", err, errMsg);
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        GetInviteInfoHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, err, errMsg, item);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}
/**
 *  9.2.接收立即私密邀请回复通知 回调
 *
 *  @param inviteId      邀请ID
 *  @param replyType     主播回复 （0:拒绝 1:同意）
 *  @param roomId        直播间ID （可无，m_replyType ＝ 1存在）
 *  @param roomType      直播间类型
 *  @param userId        观众ID
 *  @param nickName      主播昵称
 *  @param avatarImg     主播头像
 *
 */
- (void)onZBRecvInstantInviteReplyNotice:(NSString* _Nonnull)inviteId replyType:(ZBReplyType)replyType roomId:(NSString* _Nonnull)roomId roomType:(ZBRoomType)roomType userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName avatarImg:(NSString* _Nonnull)avatarImg {
    NSLog(@"LSAnchorImManager::onRecvInstantInviteReplyNotice( [接收立即私密邀请回复通知], roomId : %@, inviteId : %@, nickName : %@ )", roomId, inviteId, nickName);
    
    @synchronized(self) {
        if ([self.inviteId isEqualToString:inviteId]) {
            // 清空邀请Id
            self.inviteId = nil;
        }
    }
}

/**
 *  9.3.接收立即私密邀请通知 回调
 *
 *  @param userId           观众ID
 *  @param nickName         观众昵称
 *  @param photoUrl         观众头像url
 *  @param invitationId     邀请ID
 *
 */
- (void)onZBRecvInstantInviteUserNotice:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl invitationId:(NSString* _Nonnull)invitationId {
    NSLog(@"LSAnchorImManager::onRecvInstantInviteUserNotice( [接收主播立即私密邀请通知], invitationId : %@, userId : %@, userName : %@, photoUrl : %@ )", invitationId, userId, nickName, photoUrl);
}

/**
 *  9.4.接收预约开始倒数通知 回调
 *
 *  @param roomId       直播间ID
 *  @param userId       对端ID
 *  @param nickName     对端昵称
 *  @param avatarImg    对端头像url
 *  @param leftSeconds  倒数时间（秒）
 *
 */
- (void)onZBRecvBookingNotice:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName avatarImg:(NSString* _Nonnull)avatarImg  leftSeconds:(int)leftSeconds {
    NSLog(@"LSAnchorImManager::onZBRecvBookingNotice( [接收预约开始倒数通知], userId : %@, nickName : %@, avatarImg : %@ roomId : %@ leftSeconds:%d)", userId, nickName, avatarImg, roomId, leftSeconds);
}

/**
 *  9.6.接收观众接受预约通知接口 回调
 *
 *  @param userId           观众ID
 *  @param nickName         观众昵称
 *  @param photoUrl         观众头像url
 *  @param invitationId     预约ID
 *  @param bookTime         预约时间（1970年起的秒数）
 */
- (void)onZBRecvInvitationAcceptNotice:(NSString* _Nonnull)userId nickName:(NSString* _Nonnull)nickName photoUrl:(NSString* _Nonnull)photoUrl invitationId:(NSString* _Nonnull)invitationId bookTime:(long)bookTime {
    NSLog(@"LSAnchorImManager::onZBRecvInvitationAcceptNotice( [接收观众接受预约通知接口], userId : %@, nickName : %@, photoUrl : %@ invitationId : %@ bookTime:%ld)", userId, nickName, photoUrl, invitationId, bookTime);
    
    for (NSValue *value in self.delegates) {
        id<ZBIMManagerDelegate> delegate = (id<ZBIMManagerDelegate>)value.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(onZBHandleRecvScheduleAcceptNotice:nickName:photoUrl:invitationId:bookTime:)]) {
            [delegate onZBHandleRecvScheduleAcceptNotice:userId nickName:nickName photoUrl:photoUrl invitationId:invitationId bookTime:bookTime];
        }
    }
}




#pragma mark - 消息和礼物
- (BOOL)sendLiveChat:(NSString *_Nonnull)roomId nickName:(NSString *_Nonnull)nickName msg:(NSString *_Nonnull)msg at:(NSArray<NSString *> *_Nullable)at {
    NSLog(@"LSAnchorImManager::sendLiveChat( [发送直播间文本消息], roomId : %@, nickName : %@, msg : %@ )", roomId, nickName, msg);
    BOOL bFlag = NO;
    
    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            //bFlag = [self.client sendLiveChat:reqId roomId:roomId nickName:nickName msg:msg at:at];
            bFlag = [self.client anchorSendLiveChat:reqId roomId:roomId nickName:nickName msg:msg at:at];
            if (bFlag) {
            }
        }
    }
    return bFlag;
}

- (void)onZBSendLiveChat:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"LSAnchorImManager::onSendLiveChat( [发送直播间文本消息, %@], errType : %d, errmsg : %@ )", (errType == ZBLCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
}

- (void)onZBRecvSendChatNotice:(NSString* _Nonnull)roomId level:(int)level fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg honorUrl:(NSString* _Nonnull)honorUrl {
    NSLog(@"LSAnchorImManager::onRecvSendChatNotice( [接收直播间文本消息通知], roomId : %@, nickName : %@, msg : %@, honorUrl : %@ )", roomId, nickName, msg, honorUrl);
}

- (void)onZBRecvSendSystemNotice:(NSString* _Nonnull)roomId msg:(NSString* _Nonnull)msg link:(NSString* _Nonnull)link type:(ZBIMSystemType)type {
    NSLog(@"LSAnchorImManager::onRecvSendSystemNotice( [接收直播间公告消息], roomId : %@, msg : %@, link: %@ type:%d)", roomId, msg, link, type);
}


- (void)onZBRecvSendToastNotice:(NSString* _Nonnull)roomId fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg honorUrl:(NSString* _Nonnull)honorUrl{
    NSLog(@"LSAnchorImManager::onRecvSendToastNotice( [接收直播间弹幕通知], roomId : %@, fromId : %@, nickName : %@, msg : %@ honorUrl:%@)", roomId, fromId, nickName, msg, honorUrl);
}

- (BOOL)sendGift:(NSString* _Nonnull)roomId nickName:(NSString* _Nonnull)nickName giftId:(NSString* _Nonnull)giftId giftName:(NSString* _Nonnull)giftName isBackPack:(BOOL)isBackPack giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id finishHandler:(SendGiftHandler _Nullable)finishHandler {
    NSLog(@"LSAnchorImManager::sendGift( [发送直播间礼物消息], roomId : %@, nickName : %@, giftId : %@ )", roomId, nickName, giftId);
    BOOL bFlag = NO;
    
    @synchronized(self) {
        // 标记IM登陆未登陆
        if (self.isIMLogin) {
            SEQ_T reqId = [self.client getReqId];
            //            bFlag = [self.client sendGift:reqId roomId:roomId nickName:nickName giftId:giftId giftName:giftName isBackPack:isBackPack giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id];
            bFlag = [self.client anchorSendGift:reqId roomId:roomId nickName:nickName giftId:giftId giftName:giftName isBackPack:isBackPack giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id];
            if (bFlag && finishHandler) {
                [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            }
        }
    }
    return bFlag;
}

- (void)onZBSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(ZBLCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"LSAnchorImManager::onSendGift( [发送直播间礼物消息], errmsg : %@ )", errmsg);
    
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        SendGiftHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, errType, errmsg);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

- (void)onZBRecvSendGiftNotice:(NSString* _Nonnull)roomId fromId:(NSString* _Nonnull)fromId nickName:(NSString* _Nonnull)nickName giftId:(NSString* _Nonnull)giftId giftName:(NSString* _Nonnull)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id honorUrl:(NSString* _Nonnull)honorUrl totalCredit:(int)totalCredit {
    NSLog(@"LSAnchorImManager::onRecvSendGiftNotice( [接收直播间礼物通知], roomId : %@, fromId : %@, nickName : %@ honorUrl : %@)", roomId, fromId, nickName, honorUrl);
}

// 7.1.接收直播间才艺点播邀请通知
- (void)onZBRecvTalentRequestNotice:(ZBImTalentRequestObject* _Nonnull)talentRequestItem {
    NSLog(@"LSAnchorImManager::onZBRecvTalentRequestNotice( [接收直播间才艺点播邀请通知])");
}

// ------------- 直播间视频互动 -------------
/**
 *  8.1.接收观众启动/关闭视频互动通知回调
 *
 *  @param item            互动切换
 *
 */
- (void)onZBRecvControlManPushNotice:(ZBImControlPushItemObject * _Nonnull)item {
    NSLog(@"LSAnchorImManager::onZBRecvControlManPushNotice( [接收观众启动/关闭视频互动通知])");
}
// ------------- 多人互动直播间 -------------
/**
 *  10.1.进入多人互动直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg      结果描述
 *  @param item        进入多人互动直播间信息
 *  @param expire      倒数进入秒数，倒数完成后再调用本接口重新进入
 *
 */
- (void)onAnchorEnterHangoutRoom:(SEQ_T)reqId  success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg item:(AnchorHangoutRoomItemObject *_Nonnull)item expire:(int)expire {
    NSLog(@"LSAnchorImManager::onAnchorEnterHangoutRoom( [进入多人互动直播间])");
}

/**
 *  10.2.退出多人互动直播间接口 回调
 *
 *  @param success      操作是否成功
 *  @param reqId        请求序列号
 *  @param errMsg      结果描述
 *
 */
- (void)onAnchorLeaveHangoutRoom:(SEQ_T)reqId  success:(BOOL)success err:(ZBLCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg {
    NSLog(@"LSAnchorImManager::onAnchorLeaveHangoutRoom( [退出多人互动直播间])");
}

/**
 *  10.3.接收观众邀请多人互动通知接口 回调
 *
 *  @param item      观众邀请多人互动信息
 *
 */
- (void)RecvAnchorInvitationHangoutNotice:(AnchorHangoutInviteItemObject *_Nonnull)item {
    NSLog(@"LSAnchorImManager::RecvAnchorInvitationHangoutNotice( [接收观众邀请多人互动通知])");
}

/**
 *  10.4.接收推荐好友通知接口 回调
 *
 *  @param item         主播端接收自己推荐好友给观众的信息
 *
 */
- (void)onRecvAnchorRecommendHangoutNotice:(IMAnchorRecommendHangoutItemObject *_Nonnull)item {
    NSLog(@"LSAnchorImManager::onRecvAnchorRecommendHangoutNotice( [接收推荐好友通知])");
}

/**
 *  10.5.接收敲门回复通知接口 回调
 *
 *  @param item         接收敲门回复信息
 *
 */
- (void)onRecvAnchorDealKnockRequestNotice:(IMAnchorKnockRequestItemObject *_Nonnull)item {
    NSLog(@"LSAnchorImManager::onRecvAnchorDealKnockRequestNotice( [接收敲门回复通知])");
}

/**
 *  10.6.接收观众邀请其它主播加入多人互动通知接口 回调
 *
 *  @param item         接收观众邀请其它主播加入多人互动信息
 *
 */
- (void)onRecvAnchorOtherInviteNotice:(IMAnchorRecvOtherInviteItemObject *_Nonnull)item {
    NSLog(@"LSAnchorImManager::onRecvAnchorOtherInviteNotice( [接收观众邀请其它主播加入多人互动通知])");
}

/**
 *  10.7.接收主播回复观众多人互动邀请通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
- (void)onRecvAnchorDealInviteNotice:(IMAnchorRecvDealInviteItemObject *_Nonnull)item {
    NSLog(@"LSAnchorImManager::onRecvAnchorDealInviteNotice( [接收主播回复观众多人互动邀请通知])");
}

/**
 *  10.8.观众端/主播端接收观众/主播进入多人互动直播间通知接口 回调
 *
 *  @param item         接收主播回复观众多人互动邀请信息
 *
 */
- (void)onRecvAnchorEnterRoomNotice:(IMAnchorRecvEnterRoomItemObject *_Nonnull)item {
    NSLog(@"LSAnchorImManager::onRecvAnchorEnterRoomNotice( [观众端/主播端接收观众/主播进入多人互动直播间通知])");
}

/**
 *  10.9.接收观众/主播退出多人互动直播间通知接口 回调
 *
 *  @param item         接收观众/主播退出多人互动直播间信息
 *
 */
- (void)onRecvAnchorLeaveRoomNotice:(IMAnchorRecvLeaveRoomItemObject *_Nonnull)item {
    NSLog(@"LSAnchorImManager::onRecvAnchorLeaveRoomNotice( [接收观众/主播退出多人互动直播间通知])");
}

/**
 *  10.10.接收观众/主播多人互动直播间视频切换通知接口 回调
 *
 *  @param roomId         直播间ID
 *  @param isAnchor       是否主播（0：否，1：是）
 *  @param userId         观众/主播ID
 *  @param playUrl        视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
 *
 */
- (void)onRecvAnchorChangeVideoUrl:(NSString* _Nonnull)roomId isAnchor:(bool)isAnchor userId:(NSString* _Nonnull)userId playUrl:(NSMutableArray *_Nullable)playUrl {
    NSLog(@"LSAnchorImManager::onRecvAnchorChangeVideoUrl( [接收观众/主播多人互动直播间视频切换通知])");
}

/**
 *  10.11.发送多人互动直播间礼物消息接口 回调
 *
 *  @param success          操作是否成功
 *  @param reqId            请求序列号
 *  @param errMsg           结果描述
 *
 */
- (void)onSendAnchorHangoutGift:(SEQ_T)reqId success:(bool)success err:(ZBLCC_ERR_TYPE)err errMsg:(NSString* _Nonnull)errMsg {
    NSLog(@"LSAnchorImManager::onSendAnchorHangoutGift( [发送多人互动直播间礼物消息])");
}

/**
 *  10.12.接收多人互动直播间礼物通知接口 回调
 *
 *  @param item         接收多人互动直播间礼物信息
 *
 */
- (void)onRecvAnchorGiftNotice:(IMAnchorRecvGiftItemObject *_Nonnull)item {
    NSLog(@"LSAnchorImManager::onRecvAnchorGiftNotice( [接收多人互动直播间礼物通知])");
}

// ------------- 节目 -------------
/**
 *  11.1.接收节目开播通知接口 回调
 *
 *  @param item         节目信息
 *  @param msg          消息提示文字
 *
 */
- (void)onRecvAnchorProgramPlayNotice:(IMAnchorProgramItemObject *_Nonnull)item msg:(NSString * _Nonnull)msg{
    NSLog(@"LSAnchorImManager::onRecvAnchorProgramPlayNotice( [接收节目开播通知])");
}
/**
 *  11.2.接收节目状态改变通知接口 回调
 *
 *  @param item         节目信息
 *
 */
- (void)onRecvAnchorChangeStatusNotice:(IMAnchorProgramItemObject *_Nonnull)item {
    NSLog(@"LSAnchorImManager::onRecvAnchorChangeStatusNotice( [接收节目状态改变通知])");
}

/**
 *  11.3.接收无操作的提示通知接口 回调
 *
 *  @param backgroundUrl 背景图url
 *  @param msg           描述
 *
 */
- (void)onRecvAnchorShowMsgNotice:(NSString* _Nonnull)backgroundUrl msg:(NSString* _Nonnull)msg {
    NSLog(@"LSAnchorImManager::onRecvAnchorShowMsgNotice( [接收无操作的提示通知])");
}

@end

