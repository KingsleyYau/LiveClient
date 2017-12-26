//
//  LSRequestManager.m
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSRequestManager.h"

#include <common/CommonFunc.h>
#include <common/KZip.h>

#include <httpclient/HttpRequestManager.h>

#include <httpcontroller/HttpRequestController.h>

#include <httpcontroller/HttpRequestDefine.h>

static LSRequestManager *gManager = nil;
@interface LSRequestManager () {
    HttpRequestManager mHttpRequestManager;
    HttpRequestManager mConfigHttpRequestManager;
    HttpRequestController mHttpRequestController;
}

@property (nonatomic, strong) NSMutableDictionary *delegateDictionary;

@end

@implementation LSRequestManager

#pragma mark - 获取实例
+ (instancetype)manager {
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if (self = [super init]) {
        self.delegateDictionary = [NSMutableDictionary dictionary];
        self.versionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Version"];
        
        mHttpRequestManager.SetVersionCode(COMMON_VERSION_CODE, [self.versionCode UTF8String]);
        mConfigHttpRequestManager.SetVersionCode(COMMON_VERSION_CODE, [self.versionCode UTF8String]);
    }
    return self;
}

#pragma mark - 公共模块
+ (void)setLogEnable:(BOOL)enable {
    KLog::SetLogEnable(enable);
    KLog::SetLogFileEnable(YES);
    KLog::SetLogLevel(KLog::LOG_MSG);
}

+ (void)setLogDirectory:(NSString *)directory {
    KLog::SetLogDirectory([directory UTF8String]);
    HttpClient::SetCookiesDirectory([directory UTF8String]);
//    CleanDir([directory UTF8String]);
}

- (void)setConfigWebSite:(NSString * _Nonnull)webSite {
    mConfigHttpRequestManager.SetWebSite([webSite UTF8String]);
}

- (void)setWebSite:(NSString *_Nonnull)webSite {
    mHttpRequestManager.SetWebSite([webSite UTF8String]);
}

- (void)setAuthorization:(NSString *)user password:(NSString *)password {
    mHttpRequestManager.SetAuthorization([user UTF8String], [password UTF8String]);
    mConfigHttpRequestManager.SetAuthorization([user UTF8String], [password UTF8String]);
}

- (void)cleanCookies {
    HttpClient::CleanCookies();
}

- (NSArray<NSHTTPCookie *> *)getCookies {
    NSMutableArray *cookies = [NSMutableArray array];
    
    list<CookiesItem> cookiesList = HttpClient::GetCookiesItem();
    for(list<CookiesItem>::const_iterator itr = cookiesList.begin(); itr != cookiesList.end(); itr++) {
        NSMutableDictionary<NSHTTPCookiePropertyKey, id> *properties = [NSMutableDictionary dictionary];
        
        CookiesItem item = *itr;
        [properties setObject:[NSString stringWithUTF8String:item.m_domain.c_str()] forKey:NSHTTPCookieDomain];
        [properties setObject:[NSString stringWithUTF8String:item.m_symbol.c_str()] forKey:NSHTTPCookiePath];
        [properties setObject:[NSString stringWithUTF8String:item.m_cName.c_str()] forKey:NSHTTPCookieName];
        [properties setObject:[NSString stringWithUTF8String:item.m_value.c_str()] forKey:NSHTTPCookieValue];
        [properties setObject:[NSString stringWithUTF8String:item.m_expiresTime.c_str()] forKey:NSHTTPCookieMaximumAge];
        
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
        [cookies addObject:cookie];
    }
    
    return cookies;
}

- (void)stopRequest:(NSInteger)request {
    mHttpRequestController.Stop(request);
}

- (void)stopAllRequest {
    mHttpRequestManager.StopAllRequest();
    mConfigHttpRequestManager.StopAllRequest();
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
    void OnLogin(HttpLoginTask *task, bool success, int errnum, const string &errmsg, const HttpLoginItem &item) {
        NSLog(@"LSRequestManager::onLogin( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LoginFinishHandler handler = nil;
        LSLoginItemObject *obj = [[LSLoginItemObject alloc] init];
        obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
        obj.token = [NSString stringWithUTF8String:item.token.c_str()];
        obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
        obj.level = item.level;
        obj.experience = item.experience;
        obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
        obj.isPushAd = item.isPushAd;
        NSMutableArray *array = [NSMutableArray array];
        for (HttpLoginItem::SvrList::const_iterator iter = item.svrList.begin(); iter != item.svrList.end(); iter++) {
            LSSvrItemObject *svrItem = [[LSSvrItemObject alloc] init];
            svrItem.svrId = [NSString stringWithUTF8String:(*iter).svrId.c_str()];
            svrItem.tUrl = [NSString stringWithUTF8String:(*iter).tUrl.c_str()];
            [array addObject:svrItem];
        }
        obj.svrList = array;
        obj.userType = item.userType;
        
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestLoginCallbackImp gRequestLoginCallbackImp;

- (NSInteger)login:(NSString *_Nonnull)manId
           userSid:(NSString *_Nonnull)userSid
          deviceid:(NSString *_Nonnull)deviceid
             model:(NSString *_Nonnull)model
      manufacturer:(NSString *_Nonnull)manufacturer
     finishHandler:(LoginFinishHandler _Nullable)finishHandler {
    
    string strManId;
    if (nil != manId) {
        strManId = [manId UTF8String];
    }
    
    string strUserSid;
    if (nil != userSid) {
        strUserSid = [userSid UTF8String];
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
    
    NSInteger request = (NSInteger)mHttpRequestController.Login(&mHttpRequestManager, strManId, strUserSid, strDeviceid, strModel, strManufacturer, &gRequestLoginCallbackImp);
    
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestLogoutCallbackImp : public IRequestLogoutCallback {
public:
    RequestLogoutCallbackImp(){};
    ~RequestLogoutCallbackImp(){};
    
    void OnLogout(HttpLogoutTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::onLogout( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LogoutFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestLogoutCallbackImp gRequestLogoutCallbackImp;

- (NSInteger)logout:(LogoutFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.Logout(&mHttpRequestManager, &gRequestLogoutCallbackImp);
    
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestUpdateTokenIdCallbackImp : public IRequestUpdateTokenIdCallback {
public:
    RequestUpdateTokenIdCallbackImp(){};
    ~RequestUpdateTokenIdCallbackImp(){};
    
    void OnUpdateTokenId(HttpUpdateTokenIdTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::onLogout( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        UpdateTokenIdFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestUpdateTokenIdCallbackImp gRequestUpdateTokenIdCallbackImp;

- (NSInteger)updateTokenId:(NSString *_Nonnull)tokenId
             finishHandler:(UpdateTokenIdFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.UpdateTokenId(&mHttpRequestManager, [tokenId UTF8String], &gRequestUpdateTokenIdCallbackImp);
    
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

#pragma mark - 直播间模块
class RequestGetAnchorListCallbackImp : public IRequestGetAnchorListCallback {
public:
    RequestGetAnchorListCallbackImp(){};
    ~RequestGetAnchorListCallbackImp(){};
    void OnGetAnchorList(HttpGetAnchorListTask *task, bool success, int errnum, const string &errmsg, const HotItemList &listItem) {
        NSLog(@"LSRequestManager::OnGetAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s, count : %lu )", task, success ? "true" : "false", errnum, errmsg.c_str(), listItem.size());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HotItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            LiveRoomInfoItemObject *item = [[LiveRoomInfoItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter).roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter).onlineStatus;
            item.roomType = (*iter).roomType;
            NSMutableArray *nsInterest = [NSMutableArray array];
            //int i = 0;
            for (InterestList::const_iterator itr = (*iter).interest.begin(); itr != (*iter).interest.end(); itr++) {
                //NSString* strInterest = [NSString stringWithUTF8String:(*itr).c_str()];
                int num = (*itr);
                NSNumber *numInterest = [NSNumber numberWithInt:num];
                [nsInterest addObject:numInterest];
                //item->interest[i] = (*itr);
                //i++;
            }
            item.interest = nsInterest;
            item.anchorType = (*iter).anchorType;
            [array addObject:item];
            //            NSLog(@"LSRequestManager::OnGetAnchorList( task : %p, userId : %@, nickName : %@, onlineStatus : %d, roomType : %d )", task, item.userId, item.nickName, item.onlineStatus, item.roomType);
        }
        GetAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetAnchorListCallbackImp gRequestGetAnchorListCallbackImp;
- (NSInteger)getAnchorList:(int)start
                      step:(int)step
                  hasWatch:(BOOL)hasWatch
                 isForTest:(BOOL)isForTest
             finishHandler:(GetAnchorListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetAnchorList(&mHttpRequestManager, start, step, hasWatch, isForTest, &gRequestGetAnchorListCallbackImp);
    
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetFollowListCallbackImp : public IRequestGetFollowListCallback {
public:
    RequestGetFollowListCallbackImp(){};
    ~RequestGetFollowListCallbackImp(){};
    void OnGetFollowList(HttpGetFollowListTask *task, bool success, int errnum, const string &errmsg, const FollowItemList &listItem) {
        NSLog(@"LSRequestManager::OnGetFollowList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (FollowItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            FollowItemObject *item = [[FollowItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter).roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter).onlineStatus;
            item.roomType = (*iter).roomType;
            item.loveLevel = (*iter).loveLevel;
            item.addDate = (*iter).addDate;
            NSMutableArray *nsInterest = [NSMutableArray array];
            for (FollowInterestList::const_iterator itr = (*iter).interest.begin(); itr != (*iter).interest.end(); itr++) {
                int num = (*itr);
                NSNumber *numInterest = [NSNumber numberWithInt:num];
                [nsInterest addObject:numInterest];
            }
            item.interest = nsInterest;
            item.anchorType = (*iter).anchorType;
            [array addObject:item];
            //            NSLog(@"LSRequestManager::OnGetFollowList( task : %p, userId : %@, nickName : %@, onlineStatus : %d, roomType : %d )", task, item.userId, item.nickName, item.onlineStatus, item.roomType);
        }
        GetFollowListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetFollowListCallbackImp gRequestGetFollowListCallbackImp;
- (NSInteger)getFollowList:(int)start
                      step:(int)step
             finishHandler:(GetFollowListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetFollowList(&mHttpRequestManager, start, step, &gRequestGetFollowListCallbackImp);
    
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetRoomInfoCallbackImp : public IRequestGetRoomInfoCallback {
public:
    RequestGetRoomInfoCallbackImp(){};
    ~RequestGetRoomInfoCallbackImp(){};
    void OnGetRoomInfo(HttpGetRoomInfoTask *task, bool success, int errnum, const string &errmsg, const HttpGetRoomInfoItem &Item) {
        NSLog(@"LSRequestManager::OnGetRoomInfo( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        RoomInfoItemObject *Obj = [[RoomInfoItemObject alloc] init];
        NSMutableArray *array = [NSMutableArray array];
        for (HttpGetRoomInfoItem::RoomItemList::const_iterator iter = Item.roomList.begin(); iter != Item.roomList.end(); iter++) {
            RoomItemObject *item = [[RoomItemObject alloc] init];
            item.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
            item.roomUrl = [NSString stringWithUTF8String:(*iter).roomUrl.c_str()];
            [array addObject:item];
        }
        Obj.roomList = array;
        
        NSMutableArray *array1 = [NSMutableArray array];
        for (InviteItemList::const_iterator iter = Item.inviteList.begin(); iter != Item.inviteList.end(); iter++) {
            InviteIdItemObject *item = [[InviteIdItemObject alloc] init];
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
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], Obj);
        }
    }
};
RequestGetRoomInfoCallbackImp gGetRoomInfoCallbackImp;
- (NSInteger)getRoomInfo:(GetRoomInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetRoomInfo(&mHttpRequestManager, &gGetRoomInfoCallbackImp);
    
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestLiveFansListCallbackImp : public IRequestLiveFansListCallback {
public:
    RequestLiveFansListCallbackImp(){};
    ~RequestLiveFansListCallbackImp(){};
    void OnLiveFansList(HttpLiveFansListTask *task, bool success, int errnum, const string &errmsg, const HttpLiveFansList &listItem) {
        NSLog(@"LSRequestManager::OnLiveFansList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HttpLiveFansList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            ViewerFansItemObject *item = [[ViewerFansItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.mountId = [NSString stringWithUTF8String:(*iter).mountId.c_str()];
            item.mountUrl = [NSString stringWithUTF8String:(*iter).mountUrl.c_str()];
            item.level = (*iter).level;
            [array addObject:item];
            NSLog(@"LSRequestManager::OnGetLiveRoomFansList( task : %p, userId : %@, nickName : %@, photoUrl : %@ )", task, item.userId, item.nickName, item.photoUrl);
        }
        LiveFansListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestLiveFansListCallbackImp gLiveFansListCallbackImp;

- (NSInteger)liveFansList:(NSString *_Nonnull)roomId
                    start:(int)start
                     step:(int)step
            finishHandler:(LiveFansListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.LiveFansList(&mHttpRequestManager, [roomId UTF8String], start, step, &gLiveFansListCallbackImp);
    
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetAllGiftListCallbackImp : public IRequestGetAllGiftListCallback {
public:
    RequestGetAllGiftListCallbackImp(){};
    ~RequestGetAllGiftListCallbackImp(){};
    void OnGetAllGiftList(HttpGetAllGiftListTask *task, bool success, int errnum, const string &errmsg, const GiftItemList &itemList) {
        NSLog(@"LSRequestManager::OnGetLiveRoomAllGiftList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
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
            gift.credit = (*iter).credit;
            gift.multiClick = (*iter).multiClick;
            gift.type = (*iter).type;
            gift.level = (*iter).level;
            gift.loveLevel = (*iter).loveLevel;
            gift.updateTime = (*iter).updateTime;
            gift.playTime = (*iter).playTime;
            NSMutableArray *arrayNum = [NSMutableArray array];
            for (SendNumList::const_iterator iterNum = (*iter).sendNumList.begin(); iterNum != (*iter).sendNumList.end(); iterNum++) {
                NSNumber *nsNum = [NSNumber numberWithInt:(*iterNum)];
                [arrayNum addObject:nsNum];
            }
            gift.sendNumList = arrayNum;
            [array addObject:gift];
        }
        GetAllGiftListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetAllGiftListCallbackImp gRequestGetAllGiftListCallbackImp;
- (NSInteger)getAllGiftList:(GetAllGiftListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetAllGiftList(&mHttpRequestManager, &gRequestGetAllGiftListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetGiftListByUserIdCallbackImp : public IRequestGetGiftListByUserIdCallback {
public:
    RequestGetGiftListByUserIdCallbackImp(){};
    ~RequestGetGiftListByUserIdCallbackImp(){};
    void OnGetGiftListByUserId(HttpGetGiftListByUserIdTask *task, bool success, int errnum, const string &errmsg, const GiftWithIdItemList &itemList) {
        NSLog(@"LSRequestManager::OnGetAllGiftList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (GiftWithIdItemList::const_iterator iter = itemList.begin(); iter != itemList.end(); iter++) {
            GiftWithIdItemObject *item = [[GiftWithIdItemObject alloc] init];
            item.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            item.isShow = (*iter).isShow;
            item.isPromo = (*iter).isPromo;
            [array addObject:item];
            //            NSLog(@"LSRequestManager::OnGetLiveRoomGiftListByUserId( task : %p, giftId : %@ )", task, item.giftId);
        }
        GetGiftListByUserIdFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetGiftListByUserIdCallbackImp gRequestGetGiftListByUserIdCallbackImp;
- (NSInteger)getGiftListByUserId:(NSString *_Nonnull)roomId
                   finishHandler:(GetGiftListByUserIdFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetGiftListByUserId(&mHttpRequestManager, [roomId UTF8String], &gRequestGetGiftListByUserIdCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetGiftDetailCallbackImp : public IRequestGetGiftDetailCallback {
public:
    RequestGetGiftDetailCallbackImp(){};
    ~RequestGetGiftDetailCallbackImp(){};
    void OnGetGiftDetail(HttpGetGiftDetailTask *task, bool success, int errnum, const string &errmsg, const HttpGiftInfoItem &item) {
        NSLog(@"LSRequestManager::OnGetGiftDetail( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        GiftInfoItemObject *gift = [[GiftInfoItemObject alloc] init];
        gift.giftId = [NSString stringWithUTF8String:item.giftId.c_str()];
        gift.name = [NSString stringWithUTF8String:item.name.c_str()];
        gift.smallImgUrl = [NSString stringWithUTF8String:item.smallImgUrl.c_str()];
        gift.middleImgUrl = [NSString stringWithUTF8String:item.middleImgUrl.c_str()];
        gift.bigImgUrl = [NSString stringWithUTF8String:item.bigImgUrl.c_str()];
        gift.srcFlashUrl = [NSString stringWithUTF8String:item.srcFlashUrl.c_str()];
        gift.srcwebpUrl = [NSString stringWithUTF8String:item.srcwebpUrl.c_str()];
        gift.credit = item.credit;
        gift.multiClick = item.multiClick;
        gift.type = item.type;
        gift.level = item.level;
        gift.loveLevel = item.loveLevel;
        gift.updateTime = item.updateTime;
        gift.playTime = item.playTime;
        NSMutableArray *arrayNum = [NSMutableArray array];
        for (SendNumList::const_iterator iterNum = item.sendNumList.begin(); iterNum != item.sendNumList.end(); iterNum++) {
            NSNumber *nsNum = [NSNumber numberWithInt:(*iterNum)];
            [arrayNum addObject:nsNum];
        }
        gift.sendNumList = arrayNum;
        
        GetGiftDetailFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], gift);
        }
    }
};
RequestGetGiftDetailCallbackImp gRequestGetGiftDetailCallbackImp;
- (NSInteger)getGiftDetail:(NSString *_Nonnull)giftId
             finishHandler:(GetGiftDetailFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetGiftDetail(&mHttpRequestManager, [giftId UTF8String], &gRequestGetGiftDetailCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetEmoticonListCallbackImp : public IRequestGetEmoticonListCallback {
public:
    RequestGetEmoticonListCallbackImp(){};
    ~RequestGetEmoticonListCallbackImp(){};
    void OnGetEmoticonList(HttpGetEmoticonListTask *task, bool success, int errnum, const string &errmsg, const EmoticonItemList &listItem) {
        NSLog(@"LSRequestManager::OnGetEmoticonList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (EmoticonItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            EmoticonItemObject *item = [[EmoticonItemObject alloc] init];
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
                Emo.emoType = (*iterEmo).emoType;
                Emo.emoIconUrl = [NSString stringWithUTF8String:(*iterEmo).emoIconUrl.c_str()];
                [arrayEmo addObject:Emo];
            }
            item.emoList = arrayEmo;
            [array addObject:item];
        }
        
        GetEmoticonListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetEmoticonListCallbackImp gRequestGetEmoticonListCallbackImp;
- (NSInteger)getEmoticonList:(GetEmoticonListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetEmoticonList(&mHttpRequestManager, &gRequestGetEmoticonListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetInviteInfoCallbackImp : public IRequestGetInviteInfoCallback {
public:
    RequestGetInviteInfoCallbackImp(){};
    ~RequestGetInviteInfoCallbackImp(){};
    void OnGetInviteInfo(HttpGetInviteInfoTask *task, bool success, int errnum, const string &errmsg, const HttpInviteInfoItem &inviteItem) {
        NSLog(@"LSRequestManager::OnGetInviteInfo( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        InviteIdItemObject *item = [[InviteIdItemObject alloc] init];
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
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], item);
        }
    }
};
RequestGetInviteInfoCallbackImp gRequestGetInviteInfoCallbackImp;
- (NSInteger)getInviteInfo:(NSString *_Nonnull)inviteId
             finishHandler:(GetInviteInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetInviteInfo(&mHttpRequestManager, [inviteId UTF8String], &gRequestGetInviteInfoCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetTalentListCallbackImp : public IRequestGetTalentListCallback {
public:
    RequestGetTalentListCallbackImp(){};
    ~RequestGetTalentListCallbackImp(){};
    void OnGetTalentList(HttpGetTalentListTask *task, bool success, int errnum, const string &errmsg, const TalentItemList &list) {
        NSLog(@"LSRequestManager::OnGetTalentList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        NSMutableArray *array = [NSMutableArray array];
        for (TalentItemList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            GetTalentItemObject *item = [[GetTalentItemObject alloc] init];
            item.talentId = [NSString stringWithUTF8String:(*iter).talentId.c_str()];
            item.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            item.credit = (*iter).credit;
            [array addObject:item];
        }
        
        GetTalentListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetTalentListCallbackImp gRequestGetTalentListCallbackImp;
- (NSInteger)getTalentList:(NSString *_Nonnull)roomId
             finishHandler:(GetTalentListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetTalentList(&mHttpRequestManager, [roomId UTF8String], &gRequestGetTalentListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetTalentStatusCallbackImp : public IRequestGetTalentStatusCallback {
public:
    RequestGetTalentStatusCallbackImp(){};
    ~RequestGetTalentStatusCallbackImp(){};
    void OnGetTalentStatus(HttpGetTalentStatusTask *task, bool success, int errnum, const string &errmsg, const HttpGetTalentStatusItem &item) {
        NSLog(@"LSRequestManager::OnGetTalentStatus( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        GetTalentStatusItemObject *obj = [[GetTalentStatusItemObject alloc] init];
        obj.talentInviteId = [NSString stringWithUTF8String:item.talentInviteId.c_str()];
        obj.talentId = [NSString stringWithUTF8String:item.talentId.c_str()];
        obj.name = [NSString stringWithUTF8String:item.name.c_str()];
        obj.credit = item.credit;
        obj.status = item.status;
        
        GetTalentStatusFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetTalentStatusCallbackImp gRequestGetTalentStatusCallbackImp;
- (NSInteger)getTalentStatus:(NSString *_Nonnull)roomId
              talentInviteId:(NSString *_Nonnull)talentInviteId
               finishHandler:(GetTalentStatusFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetTalentStatus(&mHttpRequestManager, [roomId UTF8String], [talentInviteId UTF8String], &gRequestGetTalentStatusCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetNewFansBaseInfoCallbackImp : public IRequestGetNewFansBaseInfoCallback {
public:
    RequestGetNewFansBaseInfoCallbackImp(){};
    ~RequestGetNewFansBaseInfoCallbackImp(){};
    void OnGetNewFansBaseInfo(HttpGetNewFansBaseInfoTask *task, bool success, int errnum, const string &errmsg, const HttpLiveFansInfoItem &item) {
        NSLog(@"LSRequestManager::OnGetNewFansBaseInfo( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        GetNewFansBaseInfoItemObject *obj = [[GetNewFansBaseInfoItemObject alloc] init];
        obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
        obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
        obj.riderId = [NSString stringWithUTF8String:item.riderId.c_str()];
        obj.riderName = [NSString stringWithUTF8String:item.riderName.c_str()];
        obj.riderUrl = [NSString stringWithUTF8String:item.riderUrl.c_str()];
        
        GetNewFansBaseInfoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetNewFansBaseInfoCallbackImp gRequestGetNewFansBaseInfoCallbackImp;
- (NSInteger)getNewFansBaseInfo:(NSString *_Nonnull)userId
                  finishHandler:(GetNewFansBaseInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetNewFansBaseInfo(&mHttpRequestManager, [userId UTF8String], &gRequestGetNewFansBaseInfoCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestControlManPushCallbackImp : public IRequestControlManPushCallback {
public:
    RequestControlManPushCallbackImp(){};
    ~RequestControlManPushCallbackImp(){};
    void OnControlManPush(HttpControlManPushTask *task, bool success, int errnum, const string &errmsg, const list<string> &uploadUrls) {
        NSLog(@"LSRequestManager::OnControlManPush( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *nsUploadUrls = [NSMutableArray array];
        for (list<string>::const_iterator itr = uploadUrls.begin(); itr != uploadUrls.end(); itr++) {
            NSString *strUploadUrl = [NSString stringWithUTF8String:(*itr).c_str()];
            [nsUploadUrls addObject:strUploadUrl];
        }
        
        ControlManPushFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], nsUploadUrls);
        }
    }
};
RequestControlManPushCallbackImp gRequestControlManPushCallbackImp;
- (NSInteger)controlManPush:(NSString *_Nonnull)roomId
                    control:(ControlType)control
              finishHandler:(ControlManPushFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ControlManPush(&mHttpRequestManager, [roomId UTF8String], control, &gRequestControlManPushCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetPromoAnchorListCallbackImp : public IRequestGetPromoAnchorListCallback {
public:
    RequestGetPromoAnchorListCallbackImp(){};
    ~RequestGetPromoAnchorListCallbackImp(){};
    void OnGetPromoAnchorList(HttpGetPromoAnchorListTask *task, bool success, int errnum, const string &errmsg, const HotItemList &listItem) {
        NSLog(@"LSRequestManager::OnGetPromoAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HotItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            LiveRoomInfoItemObject *item = [[LiveRoomInfoItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            //            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter).roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter).onlineStatus;
            item.roomType = (*iter).roomType;
            //            NSMutableArray* nsInterest = [NSMutableArray array];
            //            for (InterestList::const_iterator itr = (*iter).interest.begin(); itr != (*iter).interest.end(); itr++) {
            //                int num = (*itr);
            //                NSNumber *numInterest = [NSNumber numberWithInt:num];
            //                [nsInterest addObject:numInterest];
            //            }
            //            item.interest = nsInterest;
            item.anchorType = (*iter).anchorType;
            [array addObject:item];
        }
        
        GetPromoAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetPromoAnchorListCallbackImp gRequestGetPromoAnchorListCallbackImp;
- (NSInteger)getPromoAnchorList:(int)number
                           type:(PromoAnchorType)type
                         userId:(NSString *_Nonnull)userId
                  finishHandler:(GetPromoAnchorListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetPromoAnchorList(&mHttpRequestManager, number, type, [userId UTF8String], &gRequestGetPromoAnchorListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

#pragma mark - 预约私密

class RequestManHandleBookingListCallbackImp : public IRequestManHandleBookingListCallback {
public:
    RequestManHandleBookingListCallbackImp(){};
    ~RequestManHandleBookingListCallbackImp(){};
    void OnManHandleBookingList(HttpManHandleBookingListTask *task, bool success, int errnum, const string &errmsg, const HttpBookingInviteListItem &BookingListItem) {
        NSLog(@"LSRequestManager::OnManHandleBookingList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        BookingPrivateInviteListObject *item = [[BookingPrivateInviteListObject alloc] init];
        item.total = BookingListItem.total;
        item.noReadCount = BookingListItem.noReadCount;
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
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], item);
        }
    }
};
RequestManHandleBookingListCallbackImp gRequestManHandleBookingListCallbackImp;
- (NSInteger)manHandleBookingList:(BookingListType)type
                            start:(int)start
                             step:(int)step
                    finishHandler:(ManHandleBookingListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ManHandleBookingList(&mHttpRequestManager, type, start, step, &gRequestManHandleBookingListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestHandleBookingCallbackImp : public IRequestHandleBookingCallback {
public:
    RequestHandleBookingCallbackImp(){};
    ~RequestHandleBookingCallbackImp(){};
    void OnHandleBooking(HttpHandleBookingTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnHandleBooking( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        HandleBookingFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestHandleBookingCallbackImp gRequestHandleBookingCallbackImp;
- (NSInteger)handleBooking:(NSString *_Nonnull)inviteId
                 isConfirm:(BOOL)isConfirm
             finishHandler:(HandleBookingFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.HandleBooking(&mHttpRequestManager, [inviteId UTF8String], isConfirm, &gRequestHandleBookingCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestSendCancelPrivateLiveInviteCallbackImp : public IRequestSendCancelPrivateLiveInviteCallback {
public:
    RequestSendCancelPrivateLiveInviteCallbackImp(){};
    ~RequestSendCancelPrivateLiveInviteCallbackImp(){};
    void OnSendCancelPrivateLiveInvite(HttpSendCancelPrivateLiveInviteTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnSendCancelPrivateLiveInvite( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        SendCancelPrivateLiveInviteFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSendCancelPrivateLiveInviteCallbackImp gRequestSendCancelPrivateLiveInviteCallbackImp;
- (NSInteger)sendCancelPrivateLiveInvite:(NSString *_Nonnull)invitationId
                           finishHandler:(SendCancelPrivateLiveInviteFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.SendCancelPrivateLiveInvite(&mHttpRequestManager, [invitationId UTF8String], &gRequestSendCancelPrivateLiveInviteCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestManBookingUnreadUnhandleNumCallbackImp : public IRequestManBookingUnreadUnhandleNumCallback {
public:
    RequestManBookingUnreadUnhandleNumCallbackImp(){};
    ~RequestManBookingUnreadUnhandleNumCallbackImp(){};
    void OnManBookingUnreadUnhandleNum(HttpManBookingUnreadUnhandleNumTask *task, bool success, int errnum, const string &errmsg, const HttpBookingUnreadUnhandleNumItem &item) {
        NSLog(@"LSRequestManager::OnManBookingUnreadUnhandleNum( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        BookingUnreadUnhandleNumItemObject *obj = [[BookingUnreadUnhandleNumItemObject alloc] init];
        obj.totalNoReadNum = item.totalNoReadNum;
        obj.pendingNoReadNum = item.pendingNoReadNum;
        obj.scheduledNoReadNum = item.scheduledNoReadNum;
        obj.historyNoReadNum = item.historyNoReadNum;
        
        ManBookingUnreadUnhandleNumFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestManBookingUnreadUnhandleNumCallbackImp gRequestManBookingUnreadUnhandleNumCallbackImp;
- (NSInteger)manBookingUnreadUnhandleNum:(ManBookingUnreadUnhandleNumFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ManBookingUnreadUnhandleNum(&mHttpRequestManager, &gRequestManBookingUnreadUnhandleNumCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetCreateBookingInfoCallbackImp : public IRequestGetCreateBookingInfoCallback {
public:
    RequestGetCreateBookingInfoCallbackImp(){};
    ~RequestGetCreateBookingInfoCallbackImp(){};
    void OnGetCreateBookingInfo(HttpGetCreateBookingInfoTask *task, bool success, int errnum, const string &errmsg, const HttpGetCreateBookingInfoItem &item) {
        NSLog(@"LSRequestManager::OnGetCreateBookingInfo( task : %p, success : %s, errnum : %d, errmsg : %s, count : %d )", task, success ? "true" : "false", errnum, errmsg.c_str(), (int)item.bookTime.size());
        
        GetCreateBookingInfoItemObject *obj = [[GetCreateBookingInfoItemObject alloc] init];
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
            LSGiftItemObject *objBookGift = [[LSGiftItemObject alloc] init];
            objBookGift.giftId = [NSString stringWithUTF8String:(*iterBookGift).giftId.c_str()];
            NSMutableArray *arrayGiftNum = [NSMutableArray array];
            for (HttpGetCreateBookingInfoItem::GiftNumList::const_iterator iterGiftNum = (*iterBookGift).sendNumList.begin(); iterGiftNum != (*iterBookGift).sendNumList.end(); iterGiftNum++) {
                GiftNumItemObject *objGiftNum = [[GiftNumItemObject alloc] init];
                objGiftNum.num = (*iterGiftNum).num;
                objGiftNum.isDefault = (*iterGiftNum).isDefault;
                [arrayGiftNum addObject:objGiftNum];
            }
            objBookGift.sendNumList = arrayGiftNum;
            [arrayBookGift addObject:objBookGift];
        }
        obj.bookGift = arrayBookGift;
        
        BookPhoneItemObject *bookPhone = [[BookPhoneItemObject alloc] init];
        bookPhone.country = [NSString stringWithUTF8String:item.bookPhone.country.c_str()];
        bookPhone.areaCode = [NSString stringWithUTF8String:item.bookPhone.areaCode.c_str()];
        bookPhone.phoneNo = [NSString stringWithUTF8String:item.bookPhone.phoneNo.c_str()];
        obj.bookPhone = bookPhone;
        
        GetCreateBookingInfoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetCreateBookingInfoCallbackImp gRequestGetCreateBookingInfoCallbackImp;
- (NSInteger)getCreateBookingInfo:(NSString *_Nullable)userId
                    finishHandler:(GetCreateBookingInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetCreateBookingInfo(&mHttpRequestManager, [userId UTF8String], &gRequestGetCreateBookingInfoCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestSendBookingRequestCallbackImp : public IRequestSendBookingRequestCallback {
public:
    RequestSendBookingRequestCallbackImp(){};
    ~RequestSendBookingRequestCallbackImp(){};
    void OnSendBookingRequest(HttpSendBookingRequestTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnSendBookingRequest( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        SendBookingRequestFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSendBookingRequestCallbackImp gRequestSendBookingRequestCallbackImp;
- (NSInteger)sendBookingRequest:(NSString *_Nullable)userId
                         timeId:(NSString *_Nullable)timeId
                       bookTime:(NSInteger)bookTime
                         giftId:(NSString *_Nullable)giftId
                        giftNum:(int)giftNum
                        needSms:(BOOL)needSms
                  finishHandler:(SendBookingRequestFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.SendBookingRequest(&mHttpRequestManager, [userId UTF8String], [timeId UTF8String], bookTime, [giftId UTF8String], giftNum, needSms, &gRequestSendBookingRequestCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAcceptInstanceInviteCallbackImp : public IRequestAcceptInstanceInviteCallback {
public:
    RequestAcceptInstanceInviteCallbackImp(){};
    ~RequestAcceptInstanceInviteCallbackImp(){};
    void OnAcceptInstanceInvite(HttpAcceptInstanceInviteTask *task, bool success, int errnum, const string &errmsg, const HttpAcceptInstanceInviteItem &item) {
        NSLog(@"LSRequestManager::OnAcceptInstanceInvite( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        AcceptInstanceInviteItemObject *obj = [[AcceptInstanceInviteItemObject alloc] init];
        obj.roomId = [NSString stringWithUTF8String:item.roomId.c_str()];
        obj.roomType = item.roomType;
        
        AcceptInstanceInviteFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestAcceptInstanceInviteCallbackImp gRequestAcceptInstanceInviteCallbackImp;
- (NSInteger)acceptInstanceInvite:(NSString *_Nullable)inviteId
                        isConfirm:(BOOL)isConfirm
                    finishHandler:(AcceptInstanceInviteFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.AcceptInstanceInvite(&mHttpRequestManager, [inviteId UTF8String], isConfirm, &gRequestAcceptInstanceInviteCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

#pragma mark - 背包

class RequestGiftListCallbackImp : public IRequestGiftListCallback {
public:
    RequestGiftListCallbackImp(){};
    ~RequestGiftListCallbackImp(){};
    void OnGiftList(HttpGiftListTask *task, bool success, int errnum, const string &errmsg, const BackGiftItemList &list, int totalCount) {
        NSLog(@"LSRequestManager::OnGiftList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (BackGiftItemList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            BackGiftItemObject *item = [[BackGiftItemObject alloc] init];
            item.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            item.num = (*iter).num;
            item.grantedDate = (*iter).grantedDate;
            item.startValidDate = (*iter).startValidDate;
            item.expDate = (*iter).expDate;
            item.read = (*iter).read;
            [array addObject:item];
        }
        
        GiftListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array, totalCount);
        }
    }
};
RequestGiftListCallbackImp gRequestGiftListCallbackImp;
- (NSInteger)giftList:(GiftListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GiftList(&mHttpRequestManager, &gRequestGiftListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestVoucherListCallbackImp : public IRequestVoucherListCallback {
public:
    RequestVoucherListCallbackImp(){};
    ~RequestVoucherListCallbackImp(){};
    void OnVoucherList(HttpVoucherListTask *task, bool success, int errnum, const string &errmsg, const VoucherList &list, int totalCount) {
        NSLog(@"LSRequestManager::OnVoucherList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (VoucherList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            VoucherItemObject *item = [[VoucherItemObject alloc] init];
            item.voucherId = [NSString stringWithUTF8String:(*iter).voucherId.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.photoUrlMobile = [NSString stringWithUTF8String:(*iter).photoUrlMobile.c_str()];
            item.desc = [NSString stringWithUTF8String:(*iter).desc.c_str()];
            item.useRoomType = (*iter).useRoomType;
            item.anchorType = (*iter).anchorType;
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.anchorNcikName = [NSString stringWithUTF8String:(*iter).anchorNcikName.c_str()];
            item.anchorPhotoUrl = [NSString stringWithUTF8String:(*iter).anchorPhotoUrl.c_str()];
            item.grantedDate = (*iter).grantedDate;
            item.startValidDate = (*iter).startValidDate;
            item.expDate = (*iter).expDate;
            item.read = (*iter).read;
            [array addObject:item];
        }
        
        VoucherListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array, totalCount);
        }
    }
};
RequestVoucherListCallbackImp gRequestVoucherListCallbackImp;
- (NSInteger)voucherList:(VoucherListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.VoucherList(&mHttpRequestManager, &gRequestVoucherListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestRideListCallbackImp : public IRequestRideListCallback {
public:
    RequestRideListCallbackImp(){};
    ~RequestRideListCallbackImp(){};
    void OnRideList(HttpRideListTask *task, bool success, int errnum, const string &errmsg, const RideList &list, int totalCount) {
        NSLog(@"LSRequestManager::OnRideList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (RideList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            RideItemObject *item = [[RideItemObject alloc] init];
            item.rideId = [NSString stringWithUTF8String:(*iter).rideId.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            item.grantedDate = (*iter).grantedDate;
            item.startValidDate = (*iter).startValidDate;
            item.expDate = (*iter).expDate;
            item.read = (*iter).read;
            item.isUse = (*iter).isUse;
            [array addObject:item];
        }
        
        RideListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array, totalCount);
        }
    }
};
RequestRideListCallbackImp gRequestRideListCallbackImp;
- (NSInteger)rideList:(RideListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.RideList(&mHttpRequestManager, &gRequestRideListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestSetRideCallbackImp : public IRequestSetRideCallback {
public:
    RequestSetRideCallbackImp(){};
    ~RequestSetRideCallbackImp(){};
    void OnSetRide(HttpSetRideTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnSetRide( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        SetRideFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSetRideCallbackImp gRequestSetRideCallbackImp;
- (NSInteger)setRide:(NSString *_Nonnull)rideId
       finishHandler:(SetRideFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.SetRide(&mHttpRequestManager, [rideId UTF8String], &gRequestSetRideCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetBackpackUnreadNumCallbackImp : public IRequestGetBackpackUnreadNumCallback {
public:
    RequestGetBackpackUnreadNumCallbackImp(){};
    ~RequestGetBackpackUnreadNumCallbackImp(){};
    void OnGetBackpackUnreadNum(HttpGetBackpackUnreadNumTask *task, bool success, int errnum, const string &errmsg, const HttpGetBackPackUnreadNumItem &item) {
        NSLog(@"LSRequestManager::OnGetBackpackUnreadNum( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        GetBackPackUnreadNumItemObject *obj = [[GetBackPackUnreadNumItemObject alloc] init];
        obj.total = item.total;
        obj.voucherUnreadNum = item.voucherUnreadNum;
        obj.giftUnreadNum = item.giftUnreadNum;
        obj.rideUnreadNum = item.rideUnreadNum;
        
        GetBackpackUnreadNumFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetBackpackUnreadNumCallbackImp gRequestGetBackpackUnreadNumCallbackImp;
- (NSInteger)getBackpackUnreadNum:(GetBackpackUnreadNumFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetBackpackUnreadNum(&mHttpRequestManager, &gRequestGetBackpackUnreadNumCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

#pragma mark - 其它

class RequestGetConfigCallbackImp : public IRequestGetConfigCallback {
public:
    RequestGetConfigCallbackImp(){};
    ~RequestGetConfigCallbackImp(){};
    void OnGetConfig(HttpGetConfigTask *task, bool success, int errnum, const string &errmsg, const HttpConfigItem &configItem) {
        NSLog(@"LSRequestManager::OnGetConfig( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ConfigItemObject *obj = [[ConfigItemObject alloc] init];
        obj.imSvrUrl = [NSString stringWithUTF8String:configItem.imSvrUrl.c_str()];
        obj.httpSvrUrl = [NSString stringWithUTF8String:configItem.httpSvrUrl.c_str()];
        obj.addCreditsUrl = [NSString stringWithUTF8String:configItem.addCreditsUrl.c_str()];
        obj.anchorPage = [NSString stringWithUTF8String:configItem.anchorPage.c_str()];
        obj.userLevel = [NSString stringWithUTF8String:configItem.userLevel.c_str()];
        obj.intimacy = [NSString stringWithUTF8String:configItem.intimacy.c_str()];
        obj.userProtocol = [NSString stringWithUTF8String:configItem.userProtocol.c_str()];
        
        GetConfigFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetConfigCallbackImp gRequestGetConfigCallbackImp;
- (NSInteger)getConfig:(GetConfigFinishHandler _Nullable)finishHandler {
    
    NSInteger request = (NSInteger)mHttpRequestController.GetConfig(&mConfigHttpRequestManager, &gRequestGetConfigCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetLeftCreditCallbackImp : public IRequestGetLeftCreditCallback {
public:
    RequestGetLeftCreditCallbackImp(){};
    ~RequestGetLeftCreditCallbackImp(){};
    void OnGetLeftCredit(HttpGetLeftCreditTask *task, bool success, int errnum, const string &errmsg, double credit) {
        NSLog(@"LSRequestManager::OnGetLeftCredit( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        GetLeftCreditFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], credit);
        }
    }
};
RequestGetLeftCreditCallbackImp gRequestGetLeftCreditCallbackImp;
- (NSInteger)getLeftCredit:(GetLeftCreditFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetLeftCredit(&mHttpRequestManager, &gRequestGetLeftCreditCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestSetFavoriteCallbackImp : public IRequestSetFavoriteCallback {
public:
    RequestSetFavoriteCallbackImp(){};
    ~RequestSetFavoriteCallbackImp(){};
    void OnSetFavorite(HttpSetFavoriteTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnSetFavorite( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        SetFavoriteFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSetFavoriteCallbackImp gRequestSetFavoriteCallbackImp;
- (NSInteger)setFavorite:(NSString *_Nonnull)userId
                  roomId:(NSString *_Nonnull)roomId
                   isFav:(BOOL)isFav
           finishHandler:(SetFavoriteFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.SetFavorite(&mHttpRequestManager, [userId UTF8String], [roomId UTF8String], isFav, &gRequestSetFavoriteCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetAdAnchorListCallbackImp : public IRequestGetAdAnchorListCallback {
public:
    RequestGetAdAnchorListCallbackImp(){};
    ~RequestGetAdAnchorListCallbackImp(){};
    void OnGetAdAnchorList(HttpGetAdAnchorListTask *task, bool success, int errnum, const string &errmsg, const HotItemList &list) {
        NSLog(@"LSRequestManager::OnGetAdAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HotItemList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LiveRoomInfoItemObject *item = [[LiveRoomInfoItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter).roomPhotoUrl.c_str()];
            item.onlineStatus = (*iter).onlineStatus;
            item.roomType = (*iter).roomType;
            NSMutableArray *nsInterest = [NSMutableArray array];
            //int i = 0;
            for (InterestList::const_iterator itr = (*iter).interest.begin(); itr != (*iter).interest.end(); itr++) {
                //NSString* strInterest = [NSString stringWithUTF8String:(*itr).c_str()];
                int num = (*itr);
                NSNumber *numInterest = [NSNumber numberWithInt:num];
                [nsInterest addObject:numInterest];
                //item->interest[i] = (*itr);
                //i++;
            }
            item.interest = nsInterest;
            item.anchorType = (*iter).anchorType;
            [array addObject:item];
        }
        
        GetAdAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestGetAdAnchorListCallbackImp gRequestGetAdAnchorListCallbackImp;
- (NSInteger)getAdAnchorList:(int)number
               finishHandler:(GetAdAnchorListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetAdAnchorList(&mHttpRequestManager, number, &gRequestGetAdAnchorListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestCloseAdAnchorListCallbackImp : public IRequestCloseAdAnchorListCallback {
public:
    RequestCloseAdAnchorListCallbackImp(){};
    ~RequestCloseAdAnchorListCallbackImp(){};
    void OnCloseAdAnchorList(HttpCloseAdAnchorListTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnCloseAdAnchorList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        CloseAdAnchorListFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestCloseAdAnchorListCallbackImp gRequestCloseAdAnchorListCallbackImp;
- (NSInteger)closeAdAnchorList:(CloseAdAnchorListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.CloseAdAnchorList(&mHttpRequestManager, &gRequestCloseAdAnchorListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestGetPhoneVerifyCodeCallbackImp : public IRequestGetPhoneVerifyCodeCallback {
public:
    RequestGetPhoneVerifyCodeCallbackImp(){};
    ~RequestGetPhoneVerifyCodeCallbackImp(){};
    void OnGetPhoneVerifyCode(HttpGetPhoneVerifyCodeTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnGetPhoneVerifyCode( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        GetPhoneVerifyCodeFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestGetPhoneVerifyCodeCallbackImp gRequestGetPhoneVerifyCodeCallbackImp;
- (NSInteger)getPhoneVerifyCode:(NSString *_Nonnull)country
                       areaCode:(NSString *_Nonnull)areaCode
                        phoneNo:(NSString *_Nonnull)phoneNo
                  finishHandler:(GetPhoneVerifyCodeFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetPhoneVerifyCode(&mHttpRequestManager, [country UTF8String], [areaCode UTF8String], [phoneNo UTF8String], &gRequestGetPhoneVerifyCodeCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestSubmitPhoneVerifyCodeCallbackImp : public IRequestSubmitPhoneVerifyCodeCallback {
public:
    RequestSubmitPhoneVerifyCodeCallbackImp(){};
    ~RequestSubmitPhoneVerifyCodeCallbackImp(){};
    void OnSubmitPhoneVerifyCode(HttpSubmitPhoneVerifyCodeTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSRequestManager::OnSubmitPhoneVerifyCode( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        SubmitPhoneVerifyCodeFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSubmitPhoneVerifyCodeCallbackImp gRequestSubmitPhoneVerifyCodeCallbackImp;
- (NSInteger)submitPhoneVerifyCode:(NSString *_Nonnull)country
                          areaCode:(NSString *_Nonnull)areaCode
                           phoneNo:(NSString *_Nonnull)phoneNo
                        verifyCode:(NSString *_Nonnull)verifyCode
                     finishHandler:(SubmitPhoneVerifyCodeFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.SubmitPhoneVerifyCode(&mHttpRequestManager, [country UTF8String], [areaCode UTF8String], [phoneNo UTF8String], [verifyCode UTF8String], &gRequestSubmitPhoneVerifyCodeCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestServerSpeedCallbackImp : public IRequestServerSpeedCallback {
public:
    RequestServerSpeedCallbackImp(){};
    ~RequestServerSpeedCallbackImp(){};
    void OnServerSpeed(HttpServerSpeedTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"RequestManager::OnServerSpeed( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ServerSpeedFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestServerSpeedCallbackImp gRequestServerSpeedCallbackImp;
- (NSInteger)serverSpeed:(NSString *_Nonnull)sid
                     res:(int)res
           finishHandler:(ServerSpeedFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ServerSpeed(&mHttpRequestManager, [sid UTF8String], res, &gRequestServerSpeedCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestBannerCallbackImp : public IRequestBannerCallback {
public:
    RequestBannerCallbackImp(){};
    ~RequestBannerCallbackImp(){};
    void OnBanner(HttpBannerTask *task, bool success, int errnum, const string &errmsg, const string &bannerImg, const string &bannerLink, const string &bannerName) {
        NSLog(@"LSRequestManager::OnBanner( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        BannerFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:bannerImg.c_str()], [NSString stringWithUTF8String:bannerLink.c_str()], [NSString stringWithUTF8String:bannerName.c_str()]);
        }
    }
};
RequestBannerCallbackImp gRequestBannerCallbackImp;
- (NSInteger)banner:(BannerFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.Banner(&mHttpRequestManager, &gRequestBannerCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetUserInfoCallbackImp : public IRequestGetUserInfoCallback {
public:
    RequestGetUserInfoCallbackImp(){};
    ~RequestGetUserInfoCallbackImp(){};
    void OnGetUserInfo(HttpGetUserInfoTask* task, bool success, int errnum, const string& errmsg, const HttpUserInfoItem& userItem) {
        NSLog(@"LSRequestManager::OnGetUserInfo( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSUserInfoItemObject * item  = [[LSUserInfoItemObject alloc] init];
        item.userId = [NSString stringWithUTF8String:userItem.userId.c_str()];
        item.nickName = [NSString stringWithUTF8String:userItem.nickName.c_str()];
        item.photoUrl = [NSString stringWithUTF8String:userItem.photoUrl.c_str()];
        item.age = userItem.age;
        item.country = [NSString stringWithUTF8String:userItem.country.c_str()];
        item.userLevel = userItem.userLevel;
        item.isOnline = userItem.isOnline;
        item.isAnchor = userItem.isAnchor;
        item.leftCredit = userItem.leftCredit;
        LSAnchorInfoItemObject * anchorItem = [[LSAnchorInfoItemObject alloc] init];
        anchorItem.address = [NSString stringWithUTF8String:userItem.anchorInfo.address.c_str()];
        anchorItem.anchorType = userItem.anchorInfo.anchorType;
        anchorItem.isLive = userItem.anchorInfo.isLive;
        anchorItem.introduction = [NSString stringWithUTF8String:userItem.anchorInfo.introduction.c_str()];
        item.anchorInfo = anchorItem;
        
        GetUserInfoFinishHandler handler = nil;
        LSRequestManager *manager = [LSRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], item);
        }
    }
};

RequestGetUserInfoCallbackImp gRequestGetUserInfoCallbackImp;
- (NSInteger)getUserInfo:(NSString * _Nonnull) userId
           finishHandler:(GetUserInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.GetUserInfo(&mHttpRequestManager, [userId UTF8String], &gRequestGetUserInfoCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

@end

