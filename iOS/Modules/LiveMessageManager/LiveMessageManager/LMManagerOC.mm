//
//   LMManagerOC.m
//
//
//  Created by  Samson on 26/06/2018.
//  Copyright © 2017 Samson. All rights reserved.
//

#import "LMManagerOC.h"
#include "ILiveMessageManManager.h"
#include "HttpRequestPrivateMsgController.h"
#import "LMHandleHttpListener.h"



static LMManagerOC *gLMManagerOC = nil;
class LiveMessageManManagerCallback;

@interface LMManagerOC () {
}

@property (nonatomic, assign) ILiveMessageManManager *manager;
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, assign) LiveMessageManManagerCallback *lmManagerCallback;
@property (nonatomic, strong) id<LMHandleHttpListenerDelegate> httpRequestDelegates;

#pragma mark - 公共操作

- (LMPrivateMsgContactObject* _Nonnull)transformHttpContactToOCContact:(LMUserItem*)item;
- (NSMutableArray* _Nullable)transformHttpContactListToOCContactList:(const LMUserList&)list;
- (LMMessageItemObject* _Nonnull)transformLiveMessageToOCLiveMessage:(LiveMessageItem*)item;
- (NSMutableArray* _Nullable)transformLiveMessageListToOCLiveMessageList:(const LMMessageList&)list;
- (LMPrivateMsgItemObject* _Nullable)transformPrivateMsgToOCPrivateMsg:(LMPrivateMsgItem*)item;

#pragma mark - 私信联系人 listener(http接口的返回)
//- (void)onGetPrivateMsgFriendList:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg ContactList:(const LMUserList&)ContactList;
//
//- (void)onGetFollowPrivateMsgFriendList:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg  followList:(const LMUserList&)followList;

- (void)onUpdateFriendListNotice:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

#pragma mark - 私信消息公共操作

- (void)onRefreshPrivateMsgWithUserId:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg userId:(const string &)userId list:(const LMMessageList&)list reqId:(int)reqId;

- (void)onGetMorePrivateMsgWithUserId:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg userId:(const string &)userId list:(const LMMessageList&)list reqId:(int)reqId;

- (void)onUpdatePrivateMsgWithUserId:(const string &)userId msgList:(const LMMessageList&)msgList;

//- (void)onSetPrivateMsgReaded:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg;

#pragma mark - 私信listener
- (void)onSendPrivateMessage:(BOOL)success errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(LiveMessageItem*)item;

- (void)onRepeatSendPrivateMsgNotice:(const string &)userId msgList:(const LMMessageList&)msgList;

- (void)onRecvPrivateMessage:(LiveMessageItem*)item;

#pragma mark - 私信http调用
- (long long) handlePrivateMsgFriendListRequest:(IRequestGetPrivateMsgFriendListCallback*)callback;

- (long long) handleFollowPrivateMsgFriendListRequest:(IRequestGetFollowPrivateMsgFriendListCallback*)callback;

- (void) handlePrivateMsgWithUserIdRequest:(const string &)userId startMsgId:(const string &)startMsgId order:(PrivateMsgOrderType)order limit:(int)limit reqId:(int)reqId callback:(IRequestGetPrivateMsgHistoryByIdCallback*)callback;

- (long long) handleSetPrivateMsgReadedRequest:(const string &)userId msgId:(const string &)msgId callback:(IRequestSetPrivateMsgReadedCallback*)callback;

@end

long long HandlePrivateMsgFriendListRequest(IRequestGetPrivateMsgFriendListCallback* callback);
long long HandleFollowPrivateMsgFriendListRequest(IRequestGetFollowPrivateMsgFriendListCallback* callback);
void HandlePrivateMsgWithUserIdRequest(const string& userId, const string& startMsgId, PrivateMsgOrderType order, int limit, int reqId, IRequestGetPrivateMsgHistoryByIdCallback* callback);
long long HandleSetPrivateMsgReadedRequest(const string& userId, const string& msgId, IRequestSetPrivateMsgReadedCallback* callback);
static IHttpRequestPrivateMsgControllerHandler gHttpRequestPrivateMsgControllerHandler {
    HandlePrivateMsgFriendListRequest,
    HandleFollowPrivateMsgFriendListRequest,
    HandlePrivateMsgWithUserIdRequest,
    HandleSetPrivateMsgReadedRequest
};

long long HandlePrivateMsgFriendListRequest(IRequestGetPrivateMsgFriendListCallback* callback) {
    long long result = 0;
//    long mCallback = (long)callback;
    result = [[LMManagerOC manager] handlePrivateMsgFriendListRequest:callback];
    return result;
}
long long HandleFollowPrivateMsgFriendListRequest(IRequestGetFollowPrivateMsgFriendListCallback* callback) {
    long long result = 0;
//    long mCallback = (long)callback;
    result = [[LMManagerOC manager] handleFollowPrivateMsgFriendListRequest:callback];
    return result;
}
void HandlePrivateMsgWithUserIdRequest(const string& userId, const string& startMsgId, PrivateMsgOrderType order, int limit, int reqId, IRequestGetPrivateMsgHistoryByIdCallback* callback) {
//    long mCallback = (long)callback;
//    NSString* strUserId = [NSString stringWithUTF8String:userId.c_str()];
//    NSString* strStartMsgId = [NSString stringWithUTF8String:startMsgId.c_str()];
//    [[LSRequestManager manager] getPrivateMsgWithUserId:strUserId startMsgId:strStartMsgId order:order limit:limit reqId:reqId callback:mCallback];
    [[LMManagerOC manager] handlePrivateMsgWithUserIdRequest:userId startMsgId:startMsgId order:order limit:limit reqId:reqId callback:callback];
    
}

long long HandleSetPrivateMsgReadedRequest(const string& userId, const string& msgId,IRequestSetPrivateMsgReadedCallback* callback) {
    long long result = 0;
//    NSString* strUserId = [NSString stringWithUTF8String:userId.c_str()];
//    NSString* strMsgId = [NSString stringWithUTF8String:msgId.c_str()];
//    long mCallback = (long)callback;
//    [[LSRequestManager manager] setPrivateMsgReaded:strUserId msgId:strMsgId callback:mCallback];
    result = [[LMManagerOC manager] handleSetPrivateMsgReadedRequest:userId msgId:msgId callback:callback];
    return result;
}


class LiveMessageManManagerCallback : public ILiveMessageManManagerListener {
  public:
    LiveMessageManManagerCallback(LMManagerOC *managerOC) {
        this->managerOC = managerOC;
    };
    virtual ~LiveMessageManManagerCallback(){};

  public:
    // 私信联系人有改变通知
    virtual void OnUpdateFriendListNotice(bool success, int errnum, const string& errmsg) override{
        if (nil != managerOC) {
            [managerOC onUpdateFriendListNotice:success errType:(HTTP_LCC_ERR_TYPE)errnum errMsg:errmsg];
        }
    }
//    virtual void OnLMGetPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const LMUserList& ContactList) override {
//        if (nil != managerOC) {
//           [managerOC onGetPrivateMsgFriendList:(HTTP_LCC_ERR_TYPE)errnum errMsg:errmsg ContactList:ContactList];
//        }
//    }
//    virtual void OnLMGetFollowPrivateMsgFriendList(long long requestId, bool success, int errnum, const string& errmsg, const LMUserList& followList) override {
//        if (nil != managerOC) {
//            [managerOC onGetFollowPrivateMsgFriendList:(HTTP_LCC_ERR_TYPE)errnum errMsg:errmsg followList:followList];
//        }
//    }
    virtual void OnLMRefreshPrivateMsgWithUserId(const string& userId, bool success, int errnum, const string& errmsg, const LMMessageList& msgList, int reqId) override {
        if (nil != managerOC) {
            [managerOC onRefreshPrivateMsgWithUserId:success errType:(HTTP_LCC_ERR_TYPE)errnum errMsg:errmsg userId:userId list:msgList reqId:reqId];
        }
    }
    virtual void OnLMGetMorePrivateMsgWithUserId(const string& userId, bool success, int errnum, const string& errmsg, const LMMessageList& msgList, int reqId, bool isMuchMore,  bool isInsertHead) override {
        if (nil != managerOC) {
                [managerOC onGetMorePrivateMsgWithUserId:success errType:(HTTP_LCC_ERR_TYPE)errnum errMsg:errmsg userId:userId list:msgList reqId:reqId];
        }
    }
    virtual void OnLMUpdatePrivateMsgWithUserId(const string& userId, const LMMessageList& msgList) override {
        if (nil != managerOC) {
            [managerOC onUpdatePrivateMsgWithUserId:userId msgList:msgList];
        }
    }
    
    // 提交阅读私信（用于私信聊天间，向服务器提交已读私信）回调
    virtual void OnLMSetPrivateMsgReaded(long long requestId, bool success, int errnum, const string& errmsg, bool isModify, const string& toId) override {
//        if (nil != managerOC) {
//            [managerOC onSetPrivateMsgReaded:(HTTP_LCC_ERR_TYPE)errnum errMsg:errmsg];
//        }
    }
    
    virtual void OnLMSendPrivateMessage(const string& userId, bool success, int errnum, const string& errmsg, LiveMessageItem* item) override {
        if (nil != managerOC) {
           [managerOC onSendPrivateMessage:success errType:(LCC_ERR_TYPE)errnum errMsg:errmsg item:item];
        }
    }
    
    // 接收私信消息（用于提示未读数接口调用）
    virtual void OnLMRecvPrivateMessage(LiveMessageItem* item) override {
        if (nil != managerOC) {
           [managerOC onRecvPrivateMessage:item];
        }
    }
    
    
    // 重发通知（上层按了重发，c层删除所有时间item（android不好删除可能有时间item），把所有发送给上层）
    virtual void OnRepeatSendPrivateMsgNotice(const string& userId, const LMMessageList& msgList)override {
        if (nil != managerOC) {
             [managerOC onRepeatSendPrivateMsgNotice:userId msgList:msgList];
        }
    }
    

  private:
    __weak typeof(LMManagerOC *) managerOC;
};

@implementation LMManagerOC

#pragma mark - 获取实例
+ (instancetype)manager {
    if (gLMManagerOC == nil) {
        gLMManagerOC = [[[self class] alloc] init];
    }
    return gLMManagerOC;
}

- (instancetype _Nullable)init {
    self = [super init];
    if (nil != self) {
        self.delegates = [NSMutableArray array];
        self.manager = ILiveMessageManManager::Create();
        self.lmManagerCallback = new LiveMessageManManagerCallback(self);
        // self.client->AddListener(self.lmManagerCallback);
    }
    return self;
}

- (void)dealloc {
    if (self.manager) {
        if (self.lmManagerCallback) {
            // self.manager->RemoveListener(self.lmManagerCallback);
            delete self.lmManagerCallback;
            self.lmManagerCallback = NULL;
        }

        ILiveMessageManManager::Release(self.manager);
        self.manager = NULL;
    }
}

- (BOOL)addDelegate:(id<LMMessageManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;
    NSLog(@"LMManagerOC::addDelegate( delegate : %@ )", delegate);

    @synchronized(self) {
        // 查找是否已存在
        for (NSValue *value in self.delegates) {
            id<LMMessageManagerDelegate> item = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                NSLog(@"LMManagerOC::addDelegate() add again, delegate:<%@>", delegate);
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

- (BOOL)removeDelegate:(id<LMMessageManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;

    NSLog(@"LMManagerOC::removeDelegate( delegate : %@ )", delegate);

    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<LMMessageManagerDelegate> item = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                result = YES;
                break;
            }
        }
    }

    // log
    if (!result) {
        NSLog(@"LMManagerOC::removeDelegate() fail, delegate:<%@>", delegate);
    }

    return result;
}

- (void)setHttpRequestDelegate:(id<LMHandleHttpListenerDelegate> _Nonnull)delegate {
    NSLog(@"LMManagerOC::setHttpRequestDelegate( delegate : %@ )", delegate);
    if (self.httpRequestDelegates) {
        self.httpRequestDelegates = nil;
    }
    self.httpRequestDelegates = delegate;

}

//- (SEQ_T)getReqId {
//    SEQ_T reqId = 0;
//    if (NULL != self.client) {
//        reqId = self.client->GetReqId();
//    }
//    return reqId;
//}


- (BOOL)initManager:(long)imClient {
    BOOL result = NO;
    IImClient* client = (IImClient*)imClient;
    if (client != NULL && self.lmManagerCallback != NULL) {
        result = self.manager->Init(client, gHttpRequestPrivateMsgControllerHandler, self.lmManagerCallback);
    }
    
    return result;
}

- (BOOL)setManagerInfo:(NSString* _Nullable)userId privateNotice:(NSString* _Nullable)privateNotice {
    BOOL result = NO;
    
    string strUserId = "";
    if ( nil != userId) {
        strUserId = [userId UTF8String];
    }
    string strPrivateNotice = "";
    if ( nil != privateNotice) {
        strPrivateNotice = [privateNotice UTF8String];
    }
    if (NULL != self.manager) {
        PrivateSupportTypeList supportList;
        supportList.push_back(LMPMSType_Text);
        result = self.manager->InitUserInfo(strUserId, supportList, strPrivateNotice);

    }
    return result;
}

#pragma mark - 获取本地联系人列表
- (NSArray<LMPrivateMsgContactObject*>* _Nullable)getLocalPrivateMsgFriendList {
    NSMutableArray* array = nil;
    if (NULL != self.manager) {
        array = [self transformHttpContactListToOCContactList:self.manager->GetLocalPrivateMsgFriendList()];
    }
    return array;
}

- (BOOL)getPrivateMsgFriendList {
    BOOL result = NO;
    if (NULL != self.manager) {
        result = self.manager->GetPrivateMsgFriendList();
    }
    return result;
}

- (NSArray<LMPrivateMsgContactObject*>* _Nullable)getLocalFollowPrivateMsgFriendList {
    NSMutableArray* array = nil;
    if (NULL != self.manager) {
        array = [self transformHttpContactListToOCContactList:self.manager->GetLocalFollowPrivateMsgFriendList()];
    }
    return array;
}

- (BOOL)getFollowPrivateMsgFriendList {
    BOOL result = NO;
    if (NULL != self.manager) {
        result = self.manager->GetFollowPrivateMsgFriendList();
    }
    return result;
}

- (BOOL)addPrivateMsgLiveChat:(NSString* _Nonnull)userId {
    BOOL result = NO;
    string strUserId = "";
    if ( nil != userId) {
        strUserId = [userId UTF8String];
    }
    if (NULL != self.manager
        && strUserId.length() > 0) {
        result = self.manager->AddPrivateMsgLiveChat(strUserId);
    }
    return result;
}

- (BOOL)removePrivateMsgLiveChat:(NSString* _Nonnull)userId {
    BOOL result = NO;
    string strUserId = "";
    if ( nil != userId) {
        strUserId = [userId UTF8String];
    }
    if (NULL != self.manager
        && strUserId.length() > 0) {
        result = self.manager->RemovePrivateMsgLiveChat(strUserId);
    }
    return result;
}

#pragma mark - 私信消息公共操作
- (NSArray<LMMessageItemObject*>* _Nullable)getLocalPrivateMsgWithUserId:(NSString* _Nonnull)userId {
    NSMutableArray* array = nil;
    string strUserId = "";
    if ( nil != userId) {
        strUserId = [userId UTF8String];
    }
    if (NULL != self.manager
        && strUserId.length() > 0) {
        array =  [self transformLiveMessageListToOCLiveMessageList:(self.manager->GetLocalPrivateMsgWithUserId(strUserId))];
    }
    return array;
}

- (int)refreshPrivateMsgWithUserId:(NSString* _Nonnull)userId {
    int result = 0;
    string strUserId = "";
    if ( nil != userId) {
        strUserId = [userId UTF8String];
    }
    if (NULL != self.manager
        && strUserId.length() > 0) {
        result = self.manager->RefreshPrivateMsgWithUserId(strUserId);
    }
    return result;
}

- (int)getMorePrivateMsgWithUserId:(NSString* _Nonnull)userId {
    int result = 0;
    string strUserId = "";
    if ( nil != userId) {
        strUserId = [userId UTF8String];
    }
    if (NULL != self.manager
        && strUserId.length() > 0) {
        result = self.manager->GetMorePrivateMsgWithUserId(strUserId);
    }
    return result;
}

- (BOOL)setPrivateMsgReaded:(NSString* _Nonnull)userId {
    BOOL result = NO;
    string strUserId = "";
    if ( nil != userId) {
        strUserId = [userId UTF8String];
    }
    if (NULL != self.manager
        && strUserId.length() > 0) {
        result = self.manager->SetPrivateMsgReaded(strUserId);
    }
    return result;
}

#pragma mark - 发送私信
- (BOOL)sendPrivateMessage:(NSString* _Nonnull)userId message:(NSString* _Nonnull)message {
    BOOL result = NO;
    string strUserId = "";
    if ( nil != userId) {
        strUserId = [userId UTF8String];
    }
    string strMessage = "";
    if (nil != message) {
        strMessage = [message UTF8String];
    }
    if (NULL != self.manager
        && strMessage.length() > 0
        && strUserId.length() > 0) {
        result = self.manager->SendPrivateMessage(strUserId, strMessage);
    }
    return result;
}

- (BOOL)repeatSendPrivateMsg:(NSString* _Nonnull)userId sendMsgId:(int)sendMsgId {
    BOOL result = NO;
    string strUserId = "";
    if ( nil != userId) {
        strUserId = [userId UTF8String];
    }
    if (NULL != self.manager
        && strUserId.length() > 0
        && sendMsgId > 0) {
        result = self.manager->RepeatSendPrivateMsg(strUserId, sendMsgId);
    }
    return result;
}


- (BOOL)isHasMorePrivateMsgWithUserId:(NSString* _Nonnull)userId {
    BOOL result = YES;
    string strUserId = "";
    if ( nil != userId) {
        strUserId = [userId UTF8String];
    }
    if (NULL != self.manager
        && strUserId.length()) {
        result = self.manager->IsHasMorePrivateMsgWithUserId(strUserId);
    }
    return result;
}

#pragma mark - 公共操作
- (LMPrivateMsgContactObject* _Nonnull)transformHttpContactToOCContact:(LMUserItem*)item {
    LMPrivateMsgContactObject* obj = [[LMPrivateMsgContactObject alloc] init];
    // 这里加锁，防止在转换时，用户信息被修改（但有一个问题，如果删除用户，可能导致内存泄露，以后如果有删除用户的，可能就要修改了）
    item->Lock();
    obj.userId = [NSString stringWithUTF8String:item->m_userId.c_str()];
    obj.nickName = [NSString stringWithUTF8String:item->m_userName.c_str()];
    obj.avatarImg = [NSString stringWithUTF8String:item->m_imageUrl.c_str()];
    obj.onlineStatus = item->m_onlineStatus;
    obj.lastMsg = [NSString stringWithUTF8String:item->m_lastMsg.c_str()];
    obj.updateTime = item->m_updateTime;
    obj.unreadNum = item->m_unreadNum;
    obj.isAnchor = item->m_isAnchor;
    item->Unlock();
    return obj;
}

- (NSMutableArray*)transformHttpContactListToOCContactList:(const LMUserList&)list {
    NSMutableArray* array = [NSMutableArray array];
    for (LMUserList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
        LMPrivateMsgContactObject *obj = [self transformHttpContactToOCContact:(*iter)];
        if (nil != obj) {
             [array addObject:obj];
        }
    }
    return array;
}

- (LMMessageItemObject* _Nonnull)transformLiveMessageToOCLiveMessage:(LiveMessageItem*)item {
    LMMessageItemObject* obj = [[LMMessageItemObject alloc] init];
    obj.sendMsgId = item->m_sendMsgId;
    obj.msgId = item->m_msgId;
    obj.sendType = item->m_sendType;
    obj.fromId = [NSString stringWithUTF8String:item->m_fromId.c_str()];
    obj.toId = [NSString stringWithUTF8String:item->m_toId.c_str()];
    obj.createTime = item->m_createTime;
    obj.statusType = item->m_statusType;
    obj.msgType = item->m_msgType;
    obj.sendErr = item->m_sendErr;
    obj.userItem = [self transformHttpContactToOCContact:item->GetUserItem()];
    switch (item->m_msgType) {
        case LMMT_Unknow:
            break;
        case LMMT_Text: {
            obj.privateItem = [self transformPrivateMsgToOCPrivateMsg:item->GetPrivateMsgItem()];
        } break;
        case LMMT_SystemWarn: {
            LMSystemNoticeItemObject* sysItemObj = [[LMSystemNoticeItemObject alloc] init];
            sysItemObj.message = [NSString stringWithUTF8String:item->GetSystemItem()->m_message.c_str()];
            sysItemObj.systemType = item->GetSystemItem()->m_systemType;
            obj.systemItem = sysItemObj;
        } break;
        case LMMT_Warning: {
            LMWarningItemObject* warningItemObj = [[LMWarningItemObject alloc] init];
            warningItemObj.warnType = item->GetWarningItem()->m_warnType;
            obj.warningItem = warningItemObj;
        } break;
        case LMMT_Time: {
            LMTimeMsgItemObject* timeMsgItemObj = [[LMTimeMsgItemObject alloc] init];
            timeMsgItemObj.msgTime = item->GetTimeMsgItem()->m_msgTime;
            obj.timeMsgItem = timeMsgItemObj;
        } break;
        default:
            break;
    }
    
    return obj;
}

- (NSMutableArray* _Nullable)transformLiveMessageListToOCLiveMessageList:(const LMMessageList&)list {
    NSMutableArray* array = [NSMutableArray array];
    for (LMMessageList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
        LMMessageItemObject *obj = [self transformLiveMessageToOCLiveMessage:(*iter)];
        if (nil != obj) {
            [array addObject:obj];
        }
    }
    return array;
}

- (LMPrivateMsgItemObject* _Nullable)transformPrivateMsgToOCPrivateMsg:(LMPrivateMsgItem*)item {
    LMPrivateMsgItemObject* obj = nil;
    if (NULL != item) {
        obj = [[LMPrivateMsgItemObject alloc] init];
        obj.message = [NSString stringWithUTF8String:item->m_message.c_str()];
    }
    return obj;
}

#pragma mark - 私信联系人 listener(http接口的返回)
//- (void)onGetPrivateMsgFriendList:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg ContactList:(const LMUserList&)ContactList {
//    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
//    NSMutableArray* array = [self transformHttpContactListToOCContactList:ContactList];
//    @synchronized(self) {
//        for (NSValue *value in self.delegates) {
//            id<LMMessageManagerDelegate> delegate = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
//            if ([delegate respondsToSelector:@selector(onGetPrivateMsgFriendList:errMsg:ContactList:)]) {
//                [delegate onGetPrivateMsgFriendList:errType errMsg:nsErrMsg ContactList:array];
//            }
//        }
//    }
//}
//
//- (void)onGetFollowPrivateMsgFriendList:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg  followList:(const LMUserList&)followList {
//    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
//    NSMutableArray* array = [self transformHttpContactListToOCContactList:followList];
//    @synchronized(self) {
//        for (NSValue *value in self.delegates) {
//            id<LMMessageManagerDelegate> delegate = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
//            if ([delegate respondsToSelector:@selector(onGetFollowPrivateMsgFriendList:errMsg:followList:)]) {
//                [delegate onGetFollowPrivateMsgFriendList:errType errMsg:nsErrMsg followList:array];
//            }
//        }
//    }
//}

- (void)onUpdateFriendListNotice:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<LMMessageManagerDelegate> delegate = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onUpdateFriendListNotice:errType:errMsg:)]) {
                [delegate onUpdateFriendListNotice:success errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

#pragma mark - 私信消息公共操作

- (void)onRefreshPrivateMsgWithUserId:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg userId:(const string &)userId list:(const LMMessageList&)list reqId:(int)reqId{
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSMutableArray* array = [self transformLiveMessageListToOCLiveMessageList:list];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<LMMessageManagerDelegate> delegate = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRefreshPrivateMsgWithUserId:errType:errMsg:userId:list:reqId:)]) {
                [delegate onRefreshPrivateMsgWithUserId:success errType:errType errMsg:nsErrMsg userId:nsUserId list:array reqId:reqId];
            }
        }
    }
}


- (void)onGetMorePrivateMsgWithUserId:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg userId:(const string &)userId list:(const LMMessageList&)list reqId:(int)reqId {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSMutableArray* array = [self transformLiveMessageListToOCLiveMessageList:list];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<LMMessageManagerDelegate> delegate = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetMorePrivateMsgWithUserId:errType:errMsg:userId:list:reqId:)]) {
                [delegate onGetMorePrivateMsgWithUserId:success errType:errType errMsg:nsErrMsg userId:nsUserId list:array reqId:reqId];
            }
        }
    }
}

- (void)onUpdatePrivateMsgWithUserId:(const string &)userId msgList:(const LMMessageList&)msgList {
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSMutableArray* array = [self transformLiveMessageListToOCLiveMessageList:msgList];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<LMMessageManagerDelegate> delegate = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onUpdatePrivateMsgWithUserId:msgList:)]) {
                [delegate onUpdatePrivateMsgWithUserId:nsUserId msgList:array];
            }
        }
    }
}

//- (void)onSetPrivateMsgReaded:(HTTP_LCC_ERR_TYPE)errType errMsg:(const string &)errmsg {
//    NSString *nsErrmsg = [NSString stringWithUTF8String:errmsg.c_str()];
//    @synchronized(self) {
//        for (NSValue *value in self.delegates) {
//            id<LMMessageManagerDelegate> delegate = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
//            if ([delegate respondsToSelector:@selector(onSetPrivateMsgReaded:errMsg:)]) {
//                [delegate onSetPrivateMsgReaded:errType errMsg:nsErrmsg];
//            }
//        }
//    }
//}

#pragma mark - 私信listener
- (void)onSendPrivateMessage:(BOOL)success errType:(LCC_ERR_TYPE)errType errMsg:(const string &)errmsg item:(LiveMessageItem*)item {
    NSString *nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    LMMessageItemObject* obj = [self transformLiveMessageToOCLiveMessage:item];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<LMMessageManagerDelegate> delegate = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onSendPrivateMessage:errType:errMsg:item:)]) {
                [delegate onSendPrivateMessage:success errType:errType errMsg:nsErrMsg item:obj];
            }
        }
    }
}

- (void)onRepeatSendPrivateMsgNotice:(const string &)userId msgList:(const LMMessageList&)msgList {
    NSString *nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSMutableArray* array = [self transformLiveMessageListToOCLiveMessageList:msgList];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<LMMessageManagerDelegate> delegate = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRepeatSendPrivateMsgNotice:msgList:)]) {
                [delegate onRepeatSendPrivateMsgNotice:nsUserId msgList:array];
            }
        }
    }
}


- (void)onRecvPrivateMessage:(LiveMessageItem*)item {
    LMMessageItemObject* obj = [self transformLiveMessageToOCLiveMessage:item];
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<LMMessageManagerDelegate> delegate = (id<LMMessageManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onRecvPrivateMessage:)]) {
                [delegate onRecvPrivateMessage:obj];
            }
        }
    }
}


- (long long) handlePrivateMsgFriendListRequest:(IRequestGetPrivateMsgFriendListCallback*)callback {
    long long result = 0;
    long mCallback = (long)callback;
    if (self.httpRequestDelegates && [self.httpRequestDelegates respondsToSelector:@selector(onHandlePrivateMsgFriendListRequest:)]) {
                result = [self.httpRequestDelegates onHandlePrivateMsgFriendListRequest:mCallback];
    }

    return result;
}

- (long long) handleFollowPrivateMsgFriendListRequest:(IRequestGetFollowPrivateMsgFriendListCallback*)callback {
    long long result = 0;
    long mCallback = (long)callback;
    if (self.httpRequestDelegates && [self.httpRequestDelegates respondsToSelector:@selector(onHandleFollowPrivateMsgFriendListRequest:)]) {
            result = [self.httpRequestDelegates onHandleFollowPrivateMsgFriendListRequest:mCallback];
    }
    return result;
}

- (void) handlePrivateMsgWithUserIdRequest:(const string &)userId startMsgId:(const string &)startMsgId order:(PrivateMsgOrderType)order limit:(int)limit reqId:(int)reqId callback:(IRequestGetPrivateMsgHistoryByIdCallback*)callback {
    long mCallback = (long)callback;
    NSString* strUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString* strStartMsgId = [NSString stringWithUTF8String:startMsgId.c_str()];
    if (self.httpRequestDelegates && [self.httpRequestDelegates respondsToSelector:@selector(onHandlePrivateMsgWithUserIdRequest:startMsgId:order:limit:reqId:callback:)]) {
                [self.httpRequestDelegates onHandlePrivateMsgWithUserIdRequest:strUserId startMsgId:strStartMsgId order:order limit:limit reqId:reqId callback:mCallback];
    }
}

- (long long) handleSetPrivateMsgReadedRequest:(const string &)userId msgId:(const string &)msgId callback:(IRequestSetPrivateMsgReadedCallback*)callback {
    long long result = 0;
    long mCallback = (long)callback;
    NSString* strUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString* strMsgId = [NSString stringWithUTF8String:msgId.c_str()];

    if (self.httpRequestDelegates && [self.httpRequestDelegates respondsToSelector:@selector(onHandleSetPrivateMsgReadedRequest:msgId:callback:)]) {
        result = [self.httpRequestDelegates onHandleSetPrivateMsgReadedRequest:strUserId msgId:strMsgId callback:mCallback];
    }

    return result;
}

@end


