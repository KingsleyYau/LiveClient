//
//  ImClientOC.m
//  ImClient_iOS_t
//
//  Created by  Samson on 27/05/2017.
//  Copyright © 2017 Samson. All rights reserved.
//

#import "ImClientOC.h"
#include "IImClient.h"

static ImClientOC* gClientOC = nil;
class ImClientCallback;

@interface ImClientOC() {

}

@property (nonatomic, assign) IImClient* client;
@property (nonatomic, strong) NSMutableArray* delegates;
@property (nonatomic, assign) ImClientCallback *imClientCallback;

#pragma mark - 登录/注销回调
/**
 *  登录回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 */
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg;

/**
 *  注销回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 */
- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg;

/**
 *  2.4.用户被挤掉线回调
 *
 *  @param reason     被挤掉理由
 */
- (void)onKickOff:(const string&)reason;

#pragma mark - 直播间主动操作回调
/**
 *  观众进入直播间回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param userId      主播ID
 *  @param nickName    主播昵称
 *  @param photoUrl    主播头像url
 *  @param country     主播国家/地区
 *  @param videoUrls   视频流url（字符串数组）
 *  @param fansNum     观众人数
 *  @param contribute  贡献值
 *  @param fansList    前n个观众信息（用于显示用户头像列表数组）
 *
 */
- (void)onFansRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg userId:(const string&)userId nickName:(const string&)nickName photoUrl:(const string&)photoUrl country:(const string&)country videoUrls:(const list<string>)videoUrls fansNum:(int)fansNum contribute:(int)contribute fansList:(const RoomTopFanList&)fansList;
/**
 *  观众退出直播间回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onFansRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg;
/**
 *  获取直播间信息回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param fansNum     观众人数
 *  @param contribute  贡献值
 *
 */
- (void)onGetRoomInfo:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg fansNum:(int)fansNum contribute:(int)contribute;

/**
 *  3.7.主播禁言观众（直播端把制定观众禁言）回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onFansShutUp:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg;

/**
 *  3.9.主播踢观众出直播间（主播端把指定观众踢出直播间）回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onFansKickOffRoom:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg;


#pragma mark - 直播间接收操作回调
/**
 *  接收直播间关闭通知(观众)回调
 *
 *  @param roomId      直播间ID
 *  @param userId      直播ID
 *  @param nickName    直播昵称
 *  @param fansNum     观众人数
 *
 */
- (void)onRecvRoomCloseFans:(const string&)roomId userId:(const string&)userId nickName:(const string&)nickName fansNum:(int)fansNum;
/**
 *  接收直播间关闭通知(直播)回调
 *
 *  @param roomId      直播间ID
 *  @param fansNum     观众人数
 *  @param income      收入
 *  @param newFans     新收藏人数
 *  @param shares      分享数
 *  @param duration    直播时长
 *
 */
- (void)onRecvRoomCloseBroad:(const string&)roomId fansNum:(int)fansNum income:(int)income newFans:(int)newFans shares:(int)shares duration:(int)duration;
/**
 *  接收观众进入直播间通知回调
 *
 *  @param roomId      直播间ID
 *  @param userId      观众ID
 *  @param nickName    观众昵称
 *  @param photoUrl    观众头像url
 *
 */
- (void)onRecvFansRoomIn:(const string&)roomId userId:(const string&)userId nickName:(const string&)nickName photoUrl:(const string&)photoUrl;

/**
 *  3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）回调
 *
 *  @param roomId      直播间ID
 *  @param userId      被禁言用户ID
 *  @param nickName    被禁言用户昵称
 *  @param timeOut     禁言时长
 *
 */
- (void)onRecvShutUpNotice:(const string&)roomId userId:(const string&)userId nickName:(const string&)nickName timeOut:(int)timeOut;
/**
 *  3.10.接收观众踢出直播间通知（观众端／主播端接收观众踢出直播间通知）回调
 *
 *  @param roomId      直播间ID
 *  @param userId      被禁言用户ID
 *  @param nickName    被禁言用户昵称
 *
 */
- (void)onRecvKickOffRoomNotice:(const string&)roomId userId:(const string&)userId nickName:(const string&)nickName;

#pragma mark - 直播间文本消息信息
/**
 *  发送直播间文本消息回调
 *
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onSendRoomMsg:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg;
/**
 *  接收直播间文本消息通知回调
 *
 *  @param roomId      直播间ID
 *  @param level       发送方级别
 *  @param fromId      发送方的用户ID
 *  @param nickName    发送方的昵称
 *  @param msg         文本消息内容
 *
 */
- (void)onRecvRoomMsg:(const string&)roomId level:(int)level fromId:(const string&)fromId nickName:(const string&)nickName msg:(const string&)msg;

#pragma mark - 直播间点赞操作回调
/**
 *  5.1.发送直播间点赞消息（观众端向直播间发送点赞消息）回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *
 */
- (void)onSendRoomFav:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg;
/**
 *  5.2.接收直播间点赞通知（观众端／主播端接收服务器的直播间点赞通知）回调
 *
 *  @param roomId      直播间ID
 *  @param fromId      发送方的用户ID
 *  @param nickName    发送人昵称
 *  @param isFirst     是否第一次点赞
 *
 */
- (void)onRecvPushRoomFav:(const string&)roomId fromId:(const string&)fromId nickName:(const string&)nickName isFirst:(bool)isFirst;

#pragma mark - 直播间礼物消息操作回调
/**
 *  6.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param coins       剩余金币数
 *
 */
- (void)onSendRoomGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg coins:(double)coins;
/**
 *  6.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）回调
 *
 *  @param roomId               直播间ID
 *  @param fromId               发送方的用户ID
 *  @param nickName             发送方的昵称
 *  @param giftId               礼物ID
 *  @param giftNum              本次发送礼物的数量
 *  @param multi_click          是否连击礼物
 *  @param multi_click_start    连击起始数
 *  @param multi_click_end      连击结束数
 *  @param multi_click_id       连击ID相同则表示同一次连击
 *
 */
- (void)onRecvRoomGiftNotice:(const string&)roomId fromId:(const string&)fromId nickName:(const string&)nickName giftId:(const string&)giftId giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id;

#pragma mark - 直播间弹幕消息操作回调
/**
 *  7.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）回调
 *
 *  @param success     操作是否成功
 *  @param reqId       请求序列号
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param coins       剩余金币数
 *
 */
- (void)onSendRoomToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg coins:(double)coins;
/**
 *  7.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）回调
 *
 *  @param roomId               直播间ID
 *  @param fromId               发送方的用户ID
 *  @param nickName             发送方的昵称
 *  @param msg                  消息内容
 *
 */
- (void)onRecvRoomToastNotice:(const string&)roomId fromId:(const string&)fromId nickName:(const string&)nickName msg:(const string&)msg;

@end

class ImClientCallback : public IImClientListener
{
public:
    ImClientCallback(ImClientOC* clientOC) {
        this->clientOC = clientOC;
    };
    virtual ~ImClientCallback() {};
    
public:
    virtual void OnLogin(LCC_ERR_TYPE err, const string& errmsg) {
        NSLog(@"OnLogin() err:%d, errmsg:%s"
              , err, errmsg.c_str());
        if (nil != clientOC) {
            [clientOC onLogin:err errMsg:errmsg];
        }
    }
    virtual void OnLogout(LCC_ERR_TYPE err, const string& errmsg) {
        NSLog(@"OnLogout() err:%d, errmsg:%s"
              , err, errmsg.c_str());
        if (nil != clientOC) {
            [clientOC onLogout:err errMsg:errmsg];
        }
    }
    virtual void OnKickOff(const string reason)  {
        NSLog(@"OnKickOff() reason:%s"
              , reason.c_str());
        if (nil != clientOC) {
            [clientOC onKickOff:reason];
        }
    }
    virtual void OnFansRoomIn(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, const string& userId, const string& nickName, const string& photoUrl, const string& country, const list<string>& videoUrls, int fansNum, int contribute, const RoomTopFanList& fans)
    {
        NSLog(@"OnFansRoomIn() err:%d, errmsg:%s"
              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onFansRoomIn:success reqId:reqId errType:err errMsg:errMsg userId:userId nickName:nickName photoUrl:photoUrl country:country videoUrls:videoUrls fansNum:fansNum contribute:contribute fansList:fans];
        }
    }
    virtual void OnFansRoomOut(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg)
    {
        NSLog(@"OnFansRoomOut() err:%d, errmsg:%s"
              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onFansRoomOut:success reqId:reqId errType:err errMsg:errMsg];
        }
    }
    virtual void OnGetRoomInfo(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, int fansNum, int contribute)
    {
        NSLog(@"OnGetRoomInfo() err:%d, errmsg:%s"
              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onGetRoomInfo:success reqId:reqId errType:err errMsg:errMsg fansNum:fansNum contribute:contribute];
        }
    }
    // 3.7.主播禁言观众（直播端把制定观众禁言）
    virtual void OnFansShutUp(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {
        NSLog(@"OnFansShutUp() err:%d, errmsg:%s"
              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onFansShutUp:success reqId:reqId errType:err errMsg:errMsg];
        }
    }
    // 3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）
    virtual void OnRecvShutUpNotice(const string& roomId, const string& userId, const string& nickName, int timeOut) {
        NSLog(@"OnRecvShutUpNotice()");
        if (nil != clientOC) {
            [clientOC onRecvShutUpNotice:roomId userId:userId nickName:nickName timeOut:timeOut];
        }
    }
    // 3.9.主播踢观众出直播间（主播端把指定观众踢出直播间）
    virtual void OnFansKickOffRoom(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {
        NSLog(@"OnFansKickOffRoom() err:%d, errmsg:%s"
              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onFansKickOffRoom:success reqId:reqId errType:err errMsg:errMsg];
        }
    }
    // 3.10.接收观众踢出直播间通知（观众端／主播端接收观众踢出直播间通知）
    virtual void OnRecvKickOffRoomNotice(const string& roomId, const string& userId, const string& nickName) {
        NSLog(@"OnRecvKickOffNoticeRoom()");
        if (nil != clientOC) {
            [clientOC onRecvKickOffRoomNotice:roomId userId:userId nickName:nickName];
        }
    }
    virtual void OnSendRoomMsg(SEQ_T reqId, LCC_ERR_TYPE err, const string& errMsg)
    {
        NSLog(@"OnSendRoomMsg() err:%d, errmsg:%s"
              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onSendRoomMsg:reqId errType:err errMsg:errMsg];
        }
    }
    virtual void OnRecvRoomCloseFans(const string& roomId, const string& userId, const string& nickName, int fansNum)
    {
        NSLog(@"OnRecvRoomCloseFans() roomId:%s, userId:%s, nickName:%s, fansNum:%d"
              , roomId.c_str(), userId.c_str(), nickName.c_str(), fansNum);
        if (nil != clientOC) {
            [clientOC onRecvRoomCloseFans:roomId userId:userId nickName:nickName fansNum:fansNum];
        }
    }
    virtual void OnRecvRoomCloseBroad(const string& roomId, int fansNum, int inCome, int newFans, int shares, int duration)
    {
        NSLog(@"OnRecvRoomCloseFans() roomId:%s, fansNum:%d, inCome:%d, newFans:%d shares:%d duration:%d"
              , roomId.c_str(), fansNum, inCome, newFans, shares, duration);
        if (nil != clientOC) {
            [clientOC onRecvRoomCloseBroad:roomId fansNum:fansNum income:inCome newFans:newFans shares:shares duration:duration];
        }
    }
    virtual void OnRecvFansRoomIn(const string& roomId, const string& userId, const string& nickName, const string& photoUrl)
    {
        NSLog(@"OnRecvRoomCloseFans() roomId:%s, userId:%s, nickName:%s, photoUrl:%s"
              , roomId.c_str(), userId.c_str(), nickName.c_str(), photoUrl.c_str());
        if (nil != clientOC) {
            [clientOC onRecvFansRoomIn:roomId userId:userId nickName:nickName photoUrl:photoUrl];
        }
    }
    virtual void OnRecvRoomMsg(const string& roomId, int level, const string& fromId, const string& nickName, const string& msg)
    {
        NSLog(@"OnRecvRoomCloseFans() roomId:%s, level:%d ,fromId:%s, nickName:%s, msg:%s"
              , roomId.c_str(), level, fromId.c_str(), nickName.c_str(), msg.c_str());
        if (nil != clientOC) {
            [clientOC onRecvRoomMsg:roomId level:level fromId:fromId nickName:nickName msg:msg];
        }
    }
    
    // ------------- 直播间点赞 -------------
    // 5.1.发送直播间点赞消息（观众端向直播间发送点赞消息）
    virtual void OnSendRoomFav(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg) {
        NSLog(@"OnSendRoomFav() err:%d, errmsg:%s"
              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onSendRoomFav:success reqId:reqId errType:err errMsg:errMsg];
        }
    }
    // 5.2.接收直播间点赞通知（观众端／主播端接收服务器的直播间点赞通知）
    virtual void OnRecvPushRoomFav(const string& roomId, const string& fromId, const string& nickName, bool isFirst) {
        NSLog(@"OnRecvPushRoomFav()");
        if (nil != clientOC) {
            [clientOC onRecvPushRoomFav:roomId fromId:fromId nickName:nickName isFirst:isFirst];
        }
    }
    
    // ------------- 直播间点赞 -------------
    // 6.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
    virtual void OnSendRoomGift(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double coins) {
        NSLog(@"OnSendRoomGift() err:%d, errmsg:%s"
              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onSendRoomGift:success reqId:reqId errType:err errMsg:errMsg coins:coins];
        }
    }
    
    // 6.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
    virtual void OnRecvRoomGiftNotice(const string& roomId, const string& fromId, const string& nickName, const string& giftId, int giftNum, bool multi_click, int multi_click_start, int multi_click_end, int multi_click_id) {
        NSLog(@"OnRecvRoomGiftNotice()");
        if (nil != clientOC) {
            [clientOC onRecvRoomGiftNotice:roomId fromId:fromId nickName:nickName giftId:giftId giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id];
        }
    }
    
    // ------------- 直播间弹幕消息 -------------
    // 7.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
    virtual void OnSendRoomToast(SEQ_T reqId, bool success, LCC_ERR_TYPE err, const string& errMsg, double coins) {
        NSLog(@"OnSendRoomToast() err:%d, errmsg:%s"
              , err, errMsg.c_str());
        if (nil != clientOC) {
            [clientOC onSendRoomToast:success reqId:reqId errType:err errMsg:errMsg coins:coins];
        }
    }
    // 7.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
    virtual void OnRecvRoomToastNotice(const string& roomId, const string& fromId, const string& nickName, const string& msg) {
        NSLog(@"OnRecvRoomToastNotice()");
        if (nil != clientOC) {
            [clientOC onRecvRoomToastNotice:roomId fromId:fromId nickName:nickName msg:msg];
        }
    }
    
private:
    __weak typeof(ImClientOC *) clientOC;
};

@implementation ImClientOC

#pragma mark - 获取实例
+ (instancetype)manager
{
    if (gClientOC == nil) {
        gClientOC = [[[self class] alloc] init];
    }
    return gClientOC;
}

- (instancetype _Nullable)init
{
    self = [super init];
    if (nil != self) {
        self.delegates = [NSMutableArray array];
        self.client = IImClient::CreateClient();
        self.imClientCallback = new ImClientCallback(self);
        self.client->AddListener(self.imClientCallback);
    }
    return self;
}

- (void)dealloc
{
    if( self.client ) {
        if( self.imClientCallback ) {
            self.client->RemoveListener(self.imClientCallback);
            delete self.imClientCallback;
            self.imClientCallback = NULL;
        }
        
        IImClient::ReleaseClient(self.client);
        self.client = NULL;
    }
}

- (BOOL)addDelegate:(id<IMLiveRoomManagerDelegate> _Nonnull)delegate
{
    BOOL result = NO;
    
    @synchronized(self.delegates)
    {
        // 查找是否已存在
        for(NSValue* value in self.delegates) {
            id<IMLiveRoomManagerDelegate> item = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                NSLog(@"ImClientOC::addDelegate() add again, delegate:<%@>", delegate);
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

- (BOOL)removeDelegate:(id<IMLiveRoomManagerDelegate> _Nonnull)delegate
{
    BOOL result = NO;
    
    @synchronized(self.delegates)
    {
        for(NSValue* value in self.delegates) {
            id<IMLiveRoomManagerDelegate> item = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
                [self.delegates removeObject:value];
                result = YES;
                break;
            }
        }
        
    }
    
    // log
    if (!result) {
        NSLog(@"ImClientOC::removeDelegate() fail, delegate:<%@>", delegate);
    }
    
    return result;
}

- (BOOL)initClient:(NSArray<NSString*>* _Nonnull)urls
{
    BOOL result = NO;
    if (NULL != self.client) {
        list<string> strUrls;
        for (NSString* url in urls) {
            if (nil != url) {
                strUrls.push_back([url UTF8String]);
            }
        }
        result = self.client->Init(strUrls);
    }
    return result;
}

- (BOOL)login:(NSString* _Nonnull)userId token:(NSString* _Nonnull)token
{
    BOOL result = NO;
    if (NULL != self.client) {
        string strUserId;
        if (nil != userId) {
            strUserId = [userId UTF8String];
        }
        
        string strToken;
        if (nil != token) {
            strToken = [token UTF8String];
        }
        
        result = self.client->Login(strUserId, strToken, CLIENTTYPE_IOS);
    }
    return result;
}

- (BOOL)logout
{
    BOOL result = NO;
    if (NULL != self.client) {
        result = self.client->Logout();
    }
    return result;
}

- (BOOL)fansRoomIn:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId
{
    BOOL result = NO;
    if (NULL != self.client) {

        string strToken;
        if (nil != token) {
            strToken = [token UTF8String];
        }
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        result = self.client->FansRoomIn(0, strToken, strRoomId);
    }
    return result;
}

- (BOOL)fansRoomout:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId
{
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strToken;
        if (nil != token) {
            strToken = [token UTF8String];
        }
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        result = self.client->FansRoomOut(0, strToken, strRoomId);
    }
    return result;
}

- (BOOL)getRoomInfo:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId
{
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strToken;
        if (nil != token) {
            strToken = [token UTF8String];
        }
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        result = self.client->GetRoomInfo(0, strToken, strRoomId);
    }
    return result;
}

- (BOOL)fansShutUp:(NSString *)roomId userId:(NSString *)userId timeOut:(int)timeOut
{
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        string strUserId;
        if (nil != userId) {
            strUserId = [userId UTF8String];
        }
        
        result = self.client->FansShutUp(0, strRoomId, strUserId, timeOut);
    }
    return result;
}

- (BOOL)fansKickOffRoom:(NSString* _Nonnull)roomId userId:(NSString* _Nonnull)userId
{
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        string strUserId;
        if (nil != userId) {
            strUserId = [userId UTF8String];
        }
        
        result = self.client->FansKickOffRoom(0, strRoomId, strUserId);
    }
    return result;
}

- (BOOL)sendRoomMsg:(NSString* _Nonnull)token roomId:(NSString* _Nonnull)roomId nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg
{
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strToken;
        if (nil != token) {
            strToken = [token UTF8String];
        }
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        string strName;
        if (nil != nickName) {
            strName = [nickName UTF8String];
        }
        string strMsg;
        if (nil != msg) {
            strMsg = [msg UTF8String];
        }
        
        result = self.client->SendRoomMsg(0, strToken, strRoomId, strName, strMsg);
    }
    return result;
}

- (BOOL)sendRoomFav:(NSString* _Nonnull)roomId token:(NSString* _Nonnull)token nickName:(NSString * _Nonnull)nickName
{
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        string strToken;
        if (nil != token) {
            strToken = [token UTF8String];
        }
        
        string strNickName;
        if (nil != nickName) {
            strNickName = [nickName UTF8String];
        }
        
        result = self.client->SendRoomFav(0, strRoomId, strToken, strNickName);
    }
    return result;
}

- (BOOL)sendRoomGift:(NSString* _Nonnull)roomId token:(NSString* _Nonnull)token nickName:(NSString* _Nonnull)nickName giftId:(NSString* _Nonnull)giftId giftName:(NSString* _Nonnull)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id
{
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        string strToken;
        if (nil != token) {
            strToken = [token UTF8String];
        }
        
        string strNickName;
        if (nil != nickName) {
            strNickName = [nickName UTF8String];
        }
        
        string strGiftId;
        if (nil != giftId) {
            strGiftId = [giftId UTF8String];
        }
        
        string strGiftName;
        if (nil != giftName) {
            strGiftName = [giftName UTF8String];
        }
        
        result = self.client->SendRoomGift(0, strRoomId, strToken, strNickName, strGiftId, strGiftName, giftNum, multi_click, multi_click_start, multi_click_end, multi_click_id);
        
    }
    return result;
}

- (BOOL)sendRoomToast:(NSString* _Nonnull)roomId token:(NSString* _Nonnull)token nickName:(NSString* _Nonnull)nickName msg:(NSString* _Nonnull)msg
{
    BOOL result = NO;
    if (NULL != self.client) {
        
        string strRoomId;
        if (nil != roomId) {
            strRoomId = [roomId UTF8String];
        }
        
        string strToken;
        if (nil != token) {
            strToken = [token UTF8String];
        }
        
        string strNickName;
        if (nil != nickName) {
            strNickName = [nickName UTF8String];
        }
        
        string strMsg;
        if (nil != msg) {
            strMsg = [msg UTF8String];
        }
        
        result = self.client->SendRoomToast(0, strRoomId, strToken, strNickName, strMsg);
    }
    return result;
}

#pragma mark - 登录/注销回调

- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onLogin:errMsg:)] ) {
                [delegate onLogin:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onLogout:errMsg:)] ) {
                [delegate onLogout:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onKickOff:(const string&)reason
{
    NSString* nsReason = [NSString stringWithUTF8String:reason.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onKickOff:)] ) {
                [delegate onKickOff:nsReason];
            }
        }
    }
}

#pragma mark - 直播间主动操作回调

- (void)onFansRoomIn:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg userId:(const string&)userId nickName:(const string&)nickName photoUrl:(const string&)photoUrl country:(const string&)country videoUrls:(const list<string>)videoUrls fansNum:(int)fansNum contribute:(int)contribute fansList:(const RoomTopFanList&)fansList
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    NSString* nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString* nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString* nsPhotoUrl = [NSString stringWithUTF8String:photoUrl.c_str()];
    NSString* nsCountry = [NSString stringWithUTF8String:country.c_str()];
    NSMutableArray* nsVideoUrls = [NSMutableArray array];
    for (list<string>::const_iterator iter = videoUrls.begin(); iter != videoUrls.end(); iter++) {
        string item = (*iter);
        NSString* videoUrl = [NSString stringWithUTF8String:item.c_str()];
        [nsVideoUrls addObject:videoUrl];
    }
    NSMutableArray* nsFansList = [NSMutableArray array];
    for (RoomTopFanList::const_iterator iter = fansList.begin(); iter != fansList.end(); iter++) {
        const RoomTopFan item = (*iter);
        RoomTopFanItemObject* itemObject = [RoomTopFanItemObject alloc];
        itemObject.userId = [NSString stringWithUTF8String:item.userId.c_str()];
        itemObject.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
        itemObject.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
        [nsFansList addObject:itemObject];
    }
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onFansRoomIn:reqId:errType:errMsg:userId:nickName:photoUrl:country:videoUrls:fansNum:contribute:fansList:)] ) {
                [delegate onFansRoomIn:success reqId:reqId errType:errType errMsg:nsErrMsg userId:nsUserId nickName:nsNickName photoUrl:nsPhotoUrl country:nsCountry videoUrls:nsVideoUrls fansNum:fansNum contribute:contribute fansList:nsFansList];
            }
        }
    }
}

- (void)onFansRoomOut:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onFansRoomOut:reqId:errType:errMsg:)] ) {
                [delegate onFansRoomOut:success reqId:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onGetRoomInfo:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg fansNum:(int)fansNum contribute:(int)contribute
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onGetRoomInfo:reqId:errType:errMsg:fansNum:contribute:)] ) {
                [delegate onGetRoomInfo:success reqId:reqId errType:errType errMsg:nsErrMsg fansNum:fansNum contribute:contribute];
            }
        }
    }
}

- (void)onFansShutUp:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onFansShutUp:reqId:errType:errMsg:)] ) {
                [delegate onFansShutUp:success reqId:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onFansKickOffRoom:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onFansKickOffRoom:reqId:errType:errMsg:)] ) {
                [delegate onFansKickOffRoom:success reqId:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

#pragma mark - 直播间接收操作回调

- (void)onRecvRoomCloseFans:(const string&)roomId userId:(const string&)userId nickName:(const string&)nickName fansNum:(int)fansNum
{
    NSString* nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString* nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvRoomCloseFans:userId:nickName:fansNum:)] ) {
                [delegate onRecvRoomCloseFans:nsRoomId userId:nsUserId nickName:nsNickName fansNum:fansNum];
            }
        }
    }
}


- (void)onRecvRoomCloseBroad:(const string&)roomId fansNum:(int)fansNum income:(int)income newFans:(int)newFans shares:(int)shares duration:(int)duration
{
    NSString* nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvRoomCloseBroad:fansNum:income:newFans:shares:duration:)] ) {
                [delegate onRecvRoomCloseBroad:nsRoomId fansNum:fansNum income:income newFans:newFans shares:shares duration:duration];
            }
        }
    }
}

- (void)onRecvFansRoomIn:(const string&)roomId userId:(const string&)userId nickName:(const string&)nickName photoUrl:(const string&)photoUrl
{
    NSString* nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString* nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString* nsPhotoUrl = [NSString stringWithUTF8String:photoUrl.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvFansRoomIn:userId:nickName:photoUrl:)] ) {
                [delegate onRecvFansRoomIn:nsRoomId userId:nsUserId nickName:nsNickName photoUrl:nsPhotoUrl];
            }
        }
    }
}

- (void)onRecvShutUpNotice:(const string&)roomId userId:(const string&)userId nickName:(const string&)nickName timeOut:(int)timeOut
{
    NSString* nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString* nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvShutUpNotice:userId:nickName:timeOut:)] ) {
                [delegate onRecvShutUpNotice:nsRoomId userId:nsUserId nickName:nsNickName timeOut:timeOut];
            }
        }
    }
}

- (void)onRecvKickOffRoomNotice:(const string&)roomId userId:(const string&)userId nickName:(const string&)nickName
{
    NSString* nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* nsUserId = [NSString stringWithUTF8String:userId.c_str()];
    NSString* nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvKickOffRoomNotice:userId:nickName:)] ) {
                [delegate onRecvKickOffRoomNotice:nsRoomId userId:nsUserId nickName:nsNickName];
            }
        }
    }
}

#pragma mark - 直播间文本消息信息
- (void)onSendRoomMsg:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onSendRoomMsg:errType:errMsg:)] ) {
                [delegate onSendRoomMsg:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onRecvRoomMsg:(const string&)roomId level:(int)level fromId:(const string&)fromId nickName:(const string&)nickName msg:(const string&)msg
{
    NSString* nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString* nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString* nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvRoomMsg:level:fromId:nickName:msg:)] ) {
                [delegate onRecvRoomMsg:nsRoomId level:level fromId:nsFromId nickName:nsNickName msg:nsMsg];
            }
        }
    }
}

#pragma mark - 直播间点赞操作回调

- (void)onSendRoomFav:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onSendRoomFav:reqId:errType:errMsg:)] ) {
                [delegate onSendRoomFav:success reqId:reqId errType:errType errMsg:nsErrMsg];
            }
        }
    }
}

- (void)onRecvPushRoomFav:(const string&)roomId fromId:(const string&)fromId
{
    NSString* nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvPushRoomFav:fromId:)] ) {
                [delegate onRecvPushRoomFav:nsRoomId fromId:nsFromId];
            }
        }
    }
}

#pragma mark - 直播间礼物消息操作回调

- (void)onSendRoomGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg coins:(double)coins
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onSendRoomGift:reqId:errType:errMsg:coins:)] ) {
                [delegate onSendRoomGift:success reqId:reqId errType:errType errMsg:nsErrMsg coins:coins];
            }
        }
    }
}

- (void)onRecvRoomGiftNotice:(const string&)roomId fromId:(const string&)fromId nickName:(const string&)nickName giftId:(const string&)giftId giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)multi_click_start multi_click_end:(int)multi_click_end multi_click_id:(int)multi_click_id
{
    NSString* nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString* nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString* nsGigtId = [NSString stringWithUTF8String:giftId.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvRoomGiftNotice:fromId:nickName:giftId:giftNum:multi_click:multi_click_start:multi_click_end:multi_click_id:)] ) {
                [delegate onRecvRoomGiftNotice:nsRoomId fromId:nsFromId nickName:nsNickName giftId:nsGigtId giftNum:giftNum multi_click:multi_click multi_click_start:multi_click_start multi_click_end:multi_click_end multi_click_id:multi_click_id];
            }
        }
    }
}

#pragma mark - 直播间弹幕消息操作回调

- (void)onSendRoomToast:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(const string&)errmsg coins:(double)coins
{
    NSString* nsErrMsg = [NSString stringWithUTF8String:errmsg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onSendRoomToast:reqId:errType:errMsg:coins:)] ) {
                [delegate onSendRoomToast:success reqId:reqId errType:errType errMsg:nsErrMsg coins:coins];
            }
        }
    }
}

- (void)onRecvRoomToastNotice:(const string&)roomId fromId:(const string&)fromId nickName:(const string&)nickName msg:(const string&)msg
{
    NSString* nsRoomId = [NSString stringWithUTF8String:roomId.c_str()];
    NSString* nsFromId = [NSString stringWithUTF8String:fromId.c_str()];
    NSString* nsNickName = [NSString stringWithUTF8String:nickName.c_str()];
    NSString* nsMsg = [NSString stringWithUTF8String:msg.c_str()];
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<IMLiveRoomManagerDelegate> delegate = (id<IMLiveRoomManagerDelegate>)value.nonretainedObjectValue;
            if( [delegate respondsToSelector:@selector(onRecvRoomToastNotice:fromId:nickName:msg:)] ) {
                [delegate onRecvRoomToastNotice:nsRoomId fromId:nsFromId nickName:nsNickName msg:nsMsg];
            }
        }
    }
}

@end
