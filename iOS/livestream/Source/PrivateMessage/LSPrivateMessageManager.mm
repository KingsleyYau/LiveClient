//
//  LSPrivateMessageManager.m
//  livestream
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSPrivateMessageManager.h"
#import "LSRequestManager.h"
#import "LSImManager.h"
#import "LSConfigManager.h"


@interface LSPrivateMessageManager () <LMMessageManagerDelegate, LMHandleHttpListenerDelegate, LoginManagerDelegate>
@property (nonatomic, strong) NSMutableArray *delegates;
// 请求字典
@property (nonatomic, strong) NSMutableDictionary *requestDictionary;
//// 上次发送返回的邀请
//@property (nonatomic, strong) NSString *inviteId;
//
@end

static LSPrivateMessageManager *gManager = nil;
@implementation LSPrivateMessageManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    NSLog(@"LSPrivateMessageManager::init()");

    if (self = [super init]) {
        self.delegates = [NSMutableArray array];

        self.client = [LMManagerOC manager];
        [self.client initManager:[[LSImManager manager].client getImClient]];
        [self.client addDelegate:self];
        
        [self.client setHttpRequestDelegate:self];

        self.requestDictionary = [NSMutableDictionary dictionary];
        
        // 加入LoginManager回调
        [[LSLoginManager manager] addDelegate:self];
        
    }
    return self;
}

- (BOOL)setManagerInfo:(NSString* _Nullable)userId privateNotice:(NSString* _Nullable)privateNotice {
    NSLog(@"LSPrivateMessageManager::initManager()");
    BOOL result = NO;
    if (self.client) {
        result = [self.client setManagerInfo:userId privateNotice:privateNotice];
    }
    return result;
}

- (void)dealloc {
    NSLog(@"LSImManager::dealloc()");

    [self.client removeDelegate:self];
   [[LSLoginManager manager] removeDelegate:self];
}


#pragma mark - 私信联系人列表

- (void)getLocalPrivateMsgFriendList:(LocalPrivateMsgFriendListHandler)finishHandler {
    @synchronized(self) {
        NSArray<LMPrivateMsgContactObject*>* array = nil;
        if (self.client) {
            array = [self.client getLocalPrivateMsgFriendList];
        }
        
        if (finishHandler) {
            finishHandler(array);
        }
    }
    
}


- (BOOL)getPrivateMsgFriendList {
    BOOL result = NO;
    if (self.client) {
        result = [self.client getPrivateMsgFriendList];
    }
    return result;
}

- (BOOL)addPrivateMsgLiveChat:(NSString* _Nonnull)userId {
    BOOL result = NO;
    if (self.client) {
        result = [self.client addPrivateMsgLiveChat:userId];
    }
    return result;
}

- (BOOL)removePrivateMsgLiveChat:(NSString* _Nonnull)userId {
    BOOL result = NO;
    if (self.client) {
        result = [self.client removePrivateMsgLiveChat:userId];
    }
    return result;
}

#pragma mark - 私信消息

- (void)getLocalPrivateMsgWithUserId:(NSString* _Nonnull)userId finishHandler:(LocalPrivateMsgWithUserIdHandler _Nullable)finishHandler {
    @synchronized(self) {
        NSArray<LMMessageItemObject*>* array = nil;
        if (self.client) {
            array = [self.client getLocalPrivateMsgWithUserId:userId];
        }
        
        if (finishHandler) {
            finishHandler(array);
        }
    }
}

- (BOOL)refreshPrivateMsgWithUserId:(NSString* _Nonnull)userId finishHandler:(RefreshPrivateMsgHandler _Nullable)finishHandler {
    BOOL result = NO;
    if (self.client) {
        int reqId = [self.client refreshPrivateMsgWithUserId:userId];
        if (reqId > 0 && finishHandler) {
            [self.requestDictionary setValue:finishHandler forKey:[NSString stringWithFormat:@"%u", reqId]];
            result = YES;
        }
    }
    return result;
}

- (BOOL)getMorePrivateMsgWithUserId:(NSString* _Nonnull)userId {
    BOOL result = NO;
    if (self.client) {
        int reqId = [self.client getMorePrivateMsgWithUserId:userId];
        if (reqId > 0) {
            result = YES;
        }
    }
    return result;
}

- (BOOL)setPrivateMsgReaded:(NSString* _Nonnull)userId {
    BOOL result = NO;
    if (self.client) {
        result = [self.client setPrivateMsgReaded:userId];
    }
    return result;
}

- (BOOL)sendPrivateMessage:(NSString* _Nonnull)userId message:(NSString* _Nonnull)message {
    BOOL result = NO;
    if (self.client) {
        result = [self.client sendPrivateMessage:userId message:message];
    }
    return result;
}

- (BOOL)repeatSendPrivateMsg:(NSString* _Nonnull)userId sendMsgId:(int)sendMsgId {
    BOOL result = NO;
    if (self.client) {
        result = [self.client repeatSendPrivateMsg:userId sendMsgId:sendMsgId];
    }
    return result;
}

- (BOOL)isHasMorePrivateMsgWithUserId:(NSString* _Nonnull)userId {
    BOOL result = YES;
    if (self.client) {
        result = [self.client isHasMorePrivateMsgWithUserId:userId];
    }
    return result;
}

#pragma mark - IMMessageManagerDelegate
#pragma mark - 私信联系人 listener(http接口的返回)

// 当私信联系人列表有改变时，会收到这个回调，success为 yes 这时需要调用getLocalPrivateMsgFriendList
- (void)onUpdateFriendListNotice:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
    NSLog(@"LSPrivateMessageManager::onUpdateFriendListNotice(errType:%d errMsg:%@)", errType, errmsg);
}

#pragma mark - 私信消息公共操作
// 私信刷新消息回调
- (void)onRefreshPrivateMsgWithUserId:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg userId:(NSString* _Nonnull)userId list:(NSArray<LMMessageItemObject*>* _Nonnull)list reqId:(int)reqId {
    NSLog(@"LSPrivateMessageManager::onRefreshPrivateMsgWithUserId(success:%d errType:%d errMsg:%@ Contact:%lu userId:%@ reqId:%d)", success, errType, errmsg, (unsigned long)[list count], userId, reqId);
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%u", reqId];
        RefreshPrivateMsgHandler finishHandler = [self.requestDictionary valueForKey:key];
        if (finishHandler) {
            finishHandler(success, errType, errmsg, list);
        }
        [self.requestDictionary removeObjectForKey:key];
    }
}

// 私信消息更多消息回调
- (void)onGetMorePrivateMsgWithUserId:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg userId:(NSString* _Nonnull)userId list:(NSArray<LMMessageItemObject*>* _Nonnull)list reqId:(int)reqId{
    NSLog(@"LSPrivateMessageManager::onGetMorePrivateMsgWithUserId(success:%d errType:%d errMsg:%@ Contact:%lu userId:%@ reqId:%d)", success, errType, errmsg, (unsigned long)[list count], userId, reqId);
//    @synchronized(self) {
//        NSString *key = [NSString stringWithFormat:@"%u", reqId];
//        GetMorePrivateMsgHandler finishHandler = [self.requestDictionary valueForKey:key];
//        if (finishHandler) {
//            finishHandler(success, errType, errmsg, list);
//        }
//        [self.requestDictionary removeObjectForKey:key];
//    }
    BOOL isMore = [self isHasMorePrivateMsgWithUserId:userId];
    NSLog(@"LSPrivateMessageManager::onGetMorePrivateMsgWithUserId:%d", isMore);
}

// 私信更新消息（放在私信消息队列后面）
- (void)onUpdatePrivateMsgWithUserId:(NSString* _Nonnull)userId msgList:(NSArray<LMMessageItemObject*>* _Nonnull)msgList {
    NSLog(@"LSPrivateMessageManager::onUpdatePrivateMsgWithUserId(Contact:%lu userId:%@)", (unsigned long)[msgList count], userId);
}

//// 设置私信已读回调（一般不处理， 放弃）
//- (void)onSetPrivateMsgReaded:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg {
//      NSLog(@"LSPrivateMessageManager::onSetPrivateMsgReaded(errType:%d errMsg:%@)", errType, errmsg);
//}

#pragma mark - 私信listener
// 发送和重发的私信消息的成功或失败，改变发送消息的状态
- (void)onSendPrivateMessage:(BOOL)success errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg item:(LMMessageItemObject* _Nonnull)item {
    NSLog(@"LSPrivateMessageManager::onSendPrivateMessage(success:%d errType:%d errMsg:%@ item.userId:%@)", success, errType, errmsg, item.toId);
}

// 这个是重发，返回的回调，回调所有本地私信消息（原因是重发的消息可能要删除时间item，android不好处理，就做成重发就重新设置本地消息的排列，所有消息返回过去）
- (void)onRepeatSendPrivateMsgNotice:(NSString* _Nonnull)userId msgList:(NSArray<LMMessageItemObject*>* _Nonnull)msgList {
    NSLog(@"LSPrivateMessageManager::onRepeatSendPrivateMsgNotice(userId:%@ msgList:%lu)", userId, (unsigned long)[msgList count]);
}

// 接收接收的私信消息（用在私信联系人列表处，而聊天间使用的是onUpdatePrivateMsgWithUserId）
- (void)onRecvPrivateMessage:(LMMessageItemObject* _Nonnull)item {
    NSLog(@"LSPrivateMessageManager::onRecvPrivateMessage(item.fromId:%@ item.toId:%@)", item.fromId, item.toId);
}


#pragma mark - http 回调
// 调用http接口获取私信联系人列表（只在这里调用，其他地方不调用）
- (long long) onHandlePrivateMsgFriendListRequest:(long)callback {
    NSLog(@"LSPrivateMessageManager::onHandlePrivateMsgFriendListRequest()");
    long long result = 0;
    result = [[LSRequestManager manager] getPrivateMsgFriendList:callback];
    return result;
}

// 调用http接口获取私信关注联系人列表（只在这里调用，其他地方不调用）
- (long long) onHandleFollowPrivateMsgFriendListRequest:(long)callback {
    NSLog(@"LSPrivateMessageManager::onHandleFollowPrivateMsgFriendListRequest()");
    long long result = 0;
    result = [[LSRequestManager manager] getFollowPrivateMsgFriendList:callback];
    return result;
}

// 调用http接口获取私信消息列表（只在这里调用，其他地方不调用）
- (void) onHandlePrivateMsgWithUserIdRequest:(NSString * _Nonnull)userId startMsgId:(NSString * _Nonnull)startMsgId order:(PrivateMsgOrderType)order limit:(int)limit reqId:(int)reqId callback:(long)callback {
    NSLog(@"LSPrivateMessageManager::onHandlePrivateMsgWithUserIdRequest(userId:%@ startMsgId:%@ order:%d limit:%d)", userId, startMsgId, order, limit);
    [[LSRequestManager manager] getPrivateMsgWithUserId:userId startMsgId:startMsgId order:order limit:limit reqId:reqId callback:callback];
}

// 调用http接口设置已读私信消息（只在这里调用，其他地方不调用）
- (long long) onHandleSetPrivateMsgReadedRequest:(NSString * _Nonnull)userId msgId:(NSString * _Nonnull)msgId callback:(long)callback {
    NSLog(@"LSPrivateMessageManager::onHandleSetPrivateMsgReadedRequest(userId:%@, msgId:%@)", userId, msgId);
    long long result = 0;
    [[LSRequestManager manager] setPrivateMsgReaded:userId msgId:msgId callback:callback];
    return result;
}

// ---------------------------- LoginManagerDelegate --------------------
- (void)manager:(LSLoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject * _Nullable)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString * _Nonnull)errmsg {
    NSLog(@"LSPrivateMessageManager::manager onLogin(%d)", success);
    if (success) {
        // 初始化私信聊天管理器
        if (gManager != nil) {
            [self setManagerInfo:loginItem.userId privateNotice:[LSConfigManager manager].item.pmStartNotice];
        }

    }
}

- (void)manager:(LSLoginManager * _Nonnull)manager onLogout:(LogoutType)type msg:(NSString * _Nullable)msg {
    
}

@end
