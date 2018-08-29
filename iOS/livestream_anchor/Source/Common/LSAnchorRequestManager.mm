//
//  LSAnchorRequestManager.m
//  dating
//
//  Created by Alex on 18/2/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSAnchorRequestManager.h"

#include <common/CommonFunc.h>
#include <common/KZip.h>

#include <httpclient/HttpRequestManager.h>

#include <anchorhttpcontroller/ZBHttpRequestController.h>

#include <anchorhttpcontroller/ZBHttpRequestDefine.h>
#import <sys/utsname.h>

/*直播间状态转换*/
static const int HTTPErrorTypeArray[] = {
    ZBHTTP_LCC_ERR_SUCCESS,   // 成功
    ZBHTTP_LCC_ERR_FAIL, // 服务器返回失败结果
    
    // 客户端定义的错误
    ZBHTTP_LCC_ERR_PROTOCOLFAIL,   // 协议解析失败（服务器返回的格式不正确）
    ZBHTTP_LCC_ERR_CONNECTFAIL,    // 连接服务器失败/断开连接
    ZBHTTP_LCC_ERR_CHECKVERFAIL,   // 检测版本号失败（可能由于版本过低导致）
    
    ZBHTTP_LCC_ERR_SVRBREAK,       // 服务器踢下线
    ZBHTTP_LCC_ERR_INVITE_TIMEOUT, // 邀请超时
    // 服务器返回错误
    ZBHTTP_LCC_ERR_INSUFFICIENT_PARAM,  // Insufficient parameters or parameter error (未传action参数或action参数不正确)
    ZBHTTP_LCC_ERR_NO_LOGIN,            // Need to login. (未登录)
    ZBHTTP_LCC_ERR_SYSTEM,              // Error. (系统错误)
    ZBHTTP_LCC_ERR_TOKEN_EXPIRE ,       // Token expire, need to login again.(Token 过期了)
    ZBHTTP_LCC_ERR_NOT_FOUND_ROOM,      // room is not found. (进入房间失败 找不到房间信息or房间关闭)
    ZBHTTP_LCC_ERR_CREDIT_FAIL,         // 远程扣费接口调用失败.（扣费信用点失败）
    ZBHTTP_LCC_ERR_ROOM_CLOSE,          // the room is closed. ( 房间已经关闭 /*important*/)
    ZBHTTP_LCC_ERR_KICKOFF,             // Sorry, you have been kickoff. (被挤掉线 默认通知内容)
    ZBHTTP_LCC_ERR_NO_AUTHORIZED,       // you are not authorized.(不能操作 不是对应的userid)
    ZBHTTP_LCC_ERR_LIVEROOM_NO_EXIST,   // 直播间不存在
    ZBHTTP_LCC_ERR_LIVEROOM_CLOSED,     // 直播间已关闭
    ZBHTTP_LCC_ERR_ANCHORID_INCONSISTENT,       // 主播id与直播场次的主播id不合
    ZBHTTP_LCC_ERR_CLOSELIVE_DATA_FAIL,         // 关闭直播场次,数据表操作出错
    ZBHTTP_LCC_ERR_CLOSELIVE_LACK_CODITION,     // 主播立即关闭私密直播间, 不满足关闭条件
    ZBHTTP_ERR_IDENTITY_FAILURE,                // 身份失效
    ZBHTTP_LCC_ERR_VERIFICATIONCODE,            // 验证码错误
    ZBHTTP_LCC_ERR_CANCEL_FAIL_INVITE,          // 取消失败，观众已接受
    
};

static LSAnchorRequestManager *gManager = nil;
@interface LSAnchorRequestManager () {
    HttpRequestManager mHttpRequestManager;
    HttpRequestManager mConfigHttpRequestManager;
    ZBHttpRequestController mHttpRequestController;
}

@property (nonatomic, strong) NSMutableDictionary *delegateDictionary;

@end

@implementation LSAnchorRequestManager

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
    KLog::SetLogDirectory(directory?[directory UTF8String]:"");
    HttpClient::SetCookiesDirectory(directory?[directory UTF8String]:"");
    //    CleanDir([directory UTF8String]);
}

+ (void)setProxy:(NSString * _Nullable)proxyUrl {
    // HttpClient::SetProxy(proxyUrl?[proxyUrl UTF8String]:"");
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

- (NSString * _Nonnull)getModelType {
    //需要导入头文件：#import <sys/utsname.h>
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"]) return@"iPhone 2G";
    
    if([platform isEqualToString:@"iPhone1,2"]) return@"iPhone 3G";
    
    if([platform isEqualToString:@"iPhone2,1"]) return@"iPhone 3GS";
    
    if([platform isEqualToString:@"iPhone3,1"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,2"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,3"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone4,1"]) return@"iPhone 4S";
    
    if([platform isEqualToString:@"iPhone5,1"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,2"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,3"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone5,4"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone6,1"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone6,2"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone7,1"]) return@"iPhone 6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"]) return@"iPhone 6";
    
    if([platform isEqualToString:@"iPhone8,1"]) return@"iPhone 6s";
    
    if([platform isEqualToString:@"iPhone8,2"]) return@"iPhone 6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"]) return@"iPhone SE";
    
    if([platform isEqualToString:@"iPhone9,1"]) return@"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,2"]) return@"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,4"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,2"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,6"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPod1,1"]) return@"iPod Touch 1G";
    
    if([platform isEqualToString:@"iPod2,1"]) return@"iPod Touch 2G";
    
    if([platform isEqualToString:@"iPod3,1"]) return@"iPod Touch 3G";
    
    if([platform isEqualToString:@"iPod4,1"]) return@"iPod Touch 4G";
    
    if([platform isEqualToString:@"iPod5,1"]) return@"iPod Touch 5G";
    
    if([platform isEqualToString:@"iPad1,1"]) return@"iPad 1G";
    
    if([platform isEqualToString:@"iPad2,1"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,2"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,3"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,4"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,5"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,6"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,7"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad3,1"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,2"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,3"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,4"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,5"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,6"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad4,1"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,2"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,3"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,4"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,5"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,6"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,7"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,8"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,9"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad5,1"]) return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,2"]) return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,3"]) return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad5,4"]) return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad6,3"]) return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,4"]) return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,7"]) return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"iPad6,8"]) return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"i386"]) return@"iPhone Simulator";
    
    if([platform isEqualToString:@"x86_64"]) return@"iPhone Simulator";
    
    return platform;
    
}


- (NSInteger)invalidRequestId {
    return HTTPREQUEST_INVALIDREQUESTID;
}

//oc层转底层枚举
-(ZBHTTP_LCC_ERR_TYPE)intToHttpLccErrType:(int)errType {
    // 默认是HTTP_LCC_ERR_FAIL，当服务器返回未知的错误码时
    ZBHTTP_LCC_ERR_TYPE value = ZBHTTP_LCC_ERR_FAIL;
    int i = 0;
    for (i = 0; i < _countof(HTTPErrorTypeArray); i++)
    {
        if (errType == HTTPErrorTypeArray[i]) {
            value = (ZBHTTP_LCC_ERR_TYPE)HTTPErrorTypeArray[i];
            break;
        }
    }
    return value;
}


#pragma mark - 登陆认证模块

class RequestZBLoginCallbackImp : public IRequestZBLoginCallback {
public:
    RequestZBLoginCallbackImp(){};
    ~RequestZBLoginCallbackImp(){};
    void OnZBLogin(ZBHttpLoginTask* task, bool success, int errnum, const string& errmsg, const ZBHttpLoginItem& item) {
        NSLog(@"LSAnchorRequestManager::OnZBLogin( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBLoginFinishHandler handler = nil;
        ZBLSLoginItemObject *obj = [[ZBLSLoginItemObject alloc] init];
        obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
        obj.token = [NSString stringWithUTF8String:item.token.c_str()];
        obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
        obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
        
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestZBLoginCallbackImp gRequestZBLoginCallbackImp;

- (NSInteger)anchorLogin:(NSString *_Nonnull)anchorId
                password:(NSString *_Nonnull)password
                    code:(NSString *_Nonnull)code
                deviceid:(NSString * _Nonnull)deviceid
                   model:(NSString * _Nonnull)model
            manufacturer:(NSString * _Nonnull)manufacturer
           finishHandler:(ZBLoginFinishHandler _Nullable)finishHandler {
    
    string strAnchorId = "";
    if (nil != anchorId) {
        strAnchorId = [anchorId UTF8String];
    }
    
    string strPassword = "";
    if (nil != password) {
        strPassword = [password UTF8String];
    }
    
    string strCode = "";
    if (nil != code) {
        strCode = [code UTF8String];
    }
    
    string strDeviceid = "";
    if (nil != deviceid) {
        strDeviceid = [deviceid UTF8String];
    }
    
    string strModel = "";
    if (nil != model) {
        strModel = [model UTF8String];
    }
    
    string strManufacturer = "";
    if (nil != manufacturer) {
        strManufacturer = [manufacturer UTF8String];
    }
    
    NSInteger request = (NSInteger)mHttpRequestController.ZBLogin(&mHttpRequestManager, strAnchorId, strPassword, strCode, strDeviceid, strModel, strManufacturer, &gRequestZBLoginCallbackImp);
    
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBUpdateTokenIdCallbackImp : public IRequestZBUpdateTokenIdCallback {
public:
    RequestZBUpdateTokenIdCallbackImp(){};
    ~RequestZBUpdateTokenIdCallbackImp(){};
    
    void OnZBUpdateTokenId(ZBHttpUpdateTokenIdTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSAnchorRequestManager::OnZBUpdateTokenId( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBUpdateTokenIdFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestZBUpdateTokenIdCallbackImp gRequestZBUpdateTokenIdCallbackImp;

- (NSInteger)anchorUpdateTokenId:(NSString * _Nonnull)tokenId
                   finishHandler:(ZBUpdateTokenIdFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ZBUpdateTokenId(&mHttpRequestManager, [tokenId UTF8String], &gRequestZBUpdateTokenIdCallbackImp);
    
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBGetVerificationCodeCallbackImp : public IRequestZBGetVerificationCodeCallback {
public:
    RequestZBGetVerificationCodeCallbackImp(){};
    ~RequestZBGetVerificationCodeCallbackImp(){};
    
    void OnZBGetVerificationCode(ZBHttpGetVerificationCodeTask* task, bool success, int errnum, const string& errmsg, const char* data, int len) {
        NSLog(@"LSAnchorRequestManager::OnZBGetVerificationCode( task : %p, success : %s, errnum : %d, errmsg : %s len :%d ", task, success ? "true" : "false", errnum, errmsg.c_str(), len);
        
        ZBGetVerificationCodeFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], data, len);
        }
    }
};
RequestZBGetVerificationCodeCallbackImp gRequestZBGetVerificationCodeCallbackImp;
- (NSInteger)anchorGetVerificationCode:(ZBGetVerificationCodeFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ZBGetVerificationCode(&mHttpRequestManager, &gRequestZBGetVerificationCodeCallbackImp);
    
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

#pragma mark - 直播间模块
class RequestZBLiveFansListCallbackImp : public IRequestZBLiveFansListCallback {
public:
    RequestZBLiveFansListCallbackImp(){};
    ~RequestZBLiveFansListCallbackImp(){};
    void OnZBLiveFansList(ZBHttpLiveFansListTask* task, bool success, int errnum, const string& errmsg, const ZBHttpLiveFansList& listItem) {
        NSLog(@"LSAnchorRequestManager::OnZBLiveFansList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (ZBHttpLiveFansList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            ZBViewerFansItemObject *item = [[ZBViewerFansItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.mountId = [NSString stringWithUTF8String:(*iter).mountId.c_str()];
            item.mountName = [NSString stringWithUTF8String:(*iter).mountName.c_str()];
            item.mountUrl = [NSString stringWithUTF8String:(*iter).mountUrl.c_str()];
            item.level = (*iter).level;
            item.isHasTicket = (*iter).isHasTicket;
            [array addObject:item];
            NSLog(@"LSAnchorRequestManager::OnZBLiveFansList( task : %p, userId : %@, nickName : %@, photoUrl : %@ )", task, item.userId, item.nickName, item.photoUrl);
        }
        ZBLiveFansListFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestZBLiveFansListCallbackImp gRequestZBLiveFansListCallbackImp;

- (NSInteger)anchorLiveFansList:(NSString * _Nonnull)roomId
                          start:(int)start
                           step:(int)step
                  finishHandler:(ZBLiveFansListFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ZBLiveFansList(&mHttpRequestManager, strRoomId, start, step, &gRequestZBLiveFansListCallbackImp);
    
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBGetNewFansBaseInfoCallbackImp : public IRequestZBGetNewFansBaseInfoCallback {
public:
    RequestZBGetNewFansBaseInfoCallbackImp(){};
    ~RequestZBGetNewFansBaseInfoCallbackImp(){};
    void OnZBGetNewFansBaseInfo(ZBHttpGetNewFansBaseInfoTask* task, bool success, int errnum, const string& errmsg, const ZBHttpLiveFansInfoItem& item) {
        NSLog(@"LSAnchorRequestManager::OnZBGetNewFansBaseInfo( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBGetNewFansBaseInfoItemObject *obj = [[ZBGetNewFansBaseInfoItemObject alloc] init];
        obj.userId = [NSString stringWithUTF8String:item.userId.c_str()];
        obj.nickName = [NSString stringWithUTF8String:item.nickName.c_str()];
        obj.photoUrl = [NSString stringWithUTF8String:item.photoUrl.c_str()];
        obj.riderId = [NSString stringWithUTF8String:item.riderId.c_str()];
        obj.riderName = [NSString stringWithUTF8String:item.riderName.c_str()];
        obj.riderUrl = [NSString stringWithUTF8String:item.riderUrl.c_str()];
        obj.level = item.level;
        
        ZBGetNewFansBaseInfoFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestZBGetNewFansBaseInfoCallbackImp gRequestZBGetNewFansBaseInfoCallbackImp;

- (NSInteger)anchorGetNewFansBaseInfo:(NSString * _Nonnull)userId
                        finishHandler:(ZBGetNewFansBaseInfoFinishHandler _Nullable)finishHandler {
    string strUserId = "";
    if (nil != userId) {
        strUserId = [userId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ZBGetNewFansBaseInfo(&mHttpRequestManager, strUserId, &gRequestZBGetNewFansBaseInfoCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBGetAllGiftListCallbackImp : public IRequestZBGetAllGiftListCallback {
public:
    RequestZBGetAllGiftListCallbackImp(){};
    ~RequestZBGetAllGiftListCallbackImp(){};
    void OnZBGetAllGiftList(ZBHttpGetAllGiftListTask* task, bool success, int errnum, const string& errmsg, const ZBGiftItemList& itemList) {
        NSLog(@"LSAnchorRequestManager::OnZBGetAllGiftList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (ZBGiftItemList::const_iterator iter = itemList.begin(); iter != itemList.end(); iter++) {
            ZBGiftInfoItemObject *gift = [[ZBGiftInfoItemObject alloc] init];
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
        ZBGetAllGiftListFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestZBGetAllGiftListCallbackImp gRequestZBGetAllGiftListCallbackImp;

- (NSInteger)anchorGetAllGiftList:(ZBGetAllGiftListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ZBGetAllGiftList(&mHttpRequestManager, &gRequestZBGetAllGiftListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBGiftListCallbackImp : public IRequestZBGiftListCallback {
public:
    RequestZBGiftListCallbackImp(){};
    ~RequestZBGiftListCallbackImp(){};
    void OnZBGiftList(ZBHttpGiftListTask* task, bool success, int errnum, const string& errmsg, const ZBHttpGiftLimitNumItemList& itemList) {
        NSLog(@"LSAnchorRequestManager::OnZBGiftList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (ZBHttpGiftLimitNumItemList::const_iterator iter = itemList.begin(); iter != itemList.end(); iter++) {
            ZBGiftLimitNumItemObject *gift = [[ZBGiftLimitNumItemObject alloc] init];
            gift.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            gift.giftNum = (*iter).giftNum;
            [array addObject:gift];
        }
        ZBGiftListFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestZBGiftListCallbackImp gRequestZBGiftListCallbackImp;

- (NSInteger)anchorGiftList:(NSString * _Nonnull)roomId
              finishHandler:(ZBGiftListFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ZBGiftList(&mHttpRequestManager, strRoomId, &gRequestZBGiftListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBGetGiftDetailCallbackImp : public IRequestZBGetGiftDetailCallback {
public:
    RequestZBGetGiftDetailCallbackImp(){};
    ~RequestZBGetGiftDetailCallbackImp(){};
    void OnZBGetGiftDetail(ZBHttpGetGiftDetailTask* task, bool success, int errnum, const string& errmsg, const ZBHttpGiftInfoItem& item) {
        NSLog(@"LSAnchorRequestManager::OnZBGetGiftDetail( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBGiftInfoItemObject *gift = [[ZBGiftInfoItemObject alloc] init];
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
        
        ZBGetGiftDetailFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], gift);
        }
    }
};
RequestZBGetGiftDetailCallbackImp gRequestZBGetGiftDetailCallbackImp;
- (NSInteger)anchorGetGiftDetail:(NSString *_Nonnull)giftId
                   finishHandler:(ZBGetGiftDetailFinishHandler _Nullable)finishHandler {
    string strGiftId = "";
    if (nil != giftId) {
        strGiftId = [giftId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ZBGetGiftDetail(&mHttpRequestManager, strGiftId, &gRequestZBGetGiftDetailCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBGetEmoticonListCallbackImp : public IRequestZBGetEmoticonListCallback {
public:
    RequestZBGetEmoticonListCallbackImp(){};
    ~RequestZBGetEmoticonListCallbackImp(){};
    void OnZBGetEmoticonList(ZBHttpGetEmoticonListTask* task, bool success, int errnum, const string& errmsg, const ZBEmoticonItemList& listItem) {
        NSLog(@"LSAnchorRequestManager::OnZBGetEmoticonList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (ZBEmoticonItemList::const_iterator iter = listItem.begin(); iter != listItem.end(); iter++) {
            ZBEmoticonItemObject *item = [[ZBEmoticonItemObject alloc] init];
            item.type = (*iter).type;
            item.name = [NSString stringWithUTF8String:(*iter).name.c_str()];
            item.errMsg = [NSString stringWithUTF8String:(*iter).errMsg.c_str()];
            item.emoUrl = [NSString stringWithUTF8String:(*iter).emoUrl.c_str()];
            NSMutableArray *arrayEmo = [NSMutableArray array];
            for (ZBEmoticonInfoItemList::const_iterator iterEmo = (*iter).emoList.begin(); iterEmo != (*iter).emoList.end(); iterEmo++) {
                ZBEmoticonInfoItemObject *Emo = [[ZBEmoticonInfoItemObject alloc] init];
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
        
        ZBGetEmoticonListFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};
RequestZBGetEmoticonListCallbackImp gRequestZBGetEmoticonListCallbackImp;
- (NSInteger)anchorGetEmoticonList:(ZBGetEmoticonListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ZBGetEmoticonList(&mHttpRequestManager, &gRequestZBGetEmoticonListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBDealTalentRequestCallbackImp : public IRequestZBDealTalentRequestCallback {
public:
    RequestZBDealTalentRequestCallbackImp(){};
    ~RequestZBDealTalentRequestCallbackImp(){};
    void OnZBDealTalentRequest(ZBHttpDealTalentRequestTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSAnchorRequestManager::ZBDealTalentRequest( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBDealTalentRequestFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestZBDealTalentRequestCallbackImp gRequestZBDealTalentRequestCallbackImp;
- (NSInteger)anchorDealTalentRequest:(NSString * _Nonnull)talentInviteId
                              status:(ZBTalentReplyType)status
                       finishHandler:(ZBDealTalentRequestFinishHandler _Nullable)finishHandler {
    string strTalentInviteId = "";
    if (nil != talentInviteId) {
        strTalentInviteId = [talentInviteId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ZBDealTalentRequest(&mHttpRequestManager, strTalentInviteId, status, &gRequestZBDealTalentRequestCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBSetAutoPushCallbackImp : public IRequestZBSetAutoPushCallback {
public:
    RequestZBSetAutoPushCallbackImp(){};
    ~RequestZBSetAutoPushCallbackImp(){};
    void OnZBSetAutoPush(ZBHttpSetAutoPushTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSAnchorRequestManager::OnZBSetAutoPush( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBSetAutoPushFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestZBSetAutoPushCallbackImp gRequestZBSetAutoPushCallbackImp;
/**
 *  3.8.设置主播公开直播间自动邀请状态接口
 *
 *  @param finishHandler    接口回调
 *  @param status           处理结果（SETPUSHTYPE_CLOSE：关闭，SETPUSHTYPE_START：启动）
 *  @return 成功请求Id
 */
- (NSInteger)anchorSetAutoPush:(ZBSetPushType)status
                 finishHandler:(ZBSetAutoPushFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ZBSetAutoPush(&mHttpRequestManager, status, &gRequestZBSetAutoPushCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

#pragma mark - 预约私密

class RequestZBManHandleBookingListCallbackImp : public IRequestZBManHandleBookingListCallback {
public:
    RequestZBManHandleBookingListCallbackImp(){};
    ~RequestZBManHandleBookingListCallbackImp(){};
    void OnZBManHandleBookingList(ZBHttpManHandleBookingListTask* task, bool success, int errnum, const string& errmsg, const ZBHttpBookingInviteListItem& BookingListItem) {
        NSLog(@"LSAnchorRequestManager::OnZBManHandleBookingList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBBookingPrivateInviteListObject *item = [[ZBBookingPrivateInviteListObject alloc] init];
        item.total = BookingListItem.total;
        item.noReadCount = BookingListItem.noReadCount;
        NSMutableArray *array = [NSMutableArray array];
        for (ZBBookingPrivateInviteItemList::const_iterator iter = BookingListItem.list.begin(); iter != BookingListItem.list.end(); iter++) {
            ZBBookingPrivateInviteItemObject *obj = [[ZBBookingPrivateInviteItemObject alloc] init];
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
        
        ZBManHandleBookingListFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], item);
        }
    }
};
RequestZBManHandleBookingListCallbackImp gRequestZBManHandleBookingListCallbackImp;
- (NSInteger)anchorManHandleBookingList:(ZBBookingListType)type
                                  start:(int)start
                                   step:(int)step
                          finishHandler:(ZBManHandleBookingListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ZBManHandleBookingList(&mHttpRequestManager, type, start, step, &gRequestZBManHandleBookingListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBAcceptScheduledInviteCallbackImp : public IRequestZBAcceptScheduledInviteCallback {
public:
    RequestZBAcceptScheduledInviteCallbackImp(){};
    ~RequestZBAcceptScheduledInviteCallbackImp(){};
    void OnZBAcceptScheduledInvite(ZBHttpAcceptScheduledInviteTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSAnchorRequestManager::OnZBAcceptScheduledInvite( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBAcceptScheduledInviteFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestZBAcceptScheduledInviteCallbackImp gRequestZBAcceptScheduledInviteCallbackImp;
- (NSInteger)anchorAcceptScheduledInvite:(NSString *_Nonnull)inviteId
                           finishHandler:(ZBAcceptScheduledInviteFinishHandler _Nullable)finishHandler {
    string strTalentInviteId = "";
    if (nil != inviteId) {
        strTalentInviteId = [inviteId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ZBAcceptScheduledInvite(&mHttpRequestManager, strTalentInviteId, &gRequestZBAcceptScheduledInviteCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBRejectScheduledInviteCallbackImp : public IRequestZBRejectScheduledInviteCallback {
public:
    RequestZBRejectScheduledInviteCallbackImp(){};
    ~RequestZBRejectScheduledInviteCallbackImp(){};
    void OnZBRejectScheduledInvite(ZBHttpRejectScheduledInviteTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSAnchorRequestManager::OnZBRejectScheduledInvite( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBRejectScheduledInviteFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestZBRejectScheduledInviteCallbackImp gRequestZBRejectScheduledInviteCallbackImp;
- (NSInteger)anchorRejectScheduledInvite:(NSString *_Nonnull)invitationId
                           finishHandler:(ZBRejectScheduledInviteFinishHandler _Nullable)finishHandler {
    string strTalentInviteId = "";
    if (nil != invitationId) {
        strTalentInviteId = [invitationId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ZBRejectScheduledInvite(&mHttpRequestManager, strTalentInviteId, &gRequestZBRejectScheduledInviteCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBGetScheduleListNoReadNumCallbackImp : public IRequestZBGetScheduleListNoReadNumCallback {
public:
    RequestZBGetScheduleListNoReadNumCallbackImp(){};
    ~RequestZBGetScheduleListNoReadNumCallbackImp(){};
    void OnZBGetScheduleListNoReadNum(ZBHttpManBookingUnreadUnhandleNumTask* task, bool success, int errnum, const string& errmsg, const ZBHttpBookingUnreadUnhandleNumItem& item) {
        NSLog(@"LSAnchorRequestManager::OnZBGetScheduleListNoReadNum( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBBookingUnreadUnhandleNumItemObject *obj = [[ZBBookingUnreadUnhandleNumItemObject alloc] init];
        obj.totalNoReadNum = item.totalNoReadNum;
        obj.pendingNoReadNum = item.pendingNoReadNum;
        obj.scheduledNoReadNum = item.scheduledNoReadNum;
        obj.historyNoReadNum = item.historyNoReadNum;
        
        ZBGetScheduleListNoReadNumFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestZBGetScheduleListNoReadNumCallbackImp gRequestZBGetScheduleListNoReadNumCallbackImp;
- (NSInteger)anchorGetScheduleListNoReadNum:(ZBGetScheduleListNoReadNumFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ZBGetScheduleListNoReadNum(&mHttpRequestManager, &gRequestZBGetScheduleListNoReadNumCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBGetScheduledAcceptNumCallbackImp : public IRequestZBGetScheduledAcceptNumCallback {
public:
    RequestZBGetScheduledAcceptNumCallbackImp(){};
    ~RequestZBGetScheduledAcceptNumCallbackImp(){};
    void OnZBGetScheduledAcceptNum(ZBHttpGetScheduledAcceptNumTask* task, bool success, int errnum, const string& errmsg, const int scheduledNum) {
        NSLog(@"LSAnchorRequestManager::OnZBGetScheduledAcceptNum( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBGetScheduledAcceptNumFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], scheduledNum);
        }
    }
};
RequestZBGetScheduledAcceptNumCallbackImp gRequestZBGetScheduledAcceptNumCallbackImp;
- (NSInteger)anchorGetScheduledAcceptNum:(ZBGetScheduledAcceptNumFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ZBGetScheduledAcceptNum(&mHttpRequestManager, &gRequestZBGetScheduledAcceptNumCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}


class RequestZBAcceptInstanceInviteCallbackImp : public IRequestZBAcceptInstanceInviteCallback {
public:
    RequestZBAcceptInstanceInviteCallbackImp(){};
    ~RequestZBAcceptInstanceInviteCallbackImp(){};
    void OnZBAcceptInstanceInvite(ZBHttpAcceptInstanceInviteTask* task, bool success, int errnum, const string& errmsg, const string& roomId, ZBHttpRoomType roomType){
        NSLog(@"LSAnchorRequestManager::OnZBAcceptInstanceInvite( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        ZBAcceptInstanceInviteFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:roomId.c_str()], roomType);
        }
    }
};
RequestZBAcceptInstanceInviteCallbackImp gRequestZBAcceptInstanceInviteCallbackImp;
- (NSInteger)anchorAcceptInstanceInvite:(NSString *_Nullable)inviteId
                          finishHandler:(ZBAcceptInstanceInviteFinishHandler _Nullable)finishHandler {
    string strInviteId = "";
    if (nil != inviteId) {
        strInviteId = [inviteId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ZBAcceptInstanceInvite(&mHttpRequestManager, strInviteId, &gRequestZBAcceptInstanceInviteCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBRejectInstanceInviteCallbackImp : public IRequestZBRejectInstanceInviteCallback {
public:
    RequestZBRejectInstanceInviteCallbackImp(){};
    ~RequestZBRejectInstanceInviteCallbackImp(){};
    void OnZBRejectInstanceInvite(ZBHttpRejectInstanceInviteTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSAnchorRequestManager::OnZBRejectInstanceInvite( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        ZBRejectInstanceInviteFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestZBRejectInstanceInviteCallbackImp gRequestZBRejectInstanceInviteCallbackImp;
- (NSInteger)anchorRejectInstanceInvite:(NSString *_Nullable)inviteId
                           rejectReason:(NSString *_Nullable)rejectReason
                          finishHandler:(ZBRejectInstanceInviteFinishHandler _Nullable)finishHandler {
    string strInviteId = "";
    if (nil != inviteId) {
        strInviteId = [inviteId UTF8String];
    }
    string strRejectReason = "";
    if (nil != rejectReason) {
        strRejectReason = [rejectReason UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.ZBRejectInstanceInvite(&mHttpRequestManager, strInviteId, strRejectReason, &gRequestZBRejectInstanceInviteCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBCancelInstantInviteUserCallbackImp : public IRequestZBCancelInstantInviteUserCallback {
public:
    RequestZBCancelInstantInviteUserCallbackImp(){};
    ~RequestZBCancelInstantInviteUserCallbackImp(){};
    void OnZBCancelInstantInviteUser(ZBHttpCancelInstantInviteUserTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSAnchorRequestManager::OnZBCancelInstantInviteUser( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        ZBCancelInstantInviteFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestZBCancelInstantInviteUserCallbackImp gRequestZBCancelInstantInviteUserCallbackImp;
- (NSInteger)anchorCancelInstantInvite:(NSString* _Nullable)inviteId
                         finishHandler:(ZBCancelInstantInviteFinishHandler _Nullable)finishHandler {
    string strInviteId = "";
    if (nil != inviteId) {
        strInviteId = [inviteId UTF8String];
    }
    
    NSInteger request = (NSInteger)mHttpRequestController.ZBCancelInstantInviteUser(&mHttpRequestManager, strInviteId, &gRequestZBCancelInstantInviteUserCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBSetRoomCountDownCallbackImp : public IRequestZBSetRoomCountDownCallback {
public:
    RequestZBSetRoomCountDownCallbackImp(){};
    ~RequestZBSetRoomCountDownCallbackImp(){};
    void OnZBSetRoomCountDown(ZBHttpSetRoomCountDownTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSAnchorRequestManager::OnZBSetRoomCountDown( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        ZBCancelInstantInviteFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestZBSetRoomCountDownCallbackImp gRequestZBSetRoomCountDownCallbackImp;
- (NSInteger)anchorSetRoomCountDowne:(NSString* _Nullable)roomId
                       finishHandler:(ZBSetRoomCountDownFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    
    NSInteger request = (NSInteger)mHttpRequestController.ZBSetRoomCountDown(&mHttpRequestManager, strRoomId, &gRequestZBSetRoomCountDownCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

#pragma mark - 其它

class RequestZBGetConfigCallbackImp : public IRequestZBGetConfigCallback {
public:
    RequestZBGetConfigCallbackImp(){};
    ~RequestZBGetConfigCallbackImp(){};
    void OnZBGetConfig(ZBHttpGetConfigTask* task, bool success, int errnum, const string& errmsg, const ZBHttpConfigItem& configItem) {
        NSLog(@"LSAnchorRequestManager::OnZBGetConfig( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBConfigItemObject *obj = [[ZBConfigItemObject alloc] init];
        obj.imSvrUrl = [NSString stringWithUTF8String:configItem.imSvrUrl.c_str()];
        obj.httpSvrUrl = [NSString stringWithUTF8String:configItem.httpSvrUrl.c_str()];
        obj.mePageUrl = [NSString stringWithUTF8String:configItem.mePageUrl.c_str()];
        obj.manPageUrl = [NSString stringWithUTF8String:configItem.manPageUrl.c_str()];
        obj.showDetailPage = [NSString stringWithUTF8String:configItem.showDetailPage.c_str()];
        obj.minAavilableVer = configItem.minAavilableVer;
        obj.minAvailableMsg = [NSString stringWithUTF8String:configItem.minAvailableMsg.c_str()];
        obj.newestVer = configItem.newestVer;
        obj.newestMsg = [NSString stringWithUTF8String:configItem.newestMsg.c_str()];
        obj.downloadAppUrl = [NSString stringWithUTF8String:configItem.downloadAppUrl.c_str()];
        NSMutableArray *array = [NSMutableArray array];
        for (ZBSvrList::const_iterator iter = configItem.svrList.begin(); iter != configItem.svrList.end(); iter++) {
            ZBLSSvrItemObject *svrItem = [[ZBLSSvrItemObject alloc] init];
            svrItem.svrId = [NSString stringWithUTF8String:(*iter).svrId.c_str()];
            svrItem.tUrl = [NSString stringWithUTF8String:(*iter).tUrl.c_str()];
            [array addObject:svrItem];
        }
        obj.svrList = array;
        
        ZBGetConfigFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestZBGetConfigCallbackImp gRequestZBGetConfigCallbackImp;
- (NSInteger)anchorGetConfig:(ZBGetConfigFinishHandler _Nullable)finishHandler {
    
    NSInteger request = (NSInteger)mHttpRequestController.ZBGetConfig(&mConfigHttpRequestManager, &gRequestZBGetConfigCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBGetTodayCreditCallbackImp : public IRequestZBGetTodayCreditCallback {
public:
    RequestZBGetTodayCreditCallbackImp(){};
    ~RequestZBGetTodayCreditCallbackImp(){};
    void OnZBGetTodayCredit(ZBHttpGetTodayCreditTask* task, bool success, int errnum, const string& errmsg, const ZBHttpTodayCreditItem& configItem) {
        NSLog(@"LSAnchorRequestManager::OnZBGetTodayCredit( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        ZBTodayCreditItemObject *obj = [[ZBTodayCreditItemObject alloc] init];
        obj.monthCredit = configItem.monthCredit;
        obj.monthCompleted = configItem.monthCompleted;
        obj.monthTarget = configItem.monthTarget;
        obj.monthProgress = configItem.monthProgress;
        
        ZBGetTodayCreditFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};
RequestZBGetTodayCreditCallbackImp gRequestZBGetTodayCreditCallbackImp;
- (NSInteger)anchorGetTodayCredit:(ZBGetTodayCreditFinishHandler _Nullable)finishHandler {
    
    NSInteger request = (NSInteger)mHttpRequestController.ZBGetTodayCredit(&mHttpRequestManager, &gRequestZBGetTodayCreditCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBServerSpeedCallbackImp : public IRequestZBServerSpeedCallback {
public:
    RequestZBServerSpeedCallbackImp(){};
    ~RequestZBServerSpeedCallbackImp(){};
    void OnZBServerSpeed(ZBHttpServerSpeedTask *task, bool success, int errnum, const string &errmsg) {
        NSLog(@"LSAnchorRequestManager::OnZBServerSpeed( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBServerSpeedFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};
RequestZBServerSpeedCallbackImp gRequestZBServerSpeedCallbackImp;
- (NSInteger)anchorServerSpeed:(NSString *_Nonnull)sid
                           res:(int)res
                 finishHandler:(ZBServerSpeedFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.ZBServerSpeed(&mHttpRequestManager, [sid UTF8String], res, &gRequestZBServerSpeedCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestZBCrashFileCallbackImp : public IRequestZBCrashFileCallback {
public:
    RequestZBCrashFileCallbackImp(){};
    ~RequestZBCrashFileCallbackImp(){};
    void OnZBCrashFile(ZBHttpCrashFileTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSAnchorRequestManager::OnZBCrashFile( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        ZBUploadCrashFileFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};

RequestZBCrashFileCallbackImp gRequestZBCrashFileCallbackImp;
- (NSInteger)anchorUploadCrashFile:(NSString * _Nonnull)deviceId
                        file:(NSString * _Nonnull)file
                tmpDirectory:(NSString * _Nonnull)tmpDirectory
               finishHandler:(ZBUploadCrashFileFinishHandler _Nullable)finishHandler; {
    //file = @"/Users/alex/Documents/crash";
    // create zip
    KZip zip;
    NSString *comment = @"";
    //    NSArray *zipPassword = @[@0x51, @0x70, @0x69, @0x64, @0x5F, @0x44, @0x61, @0x74, @0x69, @0x6E, @0x67, @0x00];
    //压缩的密码
    const char password[] = {
        0x51, 0x70, 0x69, 0x64, 0x5F, 0x44, 0x61, 0x74, 0x69, 0x6E, 0x67, 0x00
    };
    char pZipFileName[1024] = {'\0'};

    //压缩文件名称
    NSDate *curDate = [NSDate date];

    snprintf(pZipFileName, sizeof(pZipFileName), "%s/crash-%s.zip", \
             [tmpDirectory  UTF8String], [[curDate toStringCrashZipDate] UTF8String]);

//    snprintf(pZipFileName, sizeof(pZipFileName), "%s/crash-.zip", \
//             [tmpDirectory  UTF8String]);

    //创建压缩文件
    BOOL bFlag = zip.CreateZipFromDir([file UTF8String], pZipFileName,password,[comment UTF8String]);
    NSInteger request = HTTPREQUEST_INVALIDREQUESTID;
    if (bFlag) {
        string deviceIdStr = (deviceId == nil ? "" : [deviceId UTF8String]);
        request = (NSInteger)mHttpRequestController.ZBCrashFile(&mHttpRequestManager, deviceIdStr, pZipFileName, &gRequestZBCrashFileCallbackImp);
        if (request != HTTPREQUEST_INVALIDREQUESTID) {
            @synchronized(self.delegateDictionary) {
                [self.delegateDictionary setObject:finishHandler forKey:@((NSInteger)request)];
            }
        }
    }

    return request;
    
}

#pragma mark - 多人互动直播间

class RequestAnchorGetCanRecommendFriendListCallbackImp : public IRequestAnchorGetCanRecommendFriendListCallback {
public:
    RequestAnchorGetCanRecommendFriendListCallbackImp(){};
    ~RequestAnchorGetCanRecommendFriendListCallbackImp(){};
    void OnAnchorGetCanRecommendFriendList(HttpAnchorGetCanRecommendFriendListTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorItemList& anchorList) {
        NSLog(@"LSAnchorRequestManager::OnAnchorGetCanRecommendFriendList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HttpAnchorItemList::const_iterator iter = anchorList.begin(); iter != anchorList.end(); iter++) {
            AnchorItemObject *item = [[AnchorItemObject alloc] init];
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            item.age = (*iter).age;
            item.country = [NSString stringWithUTF8String:(*iter).country.c_str()];
            [array addObject:item];
            NSLog(@"LSAnchorRequestManager::OnAnchorGetCanRecommendFriendList( task : %p, anchorId : %@, nickName : %@, photoUrl : %@ age: %d country : %@)", task, item.anchorId, item.nickName, item.photoUrl, item.age, item.country);
        }
        
        AnchorGetCanRecommendFriendListFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};

RequestAnchorGetCanRecommendFriendListCallbackImp gRequestAnchorGetCanRecommendFriendListCallbackImp;
- (NSInteger)anchorGetCanRecommendFriendList:(int)start
                                        step:(int)step
                               finishHandler:(AnchorGetCanRecommendFriendListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.AnchorGetCanRecommendFriendList(&mHttpRequestManager, start, step, &gRequestAnchorGetCanRecommendFriendListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAnchorRecommendFriendJoinHangoutCallbackImp : public IRequestAnchorRecommendFriendJoinHangoutCallback {
public:
    RequestAnchorRecommendFriendJoinHangoutCallbackImp(){};
    ~RequestAnchorRecommendFriendJoinHangoutCallbackImp(){};
    void OnAnchorRecommendFriend(HttpAnchorRecommendFriendJoinHangoutTask* task, bool success, int errnum, const string& errmsg, const string& anchorId) {
        NSLog(@"LSAnchorRequestManager::OnAnchorRecommendFriend( task : %p, success : %s, errnum : %d, errmsg : %s, anchorId : %s )", task, success ? "true" : "false", errnum, errmsg.c_str(), anchorId.c_str());
        
        AnchorRecommendFriendFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:anchorId.c_str()]);
        }
    }
};
RequestAnchorRecommendFriendJoinHangoutCallbackImp gRequestAnchorRecommendFriendJoinHangoutCallbackImp;
- (NSInteger)anchorRecommendFriend:(NSString * _Nonnull)friendId
                            roomId:(NSString * _Nonnull)roomId
                     finishHandler:(AnchorRecommendFriendFinishHandler _Nullable)finishHandler {
    string strFriendId = "";
    if (nil != friendId) {
        strFriendId = [friendId UTF8String];
    }
    
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    
    NSInteger request = (NSInteger)mHttpRequestController.AnchorRecommendFriend(&mHttpRequestManager, strFriendId, strRoomId, &gRequestAnchorRecommendFriendJoinHangoutCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAnchorDealInvitationHangoutCallbackCallbackImp : public IRequestAnchorDealInvitationHangoutCallback {
public:
    RequestAnchorDealInvitationHangoutCallbackCallbackImp(){};
    ~RequestAnchorDealInvitationHangoutCallbackCallbackImp(){};
    void OnAnchorDealInvitationHangout(HttpAnchorDealInvitationHangoutTask* task, bool success, int errnum, const string& errmsg, const string& roomId) {
        NSLog(@"LSAnchorRequestManager::OnAnchorDealInvitationHangout( task : %p, success : %s, errnum : %d, errmsg : %s, roomId : %s )", task, success ? "true" : "false", errnum, errmsg.c_str(), roomId.c_str());
        
        AnchorDealInvitationHangoutFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:roomId.c_str()]);
        }
    }
};
RequestAnchorDealInvitationHangoutCallbackCallbackImp gRequestAnchorDealInvitationHangoutCallbackCallbackImp;

- (NSInteger)anchorDealInvitationHangout:(NSString * _Nonnull)inviteId
                                    type:(AnchorMultiplayerReplyType)type
                           finishHandler:(AnchorDealInvitationHangoutFinishHandler _Nullable)finishHandler {
    string strInviteId = "";
    if (nil != inviteId) {
        strInviteId = [inviteId UTF8String];
    }
    
    NSInteger request = (NSInteger)mHttpRequestController.AnchorDealInvitationHangout(&mHttpRequestManager, strInviteId, type, &gRequestAnchorDealInvitationHangoutCallbackCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAnchorGetOngoingHangoutListCallbackImp : public IRequestAnchorGetOngoingHangoutListCallback {
public:
    RequestAnchorGetOngoingHangoutListCallbackImp(){};
    ~RequestAnchorGetOngoingHangoutListCallbackImp(){};
    void OnAnchorGetOngoingHangoutList(HttpAnchorGetOngoingHangoutListTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorHangoutItemList& hangoutList) {
        NSLog(@"LSAnchorRequestManager::OnAnchorGetOngoingHangoutList( task : %p, success : %s, errnum : %d, errmsg : %s )", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray *array = [NSMutableArray array];
        for (HttpAnchorHangoutItemList::const_iterator iter = hangoutList.begin(); iter != hangoutList.end(); iter++) {
            AnchorHangoutItemObject *item = [[AnchorHangoutItemObject alloc] init];
            item.userId = [NSString stringWithUTF8String:(*iter).userId.c_str()];
            item.nickName = [NSString stringWithUTF8String:(*iter).nickName.c_str()];
            item.photoUrl = [NSString stringWithUTF8String:(*iter).photoUrl.c_str()];
            NSMutableArray *anchorArray = [NSMutableArray array];
            for(HttpAnchorBaseInfoItemList::const_iterator anchorIter = (*iter).anchorList.begin(); anchorIter != (*iter).anchorList.end(); anchorIter++) {
                AnchorBaseInfoItemObject *anchorItem = [[AnchorBaseInfoItemObject alloc] init];
                anchorItem.anchorId = [NSString stringWithUTF8String:(*anchorIter).anchorId.c_str()];
                anchorItem.nickName = [NSString stringWithUTF8String:(*anchorIter).nickName.c_str()];
                anchorItem.photoUrl = [NSString stringWithUTF8String:(*anchorIter).photoUrl.c_str()];
                NSLog(@"LSAnchorRequestManager::OnAnchorGetOngoingHangoutList( task : %p,AnchorBaseInfoItemObject is anchorId : %@, nickName : %@, photoUrl : %@)", task, anchorItem.anchorId, anchorItem.nickName, anchorItem.photoUrl);
                [anchorArray addObject:anchorItem];
            }
            item.anchorList = anchorArray;
            item.roomId = [NSString stringWithUTF8String:(*iter).roomId.c_str()];
            [array addObject:item];
            NSLog(@"LSAnchorRequestManager::OnAnchorGetOngoingHangoutList( task : %p, userId : %@, nickName : %@, photoUrl : %@ roomId : %@)", task, item.userId, item.nickName, item.photoUrl, item.roomId);
        }
        
        AnchorGetOngoingHangoutListFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};

RequestAnchorGetOngoingHangoutListCallbackImp gRequestAnchorGetOngoingHangoutListCallbackImp;
- (NSInteger)anchorGetOngoingHangoutList:(int)start
                                    step:(int)step
                           finishHandler:(AnchorGetOngoingHangoutListFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.AnchorGetOngoingHangoutList(&mHttpRequestManager, start, step, &gRequestAnchorGetOngoingHangoutListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAnchorSendKnockRequestCallbackImp : public IRequestAnchorSendKnockRequestCallback {
public:
    RequestAnchorSendKnockRequestCallbackImp(){};
    ~RequestAnchorSendKnockRequestCallbackImp(){};
    void OnAnchorSendKnockRequest(HttpAnchorSendKnockRequestTask* task, bool success, int errnum, const string& errmsg, const string& knockId, int expire) {
        NSLog(@"LSAnchorRequestManager::OnAnchorSendKnockRequest( task : %p, success : %s, errnum : %d, errmsg : %s knockId : %s expire : %d)", task, success ? "true" : "false", errnum, errmsg.c_str(), knockId.c_str(), expire);
        
        
        AnchorSendKnockRequestFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:knockId.c_str()], expire);
        }
    }
};

RequestAnchorSendKnockRequestCallbackImp gRequestAnchorSendKnockRequestCallbackImp;
- (NSInteger)anchorSendKnockRequest:(NSString * _Nonnull)roomId
                      finishHandler:(AnchorSendKnockRequestFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.AnchorSendKnockRequest(&mHttpRequestManager, strRoomId, &gRequestAnchorSendKnockRequestCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAnchorGetHangoutKnockStatusCallbackImp : public IRequestAnchorGetHangoutKnockStatusCallback {
public:
    RequestAnchorGetHangoutKnockStatusCallbackImp(){};
    ~RequestAnchorGetHangoutKnockStatusCallbackImp(){};
    void OnAnchorGetHangoutKnockStatus(HttpAnchorGetHangoutKnockStatusTask* task, bool success, int errnum, const string& errmsg, const string& roomId, AnchorMultiKnockType status, int expire) {
        NSLog(@"LSAnchorRequestManager::OnAnchorGetHangoutKnockStatus( task : %p, success : %s, errnum : %d, errmsg : %s roomId : %s status : %d expire : %d)", task, success ? "true" : "false", errnum, errmsg.c_str(), roomId.c_str(), status, expire);
        
        
        AnchorGetHangoutKnockStatusFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:roomId.c_str()], status, expire);
        }
    }
};

RequestAnchorGetHangoutKnockStatusCallbackImp gRequestAnchorGetHangoutKnockStatusCallbackImp;
- (NSInteger)anchorGetHangoutKnockStatus:(NSString * _Nonnull)knockId
                           finishHandler:(AnchorGetHangoutKnockStatusFinishHandler _Nullable)finishHandler {
    string strKnockId = "";
    if (nil != knockId) {
        strKnockId = [knockId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.AnchorGetHangoutKnockStatus(&mHttpRequestManager, strKnockId, &gRequestAnchorGetHangoutKnockStatusCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}


class RequestAnchorCancelHangoutKnockCallbackCallbackImp : public IRequestAnchorCancelHangoutKnockCallback {
public:
    RequestAnchorCancelHangoutKnockCallbackCallbackImp(){};
    ~RequestAnchorCancelHangoutKnockCallbackCallbackImp(){};
    void OnAnchorCancelHangoutKnock(HttpAnchorCancelHangoutKnockTask* task, bool success, int errnum, const string& errmsg) {
        NSLog(@"LSAnchorRequestManager::OnAnchorCancelHangoutKnock( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        
        AnchorCancelHangoutKnockFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()]);
        }
    }
};

RequestAnchorCancelHangoutKnockCallbackCallbackImp gRequestAnchorCancelHangoutKnockCallbackCallbackImp;
- (NSInteger)anchorCancelHangoutKnock:(NSString * _Nonnull)knockId
                        finishHandler:(AnchorCancelHangoutKnockFinishHandler _Nullable)finishHandler {
    string strKnockId = "";
    if (nil != knockId) {
        strKnockId = [knockId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.AnchorCancelHangoutKnock(&mHttpRequestManager, strKnockId, &gRequestAnchorCancelHangoutKnockCallbackCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAnchorHangoutGiftListCallbackImp : public IRequestAnchorHangoutGiftListCallback {
public:
    RequestAnchorHangoutGiftListCallbackImp(){};
    ~RequestAnchorHangoutGiftListCallbackImp(){};
    void OnAnchorHangoutGiftList(HttpAnchorHangoutGiftListTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorHangoutGiftListItem& hangoutGiftItem) {
        NSLog(@"LSAnchorRequestManager::OnAnchorHangoutGiftList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        AnchorHangoutGiftListObject *obj = [[AnchorHangoutGiftListObject alloc] init];
        NSMutableArray *buyArray = [NSMutableArray array];
        for (HttpAnchorGiftNumItemList::const_iterator iter = hangoutGiftItem.buyforList.begin(); iter != hangoutGiftItem.buyforList.end(); iter++) {
            ZBGiftLimitNumItemObject *gift = [[ZBGiftLimitNumItemObject alloc] init];
            gift.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            gift.giftNum = (*iter).giftNum;
            [buyArray addObject:gift];
        }
        obj.buyforList = buyArray;
        
        NSMutableArray *normalListArray = [NSMutableArray array];
        for (HttpAnchorGiftNumItemList::const_iterator iter = hangoutGiftItem.normalList.begin(); iter != hangoutGiftItem.normalList.end(); iter++) {
            ZBGiftLimitNumItemObject *gift = [[ZBGiftLimitNumItemObject alloc] init];
            gift.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            gift.giftNum = (*iter).giftNum;
            [normalListArray addObject:gift];
        }
        obj.normalList = normalListArray;
        
        NSMutableArray *celebrationListArray = [NSMutableArray array];
        for (HttpAnchorGiftNumItemList::const_iterator iter = hangoutGiftItem.celebrationList.begin(); iter != hangoutGiftItem.celebrationList.end(); iter++) {
            ZBGiftLimitNumItemObject *gift = [[ZBGiftLimitNumItemObject alloc] init];
            gift.giftId = [NSString stringWithUTF8String:(*iter).giftId.c_str()];
            gift.giftNum = (*iter).giftNum;
            [celebrationListArray addObject:gift];
        }
        obj.celebrationList = celebrationListArray;
        
        AnchorHangoutGiftListFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj);
        }
    }
};

RequestAnchorHangoutGiftListCallbackImp gRequestAnchorHangoutGiftListCallbackImp;
- (NSInteger)anchorHangoutGiftList:(NSString * _Nonnull)roomId
                     finishHandler:(AnchorHangoutGiftListFinishHandler _Nullable)finishHandler {
    string strRoomId = "";
    if (nil != roomId) {
        strRoomId = [roomId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.AnchorHangoutGiftList(&mHttpRequestManager, strRoomId, &gRequestAnchorHangoutGiftListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}


#pragma mark - 节目
class RequestAnchorGetProgramListCallbackImp : public IRequestAnchorGetProgramListCallback {
public:
    RequestAnchorGetProgramListCallbackImp(){};
    ~RequestAnchorGetProgramListCallbackImp(){};
    void OnAnchorGetProgramList(HttpAnchorGetProgramListTask* task, bool success, int errnum, const string& errmsg, const AnchorProgramInfoList& list) {
        NSLog(@"LSAnchorRequestManager::OnAnchorGetProgramList( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSMutableArray* array = [NSMutableArray array];
        for(AnchorProgramInfoList::const_iterator iter = list.begin(); iter != list.end(); iter++) {
            LSAnchorProgramItemObject* item = [[LSAnchorProgramItemObject alloc] init];
            item.showLiveId = [NSString stringWithUTF8String:(*iter).showLiveId.c_str()];
            item.anchorId = [NSString stringWithUTF8String:(*iter).anchorId.c_str()];
            item.showTitle = [NSString stringWithUTF8String:(*iter).showTitle.c_str()];
            item.showIntroduce = [NSString stringWithUTF8String:(*iter).showIntroduce.c_str()];
            item.cover = [NSString stringWithUTF8String:(*iter).cover.c_str()];
            item.approveTime = (*iter).approveTime;
            item.startTime = (*iter).startTime;
            item.duration = (*iter).duration;
            item.leftSecToStart = (*iter).leftSecToStart;
            item.leftSecToEnter = (*iter).leftSecToEnter;
            item.price = (*iter).price;
            item.status = (*iter).status;
            item.ticketNum = (*iter).ticketNum;
            item.followNum = (*iter).followNum;
            item.isTicketFull = (*iter).isTicketFull;
            [array addObject:item];
        }
        
        AnchorGetProgramListFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], array);
        }
    }
};

RequestAnchorGetProgramListCallbackImp gRequestAnchorGetProgramListCallbackImp;
- (NSInteger)anchorGetProgramList:(int)start
                             step:(int)step
                           status:(AnchorProgramListType)status
                    finishHandler:(AnchorGetProgramListFinishHandler _Nullable)finishHandler {
    
    NSInteger request = (NSInteger)mHttpRequestController.AnchorGetProgramList(&mHttpRequestManager, start, step, status, &gRequestAnchorGetProgramListCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAnchorGetNoReadNumProgramCallbackImp : public IRequestAnchorGetNoReadNumProgramCallback {
public:
    RequestAnchorGetNoReadNumProgramCallbackImp(){};
    ~RequestAnchorGetNoReadNumProgramCallbackImp(){};
    void OnAnchorGetNoReadNumProgram(HttpAnchorGetNoReadNumProgramTask* task, bool success, int errnum, const string& errmsg, int num) {
        NSLog(@"LSAnchorRequestManager::OnAnchorGetNoReadNumProgram( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        AnchorGetNoReadNumProgramFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], num);
        }
    }
};

RequestAnchorGetNoReadNumProgramCallbackImp gRequestAnchorGetNoReadNumProgramCallbackImp;
- (NSInteger)anchorGetNoReadNumProgram:(AnchorGetNoReadNumProgramFinishHandler _Nullable)finishHandler {
    NSInteger request = (NSInteger)mHttpRequestController.AnchorGetNoReadNumProgram(&mHttpRequestManager, &gRequestAnchorGetNoReadNumProgramCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAnchorGetShowRoomInfoCallbackImp : public IRequestAnchorGetShowRoomInfoCallback {
public:
    RequestAnchorGetShowRoomInfoCallbackImp(){};
    ~RequestAnchorGetShowRoomInfoCallbackImp(){};
    void OnAnchorGetShowRoomInfo(HttpAnchorGetShowRoomInfoTask* task, bool success, int errnum, const string& errmsg, HttpAnchorProgramInfoItem showInfo, const string& roomId) {
        NSLog(@"LSAnchorRequestManager::OnAnchorGetShowRoomInfo( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        LSAnchorProgramItemObject* obj = [[LSAnchorProgramItemObject alloc] init];
        obj.showLiveId = [NSString stringWithUTF8String:showInfo.showLiveId.c_str()];
        obj.anchorId = [NSString stringWithUTF8String:showInfo.anchorId.c_str()];
        obj.showTitle = [NSString stringWithUTF8String:showInfo.showTitle.c_str()];
        obj.showIntroduce = [NSString stringWithUTF8String:showInfo.showIntroduce.c_str()];
        obj.cover = [NSString stringWithUTF8String:showInfo.cover.c_str()];
        obj.approveTime = showInfo.approveTime;
        obj.startTime = showInfo.startTime;
        obj.duration = showInfo.duration;
        obj.leftSecToStart = showInfo.leftSecToStart;
        obj.leftSecToEnter = showInfo.leftSecToEnter;
        obj.price = showInfo.price;
        obj.status = showInfo.status;
        obj.ticketNum = showInfo.ticketNum;
        obj.followNum = showInfo.followNum;
        obj.isTicketFull = showInfo.isTicketFull;
        NSString* strRoomId = [NSString stringWithUTF8String:roomId.c_str()];
        
        AnchorGetShowRoomInfoFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], obj, strRoomId);
        }
    }
};

RequestAnchorGetShowRoomInfoCallbackImp gRequestAnchorGetShowRoomInfoCallbackImp;
- (NSInteger)anchorGetShowRoomInfo:(NSString* _Nonnull)liveShowId
                     finishHandler:(AnchorGetShowRoomInfoFinishHandler _Nullable)finishHandler {
    string strLiveShowId = "";
    if (nil != liveShowId) {
        strLiveShowId = [liveShowId UTF8String];
    }
    NSInteger request = (NSInteger)mHttpRequestController.AnchorGetShowRoomInfo(&mHttpRequestManager, strLiveShowId, &gRequestAnchorGetShowRoomInfoCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

class RequestAnchorCheckIsPlayProgramCallbackImp : public IRequestAnchorCheckIsPlayProgramCallback {
public:
    RequestAnchorCheckIsPlayProgramCallbackImp(){};
    ~RequestAnchorCheckIsPlayProgramCallbackImp(){};
    void OnAnchorCheckPublicRoomType(HttpAnchorCheckIsPlayProgramTask* task, bool success, int errnum, const string& errmsg, AnchorPublicRoomType liveShowType, const string& liveShowId) {
        NSLog(@"LSAnchorRequestManager::OnAnchorCheckPublicRoomType( task : %p, success : %s, errnum : %d, errmsg : %s)", task, success ? "true" : "false", errnum, errmsg.c_str());
        
        NSString* strLiveShowId = [NSString stringWithUTF8String:liveShowId.c_str()];
        
        AnchorCheckPublicRoomTypeFinishHandler handler = nil;
        LSAnchorRequestManager *manager = [LSAnchorRequestManager manager];
        @synchronized(manager.delegateDictionary) {
            handler = [manager.delegateDictionary objectForKey:@((NSInteger)task)];
            [manager.delegateDictionary removeObjectForKey:@((NSInteger)task)];
        }
        
        if (handler) {
            handler(success, [[LSAnchorRequestManager manager] intToHttpLccErrType:errnum], [NSString stringWithUTF8String:errmsg.c_str()], liveShowType, strLiveShowId);
        }
    }
};

RequestAnchorCheckIsPlayProgramCallbackImp gRequestAnchorCheckIsPlayProgramCallbackImp;
- (NSInteger)anchorCheckPublicRoomType:(AnchorCheckPublicRoomTypeFinishHandler _Nullable)finishHandler {
    
    NSInteger request = (NSInteger)mHttpRequestController.AnchorCheckPublicRoomType(&mHttpRequestManager, &gRequestAnchorCheckIsPlayProgramCallbackImp);
    if (request != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(request)];
        }
    }
    
    return request;
}

@end

