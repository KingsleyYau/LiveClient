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
    HttpRequestManager mHttpRequestManagerUpload;
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
        mHttpRequestManagerUpload.SetVersionCode(COMMON_VERSION_CODE, [self.versionCode UTF8String]);
        
    }
    return self;
}

#pragma mark - 公共模块
+ (void)setLogEnable:(BOOL)enable {
    KLog::SetLogEnable(enable);
    KLog::SetLogLevel(KLog::LOG_MSG);
    KLog::SetLogFileEnable(NO);
}

+ (void)setLogDirectory:(NSString *)directory {
    KLog::SetLogDirectory([directory UTF8String]);
    CleanDir([directory UTF8String]);
}

- (void)setWebSite:(NSString * _Nonnull)webSite {
    mHttpRequestManager.SetWebSite([webSite UTF8String]);
}

- (void)setWebSiteUpload:(NSString * _Nonnull)webSite {
    mHttpRequestManagerUpload.SetWebSite([webSite UTF8String]);
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

#pragma mark - 登陆认证模块

class RequestRegisterCheckPhoneCallbackImp : public IRequestRegisterCheckPhoneCallback {
public:
    RequestRegisterCheckPhoneCallbackImp(){};
    ~RequestRegisterCheckPhoneCallbackImp(){};
    void OnRegisterCheckPhone(HttpRegisterCheckPhoneTask* task, bool success, int errnum, const string& errmsg, bool isRegistered) {
        NSLog(@"RequestManager::OnRegisterCheckPhone( task : %p, success : %s, errnum : %d, errmsg : %s isRegistered : %d )", task, success?"true":"false", errnum, errmsg.c_str(), isRegistered);
        
        RegisterCheckPhoneFinishHandler handler = nil;
        
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], isRegistered);
        }
    }
};
RequestRegisterCheckPhoneCallbackImp gRequestRegisterCheckPhoneCallbackImp;

- (NSInteger)registerCheckPhone:(NSString * _Nullable)phoneno
                          areno:(NSString * _Nullable)areno
                  finishHandler:(RegisterCheckPhoneFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.RegisterCheckPhone(&mHttpRequestManager, [phoneno UTF8String], [areno UTF8String], &gRequestRegisterCheckPhoneCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestRegisterGetSMSCodeCallbackImp : public IRequestRegisterGetSMSCodeCallback{
public:
    RequestRegisterGetSMSCodeCallbackImp(){};
    ~RequestRegisterGetSMSCodeCallbackImp(){};
    void OnRegisterGetSMSCode(HttpRegisterGetSMSCodeTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnRegisterGetSMSCode( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success?"true":"false", errnum, errmsg.c_str());
        
        RegisterGetSMSCodeFinishHandler handler = nil;
        
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
RequestRegisterGetSMSCodeCallbackImp gRequestRegisterGetSMSCodeCallbackImp;

- (NSInteger)registerGetSMSCode:(NSString * _Nullable)phoneno
                          areno:(NSString * _Nullable)areno
                  finishHandler:(RegisterGetSMSCodeFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.RegisterGetSMSCode(&mHttpRequestManager, [phoneno UTF8String],  [areno UTF8String], &gRequestRegisterGetSMSCodeCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestRegisterPhoneCallbackImp : public IRequestRegisterPhoneCallback {
public:
    RequestRegisterPhoneCallbackImp(){};
    ~RequestRegisterPhoneCallbackImp(){};
    void OnRegisterPhone(HttpRegisterPhoneTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnRegisterPhone( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success?"true":"false", errnum, errmsg.c_str());
        
        RegisterPhoneFinishHandler handler = nil;
        
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
RequestRegisterPhoneCallbackImp gRequestRegisterPhoneCallbackImp;

- (NSInteger)registerPhone:(NSString * _Nullable)phoneno
                     areno:(NSString * _Nullable)areno
                 checkcode:(NSString * _Nonnull)checkcode
                  password:(NSString * _Nonnull)password
                  deviceid:(NSString * _Nonnull)deviceid
                     model:(NSString * _Nonnull)model
              manufacturer:(NSString * _Nonnull)manufacturer
             finishHandler:(RegisterPhoneFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.RegisterPhone(&mHttpRequestManager, [phoneno UTF8String], [areno UTF8String], [checkcode UTF8String], [password UTF8String], [deviceid UTF8String], [model UTF8String], [manufacturer UTF8String], &gRequestRegisterPhoneCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

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
        obj.country = [NSString stringWithUTF8String:item.country.c_str()];
        obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
        obj.sign = [NSString stringWithUTF8String:item.sign.c_str()];
        obj.anchor = item.anchor;
        obj.modifyinfo = item.modifyinfo;
    
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

- (NSInteger)login:(LoginType)type
           phoneno:(NSString * _Nullable)phoneno
             areno:(NSString * _Nullable)areno
          password:(NSString * _Nonnull)password
          deviceid:(NSString * _Nonnull)deviceid
             model:(NSString * _Nonnull)model
      manufacturer:(NSString * _Nonnull)manufacturer
         autoLogin:(BOOL)autoLogin
    finishHandler:(LoginFinishHandler _Nullable)finishHandler {
    string strAreno;
    if (nil != areno) {
        strAreno = [areno UTF8String];
    }
    
    string strPhone;
    if (nil != phoneno) {
        strPhone = [phoneno UTF8String];
    }
    string strPassword;
    if (nil != password) {
        strPassword = [password UTF8String];
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
    
    NSInteger request = mHttpRequestController.Login(&mHttpRequestManager, type, strPhone, strAreno, strPassword, strDeviceid, strModel, strManufacturer, autoLogin, &gRequestLoginCallbackImp);
    
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

- (NSInteger)logout:(NSString * _Nonnull)token finishHandler:(LogoutFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.Logout(&mHttpRequestManager, [token UTF8String], &gRequestLogoutCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

#pragma mark - 直播间模块
class RequestUpdateLiveRoomTokenIdCallbackImp : public IRequestUpdateLiveRoomTokenIdCallback {
public:
    RequestUpdateLiveRoomTokenIdCallbackImp(){};
    ~RequestUpdateLiveRoomTokenIdCallbackImp(){};
    
    void OnUpdateLiveRoomTokenId(HttpUpdateLiveRoomTokenIdTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::onLogout( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success?"true":"false", errnum, errmsg.c_str());
        
        UpdateLiveRoomTokenIdFinishHandler handler = nil;
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
RequestUpdateLiveRoomTokenIdCallbackImp gRequestUpdateLiveRoomTokenIdCallbackImp;
- (NSInteger)updateLiveRoomTokenId:(NSString * _Nonnull)token
                           tokenId:(NSString * _Nonnull)tokenId
                     finishHandler:(UpdateLiveRoomTokenIdFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.UpdateLiveRoomTokenId(&mHttpRequestManager, [token UTF8String], [tokenId UTF8String], &gRequestUpdateLiveRoomTokenIdCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestLiveRoomCreateCallbackImp : public IRequestLiveRoomCreateCallback {
public:
    RequestLiveRoomCreateCallbackImp(){};
    ~RequestLiveRoomCreateCallbackImp(){};
    
    void OnCreateLiveRoom(HttpLiveRoomCreateTask* task, bool success, int errnum, const string& errmsg, const string& roomId, const string& roomUrl) {
        NSLog(@"RequestManager::OnCreateLiveRoom( task : %p, success : %s, errnum : %d, errmsg : %s roomId : %s roomUrl : %s)", task, success?"true":"false", errnum, errmsg.c_str(), roomId.c_str(), roomUrl.c_str());
        
        CreateLiveRoomFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:roomId.c_str()], [NSString stringWithUTF8String:roomUrl.c_str()]);
        }
    }
};
RequestLiveRoomCreateCallbackImp gRequestLiveRoomCreateCallbackImp;


- (NSInteger)createLiveRoom:(NSString * _Nonnull)token
                   roomName:(NSString * _Nonnull)roomName
                roomPhotoId:(NSString * _Nonnull)roomPhotoId
              finishHandler:(CreateLiveRoomFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.CreateLiveRoom(&mHttpRequestManager, [token UTF8String], [roomName UTF8String], [roomPhotoId UTF8String], &gRequestLiveRoomCreateCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;

}

class RequestCheckLiveRoomCallbackImp : public IRequestCheckLiveRoomCallback {
public:
    RequestCheckLiveRoomCallbackImp(){};
    ~RequestCheckLiveRoomCallbackImp(){};
    
    void OnCheckLiveRoom(HttpCheckLiveRoomTask* task, bool success, int errnum, const string& errmsg, const string& roomId, const string& roomUrl) {
        NSLog(@"RequestManager::OnCreateLiveRoom( task : %p, success : %s, errnum : %d, errmsg : %s roomId : %s roomUrl : %s)", task, success?"true":"false", errnum, errmsg.c_str(), roomId.c_str(), roomUrl.c_str());
        
        CheckLiveRoomFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:roomId.c_str()], [NSString stringWithUTF8String:roomUrl.c_str()]);
        }
    }
};
RequestCheckLiveRoomCallbackImp gRequestCheckLiveRoomCallbackImp;


- (NSInteger)checkLiveRoom:(NSString * _Nonnull)token
             finishHandler:(CheckLiveRoomFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.CheckLiveRoom(&mHttpRequestManager, [token UTF8String], &gRequestCheckLiveRoomCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestCloseLiveRoomCallbackImp : public IRequestCloseLiveRoomCallback {
public:
    RequestCloseLiveRoomCallbackImp(){};
    ~RequestCloseLiveRoomCallbackImp(){};
    
    void OnCloseLiveRoom(HttpCloseLiveRoomTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnCloseLiveRoom( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        CloseLiveRoomFinishHandler handler = nil;
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
RequestCloseLiveRoomCallbackImp gRequestCloseLiveRoomCallbackImp;

- (NSInteger)closeLiveRoom:(NSString * _Nonnull)token
                    roomId:(NSString * _Nonnull)roomId
             finishHandler:(CloseLiveRoomFinishHandler _Nullable)finishHandler {
    
    NSString* strToken = token?token:@"";
    NSString* strRoomId = roomId?roomId:@"";
    
    NSInteger request = mHttpRequestController.CloseLiveRoom(&mHttpRequestManager, [strToken UTF8String], [strRoomId UTF8String], &gRequestCloseLiveRoomCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetLiveRoomFansListCallbackImp : public IRequestGetLiveRoomFansListCallback {
public:
    RequestGetLiveRoomFansListCallbackImp(){};
    ~RequestGetLiveRoomFansListCallbackImp(){};
    void OnGetLiveRoomFansList(HttpGetLiveRoomFansListTask* task, bool success, int errnum, const string& errmsg, const ViewerItemList& listItem) {
        NSLog(@"RequestManager::OnGetLiveRoomFansList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (ViewerItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            ViewerFansItemObject* item = [[ViewerFansItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            [array addObject:item];
            NSLog(@"RequestManager::OnGetLiveRoomFansList( task : %p, userId : %@, nickName : %@, photoUrl : %@)", task, item.userId, item.nickName, item.photoUrl);
        }
        GetLiveRoomFansListFinishHandler handler = nil;
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
RequestGetLiveRoomFansListCallbackImp gRequestGetLiveRoomFansListCallbackImp;

- (NSInteger)getLiveRoomFansList:(NSString * _Nonnull)token
                              roomId:(NSString * _Nonnull)roomId
                       finishHandler:(GetLiveRoomFansListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetLiveRoomFansList(&mHttpRequestManager, [token UTF8String], [roomId UTF8String], &gRequestGetLiveRoomFansListCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetLiveRoomAllFansListCallbackImp : public IRequestGetLiveRoomAllFansListCallback {
public:
    RequestGetLiveRoomAllFansListCallbackImp(){};
    ~RequestGetLiveRoomAllFansListCallbackImp(){};
    void OnGetLiveRoomAllFansList(HttpGetLiveRoomAllFansListTask* task, bool success, int errnum, const string& errmsg, const ViewerItemList& listItem) {
        NSLog(@"RequestManager::OnGetLiveRoomFansList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (ViewerItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            ViewerFansItemObject* item = [[ViewerFansItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            [array addObject:item];
            NSLog(@"RequestManager::OnGetLiveRoomFansList( task : %p, userId : %@, nickName : %@, photoUrl : %@)", task, item.userId, item.nickName, item.photoUrl);
        }
        GetLiveRoomAllFansListFinishHandler handler = nil;
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
RequestGetLiveRoomAllFansListCallbackImp gRequestGetLiveRoomAllFansListCallbackImp;
- (NSInteger)getLiveRoomAllFansList:(NSString * _Nonnull)token
                             roomId:(NSString * _Nonnull)roomId
                              start:(int)start
                               step:(int)step
                      finishHandler:(GetLiveRoomAllFansListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetLiveRoomAllFansList(&mHttpRequestManager, [token UTF8String], [roomId UTF8String], start, step, &gRequestGetLiveRoomAllFansListCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

#pragma mark - 主播属性模块
class RequestGetLiveRoomHotListCallbackImp : public IRequestGetLiveRoomHotCallback {
public:
    RequestGetLiveRoomHotListCallbackImp(){};
    ~RequestGetLiveRoomHotListCallbackImp(){};
    void OnGetLiveRoomHot(HttpGetLiveRoomHotTask* task, bool success, int errnum, const string& errmsg, const HotItemList& listItem) {
        NSLog(@"RequestManager::OnGetLiveRoomHot( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HotItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            LiveRoomInfoItemObject* item = [[LiveRoomInfoItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
            item.roomName = [NSString stringWithUTF8String:(*iter).roomName.c_str()];
            item.roomPhotoUrl = [NSString stringWithUTF8String:(*iter).roomPhotoUrl.c_str()];
            item.status = (*iter).status;
            item.fansNum = (*iter).fansNum;
            item.country = [NSString stringWithUTF8String:(*iter).country.c_str()];
            [array addObject:item];
            NSLog(@"RequestManager::OnGetLiveRoomHot( task : %p, userId : %@, nickName : %@, photoUrl : %@ , roomId : %@ , roomName : %@ , roomPhotoUrl : %@ , status : %d , fansNum : %d , country :%@ ", task, item.userId, item.nickName, item.photoUrl, item.roomId, item.roomName, item.roomPhotoUrl, item.status, item.fansNum, item.country);
        }
        GetLiveRoomFansListFinishHandler handler = nil;
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
RequestGetLiveRoomHotListCallbackImp gRequestGetLiveRoomHotListCallbackImp;
- (NSInteger)getLiveRoomHotList:(NSString * _Nonnull)token
                              start:(int)start
                               step:(int)step
                      finishHandler:(GetLiveRoomHotListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetLiveRoomHotList(&mHttpRequestManager, [token UTF8String], start, step, &gRequestGetLiveRoomHotListCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetLiveRoomAllGiftListCallbackImp : public IRequestGetLiveRoomAllGiftListCallback {
public:
    RequestGetLiveRoomAllGiftListCallbackImp(){};
    ~RequestGetLiveRoomAllGiftListCallbackImp(){};
    void OnGetLiveRoomAllGiftList(HttpGetLiveRoomAllGiftListTask* task, bool success, int errnum, const string& errmsg, const GiftItemList& itemList) {
        NSLog(@"RequestManager::OnGetLiveRoomAllGiftList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (GiftItemList::const_iterator iter = itemList.begin(); iter != itemList.end(); iter++) {
            LiveRoomGiftItemObject* item = [[LiveRoomGiftItemObject alloc] init];
            item.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            item.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            item.smallImgUrl = [NSString stringWithUTF8String:(*iter).smallImgUrl.c_str()];
            item.imgUrl = [NSString stringWithUTF8String:(*iter).imgUrl.c_str()];
            item.srcUrl = [NSString stringWithUTF8String:(*iter).srcUrl.c_str()];
            item.coins = (*iter).coins;
            item.multi_click = (*iter).isMulti_click;
            item.type = (*iter).type;
            item.update_time = (*iter).update_time;
            [array addObject:item];
            NSLog(@"RequestManager::OnGetLiveRoomPhotoList( task : %p, giftId : %@, name : %@ smallImgUrl : %@ imgUrl : %@ srcUrl : %@ coins :%f type : %d , multi_click : %d update_time: %d", task, item.giftId, item.name, item.smallImgUrl, item.imgUrl, item.srcUrl, item.coins, item.type, item.multi_click, item.update_time);
        }
        GetLiveRoomAllGiftListFinishHandler handler = nil;
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
RequestGetLiveRoomAllGiftListCallbackImp gRequestGetLiveRoomAllGiftListCallbackImp;
- (NSInteger)getLiveRoomAllGiftList:(NSString * _Nonnull)token
                      finishHandler:(GetLiveRoomAllGiftListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetLiveRoomAllGiftList(&mHttpRequestManager, [token UTF8String], &gRequestGetLiveRoomAllGiftListCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetLiveRoomGiftListByUserIdCallbackImp : public IRequestGetLiveRoomGiftListByUserIdCallback {
public:
    RequestGetLiveRoomGiftListByUserIdCallbackImp(){};
    ~RequestGetLiveRoomGiftListByUserIdCallbackImp(){};
    void OnGetLiveRoomGiftListByUserId(HttpGetLiveRoomGiftListByUserIdTask* task, bool success, int errnum, const string& errmsg, const GiftWithIdItemList& itemList) {
        NSLog(@"RequestManager::OnGetLiveRoomGiftListByUserId( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (GiftWithIdItemList::const_iterator iter = itemList.begin(); iter != itemList.end(); iter++) {
            NSString* item = [NSString stringWithUTF8String:(*iter).c_str()];
            [array addObject:item];
            NSLog(@"RequestManager::OnGetLiveRoomGiftListByUserId( task : %p, giftId : %@", task, item);
        }
        GetLiveRoomGiftListByUserIdFinishHandler handler = nil;
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
RequestGetLiveRoomGiftListByUserIdCallbackImp gRequestGetLiveRoomGiftListByUserIdCallbackImp;
- (NSInteger)getLiveRoomGiftListByUserId:(NSString * _Nonnull)token
                                  roomId:(NSString * _Nonnull)roomId
                           finishHandler:(GetLiveRoomGiftListByUserIdFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetLiveRoomGiftListByUserId(&mHttpRequestManager, [token UTF8String], [roomId UTF8String], &gRequestGetLiveRoomGiftListByUserIdCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetLiveRoomGiftDetailCallbackImp : public IRequestGetLiveRoomGiftDetailCallback {
public:
    RequestGetLiveRoomGiftDetailCallbackImp(){};
    ~RequestGetLiveRoomGiftDetailCallbackImp(){};
    void OnGetLiveRoomGiftDetail(HttpGetLiveRoomGiftDetailTask* task, bool success, int errnum, const string& errmsg, const HttpLiveRoomGiftItem& item) {
        NSLog(@"RequestManager::OnGetLiveRoomGiftDetail( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        LiveRoomGiftItemObject* Obj = [[LiveRoomGiftItemObject alloc] init];
        Obj.giftId = [NSString stringWithUTF8String:item.giftId.c_str()];
        Obj.name = [NSString stringWithUTF8String:item.name.c_str()];
        Obj.smallImgUrl = [NSString stringWithUTF8String:item.smallImgUrl.c_str()];
        Obj.imgUrl = [NSString stringWithUTF8String:item.imgUrl.c_str()];
        Obj.srcUrl = [NSString stringWithUTF8String:item.srcUrl.c_str()];
        Obj.coins = item.coins;
        Obj.multi_click = item.isMulti_click;
        Obj.type = item.type;
        Obj.update_time = item.update_time;

        
        NSLog(@"RequestManager::OnGetLiveRoomGiftDetail( task : %p, giftId : %@, name : %@ smallImgUrl : %@ imgUrl : %@ srcUrl : %@ coins :%f type : %d , multi_click : %d update_time: %d", task, Obj.giftId, Obj.name, Obj.smallImgUrl, Obj.imgUrl, Obj.srcUrl, Obj.coins, Obj.type, Obj.multi_click, Obj.update_time);
        GetLiveRoomGiftDetailFinishHandler handler = nil;
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
RequestGetLiveRoomGiftDetailCallbackImp gRequestGetLiveRoomGiftDetailCallbackImp;
- (NSInteger)getLiveRoomGiftDetail:(NSString * _Nonnull)token
                            giftId:(NSString * _Nonnull)giftId
                     finishHandler:(GetLiveRoomGiftDetailFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetLiveRoomGiftDetail(&mHttpRequestManager, [token UTF8String], [giftId UTF8String], &gRequestGetLiveRoomGiftDetailCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetLiveRoomPhotoListCallbackImp : public IRequestGetLiveRoomPhotoListCallback {
public:
    RequestGetLiveRoomPhotoListCallbackImp(){};
    ~RequestGetLiveRoomPhotoListCallbackImp(){};
    void OnGetLiveRoomPhotoList(HttpGetLiveRoomPhotoListTask* task, bool success, int errnum, const string& errmsg, const CoverPhotoItemList& itemList) {
        NSLog(@"RequestManager::OnGetLiveRoomPhotoList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (CoverPhotoItemList::const_iterator iter = itemList.begin(); iter != itemList.end(); iter++) {
            CoverPhotoItemObject* item = [[CoverPhotoItemObject alloc] init];
            item.photoId = [NSString stringWithUTF8String:(*iter).photoId.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.status = (*iter).status;
            item.in_use = (*iter).isIn_use;
            [array addObject:item];
            NSLog(@"RequestManager::OnGetLiveRoomPhotoList( task : %p, photoId : %@, photoUrl : %@ status : %d , in_use : %d", task, item.photoId, item.photoUrl, item.status, item.in_use);
        }
        GetLiveRoomPhotoListFinishHandler handler = nil;
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
RequestGetLiveRoomPhotoListCallbackImp gRequestGetLiveRoomPhotoListCallbackImp;

- (NSInteger)getLiveRoomPhotoList:(NSString * _Nonnull)token
                    finishHandler:(GetLiveRoomPhotoListFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetLiveRoomPhotoList(&mHttpRequestManager,  [token UTF8String], &gRequestGetLiveRoomPhotoListCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestAddLiveRoomPhotoCallbackImp : public IRequestAddLiveRoomPhotoCallback {
public:
    RequestAddLiveRoomPhotoCallbackImp(){};
    ~RequestAddLiveRoomPhotoCallbackImp(){};
    void OnAddLiveRoomPhoto(HttpAddLiveRoomPhotoTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnAddLiveRoomPhoto( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        AddLiveRoomPhotoFinishHandler handler = nil;
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
RequestAddLiveRoomPhotoCallbackImp gRequestAddLiveRoomPhotoCallbackImp;
- (NSInteger)addLiveRoomPhoto:(NSString * _Nonnull)token
                      photoId:(NSString * _Nonnull)photoId
                finishHandler:(AddLiveRoomPhotoFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.AddLiveRoomPhoto(&mHttpRequestManager, [token UTF8String], [photoId UTF8String], &gRequestAddLiveRoomPhotoCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSetUsingLiveRoomPhotoCallbackImp : public IRequestSetUsingLiveRoomPhotoCallback {
public:
    RequestSetUsingLiveRoomPhotoCallbackImp(){};
    ~RequestSetUsingLiveRoomPhotoCallbackImp(){};
    void OnSetUsingLiveRoomPhoto(HttpSetUsingLiveRoomPhotoTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnSetUsingLiveRoomPhoto( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        SetUsingLiveRoomPhotoFinishHandler handler = nil;
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
RequestSetUsingLiveRoomPhotoCallbackImp gRequestSetUsingLiveRoomPhotoCallbackImp;
- (NSInteger)setUsingLiveRoomPhoto:(NSString * _Nonnull)token
                           photoId:(NSString * _Nonnull)photoId
                     finishHandler:(SetUsingLiveRoomPhotoFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.SetUsingLiveRoomPhoto(&mHttpRequestManager, [token UTF8String], [photoId UTF8String], &gRequestSetUsingLiveRoomPhotoCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestDelLiveRoomPhotoCallbackImp : public IRequestDelLiveRoomPhotoCallback {
public:
    RequestDelLiveRoomPhotoCallbackImp(){};
    ~RequestDelLiveRoomPhotoCallbackImp(){};
    void OnDelLiveRoomPhoto(HttpDelLiveRoomPhotoTast* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnDelLiveRoomPhoto( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        
        DelLiveRoomPhotoFinishHandler handler = nil;
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
RequestDelLiveRoomPhotoCallbackImp gRequestDelLiveRoomPhotoCallbackImp;
- (NSInteger)delLiveRoomPhoto:(NSString * _Nonnull)token
                      photoId:(NSString * _Nonnull)photoId
                finishHandler:(DelLiveRoomPhotoFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.DelLiveRoomPhoto(&mHttpRequestManager, [token UTF8String], [photoId UTF8String], &gRequestDelLiveRoomPhotoCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

#pragma mark - 个人信息模块

class RequestGetLiveRoomUserPhotoCallbackImp : public IRequestGetLiveRoomUserPhotoCallback {
public:
    RequestGetLiveRoomUserPhotoCallbackImp(){};
    ~RequestGetLiveRoomUserPhotoCallbackImp(){};
    void OnGetLiveRoomUserPhoto(HttpGetLiveRoomUserPhotoTask* task, bool success, int errnum, const string& errmsg, const string& photoUrl) {
        NSLog(@"RequestManager::OnGetLiveRoomUserPhoto( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());

        GetLiveRoomUserPhotoFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:photoUrl.c_str()]);
        }
    }
};
RequestGetLiveRoomUserPhotoCallbackImp gRequestGetLiveRoomUserPhotoCallbackImp;
- (NSInteger)getLiveRoomUserPhoto:(NSString * _Nonnull)token
                               userId:(NSString * _Nonnull)userId
                            photoType:(PhotoType)photoType
                        finishHandler:(GetLiveRoomUserPhotoFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetLiveRoomUserPhoto(&mHttpRequestManager, [token UTF8String], [userId UTF8String], photoType, &gRequestGetLiveRoomUserPhotoCallbackImp);
    
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetLiveRoomModifyInfoCallbackImp : public IRequestGetLiveRoomModifyInfoCallback {
public:
    RequestGetLiveRoomModifyInfoCallbackImp(){};
    ~RequestGetLiveRoomModifyInfoCallbackImp(){};
    void OnGetLiveRoomModifyInfo(HttpGetLiveRoomModifyInfoTask* task, bool success, int errnum, const string& errmsg, const HttpLiveRoomPersonalInfoItem& item) {
        NSLog(@"RequestManager::OnGetLiveRoomModifyInfo( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        NSLog(@"RequestManager::OnGetLiveRoomModifyInfo( task : %p, photoUrl : %s, nickName : %s, gender : %d, birthday : %s)", task, item.photoUrl.c_str(), item.nickName.c_str(), item.gender, item.birthday.c_str());
        GetLiveRoomModifyInfoFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];
        LiveRoomPersonalInfoItemObject *obj = [[LiveRoomPersonalInfoItemObject alloc] init];
        obj.photoId = [NSString stringWithUTF8String:item.photoId.c_str()];
        obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
        obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
        obj.gender = item.gender;
        obj.birthday = [NSString stringWithUTF8String:item.birthday.c_str()];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetLiveRoomModifyInfoCallbackImp gRequestGetLiveRoomModifyInfoCallbackImp;

- (NSInteger)getLiveRoomModifyInfo:(NSString * _Nonnull)token
                     finishHandler:(GetLiveRoomModifyInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetLiveRoomModifyInfo(&mHttpRequestManager, [token UTF8String], &gRequestGetLiveRoomModifyInfoCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestSetLiveRoomModifyInfoCallbackImp : public IRequestSetLiveRoomModifyInfoCallback {
public:
    RequestSetLiveRoomModifyInfoCallbackImp(){};
    ~RequestSetLiveRoomModifyInfoCallbackImp(){};
    void OnSetLiveRoomModifyInfo(HttpSetLiveRoomModifyInfoTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"RequestManager::OnSetLiveRoomModifyInfo( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        SetLiveRoomModifyInfoFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];;
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestSetLiveRoomModifyInfoCallbackImp gRequestSetLiveRoomModifyInfoCallbackImp;


- (NSInteger)setLiveRoomModifyInfo:(NSString * _Nonnull)token
                          photoId:(NSString * _Nonnull)photoId
                          nickName:(NSString * _Nonnull)nickName
                            gender:(Gender)gender
                          birthday:(NSString * _Nonnull)birthday
                     finishHandler:(SetLiveRoomModifyInfoFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.SetLiveRoomModifyInfo(&mHttpRequestManager, [token UTF8String], [photoId UTF8String], [nickName UTF8String], gender, [birthday UTF8String], &gRequestSetLiveRoomModifyInfoCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestGetLiveRoomConfigCallbackImp : public IRequestGetLiveRoomConfigCallback {
public:
    RequestGetLiveRoomConfigCallbackImp(){};
    ~RequestGetLiveRoomConfigCallbackImp(){};
    void OnGetLiveRoomConfig(HttpGetLiveRoomConfigTask* task, bool success, int errnum, const string& errmsg, const HttpLiveRoomConfigItem& item) {
        NSLog(@"RequestManager::OnGetLiveRoomConfig( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success?"true":"false", errnum, errmsg.c_str());
        LiveRoomConfigItemObject *obj = [[LiveRoomConfigItemObject alloc] init];
        obj.imSvr_ip = [NSString stringWithUTF8String:item.imSvr_ip.c_str()];
        obj.imSvr_port = item.imSvr_port;
        obj.httpSvr_ip = [NSString stringWithUTF8String:item.httpSvr_ip.c_str()];
        obj.httpSvr_port = item.httpSvr_port;
        obj.uploadSvr_ip = [NSString stringWithUTF8String:item.uploadSvr_ip.c_str()];
        obj.uploadSvr_port = item.uploadSvr_port;
         NSLog(@"RequestManager::OnGetLiveRoomConfig( task : %p, success : %s, errnum : %d, errmsg : %s, imSvr_ip : %@, imSvr_port :%d, httpSvr_ip : %@, httpSvr_port :%d, uploadSvr_ip : %@, uploadSvr_port :%d)", task, success?"true":"false", errnum, errmsg.c_str(), obj.imSvr_ip, obj.imSvr_port, obj.httpSvr_ip, obj.httpSvr_port, obj.uploadSvr_ip, obj.uploadSvr_port);
        GetLiveRoomConfigFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];;
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestGetLiveRoomConfigCallbackImp gRequestGetLiveRoomConfigCallbackImp;
- (NSInteger)getLiveRoomConfig:(GetLiveRoomConfigFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.GetLiveRoomConfig(&mHttpRequestManager, &gRequestGetLiveRoomConfigCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

class RequestUploadLiveRoomImgCallbackImp : public IRequestUploadLiveRoomImgCallback {
public:
    RequestUploadLiveRoomImgCallbackImp(){};
    ~RequestUploadLiveRoomImgCallbackImp(){};
    void OnUploadLiveRoomImg(HttpUploadLiveRoomImgTask* task, bool success, int errnum, const string& errmsg, const string& imageId, const string& imageUrl) {
        NSLog(@"RequestManager::OnUploadLiveRoomImg( task : %p, success : %s, errnum : %d, errmsg : %s, imageId:%s, imageUrl:%s )", task, success?"true":"false", errnum, errmsg.c_str(), imageId.c_str(), imageUrl.c_str());
        UploadLiveRoomImgFinishHandler handler = nil;
        RequestManager *manager = [RequestManager manager];;
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if( handler ) {
            handler(success, errnum, [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:imageId.c_str()], [NSString stringWithUTF8String:imageUrl.c_str()]);
        }
    }
};
RequestUploadLiveRoomImgCallbackImp gRequestUploadLiveRoomImgCallbackImp;

- (NSInteger)uploadLiveRoomImg:(NSString * _Nonnull)token
                     imageType:(ImageType)imageType
                 imageFileName:(NSString * _Nonnull)imageFileName
                 finishHandler:(UploadLiveRoomImgFinishHandler _Nullable)finishHandler {
    NSInteger request = mHttpRequestController.UploadLiveRoomImg(&mHttpRequestManagerUpload, [token UTF8String], imageType, [imageFileName UTF8String], &gRequestUploadLiveRoomImgCallbackImp);
    if( request != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
        }
    }
    
    return request;
}

@end
