//
//  LSLiveChatRequestManager.m
//  dating
//
//  Created by Max on 18/11/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSLiveChatRequestManager.h"

#include <manrequesthandler/LSLiveChatHttpRequestManager.h>
#include <manrequesthandler/LSLiveChatHttpRequestHostManager.h>
#include <manrequesthandler/LSLiveChatRequestOtherController.h>
#include <manrequesthandler/LSLiveChatRequestLiveChatController.h>

static LSLiveChatRequestManager *gManager = nil;
@interface LSLiveChatRequestManager () {
    LSLiveChatHttpRequestManager mHttpRequestManager;
    LSLiveChatHttpRequestHostManager mHttpRequestHostManager;
    LSLiveChatRequestOtherController *mpLSLiveChatRequestOtherController;
    LSLiveChatRequestLiveChatController *mpLSLiveChatRequestLiveChatController;

}

@property (nonatomic, strong) NSMutableDictionary *delegateDictionary;
@property (nonatomic, strong) NSString *wapSite;
@end

@implementation LSLiveChatRequestManager


#pragma mark - 其他模块回调
class LSLiveChatRequestOtherControllerCallback : public ILSLiveChatRequestOtherControllerCallback {
  public:
    LSLiveChatRequestOtherControllerCallback(){};
    virtual ~LSLiveChatRequestOtherControllerCallback(){};

  public:
    //    virtual void OnEmotionConfig(long requestId, bool success, const string &errnum, const string &errmsg, const OtherEmotionConfigItem &item){};
    virtual void OnGetCount(long requestId, bool success, const string &errnum, const string &errmsg, const LSLCOtherGetCountItem &item) {};
    //    virtual void OnPhoneInfo(long requestId, bool success, const string &errnum, const string &errmsg);
    //    virtual void OnIntegralCheck(long requestId, bool success, const string &errnum, const string &errmsg, const OtherIntegralCheckItem &item);
    //    virtual void OnVersionCheck(long requestId, bool success, const string &errnum, const string &errmsg, const OtherVersionCheckItem &item);
    //    virtual void OnSynConfig(long requestId, bool success, const string &errnum, const string &errmsg, const OtherSynConfigItem &item);
    //    virtual void OnOnlineCount(long requestId, bool success, const string &errnum, const string &errmsg, const OtherOnlineCountList &countList){};
    //    virtual void OnUploadCrashLog(long requestId, bool success, const string &errnum, const string &errmsg);
    //    virtual void OnInstallLogs(long requestId, bool success, const string &errnum, const string &errmsg);
};

static LSLiveChatRequestOtherControllerCallback gLSLiveChatRequestOtherControllerCallback;



#pragma mark - liveChat模块回调
class LSLiveChatRequestLiveChatControllerCallback : public ILSLiveChatRequestLiveChatControllerCallback {
  public:
    LSLiveChatRequestLiveChatControllerCallback(){};
    virtual ~LSLiveChatRequestLiveChatControllerCallback(){};

  public:
    virtual void OnCheckCoupon(long requestId, bool success, const LSLCCoupon &item, const string &userId, const string &errnum, const string &errmsg){};
    virtual void OnUseCoupon(long requestId, bool success, const string &errnum, const string &errmsg, const string &userId, const string &couponid){};
    virtual void OnQueryChatVirtualGift(long requestId, bool success, const list<LSLCGift> &giftList, int totalCount, const string &path, const string &version, const string &errnum, const string &errmsg){};
    virtual void OnQueryChatRecord(long requestId, bool success, int dbTime, const list<LSLCRecord> &recordList, const string &errnum, const string &errmsg, const string &inviteId){};
    virtual void OnQueryChatRecordMutiple(long requestId, bool success, int dbTime, const list<LSLCRecordMutiple> &recordMutiList, const string &errnum, const string &errmsg){};
    virtual void OnSendPhoto(long requestId, bool success, const string &errnum, const string &errmsg, const LSLCLCSendPhotoItem &item){};
    virtual void OnPhotoFee(long requestId, bool success, const string &errnum, const string &errmsg){};
    virtual void OnCheckPhoto(long requestId, bool success, const string &errnum, const string &errmsg){};
    virtual void OnGetPhoto(long requestId, bool success, const string &errnum, const string &errmsg, const string &filePath){};
    virtual void OnUploadVoice(long requestId, bool success, const string &errnum, const string &errmsg, const string &voiceId){};
    virtual void OnPlayVoice(long requestId, bool success, const string &errnum, const string &errmsg, const string &filePath){};
    virtual void OnSendGift(long requestId, bool success, const string &errnum, const string &errmsg){};
    virtual void OnQueryRecentVideoList(long requestId, bool success, const list<LSLCVideoItem>& itemList, const string& errnum, const string& errmsg);
    virtual void OnGetVideoPhoto(long requestId, bool success, const string &errnum, const string &errmsg, const string &filePath){};
    virtual void OnGetVideo(long requestId, bool success, const string &errnum, const string &errmsg, const string &url){};
    virtual void OnGetMagicIconConfig(long requestId, bool success, const string &errnum, const string &errmsg, const LSLCMagicIconConfig &config){};
    virtual void OnChatRecharge(long requestId, bool success, const string &errnum, const string &errmsg, double credits){};
    virtual void OnGetThemeConfig(long requestId, bool success, const string &errnum, const string &errmsg, const LSLCThemeConfig &config){};
    virtual void OnGetThemeDetail(long requestId, bool success, const string &errnum, const string &errmsg, const ThemeItemList &themeList){};
    virtual void OnCheckFunctions(long requestId, bool success, const string &errnum, const string &errmsg, const list<string> &flagList){};
    virtual void OnGetSessionInviteList(long requestId, bool success, int errnum, const string& errmsg, const ChatScheduleSessionList& list) {};
};

static LSLiveChatRequestLiveChatControllerCallback gLSLiveChatRequestLiveChatControllerCallback;

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

        HttpClient::Init();

        mHttpRequestManager.SetHostManager(&mHttpRequestHostManager);
        mHttpRequestManager.SetVersionCode([self.versionCode UTF8String]);
        mpLSLiveChatRequestOtherController = new LSLiveChatRequestOtherController(&mHttpRequestManager, &gLSLiveChatRequestOtherControllerCallback);
        mpLSLiveChatRequestLiveChatController = new LSLiveChatRequestLiveChatController(&mHttpRequestManager, &gLSLiveChatRequestLiveChatControllerCallback);
    }
    return self;
}

#pragma mark - 公共模块
- (void)setLogEnable:(BOOL)enable {
    KLog::SetLogEnable(enable);
}

- (void)setLogDirectory:(NSString *)directory {
    KLog::SetLogDirectory([directory UTF8String]);
}

- (void)setWebSite:(NSString *)webSite appSite:(NSString *)appSite wapSite:(NSString *)wapSite {
    if (webSite) {
        mHttpRequestHostManager.SetWebSite([webSite UTF8String]);
    }

    if (appSite) {
        mHttpRequestHostManager.SetAppSite([appSite UTF8String]);
    }
}

- (void)setFakeSite:(NSString *)fakeSite {
    if (fakeSite) {
        mHttpRequestHostManager.SetFakeSite([fakeSite UTF8String]);
    }
}

- (void)setChangeSite:(NSString *)changeSite {
    if (changeSite) {
        mHttpRequestHostManager.SetChangeSite([changeSite UTF8String]);
    }
}

- (NSString *)getWebSite {
    return [NSString stringWithUTF8String:mHttpRequestHostManager.GetWebSite().c_str()];
}

- (NSString *)getAppSite {
    return [NSString stringWithUTF8String:mHttpRequestHostManager.GetAppSite().c_str()];
}

- (NSString *)getWapSite {
    return self.wapSite;
}

- (NSString *)getChangeSite {
    return [NSString stringWithUTF8String:mHttpRequestHostManager.GetChangeSite().c_str()];
}

- (void)setVoiceSite:(NSString *)voiceSite {
    mHttpRequestHostManager.SetChatVoiceSite([voiceSite UTF8String]);
}

- (void)setAuthorization:(NSString *)user password:(NSString *)password {
    string strUser = "";
    if (nil != user) {
        strUser = [user UTF8String];
    }

    string strPassword = "";
    if (nil != password) {
        strPassword = [password UTF8String];
    }

    mHttpRequestManager.SetAuthorization(strUser, strPassword);
}

- (void)cleanCookies {
    HttpClient::CleanCookies();
}

- (void)getCookies:(NSString *)site {
    string strSite = "";
    if (nil != site) {
        strSite = [site UTF8String];
    }

    HttpClient::GetCookies(strSite);
}

- (NSArray<LSLCCookiesItemObject *> *)getCookiesItem {
    list<CookiesItem> CookiesItems = HttpClient::GetCookiesItem();
    NSMutableArray *cookiesArray = [NSMutableArray array];
    for (list<CookiesItem>::const_iterator iter = CookiesItems.begin();
         iter != CookiesItems.end();
         iter++) {
        LSLCCookiesItemObject *object = [[LSLCCookiesItemObject alloc] init];
        object.domain = [NSString stringWithUTF8String:(*iter).m_domain.c_str()];
        object.accessOtherWeb = [NSString stringWithUTF8String:(*iter).m_accessOtherWeb.c_str()];
        object.symbol = [NSString stringWithUTF8String:(*iter).m_symbol.c_str()];
        object.isSend = [NSString stringWithUTF8String:(*iter).m_isSend.c_str()];
        object.expiresTime = [NSString stringWithUTF8String:(*iter).m_expiresTime.c_str()];
        object.cName = [NSString stringWithUTF8String:(*iter).m_cName.c_str()];
        object.value = [NSString stringWithUTF8String:(*iter).m_value.c_str()];
        if (nil != object) {
            [cookiesArray addObject:object];
        }
    }
    return cookiesArray;
}

- (NSArray<NSHTTPCookie *> *)getHttpCookies {
    NSMutableArray *cookies = [NSMutableArray array];

    list<CookiesItem> cookiesList = HttpClient::GetCookiesItem();
    for (list<CookiesItem>::const_iterator itr = cookiesList.begin(); itr != cookiesList.end(); itr++) {
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

- (void)stopRequest:(NSInteger)requestId {
    mHttpRequestManager.StopRequest(requestId);
}

- (void)stopAllRequest {
    mHttpRequestManager.StopAllRequest();
}

//- (NSString *)getDeviceId {
//    return [UIDevice currentDevice].identifierForVendor.UUIDString;
//}

- (NSString *)getRefferer {
    return @"";
}

#pragma mark - liveChat他模块
void LSLiveChatRequestLiveChatControllerCallback::OnQueryRecentVideoList(long requestId, bool success, const list<LSLCVideoItem>& itemList, const string& errnum, const string& errmsg) {
    FileLog("httprequest", "RequestManager::OnQueryRecentVideoList( success : %s )", success ? "true" : "false");

    NSMutableArray *giftArray = [NSMutableArray array];
    if (success) {

        for (list<LSLCVideoItem>::const_iterator iter = itemList.begin();
             iter != itemList.end();
             iter++) {
            LSLCRecentVideoItemObject *object = [[LSLCRecentVideoItemObject alloc] init];
            object.videoId = [NSString stringWithUTF8String:(*iter).videoid.c_str()];
            object.title = [NSString stringWithUTF8String:(*iter).title.c_str()];
            object.inviteid = [NSString stringWithUTF8String:(*iter).inviteid.c_str()];
            object.videoUrl = [NSString stringWithUTF8String:(*iter).video_url.c_str()];
            object.videoCover = [NSString stringWithUTF8String:(*iter).videoCover.c_str()];

            if (nil != object) {
                [giftArray addObject:object];
            }
        }
    }

    QueryRecentVideoListFinishHandler handler = nil;
    LSLiveChatRequestManager *manager = [LSLiveChatRequestManager manager];
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
    }

    if (handler) {
        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], giftArray);
    }
}

- (NSInteger)queryRecentVideoList:(NSString *)userSid
                           userId:(NSString *)userId
                          womanId:(NSString *)womanId
                           finish:(QueryRecentVideoListFinishHandler)finishHandler {
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;

    string strUserSid = "";
    if (userSid) {
        strUserSid = [userSid UTF8String];
    }

    string strUserId = "";
    if (userId) {
        strUserId = [userId UTF8String];
    }
    string strWomanId = "";
    if (womanId) {
        strWomanId = [womanId UTF8String];
    }
    requestId = mpLSLiveChatRequestLiveChatController->QueryRecentVideo(strUserSid, strUserId, strWomanId);
    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
    }

    return requestId;
}



@end
