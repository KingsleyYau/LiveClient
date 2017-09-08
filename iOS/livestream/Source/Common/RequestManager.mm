//
//  RequestManager.m
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "RequestManager.h"

#include <common/CommonFunc.h>
#include <common/KZip.h>

#include <httpclient/HttpRequestManager.h>

#include <httpcontroller/HttpRequestController.h>

#include <httpcontroller/HttpRequestDefine.h>

static RequestManager* gManager = nil;
@interface RequestManager () {
    HttpRequestManager mHttpRequestManager;
    HttpRequestController mHttpRequestController;
}

@property (nonatomic, strong) NSMutableDictionary* delegateDictionary;

@end

@implementation RequestManager

#pragma mark - 获取实例
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        self.delegateDictionary = [NSMutableDictionary dictionary];
        self.versionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Version"];
        
        mHttpRequestManager.SetVersionCode(COMMON_VERSION_CODE, [self.versionCode UTF8String]);
    }
    return self;
}

#pragma mark - 公共模块
+ (void)setLogEnable:(BOOL)enable {
    KLog::SetLogEnable(enable);
    KLog::SetLogFileEnable(NO);
    KLog::SetLogLevel(KLog::LOG_MSG);
}

+ (void)setLogDirectory:(NSString *)directory {
    KLog::SetLogDirectory([directory UTF8String]);
    CleanDir([directory UTF8String]);
}

- (void)setWebSite:(NSString * _Nonnull)webSite {
    mHttpRequestManager.SetWebSite([webSite UTF8String]);
}

- (void)setAuthorization:(NSString *)user password:(NSString *)password {
    mHttpRequestManager.SetAuthorization([user UTF8String], [password UTF8String]);
}

- (void)cleanCookies {
    HttpClient::CleanCookies();
}

- (void)getCookies:(NSString *)site {
    HttpClient::GetCookies([site UTF8String]);
}

- (void)stopRequest:(NSInteger)request {
    mHttpRequestController.Stop(request);
}

- (void)stopAllRequest {
    mHttpRequestManager.StopAllRequest();
}

- (NSString *)getDeviceId {
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

- (NSInteger)invalidRequestId {
    return HTTPREQUEST_INVALIDREQUESTID;
}

#pragma mark - 登陆认证模块


class RequestLoginCallbackImp : public IRequestLoginCallback {
public:
    RequestLoginCallbackImp(){};
    ~RequestLoginCallbackImp(){};
    void OnLogin(HttpLoginTask* task, bool success, int errnum, const string& errmsg, const HttpLoginItem& item) {
        NSLog(@"RequestManager::onLogin( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success?"true":"false", errnum, errmsg.c_str());
        
        LoginFinishHandler handler = nil;
        LoginItemObject *obj = [[LoginItemObject alloc] init];
        obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
        obj.token = [NSString stringWithUTF8String:item.token.c_str()];
        obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
        obj.level = item.level;
        obj.experience = item.experience;
        obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
    
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestLoginCallbackImp gRequestLoginCallbackImp;

- (NSInteger)login:(NSString * _Nonnull)qnsid
          deviceid:(NSString * _Nonnull)deviceid
             model:(NSString * _Nonnull)model
      manufacturer:(NSString * _Nonnull)manufacturer
     finishHandler:(LoginFinishHandler _Nullable)finishHandler {
    string strQnsid;
    if (nil != qnsid) {
        strQnsid = [qnsid UTF8String];
    }
    
    string strDeviceid;
    if (nil != deviceid) {
        strDeviceid = [deviceid UTF8String];
    }
    
    string strModel;
    if (nil != model) {
        strModel = [model UTF8String];
    }
    
    string strManufacturer;
    if (nil != manufacturer) {
        strManufacturer = [manufacturer UTF8String];
    }
    
    NSInteger request = mHttpRequestController.Login(&mHttpRequestManager, strQnsid, strDeviceid, strModel, strManufacturer, &gRequestLoginCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestLogoutCallbackImp : public IRequestLogoutCallback {
public:
    RequestLogoutCallbackImp(){};
    ~RequestLogoutCallbackImp(){};
    
    void OnLogout(HttpLogoutTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::onLogout( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success?"true":"false", errnum, errmsg.c_str());
        
        LogoutFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestLogoutCallbackImp gRequestLogoutCallbackImp;

- (NSInteger)logout:(LogoutFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.Logout(&mHttpRequestManager, &gRequestLogoutCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestUpdateTokenIdCallbackImp : public IRequestUpdateTokenIdCallback {
public:
    RequestUpdateTokenIdCallbackImp(){};
    ~RequestUpdateTokenIdCallbackImp(){};
    
    void OnUpdateTokenId(HttpUpdateTokenIdTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::onLogout( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success?"true":"false", errnum, errmsg.c_str());
        
        UpdateTokenIdFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestUpdateTokenIdCallbackImp gRequestUpdateTokenIdCallbackImp;

- (NSInteger)updateTokenId:(NSString * _Nonnull)tokenId
             finishHandler:(UpdateTokenIdFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.UpdateTokenId(&mHttpRequestManager, [tokenId UTF8String], &gRequestUpdateTokenIdCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

#pragma mark - 直播间模块
class RequestGetAnchorListCallbackImp : public IRequestGetAnchorListCallback {
public:
    RequestGetAnchorListCallbackImp(){};
    ~RequestGetAnchorListCallbackImp(){};
    void OnGetAnchorList(HttpGetAnchorListTask* task, bool success, int errnum, const string& errmsg, const HotItemList& listItem) {
        NSLog(@"RequestManager::OnGetLiveRoomHot( task : %p, success : %s, errnum : %d, errmsg : %s, count : %lu )", task, success?"true":"false", errnum, errmsg.c_str(), listItem.size());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HotItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            LiveRoomInfoItemObject* item = [[LiveRoomInfoItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter).roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter).onlineStatus;
            item.roomType = (*iter).roomType;
            NSMutableArray* nsInterest = [NSMutableArray array];
            for (InterestList::const_iterator itr = (*iter).interest.begin(); itr != (*iter).interest.end(); itr++) {
                NSString* strInterest = [NSString stringWithUTF8String:(*itr).c_str()];
                [nsInterest addObject:strInterest];
            }
            item.interest = nsInterest;
            [array addObject:item];
//            NSLog(@"RequestManager::OnGetLiveRoomHot( task : %p, userId : %@, nickName : %@, photoUrl : %@ , roomId : %@ , roomPhotoUrl : %@ , onlineStatus : %d , roomType : %d ", task, item.userId, item.nickName, item.photoUrl, item.roomId, item.roomPhotoUrl, item.onlineStatus, item.roomType);
        }
        GetAnchorListFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetAnchorListCallbackImp gRequestGetAnchorListCallbackImp;
- (NSInteger)getAnchorList:(int)start
                      step:(int)step
             finishHandler:(GetAnchorListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetAnchorList(&mHttpRequestManager, start, step, &gRequestGetAnchorListCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetFollowListCallbackImp : public IRequestGetFollowListCallback {
public:
    RequestGetFollowListCallbackImp(){};
    ~RequestGetFollowListCallbackImp(){};
    void OnGetFollowList(HttpGetFollowListTask* task, bool success, int errnum, const string& errmsg, const FollowItemList& listItem) {
        NSLog(@"RequestManager::OnGetLiveRoomHot( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (FollowItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            FollowItemObject* item = [[FollowItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.roomName = [NSString stringWithUTF8String:(*iter).roomName.c_str()];
            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter).roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter).onlineStatus;
            item.roomType = (*iter).roomType;
            item.loveLevel = (*iter).loveLevel;
            item.addDate = (*iter).addDate;
            NSMutableArray* nsInterest = [NSMutableArray array];
            for (FollowInterestList::const_iterator itr = (*iter).interest.begin(); itr != (*iter).interest.end(); itr++) {
                NSString* strInterest = [NSString stringWithUTF8String:(*itr).c_str()];
                [nsInterest addObject:strInterest];
            }
            item.interest = nsInterest;
            [array addObject:item];
            NSLog(@"RequestManager::OnGetLiveRoomHot( task : %p, userId : %@, nickName : %@, photoUrl : %@ , roomName : %@ , roomPhotoUrl : %@ , onlineStatus : %d , roomType : %d ", task, item.userId, item.nickName, item.photoUrl, item.roomName, item.roomPhotoUrl, item.onlineStatus, item.roomType);
        }
        GetFollowListFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetFollowListCallbackImp gRequestGetFollowListCallbackImp;
- (NSInteger)getFollowList:(int)start
                      step:(int)step
             finishHandler:(GetFollowListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetFollowList(&mHttpRequestManager, start, step, &gRequestGetFollowListCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestGetRoomInfoCallbackImp : public IRequestGetRoomInfoCallback {
public:
    RequestGetRoomInfoCallbackImp(){};
    ~RequestGetRoomInfoCallbackImp(){};
    void OnGetRoomInfo(HttpGetRoomInfoTask* task, bool success, int errnum, const string& errmsg, const HttpGetRoomInfoItem& Item) {
        NSLog(@"RequestManager::OnGetLiveRoomHot( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        RoomInfoItemObject* Obj = [[RoomInfoItemObject alloc] init];
        NSMutableArray *array = [NSMutableArray array];
        for (HttpGetRoomInfoItem::RoomItemList::const_iterator iter = Item.roomList.begin(); iter != Item.roomList.end(); iter++) {
            RoomItemObject* item = [[RoomItemObject alloc] init];
            item.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
            item.roomUrl = [NSString stringWithUTF8String:(*iter).roomUrl.c_str()];
            [array addObject:item];
        }
        Obj.roomList = array;
        
        NSMutableArray *array1 = [NSMutableArray array];
        for (InviteItemList::const_iterator iter = Item.inviteList.begin(); iter != Item.inviteList.end(); iter++) {
            InviteIdItemObject* item = [[InviteIdItemObject alloc] init];
            item.invitationId = [NSString stringWithUTF8String:(*iter).invitationId.c_str()];
            item.oppositeId = [NSString stringWithUTF8String:(*iter).oppositeId.c_str()];
            item.oppositeNickName = [NSString stringWithUTF8String:(*iter).oppositeNickName.c_str()];
            item.oppositePhotoUrl = [NSString stringWithUTF8String:(*iter).oppositePhotoUrl.c_str()];
            item.oppositeLevel = (*iter).oppositeLevel;
            item.oppositeAge = (*iter).oppositeAge;
            item.oppositeCountry = [NSString stringWithUTF8String:(*iter).oppositeCountry.c_str()];
            item.read = (*iter).read;
            item.inviTime = (*iter).inviTime;
            item.replyType = (*iter).replyType;
            item.validTime = (*iter).validTime;
            item.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
            [array1 addObject:item];
        }
        Obj.inviteList = array1;
        
        GetRoomInfoFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], Obj);
        }
    }
};
RequestGetRoomInfoCallbackImp gGetRoomInfoCallbackImp;
- (NSInteger)getRoomInfo:(GetRoomInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetRoomInfo(&mHttpRequestManager, &gGetRoomInfoCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestLiveFansListCallbackImp : public IRequestLiveFansListCallback {
public:
    RequestLiveFansListCallbackImp(){};
    ~RequestLiveFansListCallbackImp(){};
    void  OnLiveFansList(HttpLiveFansListTask* task, bool success, int errnum, const string& errmsg, const HttpLiveFansList& listItem) {
        NSLog(@"RequestManager::OnLiveFansList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HttpLiveFansList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            ViewerFansItemObject* item = [[ViewerFansItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.mountId = [NSString stringWithUTF8String:(*iter).mountId.c_str()];
            item.mountUrl = [NSString stringWithUTF8String:(*iter).mountUrl.c_str()];
            [array addObject:item];
            NSLog(@"RequestManager::OnGetLiveRoomFansList( task : %p, userId : %@, nickName : %@, photoUrl : %@)", task, item.userId, item.nickName, item.photoUrl);
        }
        LiveFansListFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestLiveFansListCallbackImp gLiveFansListCallbackImp;

- (NSInteger)liveFansList:(NSString * _Nonnull)roomId
                     page:(int)page
                   number:(int)number
            finishHandler:(LiveFansListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.LiveFansList(&mHttpRequestManager, [roomId UTF8String], page, number, &gLiveFansListCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}


class RequestGetAllGiftListCallbackImp : public IRequestGetAllGiftListCallback {
public:
    RequestGetAllGiftListCallbackImp(){};
    ~RequestGetAllGiftListCallbackImp(){};
    void OnGetAllGiftList(HttpGetAllGiftListTask* task, bool success, int errnum, const string& errmsg, const GiftItemList& itemList){
        NSLog(@"RequestManager::OnGetLiveRoomAllGiftList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (GiftItemList::const_iterator iter = itemList.begin(); iter != itemList.end(); iter++) {
            GiftInfoItemObject *gift = [[GiftInfoItemObject alloc] init];
            gift.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            gift.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            gift.smallImgUrl = [NSString stringWithUTF8String:(*iter).smallImgUrl.c_str()];
            gift.middleImgUrl = [NSString stringWithUTF8String:(*iter).middleImgUrl.c_str()];
            gift.bigImgUrl = [NSString stringWithUTF8String:(*iter).bigImgUrl.c_str()];
            gift.srcFlashUrl = [NSString stringWithUTF8String:(*iter).srcFlashUrl.c_str()];
            gift.srcwebpUrl = [NSString stringWithUTF8String:(*iter).srcwebpUrl.c_str()];
            gift.srcwebpUrl = [NSString stringWithUTF8String:(*iter).srcwebpUrl.c_str()];
            gift.credit = (*iter).credit;
            gift.multiClick = (*iter).multiClick;
            gift.type = (*iter).type;
            gift.level = (*iter).level;
            gift.loveLevel = (*iter).loveLevel;
            gift.updateTime = (*iter).updateTime;
            for (HttpSendNumList::const_iterator iterNum = (*iter).sendNumList.begin(); iterNum != (*iter).sendNumList.end(); iterNum++) {
                NSNumber* nsNum = [NSNumber numberWithInt:(*iterNum)];
                [gift.sendNumList addObject:nsNum];
            }
            [array addObject:gift];

        }
        GetAllGiftListFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetAllGiftListCallbackImp gRequestGetAllGiftListCallbackImp;
- (NSInteger)getAllGiftList:(GetAllGiftListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetAllGiftList(&mHttpRequestManager, &gRequestGetAllGiftListCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetGiftListByUserIdCallbackImp : public IRequestGetGiftListByUserIdCallback {
public:
    RequestGetGiftListByUserIdCallbackImp(){};
    ~RequestGetGiftListByUserIdCallbackImp(){};
    void OnGetGiftListByUserId(HttpGetGiftListByUserIdTask* task, bool success, int errnum, const string& errmsg, const GiftWithIdItemList& itemList) {
        NSLog(@"RequestManager::OnGetAllGiftList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (GiftWithIdItemList::const_iterator iter = itemList.begin(); iter != itemList.end(); iter++) {
            GiftWithIdItemObject *item = [[GiftWithIdItemObject alloc] init];
            item.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            item.isShow = (*iter).isShow;
            [array addObject:item];
            NSLog(@"RequestManager::OnGetLiveRoomGiftListByUserId( task : %p, giftId : %@", task, item);
        }
        GetGiftListByUserIdFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetGiftListByUserIdCallbackImp gRequestGetGiftListByUserIdCallbackImp;
- (NSInteger)getGiftListByUserId:(NSString * _Nonnull)roomId
                   finishHandler:(GetGiftListByUserIdFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetGiftListByUserId(&mHttpRequestManager, [roomId UTF8String], &gRequestGetGiftListByUserIdCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetGiftDetailCallbackImp : public IRequestGetGiftDetailCallback {
public:
    RequestGetGiftDetailCallbackImp(){};
    ~RequestGetGiftDetailCallbackImp(){};
    void OnGetGiftDetail(HttpGetGiftDetailTask* task, bool success, int errnum, const string& errmsg, const HttpGiftInfoItem& item) {
        NSLog(@"RequestManager::OnGetGiftDetail( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        GiftInfoItemObject *gift = [[GiftInfoItemObject alloc] init];
        gift.giftId = [NSString stringWithUTF8String:item.giftId.c_str()];
        gift.name = [NSString stringWithUTF8String:item.name.c_str()];
        gift.smallImgUrl = [NSString stringWithUTF8String:item.smallImgUrl.c_str()];
        gift.middleImgUrl = [NSString stringWithUTF8String:item.middleImgUrl.c_str()];
        gift.bigImgUrl = [NSString stringWithUTF8String:item.bigImgUrl.c_str()];
        gift.srcFlashUrl = [NSString stringWithUTF8String:item.srcFlashUrl.c_str()];
        gift.srcwebpUrl = [NSString stringWithUTF8String:item.srcwebpUrl.c_str()];
        gift.srcwebpUrl = [NSString stringWithUTF8String:item.srcwebpUrl.c_str()];
        gift.credit = item.credit;
        gift.multiClick = item.multiClick;
        gift.type = item.type;
        gift.level = item.level;
        gift.loveLevel = item.loveLevel;
        gift.updateTime = item.updateTime;

        
        GetGiftDetailFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], gift);
        }
    }
};
RequestGetGiftDetailCallbackImp gRequestGetGiftDetailCallbackImp;
- (NSInteger)getGiftDetail:(NSString * _Nonnull)giftId
             finishHandler:(GetGiftDetailFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetGiftDetail(&mHttpRequestManager, [giftId UTF8String], &gRequestGetGiftDetailCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetEmoticonListCallbackImp : public IRequestGetEmoticonListCallback {
public:
    RequestGetEmoticonListCallbackImp(){};
    ~RequestGetEmoticonListCallbackImp(){};
    void OnGetEmoticonList(HttpGetEmoticonListTask* task, bool success, int errnum, const string& errmsg, const EmoticonItemList& listItem) {
        NSLog(@"RequestManager::OnGetEmoticonList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (EmoticonItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            EmoticonItemObject* item = [[EmoticonItemObject alloc] init];
            item.type = (*iter).type;
            item.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            item.errMsg = [NSString stringWithUTF8String:(*iter).errMsg.c_str()];
            item.emoUrl = [NSString stringWithUTF8String:(*iter).emoUrl.c_str()];
            NSMutableArray *arrayEmo = [NSMutableArray array];
            for (EmoticonInfoItemList::const_iterator iterEmo = (*iter).emoList.begin(); iterEmo != (*iter).emoList.end(); iterEmo++) {
                EmoticonInfoItemObject *Emo = [[EmoticonInfoItemObject alloc] init];
                Emo.emoId = [NSString stringWithUTF8String:(*iterEmo).emoId.c_str()];
                Emo.emoSign = [NSString stringWithUTF8String:(*iterEmo).emoSign.c_str()];
                Emo.emoUrl = [NSString stringWithUTF8String:(*iterEmo).emoUrl.c_str()];
                [arrayEmo addObject:Emo];
            }
            item.emoList = arrayEmo;
            [array addObject:item];
        }
        
        GetEmoticonListFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetEmoticonListCallbackImp gRequestGetEmoticonListCallbackImp;
-(NSInteger)getEmoticonList:(GetEmoticonListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetEmoticonList(&mHttpRequestManager, &gRequestGetEmoticonListCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetInviteInfoCallbackImp : public IRequestGetInviteInfoCallback {
public:
    RequestGetInviteInfoCallbackImp(){};
    ~RequestGetInviteInfoCallbackImp(){};
    void OnGetInviteInfo(HttpGetInviteInfoTask* task, bool success, int errnum, const string& errmsg, const HttpInviteInfoItem& inviteItem) {
        NSLog(@"RequestManager::OnGetInviteInfo( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        InviteIdItemObject* item = [[InviteIdItemObject alloc] init];
        item.invitationId = [NSString stringWithUTF8String:inviteItem.invitationId.c_str()];
        item.oppositeId = [NSString stringWithUTF8String:inviteItem.oppositeId.c_str()];
        item.oppositeNickName = [NSString stringWithUTF8String:inviteItem.oppositeNickName.c_str()];
        item.oppositePhotoUrl = [NSString stringWithUTF8String:inviteItem.oppositePhotoUrl.c_str()];
        item.oppositeLevel = inviteItem.oppositeLevel;
        item.oppositeAge = inviteItem.oppositeAge;
        item.oppositeCountry = [NSString stringWithUTF8String:inviteItem.oppositeCountry.c_str()];
        item.read = inviteItem.read;
        item.inviTime = inviteItem.inviTime;
        item.replyType = inviteItem.replyType;
        item.validTime = inviteItem.validTime;
        item.roomId = [NSString stringWithUTF8String:inviteItem.roomId.c_str()];
        
        GetInviteInfoFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], item);
        }
    }
};
RequestGetInviteInfoCallbackImp gRequestGetInviteInfoCallbackImp;
- (NSInteger)getInviteInfo:(NSString * _Nonnull)inviteId
             finishHandler:(GetInviteInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetInviteInfo(&mHttpRequestManager, [inviteId UTF8String], &gRequestGetInviteInfoCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }

    return request;
}

class RequestGetTalentListCallbackImp : public IRequestGetTalentListCallback {
public:
    RequestGetTalentListCallbackImp(){};
    ~RequestGetTalentListCallbackImp(){};
    void OnGetTalentList(HttpGetTalentListTask* task, bool success, int errnum, const string& errmsg, const TalentItemList& list) {
        NSLog(@"RequestManager::OnGetTalentList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        NSMutableArray *array = [NSMutableArray array];
        for (TalentItemList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            GetTalentItemObject* item = [[GetTalentItemObject alloc] init];
            item.talentId = [NSString stringWithUTF8String:(*iter).talentId.c_str()];
            item.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            item.credit = (*iter).credit;
            [array addObject:item];
        }
        
        GetTalentListFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetTalentListCallbackImp gRequestGetTalentListCallbackImp;
- (NSInteger)getTalentList:(NSString * _Nonnull)roomId
             finishHandler:(GetTalentListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetTalentList(&mHttpRequestManager, [roomId UTF8String], &gRequestGetTalentListCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetTalentStatusCallbackImp : public IRequestGetTalentStatusCallback {
public:
    RequestGetTalentStatusCallbackImp(){};
    ~RequestGetTalentStatusCallbackImp(){};
    void OnGetTalentStatus(HttpGetTalentStatusTask* task, bool success, int errnum, const string& errmsg, const HttpGetTalentStatusItem& item) {
        NSLog(@"RequestManager::OnGetTalentStatus( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());

        GetTalentStatusItemObject* obj = [[GetTalentStatusItemObject alloc] init];
        obj.talentInviteId = [NSString stringWithUTF8String:item.talentInviteId.c_str()];
        obj.talentId = [NSString stringWithUTF8String:item.talentId.c_str()];
        obj.name = [NSString stringWithUTF8String:item.name.c_str()];
        obj.credit = item.credit;
        obj.status = item.status;

        GetTalentStatusFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetTalentStatusCallbackImp gRequestGetTalentStatusCallbackImp;
- (NSInteger)getTalentStatus:(NSString * _Nonnull)roomId
              talentInviteId:(NSString * _Nonnull)talentInviteId
               finishHandler:(GetTalentStatusFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetTalentStatus(&mHttpRequestManager, [roomId UTF8String], [talentInviteId UTF8String], &gRequestGetTalentStatusCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetNewFansBaseInfoCallbackImp : public IRequestGetNewFansBaseInfoCallback {
public:
    RequestGetNewFansBaseInfoCallbackImp(){};
    ~RequestGetNewFansBaseInfoCallbackImp(){};
    void OnGetNewFansBaseInfo(HttpGetNewFansBaseInfoTask* task, bool success, int errnum, const string& errmsg, const HttpLiveFansItem& item) {
        NSLog(@"RequestManager::OnGetNewFansBaseInfo( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        GetNewFansBaseInfoItemObject* obj = [[GetNewFansBaseInfoItemObject alloc] init];
        obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
        obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
        obj.mountId = [NSString stringWithUTF8String:item.mountId.c_str()];
        obj.mountUrl = [NSString stringWithUTF8String:item.mountUrl.c_str()];
        
        GetNewFansBaseInfoFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetNewFansBaseInfoCallbackImp gRequestGetNewFansBaseInfoCallbackImp;
- (NSInteger)getNewFansBaseInfo:(NSString * _Nonnull)userId
                  finishHandler:(GetNewFansBaseInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetNewFansBaseInfo(&mHttpRequestManager, [userId UTF8String], &gRequestGetNewFansBaseInfoCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestControlManPushCallbackImp : public IRequestControlManPushCallback {
public:
    RequestControlManPushCallbackImp(){};
    ~RequestControlManPushCallbackImp(){};
    void OnControlManPush(HttpControlManPushTask* task, bool success, int errnum, const string& errmsg, const list<string>& uploadUrls) {
        NSLog(@"RequestManager::OnControlManPush( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray* nsUploadUrls = [NSMutableArray array];
        for (list<string>::const_iterator itr = uploadUrls.begin(); itr != uploadUrls.end(); itr++) {
            NSString* strUploadUrl = [NSString stringWithUTF8String:(*itr).c_str()];
            [nsUploadUrls addObject:strUploadUrl];
        }
        
        ControlManPushFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], nsUploadUrls);
        }
    }
};
RequestControlManPushCallbackImp gRequestControlManPushCallbackImp;
- (NSInteger)controlManPush:(NSString * _Nonnull)roomId
                    control:(ControlType)control
              finishHandler:(ControlManPushFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.ControlManPush(&mHttpRequestManager, [roomId UTF8String], control, &gRequestControlManPushCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetPromoAnchorListCallbackImp : public IRequestGetPromoAnchorListCallback {
public:
    RequestGetPromoAnchorListCallbackImp(){};
    ~RequestGetPromoAnchorListCallbackImp(){};
    void OnGetPromoAnchorList(HttpGetPromoAnchorListTask* task, bool success, int errnum, const string& errmsg, const HotItemList& listItem) {
        NSLog(@"RequestManager::OnGetPromoAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HotItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            LiveRoomInfoItemObject* item = [[LiveRoomInfoItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter).roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter).onlineStatus;
            item.roomType = (*iter).roomType;
            NSMutableArray* nsInterest = [NSMutableArray array];
            for (InterestList::const_iterator itr = (*iter).interest.begin(); itr != (*iter).interest.end(); itr++) {
                NSString* strInterest = [NSString stringWithUTF8String:(*itr).c_str()];
                [nsInterest addObject:strInterest];
            }
            item.interest = nsInterest;
            [array addObject:item];
        }
        
        GetPromoAnchorListFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetPromoAnchorListCallbackImp gRequestGetPromoAnchorListCallbackImp;
- (NSInteger)getPromoAnchorList:(int)number
                  finishHandler:(GetPromoAnchorListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetPromoAnchorList(&mHttpRequestManager, number, &gRequestGetPromoAnchorListCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

#pragma mark - 预约私密

class RequestManHandleBookingListCallbackImp : public IRequestManHandleBookingListCallback {
public:
    RequestManHandleBookingListCallbackImp(){};
    ~RequestManHandleBookingListCallbackImp(){};
    void OnManHandleBookingList(HttpManHandleBookingListTask* task, bool success, int errnum, const string& errmsg, const HttpBookingInviteListItem& BookingListItem) {
        NSLog(@"RequestManager::OnManHandleBookingList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        BookingPrivateInviteListObject* item = [[BookingPrivateInviteListObject alloc] init];
        item.total = BookingListItem.total;
        NSMutableArray *array = [NSMutableArray array];
        for (BookingPrivateInviteItemList::const_iterator iter = BookingListItem.list.begin(); iter != BookingListItem.list.end(); iter++) {
            BookingPrivateInviteItemObject *obj = [[BookingPrivateInviteItemObject alloc] init];
            obj.invitationId = [NSString stringWithUTF8String:(*iter).invitationId.c_str()];
            obj.toId = [NSString stringWithUTF8String:(*iter).toId.c_str()];
            obj.fromId = [NSString stringWithUTF8String:(*iter).fromId.c_str()];
            obj.oppositePhotoUrl = [NSString stringWithUTF8String:(*iter).oppositePhotoUrl.c_str()];
            obj.oppositeNickName = [NSString stringWithUTF8String:(*iter).oppositeNickName.c_str()];
            obj.read = (*iter).read;
            obj.intimacy = (*iter).intimacy;
            obj.replyType = (*iter).replyType;
            obj.bookTime = (*iter).bookTime;
            obj.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            obj.giftName = [NSString stringWithUTF8String:(*iter).giftName.c_str()];
            obj.giftBigImgUrl = [NSString stringWithUTF8String:(*iter).giftBigImgUrl.c_str()];
            obj.giftSmallImgUrl = [NSString stringWithUTF8String:(*iter).giftSmallImgUrl.c_str()];
            obj.giftNum = (*iter).giftNum;
            obj.validTime = (*iter).validTime;
            obj.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
            [array addObject:obj];
        }
        item.list = array;
        
        ManHandleBookingListFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], item);
        }
    }
};
RequestManHandleBookingListCallbackImp gRequestManHandleBookingListCallbackImp;
- (NSInteger)manHandleBookingList:(BookingListType)type
                            start:(int)start
                             step:(int)step
                    finishHandler:(ManHandleBookingListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.ManHandleBookingList(&mHttpRequestManager, type, start, step, &gRequestManHandleBookingListCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestHandleBookingCallbackImp : public IRequestHandleBookingCallback {
public:
    RequestHandleBookingCallbackImp(){};
    ~RequestHandleBookingCallbackImp(){};
    void OnHandleBooking(HttpHandleBookingTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnHandleBooking( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        HandleBookingFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestHandleBookingCallbackImp gRequestHandleBookingCallbackImp;
- (NSInteger)handleBooking:(NSString * _Nonnull)inviteId
                 isConfirm:(BOOL)isConfirm
             finishHandler:(HandleBookingFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.HandleBooking(&mHttpRequestManager, [inviteId UTF8String], isConfirm, &gRequestHandleBookingCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSendCancelPrivateLiveInviteCallbackImp : public IRequestSendCancelPrivateLiveInviteCallback {
public:
    RequestSendCancelPrivateLiveInviteCallbackImp(){};
    ~RequestSendCancelPrivateLiveInviteCallbackImp(){};
    void OnSendCancelPrivateLiveInvite(HttpSendCancelPrivateLiveInviteTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnSendCancelPrivateLiveInvite( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        SendCancelPrivateLiveInviteFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSendCancelPrivateLiveInviteCallbackImp gRequestSendCancelPrivateLiveInviteCallbackImp;
- (NSInteger)sendCancelPrivateLiveInvite:(NSString * _Nonnull)invitationId
                           finishHandler:(SendCancelPrivateLiveInviteFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.SendCancelPrivateLiveInvite(&mHttpRequestManager, [invitationId UTF8String], &gRequestSendCancelPrivateLiveInviteCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestManBookingUnreadUnhandleNumCallbackImp : public IRequestManBookingUnreadUnhandleNumCallback {
public:
    RequestManBookingUnreadUnhandleNumCallbackImp(){};
    ~RequestManBookingUnreadUnhandleNumCallbackImp(){};
    void OnManBookingUnreadUnhandleNum(HttpManBookingUnreadUnhandleNumTask* task, bool success, int errnum, const string& errmsg, const HttpBookingUnreadUnhandleNumItem& item) {
        NSLog(@"RequestManager::OnManBookingUnreadUnhandleNum( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        BookingUnreadUnhandleNumItemObject* obj = [[BookingUnreadUnhandleNumItemObject alloc] init];
        obj.total = item.total;
        obj.handleNum = item.handleNum;
        obj.scheduledUnreadNum = item.scheduledUnreadNum;
        obj.historyUnreadNum = item.historyUnreadNum;
        
        ManBookingUnreadUnhandleNumFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestManBookingUnreadUnhandleNumCallbackImp gRequestManBookingUnreadUnhandleNumCallbackImp;
- (NSInteger)manBookingUnreadUnhandleNum:(ManBookingUnreadUnhandleNumFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.ManBookingUnreadUnhandleNum(&mHttpRequestManager, &gRequestManBookingUnreadUnhandleNumCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetCreateBookingInfoCallbackImp : public IRequestGetCreateBookingInfoCallback {
public:
    RequestGetCreateBookingInfoCallbackImp(){};
    ~RequestGetCreateBookingInfoCallbackImp(){};
    void OnGetCreateBookingInfo(HttpGetCreateBookingInfoTask* task, bool success, int errnum, const string& errmsg, const HttpGetCreateBookingInfoItem& item) {
        NSLog(@"RequestManager::OnGetCreateBookingInfo( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        GetCreateBookingInfoItemObject* obj = [[GetCreateBookingInfoItemObject alloc] init];
        obj.bookDeposit = item.bookDeposit;
        NSMutableArray *arrayBookTime = [NSMutableArray array];
        for (HttpGetCreateBookingInfoItem::BookTimeList::const_iterator iter = item.bookTime.begin(); iter != item.bookTime.end(); iter++) {
            BookTimeItemObject *objBookTime = [[BookTimeItemObject alloc] init];
            objBookTime.timeId = [NSString stringWithUTF8String:(*iter).timeId.c_str()];
            objBookTime.time = (*iter).time;
            objBookTime.status = (*iter).status;
            [arrayBookTime addObject:objBookTime];
        }
        obj.bookTime = arrayBookTime;
        
        NSMutableArray *arrayBookGift = [NSMutableArray array];
        for (HttpGetCreateBookingInfoItem::GiftList::const_iterator iterBookGift = item.bookGift.giftList.begin(); iterBookGift != item.bookGift.giftList.end(); iterBookGift++) {
            GiftItemObject *objBookGift = [[GiftItemObject alloc] init];
            objBookGift.giftId = [NSString stringWithUTF8String:(*iterBookGift).giftId.c_str()];
            NSMutableArray *arrayGiftNum = [NSMutableArray array];
            for (HttpGetCreateBookingInfoItem::GiftNumList::const_iterator iterGiftNum = (*iterBookGift).giftNumList.begin(); iterGiftNum != (*iterBookGift).giftNumList.end(); iterGiftNum++) {
                GiftNumItemObject* objGiftNum = [[GiftNumItemObject alloc] init];
                objGiftNum.num = (*iterGiftNum).num;
                objGiftNum.isDefault = (*iterGiftNum).isDefault;
                [arrayGiftNum addObject:objGiftNum];
            }
            objBookGift.giftNumList = arrayGiftNum;
            [arrayBookGift addObject:objBookGift];
        }
        obj.bookGift = arrayBookGift;
        
        GetCreateBookingInfoFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetCreateBookingInfoCallbackImp gRequestGetCreateBookingInfoCallbackImp;
- (NSInteger)getCreateBookingInfo:(NSString* _Nullable)userId
                    finishHandler:(GetCreateBookingInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetCreateBookingInfo(&mHttpRequestManager, [userId UTF8String], &gRequestGetCreateBookingInfoCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSendBookingRequestCallbackImp : public IRequestSendBookingRequestCallback {
public:
    RequestSendBookingRequestCallbackImp(){};
    ~RequestSendBookingRequestCallbackImp(){};
    void OnSendBookingRequest(HttpSendBookingRequestTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnSendBookingRequest( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());

        SendBookingRequestFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSendBookingRequestCallbackImp gRequestSendBookingRequestCallbackImp;
- (NSInteger)sendBookingRequest:(NSString* _Nullable)userId
                         timeId:(NSString* _Nullable)timeId
                       bookTime:(NSInteger)bookTime
                         giftId:(NSString* _Nullable)giftId
                        giftNum:(int)giftNum
                  finishHandler:(SendBookingRequestFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.SendBookingRequest(&mHttpRequestManager, [userId UTF8String], [timeId UTF8String], bookTime, [giftId UTF8String], giftNum, &gRequestSendBookingRequestCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

#pragma mark - 背包

class RequestGiftListCallbackImp : public IRequestGiftListCallback {
public:
    RequestGiftListCallbackImp(){};
    ~RequestGiftListCallbackImp(){};
    void OnGiftList(HttpGiftListTask* task, bool success, int errnum, const string& errmsg, const BackGiftItemList& list) {
        NSLog(@"RequestManager::OnGiftList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (BackGiftItemList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            BackGiftItemObject* item = [[BackGiftItemObject alloc] init];
            item.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            item.num = (*iter).num;
            item.grantedDate = (*iter).grantedDate;
            item.expDate = (*iter).expDate;
            item.read = (*iter).read;
            [array addObject:item];
            
        }
        
        GiftListFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGiftListCallbackImp gRequestGiftListCallbackImp;
- (NSInteger)giftList:(GiftListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GiftList(&mHttpRequestManager, &gRequestGiftListCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestVoucherListCallbackImp : public IRequestVoucherListCallback {
public:
    RequestVoucherListCallbackImp(){};
    ~RequestVoucherListCallbackImp(){};
    void OnVoucherList(HttpVoucherListTask* task, bool success, int errnum, const string& errmsg, const VoucherList& list) {
        NSLog(@"RequestManager::OnVoucherList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
    
        NSMutableArray *array = [NSMutableArray array];
        for (VoucherList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            VoucherItemObject* item = [[VoucherItemObject alloc] init];
            item.voucherId = [NSString stringWithUTF8String:(*iter).voucherId.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.desc = [NSString stringWithUTF8String:(*iter).desc.c_str()];
            item.useRoomType = (*iter).useRoomType;
            item.anchorType = (*iter).anchorType;
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.anchorNcikName = [NSString stringWithUTF8String:(*iter).anchorNcikName.c_str()];
            item.anchorPhotoUrl = [NSString stringWithUTF8String:(*iter).anchorPhotoUrl.c_str()];
            item.grantedDate = (*iter).grantedDate;
            item.expDate = (*iter).expDate;
            item.read = (*iter).read;
            [array addObject:item];
            
        }
 
        VoucherListFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestVoucherListCallbackImp gRequestVoucherListCallbackImp;
- (NSInteger)voucherList:(VoucherListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.VoucherList(&mHttpRequestManager, &gRequestVoucherListCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestRideListCallbackImp : public IRequestRideListCallback {
public:
    RequestRideListCallbackImp(){};
    ~RequestRideListCallbackImp(){};
    void OnRideList(HttpRideListTask* task, bool success, int errnum, const string& errmsg, const RideList& list) {
        NSLog(@"RequestManager::OnRideList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (RideList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            RideItemObject* item = [[RideItemObject alloc] init];
            item.rideId = [NSString stringWithUTF8String:(*iter).rideId.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            item.grantedDate = (*iter).grantedDate;
            item.expDate = (*iter).expDate;
            item.read = (*iter).read;
            item.isUse = (*iter).isUse;
            [array addObject:item];
            
        }
        
        RideListFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestRideListCallbackImp gRequestRideListCallbackImp;
- (NSInteger)rideList:(RideListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.RideList(&mHttpRequestManager, &gRequestRideListCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSetRideCallbackImp : public IRequestSetRideCallback {
public:
    RequestSetRideCallbackImp(){};
    ~RequestSetRideCallbackImp(){};
    void OnSetRide(HttpSetRideTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnSetRide( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        SetRideFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSetRideCallbackImp gRequestSetRideCallbackImp;
- (NSInteger)setRide:(NSString* _Nonnull)rideId
       finishHandler:(SetRideFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.SetRide(&mHttpRequestManager, [rideId UTF8String], &gRequestSetRideCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetBackpackUnreadNumCallbackImp : public IRequestGetBackpackUnreadNumCallback {
public:
    RequestGetBackpackUnreadNumCallbackImp(){};
    ~RequestGetBackpackUnreadNumCallbackImp(){};
    void OnGetBackpackUnreadNum(HttpGetBackpackUnreadNumTask* task, bool success, int errnum, const string& errmsg, const HttpGetBackPackUnreadNumItem& item) {
        NSLog(@"RequestManager::OnGetBackpackUnreadNum( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        GetBackPackUnreadNumItemObject* obj = [[GetBackPackUnreadNumItemObject alloc] init];
        obj.total = item.total;
        obj.voucherUnreadNum = item.voucherUnreadNum;
        obj.giftUnreadNum = item.giftUnreadNum;
        obj.rideUnreadNum = item.rideUnreadNum;

        GetBackpackUnreadNumFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetBackpackUnreadNumCallbackImp gRequestGetBackpackUnreadNumCallbackImp;
- (NSInteger)getBackpackUnreadNum:(GetBackpackUnreadNumFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetBackpackUnreadNum(&mHttpRequestManager, &gRequestGetBackpackUnreadNumCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

#pragma mark - 其它

class RequestGetConfigCallbackImp : public IRequestGetConfigCallback {
public:
    RequestGetConfigCallbackImp(){};
    ~RequestGetConfigCallbackImp(){};
    void OnGetConfig(HttpGetConfigTask* task, bool success, int errnum, const string& errmsg, const HttpConfigItem& configItem) {
        NSLog(@"RequestManager::OnGetConfig( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        ConfigItemObject *obj = [[ConfigItemObject alloc] init];
        obj.imSvrIp = [NSString stringWithUTF8String:configItem.imSvrIp.c_str()];
        obj.imSvrPort = configItem.imSvrPort;
        obj.httpSvrIp = [NSString stringWithUTF8String:configItem.httpSvrIp.c_str()];
        obj.httpSvrPort = configItem.httpSvrPort;
        obj.uploadSvrIp = [NSString stringWithUTF8String:configItem.uploadSvrIp.c_str()];
        obj.uploadSvrPort = configItem.uploadSvrPort;
        obj.addCreditsUrl = [NSString stringWithUTF8String:configItem.addCreditsUrl.c_str()];
  
        GetConfigFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetConfigCallbackImp gRequestGetConfigCallbackImp;
- (NSInteger)getConfig:(GetConfigFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetConfig(&mHttpRequestManager, &gRequestGetConfigCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetLeftCreditCallbackImp : public IRequestGetLeftCreditCallback {
public:
    RequestGetLeftCreditCallbackImp(){};
    ~RequestGetLeftCreditCallbackImp(){};
    void OnGetLeftCredit(HttpGetLeftCreditTask* task, bool success, int errnum, const string& errmsg, double credit) {
        NSLog(@"RequestManager::OnGetLeftCredit( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());

        
        GetLeftCreditFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], credit);
        }
    }
};
RequestGetLeftCreditCallbackImp gRequestGetLeftCreditCallbackImp;
- (NSInteger)getLeftCredit:(GetLeftCreditFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetLeftCredit(&mHttpRequestManager, &gRequestGetLeftCreditCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSetFavoriteCallbackImp : public IRequestSetFavoriteCallback {
public:
    RequestSetFavoriteCallbackImp(){};
    ~RequestSetFavoriteCallbackImp(){};
    void OnSetFavorite(HttpSetFavoriteTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnSetFavorite( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        
        SetFavoriteFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSetFavoriteCallbackImp gRequestSetFavoriteCallbackImp;
- (NSInteger)setFavorite:(NSString* _Nonnull)userId
                  roomId:(NSString* _Nonnull)roomId
                   isFav:(BOOL)isFav
           finishHandler:(SetFavoriteFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.SetFavorite(&mHttpRequestManager, [userId UTF8String], [roomId UTF8String], isFav, &gRequestSetFavoriteCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

@end
