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
//#include <manrequesthandler/LSLiveChatRequestFakeController.h>
//#include <manrequesthandler/LSLiveChatRequestAuthorizationController.h>
//#include <manrequesthandler/LSLiveChatRequestLadyController.h>
#include <manrequesthandler/LSLiveChatRequestOtherController.h>
//#include <manrequesthandler/LSLiveChatRequestProfileController.h>
//#include <manrequesthandler/LSLiveChatRequestPaidController.h>
//#include <manrequesthandler/LSLiveChatRequestMonthlyFeeController.h>
//#include <manrequesthandler/LSLiveChatRequestEMFController.h>
#include <manrequesthandler/LSLiveChatRequestLiveChatController.h>
//#include <manrequesthandler/LSLiveChatRequestSettingController.h>
//#include <manrequesthandler/LSLiveChatRequestVideoShowController.h>
//#include <manrequesthandler/LSLiveChatRequestLoveCallController.h>
//#include <manrequesthandler/LSLiveChatRequestAdvertController.h>
//
//#include "common/KZip.h"

static LSLiveChatRequestManager *gManager = nil;
@interface LSLiveChatRequestManager () {
    LSLiveChatHttpRequestManager mHttpRequestManager;
    LSLiveChatHttpRequestHostManager mHttpRequestHostManager;
    //    LSLiveChatRequestFakeController *mpLSLiveChatRequestFakeController;
    //    LSLiveChatRequestAuthorizationController *mpLSLiveChatRequestAuthorizationController;
    //    LSLiveChatRequestLadyController *mpLSLiveChatRequestLadyController;
    LSLiveChatRequestOtherController *mpLSLiveChatRequestOtherController;
    //    LSLiveChatRequestProfileController *mpLSLiveChatRequestProfileController;
    //    LSLiveChatRequestPaidController *mpLSLiveChatRequestPaidController;
    //    LSLiveChatRequestMonthlyFeeController *mpLSLiveChatRequestMonthlyFeeController;
    //    LSLiveChatRequestEMFController *mpLSLiveChatRequestEMFController;
    LSLiveChatRequestLiveChatController *mpLSLiveChatRequestLiveChatController;
    //    LSLiveChatRequestSettingController *mpLSLiveChatRequestSettingController;
    //    LSLiveChatRequestVideoShowController *mpLSLiveChatRequestVideoShowController;
    //    LSLiveChatRequestLoveCallController *mpLSLiveChatRequestLoveCallController;
    //    LSLiveChatRequestAdvertController *mpLSLiveChatRequestAdvertController;
}

@property (nonatomic, strong) NSMutableDictionary *delegateDictionary;
@property (nonatomic, strong) NSString *wapSite;
@end

@implementation LSLiveChatRequestManager

//#pragma mark - 真假服务器模块回调
//class LSLiveChatRequestFakeControllerCallback : public ILSLiveChatRequestFakeControllerCallback {
//  public:
//    LSLiveChatRequestFakeControllerCallback(){};
//    virtual ~LSLiveChatRequestFakeControllerCallback(){};
//
//  public:
//    void OnCheckServer(long requestId, bool success, CheckServerItem item, string errnum, string errmsg);
//};
//
//static LSLiveChatRequestFakeControllerCallback gLSLiveChatRequestFakeControllerCallback;
//
//#pragma mark - 登录认证模块回调
//void onLoginWithFacebook(long requestId, bool success, LoginFacebookItem item, string errnum, string errmsg,
//                         LoginErrorItem errItem);
//void onRegister(long requestId, bool success, RegisterItem item, string errnum, string errmsg);
//void onLogin(long requestId, bool success, LoginItem item, string errnum, string errmsg, int serverId);
//void onGetCheckCode(long requestId, bool success, const char *data, int len, string errnum, string errmsg);
//void onFindPassword(long requestId, bool success, string tips, string errnum, string errmsg);
//void onGetSms(long requestId, bool success, string errnum, string errmsg);
//void onVerifySms(long requestId, bool success, string errnum, string errmsg);
//void onGetFixedPhone(long requestId, bool success, string errnum, string errmsg);
//void onVerifyFixedPhone(long requestId, bool success, string errnum, string errmsg);
//void onGetWebsiteUrlToken(long requestId, bool success, string errnum, string errmsg, string token);
//void onSummitAppToken(long requestId, bool success, string errnum, string errmsg);
//void onUnbindAppToken(long requestId, bool success, string errnum, string errmsg);
//void onTokenLogin(long requestId, bool success, LoginItem item, string errnum, string errmsg);
//void onGetValidSiteId(long requestId, bool success, string errnum, string errmsg, ValidSiteIdList siteIdList);
//
//LSLiveChatRequestAuthorizationControllerCallback gLSLiveChatRequestAuthorizationControllerCallback{
//    NULL,
//    onRegister,
//    onGetCheckCode,
//    onLogin,
//    onFindPassword,
//    onGetSms,
//    onVerifySms,
//    onGetFixedPhone,
//    onVerifyFixedPhone,
//    onGetWebsiteUrlToken,
//    onSummitAppToken,
//    onUnbindAppToken,
//    NULL,
//    onTokenLogin,
//    onGetValidSiteId};
//
//#pragma mark - online列表模块回调
//void onQueryLadyList(long requestId, bool success, list<Lady> ladyList, int totalCount, string errnum, string errmsg);
//void onQueryLadyDetail(long requestId, bool success, LadyDetail item, string errnum, string errmsg);
//void onAddFavouritesLady(long requestId, bool success, string errnum, string errmsg);
//void onRemoveFavouritesLady(long requestId, bool success, string errnum, string errmsg);
//void onQueryLadyCall(long requestId, bool success, LadyCall item, string errnum, string errmsg);
//void onRecentContact(long requestId, bool success, const string &errnum, const string &errmsg, const list<LadyRecentContact> &list);
//void onRemoveContactList(long requestId, bool success, string errnum, string errmsg);
//void onReportLady(long requestId, bool success, const string &errnum, const string &errmsg);
//void onGetFavoriteList(long requestId, bool success, const string& errnum, const string& errmsg, list<FavoriteItem>& favList, int totalCount);
//
//LSLiveChatRequestLadyControllerCallback gLSLiveChatRequestLadyControllerCallback{
//    NULL,
//    NULL,
//    onQueryLadyList,
//    onQueryLadyDetail,
//    onAddFavouritesLady,
//    onRemoveFavouritesLady,
//    onQueryLadyCall,
//    onRecentContact,
//    onRemoveContactList,
//    NULL,
//    NULL,
//    onReportLady,
//    onGetFavoriteList
//};

#pragma mark - 其他模块回调
class LSLiveChatRequestOtherControllerCallback : public ILSLiveChatRequestOtherControllerCallback {
  public:
    LSLiveChatRequestOtherControllerCallback(){};
    virtual ~LSLiveChatRequestOtherControllerCallback(){};

  public:
    //    virtual void OnEmotionConfig(long requestId, bool success, const string &errnum, const string &errmsg, const OtherEmotionConfigItem &item){};
    virtual void OnGetCount(long requestId, bool success, const string &errnum, const string &errmsg, const LSLCOtherGetCountItem &item);
    //    virtual void OnPhoneInfo(long requestId, bool success, const string &errnum, const string &errmsg);
    //    virtual void OnIntegralCheck(long requestId, bool success, const string &errnum, const string &errmsg, const OtherIntegralCheckItem &item);
    //    virtual void OnVersionCheck(long requestId, bool success, const string &errnum, const string &errmsg, const OtherVersionCheckItem &item);
    //    virtual void OnSynConfig(long requestId, bool success, const string &errnum, const string &errmsg, const OtherSynConfigItem &item);
    //    virtual void OnOnlineCount(long requestId, bool success, const string &errnum, const string &errmsg, const OtherOnlineCountList &countList){};
    //    virtual void OnUploadCrashLog(long requestId, bool success, const string &errnum, const string &errmsg);
    //    virtual void OnInstallLogs(long requestId, bool success, const string &errnum, const string &errmsg);
};

static LSLiveChatRequestOtherControllerCallback gLSLiveChatRequestOtherControllerCallback;

//#pragma mark - 支付回调
//void onGetPaymentOrder(long requestId, bool success, const string &code, const string &orderNo, const string &productId);
//void onCheckPayment(long requestId, bool success, const string &code);
//LSLiveChatRequestPaidControllerCallback gLSLiveChatRequestPaidControllerCallback{
//    onGetPaymentOrder,
//    onCheckPayment};
//
//#pragma mark - 月费回调
//void onQueryMemberType(long requestId, bool success, string errnum, string errmsg, int memberType, string mfeeEndDate);
//void onGetMonthlyFeeTips(long requestId, bool success, string errnum, string errmsg, list<MonthlyFeeTip> tipsList);
//void onGetPremiumMemberShip(long requestId, bool success, string errnum, string errmsg, MonthlyFeeInstructionItem item);
//LSLiveChatRequestMonthlyFeeControllerCallback gLSLiveChatRequestMonthlyFeeControllerCallback{
//    onQueryMemberType,
//    onGetMonthlyFeeTips,
//    onGetPremiumMemberShip};
//
//#pragma mark - EMF回调
//void onRequestEMFInboxList(long requestId, bool success, const string &errnum, const string &errmsg, int pageIndex, int pageSize, int dataCount, const EMFInboxList &inboxList);
//void onRequestEMFInboxMsg(long requestId, bool success, const string &errnum, const string &errmsg, int memberType, const EMFInboxMsgItem &item);
//void onRequestEMFOutboxList(long requestId, bool success, const string &errnum, const string &errmsg, int pageIndex, int pageSize, int dataCount, const EMFOutboxList &outboxList);
//void onRequestEMFOutboxMsg(long requestId, bool success, const string &errnum, const string &errmsg, const EMFOutboxMsgItem &item);
//void onRequestEMFMsgTotal(long requestId, bool success, const string &errnum, const string &errmsg, const EMFMsgTotalItem &item);
//void onRequestEMFSendMsg(long requestId, bool success, const string &errnum, const string &errmsg, const EMFSendMsgItem &item, const EMFSendMsgErrorItem &errItem);
//void onRequestEMFUploadImage(long requestId, bool success, const string &errnum, const string &errmsg);
//void onRequestEMFUploadAttach(long requestId, bool success, const string &errnum, const string &errmsg, const string &attachId);
//void onRequestEMFDeleteMsg(long requestId, bool success, const string &errnum, const string &errmsg);
//void onRequestEMFAdmirerList(long requestId, bool success, const string &errnum, const string &errmsg, int pageIndex, int pageSize, int dataCount, const EMFAdmirerList &admirerList);
//void onRequestEMFAdmirerViewer(long requestId, bool success, const string &errnum, const string &errmsg, const EMFAdmirerViewerItem &item);
//void onRequestEMFBlockList(long requestId, bool success, const string &errnum, const string &errmsg, int pageIndex, int pageSize, int dataCount, const EMFBlockList &blockList);
//void onRequestEMFBlock(long requestId, bool success, const string &errnum, const string &errmsg);
//void onRequestEMFUnblock(long requestId, bool success, const string &errnum, const string &errmsg);
//void onRequestEMFInboxPhotoFee(long requestId, bool success, const string &errnum, const string &errmsg);
//void onRequestEMFPrivatePhotoView(long requestId, bool success, const string &errnum, const string &errmsg, const string &filePath);
//void onRequestGetVideoThumbPhoto(long requestId, bool success, const string &errnum, const string &errmsg, const string &filePath);
//void onRequestGetVideoUrl(long requestId, bool success, const string &errnum, const string &errmsg, const string &url);
//LSLiveChatRequestEMFControllerCallback gLSLiveChatRequestEMFControllerCallback{
//    onRequestEMFInboxList,
//    onRequestEMFInboxMsg,
//    onRequestEMFOutboxList,
//    onRequestEMFOutboxMsg,
//    onRequestEMFMsgTotal,
//    onRequestEMFSendMsg,
//    onRequestEMFUploadImage,
//    onRequestEMFUploadAttach,
//    onRequestEMFDeleteMsg,
//    onRequestEMFAdmirerList,
//    onRequestEMFAdmirerViewer,
//    onRequestEMFBlockList,
//    onRequestEMFBlock,
//    onRequestEMFUnblock,
//    onRequestEMFInboxPhotoFee,
//    onRequestEMFPrivatePhotoView,
//    onRequestGetVideoThumbPhoto,
//    onRequestGetVideoUrl};

#pragma mark - liveChat模块回调
class LSLiveChatRequestLiveChatControllerCallback : public ILSLiveChatRequestLiveChatControllerCallback {
  public:
    LSLiveChatRequestLiveChatControllerCallback(){};
    virtual ~LSLiveChatRequestLiveChatControllerCallback(){};

  public:
    virtual void OnCheckCoupon(long requestId, bool success, const LSLCCoupon &item, const string &userId, const string &errnum, const string &errmsg){};
    virtual void OnUseCoupon(long requestId, bool success, const string &errnum, const string &errmsg, const string &userId, const string &couponid){};
    virtual void OnQueryChatVirtualGift(long requestId, bool success, const list<LSLCGift> &giftList, int totalCount, const string &path, const string &version, const string &errnum, const string &errmsg);
    virtual void OnQueryChatRecord(long requestId, bool success, int dbTime, const list<LSLCRecord> &recordList, const string &errnum, const string &errmsg, const string &inviteId){};
    virtual void OnQueryChatRecordMutiple(long requestId, bool success, int dbTime, const list<LSLCRecordMutiple> &recordMutiList, const string &errnum, const string &errmsg){};
    virtual void OnSendPhoto(long requestId, bool success, const string &errnum, const string &errmsg, const LSLCLCSendPhotoItem &item){};
    virtual void OnPhotoFee(long requestId, bool success, const string &errnum, const string &errmsg){};
    virtual void OnCheckPhoto(long requestId, bool success, const string &errnum, const string &errmsg){};
    virtual void OnGetPhoto(long requestId, bool success, const string &errnum, const string &errmsg, const string &filePath){};
    virtual void OnUploadVoice(long requestId, bool success, const string &errnum, const string &errmsg, const string &voiceId){};
    virtual void OnPlayVoice(long requestId, bool success, const string &errnum, const string &errmsg, const string &filePath){};
    virtual void OnSendGift(long requestId, bool success, const string &errnum, const string &errmsg);
    virtual void OnQueryRecentVideoList(long requestId, bool success, const list<LSLCVideoItem> &itemList, const string &errnum, const string &errmsg){};
    virtual void OnGetVideoPhoto(long requestId, bool success, const string &errnum, const string &errmsg, const string &filePath){};
    virtual void OnGetVideo(long requestId, bool success, const string &errnum, const string &errmsg, const string &url){};
    virtual void OnGetMagicIconConfig(long requestId, bool success, const string &errnum, const string &errmsg, const LSLCMagicIconConfig &config){};
    virtual void OnChatRecharge(long requestId, bool success, const string &errnum, const string &errmsg, double credits){};
    virtual void OnGetThemeConfig(long requestId, bool success, const string &errnum, const string &errmsg, const LSLCThemeConfig &config){};
    virtual void OnGetThemeDetail(long requestId, bool success, const string &errnum, const string &errmsg, const ThemeItemList &themeList){};
    virtual void OnCheckFunctions(long requestId, bool success, const string &errnum, const string &errmsg, const list<string> &flagList){};
};

static LSLiveChatRequestLiveChatControllerCallback gLSLiveChatRequestLiveChatControllerCallback;

//#pragma mark - 设置模块回调
//void onChangePassword(long requestId, bool success, string errnum, string errmsg);
//
//LSLiveChatRequestSettingControllerCallback gLSLiveChatRequestSettingControllerCallback{
//    onChangePassword};
//
//#pragma mark - 视频显示模块回调
//void onRequestVSVideoDetail(long requestId, bool success, const string &errnum, const string &errmsg, const VSVideoDetailList &list);
//void onRequestVSPlayVideo(long requestId, bool success, const string &errnum, const string &errmsg, int memberType, const VSPlayVideoItem &item);
//
//LSLiveChatRequestVideoShowControllerCallback gLSLiveChatRequestVideoShowControllerCallback{
//    NULL,
//    onRequestVSVideoDetail,
//    onRequestVSPlayVideo,
//    NULL,
//    NULL,
//    NULL,
//    NULL};
//
//#pragma mark - LoveCall模块回调
//void onQueryLoveCallList(long requestId, bool success, list<LoveCall> itemList, int totalCount, string errnum, string errmsg);
//void onConfirmLoveCall(long requestId, bool success, string errnum, string errmsg, int memberType);
//void onQueryLoveCallRequestCount(long requestId, bool success, string errnum, string errmsg, int num);
//
//LSLiveChatRequestLoveCallControllerCallback gLSLiveChatRequestLoveCallControllerCallback{
//    onQueryLoveCallList,
//    onConfirmLoveCall,
//    onQueryLoveCallRequestCount};
//
//#pragma mark - 广告模块回调
//void onRequestAdMainAdvert(long requestId, bool success, const string &errnum, const string &errmsg, const AdMainAdvertItem &item);
//void onRequestAdWomanListAdvert(long requestId, bool success, const string &errnum, const string &errmsg, const AdWomanListAdvertItem &item);
//void onRequestAdPushAdvert(long requestId, bool success, const string &errnum, const string &errmsg, const AdPushAdvertList &pushList);
//void onRequestAppPromotionAdvert(long requestId, bool success, const string &errnum, const string &errmsg, const string &adOverview);
//void onRequestPopNoticeAdvert(long requestId, bool success, const string &errnum, const string &errmsg, const string &url, bool isCanClose);
//void onRequestAdmirerListAd(long requestId, bool success, const string &errnum, const string &errmsg, const string &advertId, const string &htmlCode, const string &advertTitle);
//void onRequestHtml5Ad(long requestId, bool success, const string &errnum, const string &errmsg, const AdHtml5AdvertItem &item);
//
//LSLiveChatRequestAdvertControllerCallback gLSLiveChatRequestAdvertControllerCallback{
//    NULL,
//    onRequestAdWomanListAdvert,
//    NULL,
//    NULL,
//    NULL,
//    onRequestAdmirerListAd,
//    onRequestHtml5Ad};

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
        //        mpLSLiveChatRequestFakeController = new LSLiveChatRequestFakeController(&mHttpRequestManager, &gLSLiveChatRequestFakeControllerCallback);
        //        mpLSLiveChatRequestAuthorizationController = new LSLiveChatRequestAuthorizationController(&mHttpRequestManager, gLSLiveChatRequestAuthorizationControllerCallback);
        //        mpLSLiveChatRequestLadyController = new LSLiveChatRequestLadyController(&mHttpRequestManager, gLSLiveChatRequestLadyControllerCallback);
        mpLSLiveChatRequestOtherController = new LSLiveChatRequestOtherController(&mHttpRequestManager, &gLSLiveChatRequestOtherControllerCallback);
        //        mpLSLiveChatRequestProfileController = new LSLiveChatRequestProfileController(&mHttpRequestManager, gLSLiveChatRequestProfileControllerCallback);
        //        mpLSLiveChatRequestPaidController = new LSLiveChatRequestPaidController(&mHttpRequestManager, gLSLiveChatRequestPaidControllerCallback);
        //        mpLSLiveChatRequestMonthlyFeeController = new LSLiveChatRequestMonthlyFeeController(&mHttpRequestManager, gLSLiveChatRequestMonthlyFeeControllerCallback);
        //        mpLSLiveChatRequestEMFController = new LSLiveChatRequestEMFController(&mHttpRequestManager, gLSLiveChatRequestEMFControllerCallback);

        mpLSLiveChatRequestLiveChatController = new LSLiveChatRequestLiveChatController(&mHttpRequestManager, &gLSLiveChatRequestLiveChatControllerCallback);
        //
        //        mpLSLiveChatRequestSettingController = new LSLiveChatRequestSettingController(&mHttpRequestManager, gLSLiveChatRequestSettingControllerCallback);
        //
        //        mpLSLiveChatRequestVideoShowController = new LSLiveChatRequestVideoShowController(&mHttpRequestManager, gLSLiveChatRequestVideoShowControllerCallback);
        //
        //        mpLSLiveChatRequestLoveCallController = new LSLiveChatRequestLoveCallController(&mHttpRequestManager, gLSLiveChatRequestLoveCallControllerCallback);
        //
        //        mpLSLiveChatRequestAdvertController = new LSLiveChatRequestAdvertController(&mHttpRequestManager, gLSLiveChatRequestAdvertControllerCallback);
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

//#pragma mark - 真假服务器模块
//void LSLiveChatRequestFakeControllerCallback::OnCheckServer(long requestId, bool success, CheckServerItem item, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::OnCheckServer( success : %s )", success ? "true" : "false");
//    RequestManager *manager = [RequestManager manager];
//
//    CheckServerItemObject *obj = [[CheckServerItemObject alloc] init];
//    if (success) {
//        obj.webhost = [NSString stringWithUTF8String:item.webhost.c_str()];
//        obj.apphost = [NSString stringWithUTF8String:item.apphost.c_str()];
//        obj.waphost = [NSString stringWithUTF8String:item.waphost.c_str()];
//        obj.pay_api = [NSString stringWithUTF8String:item.pay_api.c_str()];
//        obj.fake = item.fake;
//    }
//
//    CheckServerFinishHandler handler = nil;
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, obj, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)checkServer:(NSString *)user finishHandler:(CheckServerFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strUser = "";
//    if (nil != user) {
//        strUser = [user UTF8String];
//    }
//    requestId = mpLSLiveChatRequestFakeController->CheckServer(strUser);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//#pragma mark - 登录认证模块
////注册
//void onRegister(long requestId, bool success, RegisterItem item, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::onRegister( success : %s )", success ? "true" : "false");
//    RequestManager *manager = [RequestManager manager];
//    registerFinishHandler handler = nil;
//    RegisterItemObject *obj = [[RegisterItemObject alloc] init];
//    if (success) {
//        obj.login = item.login;
//        obj.email = [NSString stringWithUTF8String:item.email.c_str()];
//        obj.firstname = [NSString stringWithUTF8String:item.firstname.c_str()];
//        obj.lastname = [NSString stringWithUTF8String:item.lastname.c_str()];
//        obj.sid = [NSString stringWithUTF8String:item.sid.c_str()];
//        obj.reg_step = [NSString stringWithUTF8String:item.reg_step.c_str()];
//        obj.errnum = [NSString stringWithUTF8String:item.errnum.c_str()];
//        obj.errtext = [NSString stringWithUTF8String:item.errtext.c_str()];
//        obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
//        obj.sessionid = [NSString stringWithUTF8String:item.sessionid.c_str()];
//        obj.ga_uid = [NSString stringWithUTF8String:item.ga_uid.c_str()];
//        obj.photosend = item.photosend;
//        obj.photoreceived = item.photoreceived;
//        obj.videoreceived = item.videoreceived;
//    }
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, obj, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)registerUser:(NSString *)user
//                 password:(NSString *)password
//                      sex:(BOOL)isMale
//                firstname:(NSString *)firstname
//                 lastname:(NSString *)lastname
//                  country:(int)country
//               birthday_y:(NSString *)birthday_y
//               birthday_m:(NSString *)birthday_m
//               birthday_d:(NSString *)birthday_d
//               weeklymail:(BOOL)isWeeklymail
//            finishHandler:(registerFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//
//    string strUser = "";
//    if (nil != user) {
//        strUser = [user UTF8String];
//    }
//
//    string strPassword = "";
//    if (nil != password) {
//        strPassword = [password UTF8String];
//    }
//
//    string strFirstname = "";
//    if (nil != firstname) {
//        strFirstname = [firstname UTF8String];
//    }
//
//    string strLastname = "";
//    if (nil != lastname) {
//        strLastname = [lastname UTF8String];
//    }
//
//    string strBirthday_y = "";
//    if (nil != birthday_y) {
//        strBirthday_y = [birthday_y UTF8String];
//    }
//
//    string strBirthday_m = "";
//    if (nil != birthday_m) {
//        strBirthday_m = [birthday_m UTF8String];
//    }
//
//    string strBirthday_d = "";
//    if (nil != birthday_d) {
//        strBirthday_d = [birthday_d UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestAuthorizationController->Register(strUser, strPassword, isMale, strFirstname, strLastname, country, strBirthday_y, strBirthday_m, strBirthday_d, isWeeklymail, [[[UIDevice currentDevice] model] UTF8String], [[self getDeviceId] UTF8String], "apple", [self.getRefferer UTF8String]);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
////登录
//void onLogin(long requestId, bool success, LoginItem item, string errnum, string errmsg, int serverId) {
//    FileLog("httprequest", "RequestManager::onLogin( success : %s )", success ? "true" : "false");
//
//    LoginItemObject *obj = [[LoginItemObject alloc] init];
//    if (success) {
//        obj.manid = [NSString stringWithUTF8String:item.manid.c_str()];
//        obj.email = [NSString stringWithUTF8String:item.email.c_str()];
//        obj.firstname = [NSString stringWithUTF8String:item.firstname.c_str()];
//        obj.lastname = [NSString stringWithUTF8String:item.lastname.c_str()];
//        obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
//        obj.reg_step = [NSString stringWithUTF8String:item.reg_step.c_str()];
//        obj.country = item.country;
//        obj.telephone = [NSString stringWithUTF8String:item.telephone.c_str()];
//        obj.telephone_verify = item.telephone_verify;
//        obj.telephone_cc = item.telephone_cc;
//        obj.sessionid = [NSString stringWithUTF8String:item.sessionid.c_str()];
//        obj.ga_uid = [NSString stringWithUTF8String:item.ga_uid.c_str()];
//        obj.ga_activity = [NSString stringWithUTF8String:item.gaActivity.c_str()];
//        obj.ticketid = [NSString stringWithUTF8String:item.ticketid.c_str()];
//        obj.photosend = item.photosend;
//        obj.photoreceived = item.photoreceived;
//        obj.premit = item.premit;
//        obj.ladyprofile = item.ladyprofile;
//        obj.livechat = item.livechat;
//        obj.admirer = item.admirer;
//        obj.bpemf = item.bpemf;
//        obj.videoreceived = item.videoreceived;
//        obj.camshare = item.camshare;
//        obj.livechatInvite = item.livechat_invite;
//        obj.liveEnable = item.liveEnable;
//        obj.adOverview = [NSString stringWithUTF8String:item.adOverview.c_str()];
//    }
//
//    LoginFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, obj, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], serverId);
//    }
//}
//
//- (NSInteger)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode finishHandler:(LoginFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//
//    string strUser = "";
//    if (nil != user) {
//        strUser = [user UTF8String];
//    }
//    string strPassword = "";
//    if (nil != password) {
//        strPassword = [password UTF8String];
//    }
//    string strCheckcode = "";
//    if (nil != checkcode) {
//        strCheckcode = [checkcode UTF8String];
//    }
//
//    string strVersionCode = "";
//    if (nil != self.versionCode) {
//        strVersionCode = [self.versionCode UTF8String];
//    }
//    requestId = mpLSLiveChatRequestAuthorizationController->Login(strUser, strPassword, strCheckcode, [[self getDeviceId] UTF8String], strVersionCode, [[[UIDevice currentDevice] model] UTF8String], "apple");
//
//    @synchronized(self.delegateDictionary) {
//        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//void onGetCheckCode(long requestId, bool success, const char *data, int len, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::onGetCheckCode( success : %s )", success ? "true" : "false");
//
//    GetCheckCodeFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, data, len, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)getCheckCode:(BOOL)isUseCode
//            finishHandler:(GetCheckCodeFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestAuthorizationController->GetCheckCode(isUseCode);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onFindPassword(long requestId, bool success, string tips, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::::onFindPassword( success : %s )", success ? "true" : "false");
//    FindPasswordFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:tips.c_str()], [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)findPassword:(NSString *)mail
//                checkCode:(NSString *)checkCode
//            finishHandler:(FindPasswordFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strMail = "";
//    if (nil != mail) {
//        strMail = [mail UTF8String];
//    }
//    string strCheckCode = "";
//    if (nil != checkCode) {
//        strCheckCode = [checkCode UTF8String];
//    }
//    requestId = mpLSLiveChatRequestAuthorizationController->FindPassword(strMail, strCheckCode);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onGetSms(long requestId, bool success, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::::onGetSms( success : %s )", success ? "true" : "false");
//    GetSmsFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)getSms:(NSString *)telephone
//       telephone_cc:(int)telephone_cc
//      finishHandler:(GetSmsFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strTelephone = "";
//    if (telephone) {
//        strTelephone = [telephone UTF8String];
//    }
//    requestId = mpLSLiveChatRequestAuthorizationController->GetSms(strTelephone, telephone_cc, [[self getDeviceId] UTF8String]);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onVerifySms(long requestId, bool success, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::::onVerifySms( success : %s )", success ? "true" : "false");
//    VerifySmsFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)verifySms:(NSString *)verifyCode
//                 vType:(int)vType
//         finishHandler:(VerifySmsFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strVerifyCode = "";
//    if (verifyCode) {
//        strVerifyCode = [verifyCode UTF8String];
//    }
//    requestId = mpLSLiveChatRequestAuthorizationController->VerifySms(strVerifyCode, vType);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onGetFixedPhone(long requestId, bool success, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::::onGetFixedPhone( success : %s )", success ? "true" : "false");
//    GetFixedPhoneFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)getFixedPhone:(NSString *)landline
//               landline_cc:(int)landline_cc
//               landline_ac:(NSString *)landline_ac
//             finishHandler:(GetFixedPhoneFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strLandline = "";
//    if (landline) {
//        strLandline = [landline UTF8String];
//    }
//    string strLandlineAc = "";
//    if (landline_ac) {
//        strLandlineAc = [landline_ac UTF8String];
//    }
//    requestId = mpLSLiveChatRequestAuthorizationController->GetFixedPhone(strLandline, landline_cc, strLandlineAc, [[self getDeviceId] UTF8String]);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onVerifyFixedPhone(long requestId, bool success, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::::onVerifyFixedPhone( success : %s )", success ? "true" : "false");
//    VerifyFixedPhoneFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)verifyFixedPhone:(NSString *)verifyCode
//                finishHandler:(VerifyFixedPhoneFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strVerifyCode = "";
//    if (verifyCode) {
//        strVerifyCode = [verifyCode UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestAuthorizationController->VerifyFixedPhone(strVerifyCode);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onGetWebsiteUrlToken(long requestId, bool success, string errnum, string errmsg, string token) {
//    FileLog("httprequest", "RequestManager::::onGetWebsiteUrlToken( success : %s, token:%s)", success ? "true" : "false", token.c_str());
//    GetWebsiteUrlTokenFinishHandler handler = nil;
//    NSString *strToken = [NSString stringWithUTF8String:token.c_str()];
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], strToken);
//    }
//}
//
//- (NSInteger)getWebsiteUrlToken:(OTHER_SITE_TYPE)siteId
//                  finishHandler:(GetWebsiteUrlTokenFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    VERIFY_CLIENT_TYPE clientType = VERIFY_CLIENT_TYPE_APP;
//    requestId = mpLSLiveChatRequestAuthorizationController->GetWebsiteUrlToken(siteId, clientType, "");
//
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
////上传AppToken
//void onSummitAppToken(long requestId, bool success, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::onSummitAppToken( success : %s )", success ? "true" : "false");
//
//    SummitApptokenFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)summitAppTokenDeviced:(NSString *)tokenId appId:(NSString *)appId finishHandler:(SummitApptokenFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    //    if (tokenId) {
//    requestId = mpLSLiveChatRequestAuthorizationController->SummitAppToken([[self getDeviceId] UTF8String], [tokenId UTF8String], [appId UTF8String]);
//    //    }
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
////销毁AppToken
//void onUnbindAppToken(long requestId, bool success, string errnum, string errmsg) {
//    UnbindAppTokenFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)unbindAppToken:(UnbindAppTokenFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestAuthorizationController->UnbindAppToken();
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onTokenLogin(long requestId, bool success, LoginItem item, string errnum, string errmsg) {
//
//    FileLog("httprequest", "RequestManager::onTokenLogin( success : %s )", success ? "true" : "false");
//
//    LoginItemObject *obj = [[LoginItemObject alloc] init];
//    if (success) {
//        obj.manid = [NSString stringWithUTF8String:item.manid.c_str()];
//        obj.email = [NSString stringWithUTF8String:item.email.c_str()];
//        obj.firstname = [NSString stringWithUTF8String:item.firstname.c_str()];
//        obj.lastname = [NSString stringWithUTF8String:item.lastname.c_str()];
//        obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
//        obj.reg_step = [NSString stringWithUTF8String:item.reg_step.c_str()];
//        obj.country = item.country;
//        obj.telephone = [NSString stringWithUTF8String:item.telephone.c_str()];
//        obj.telephone_verify = item.telephone_verify;
//        obj.telephone_cc = item.telephone_cc;
//        obj.sessionid = [NSString stringWithUTF8String:item.sessionid.c_str()];
//        obj.ga_uid = [NSString stringWithUTF8String:item.ga_uid.c_str()];
//        obj.ga_activity = [NSString stringWithUTF8String:item.gaActivity.c_str()];
//        obj.ticketid = [NSString stringWithUTF8String:item.ticketid.c_str()];
//        obj.photosend = item.photosend;
//        obj.photoreceived = item.photoreceived;
//        obj.premit = item.premit;
//        obj.ladyprofile = item.ladyprofile;
//        obj.livechat = item.livechat;
//        obj.admirer = item.admirer;
//        obj.bpemf = item.bpemf;
//        obj.videoreceived = item.videoreceived;
//        obj.camshare = item.camshare;
//        obj.livechatInvite = item.livechat_invite;
//        obj.liveEnable = item.liveEnable;
//        obj.adOverview = [NSString stringWithUTF8String:item.adOverview.c_str()];
//    }
//
//    TokenLoginFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, obj, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)tokenLogin:(NSString *)token
//               memberId:(NSString *)memberId
//          finishHandler:(TokenLoginFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strToken = "";
//    if (token) {
//        strToken = [token UTF8String];
//    }
//
//    string strMemberId = "";
//    if (memberId) {
//        strMemberId = [memberId UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestAuthorizationController->TokenLogin(strToken, strMemberId, [[self getDeviceId] UTF8String], [self.versionCode UTF8String], [[[UIDevice currentDevice] model] UTF8String], "apple");
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onGetValidSiteId(long requestId, bool success, string errnum, string errmsg, ValidSiteIdList siteIdList) {
//
//    FileLog("httprequest", "RequestManager::onGetValidSiteId( success : %s )", success ? "true" : "false");
//    NSMutableArray *array = [NSMutableArray array];
//    if (success) {
//        for (ValidSiteIdList::iterator itr = siteIdList.begin(); itr != siteIdList.end(); itr++) {
//            ValidSiteIdItemObject *obj = [[ValidSiteIdItemObject alloc] init];
//            obj.siteId = (*itr).siteId;
//            obj.isLive = (*itr).isLive;
//            [array addObject:obj];
//        }
//    }
//
//    GetValidSiteIdFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], array);
//    }
//}
//
//- (NSInteger)getValidSiteId:(NSString *)email
//                   password:(NSString *)password
//              finishHandler:(GetValidSiteIdFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strEmail = "";
//    if (email) {
//        strEmail = [email UTF8String];
//    }
//
//    string strPassword = "";
//    if (password) {
//        strPassword = [password UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestAuthorizationController->GetValidSiteId(strEmail, strPassword);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//#pragma mark - 个人信息模块回调
//void onGetMyProfile(long requestId, bool success, ProfileItem item, string errnum, string errmsg);
//void onUpdateMyProfile(long requestId, bool success, bool rsModified, string errnum, string errmsg);
//void onStartEditResume(long requestId, bool success, string errnum, string errmsg);
//void onSaveContact(long requestId, bool success, string errnum, string errmsg);
//void onUploadHeaderPhoto(long requestId, bool success, string errnum, string errmsg);
//LSLiveChatRequestProfileControllerCallback gLSLiveChatRequestProfileControllerCallback{
//    onGetMyProfile,
//    onUpdateMyProfile,
//    onStartEditResume,
//    NULL,
//    onUploadHeaderPhoto};
//
//#pragma mark - 个人资料模块
//void onGetMyProfile(long requestId, bool success, ProfileItem item, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::onGetMyProfile( success : %s )", success ? "true" : "false");
//    PersonalProfile *profile = [[PersonalProfile alloc] init];
//    NSMutableArray *interestsArray = [NSMutableArray array];
//    if (success) {
//        profile.manId = [NSString stringWithUTF8String:item.manid.c_str()];
//        profile.age = item.age;
//        profile.birthday = [NSString stringWithUTF8String:item.birthday.c_str()];
//        profile.firstname = [NSString stringWithUTF8String:item.firstname.c_str()];
//        profile.lastname = [NSString stringWithUTF8String:item.lastname.c_str()];
//        profile.email = [NSString stringWithUTF8String:item.email.c_str()];
//        profile.gender = item.gender;
//        profile.country = item.country;
//        profile.marry = item.marry;
//        profile.height = item.height;
//        profile.weight = item.weight;
//        profile.drink = item.drink;
//        profile.smoke = item.smoke;
//        profile.language = item.language;
//        profile.religion = item.religion;
//        profile.education = item.education;
//        profile.profession = item.profession;
//        profile.ethnicity = item.ethnicity;
//        profile.income = item.income;
//        profile.children = item.children;
//        profile.resume = [NSString stringWithUTF8String:item.resume.c_str()];
//        profile.resume_content = [NSString stringWithUTF8String:item.resume_content.c_str()];
//        profile.resume_status = item.resume_status;
//        profile.address1 = [NSString stringWithUTF8String:item.address1.c_str()];
//        profile.address2 = [NSString stringWithUTF8String:item.address2.c_str()];
//        profile.city = [NSString stringWithUTF8String:item.city.c_str()];
//        profile.province = [NSString stringWithUTF8String:item.province.c_str()];
//        profile.zipcode = [NSString stringWithUTF8String:item.zipcode.c_str()];
//        profile.telephone = [NSString stringWithUTF8String:item.telephone.c_str()];
//        profile.fax = [NSString stringWithUTF8String:item.fax.c_str()];
//        profile.alternate_email = [NSString stringWithUTF8String:item.alternate_email.c_str()];
//        profile.money = [NSString stringWithUTF8String:item.money.c_str()];
//        profile.v_id = item.v_id;
//        profile.photoStatus = item.photo;
//        profile.photoUrl = [NSString stringWithUTF8String:item.photoURL.c_str()];
//        profile.integral = item.integral;
//        profile.mobile = [NSString stringWithUTF8String:item.mobile.c_str()];
//        profile.mobileZoom = item.mobile_cc;
//        profile.mobileStatus = item.mobile_status;
//        profile.landline = [NSString stringWithUTF8String:item.landline.c_str()];
//        profile.landlineZoom = item.landline_cc;
//        profile.landlineLocation = [NSString stringWithUTF8String:item.landline_ac.c_str()];
//        profile.landlineStatus = item.landline_status;
//        profile.zodiac = item.zodiac;
//
//        for (list<string>::iterator itr = item.interests.begin(); itr != item.interests.end(); itr++) {
//            [interestsArray addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        profile.interests = interestsArray;
//    }
//    RequestManager *manger = [RequestManager manager];
//    getMyProfileFinishHandler handler = nil;
//
//    @synchronized(manger.delegateDictionary) {
//        handler = [manger.delegateDictionary objectForKey:@(requestId)];
//        [manger.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, profile, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)getMyProfileFinishHandler:(getMyProfileFinishHandler)finishHandler {
//    NSInteger requestId = mpLSLiveChatRequestProfileController->GetMyProfile();
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onUpdateMyProfile(long requestId, bool success, bool rsModified, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::onUpdateMyProfile( success : %s )", success ? "true" : "false");
//    RequestManager *manger = [RequestManager manager];
//    updateMyProfileFinishHandler handler = nil;
//    @synchronized(manger.delegateDictionary) {
//        handler = [manger.delegateDictionary objectForKey:@(requestId)];
//        [manger.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, rsModified, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)updateMyProfileWeight:(int)weight height:(int)height language:(int)language ethnicity:(int)ethnicity religion:(int)religion education:(int)education profession:(int)profession income:(int)income children:(int)children smoke:(int)smoke drink:(int)drink resume:(NSString *)resume interests:(NSArray *)interests zodiac:(int)zodiac finish:(updateMyProfileFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//
//    list<string> strList;
//    for (NSString *str in interests) {
//        const char *pStr = [str UTF8String];
//        strList.push_back(pStr);
//    }
//
//    string strResume = "";
//    if (nil != resume) {
//        strResume = [resume UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestProfileController->UpdateProfile(weight, height, language, ethnicity, religion, education, profession, income, children, smoke, drink, strResume, strList, zodiac);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onStartEditResume(long requestId, bool success, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::onStartEditResume( success : %s )", success ? "true" : "false");
//    RequestManager *manger = [RequestManager manager];
//    startEditResumeFinishHandler handler = nil;
//    @synchronized(manger.delegateDictionary) {
//        handler = [manger.delegateDictionary objectForKey:@(requestId)];
//        [manger.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)startEditResumeFinishHandler:(startEditResumeFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestProfileController->StartEditResume();
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onUploadHeaderPhoto(long reqeustId, bool success, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::onUploadHeaderPhoto( success : %s )", success ? "true" : "false");
//    RequestManager *manger = [RequestManager manager];
//    uploadHeaderPhotoFinishHandler handler = nil;
//    @synchronized(manger.delegateDictionary) {
//        handler = [manger.delegateDictionary objectForKey:@(reqeustId)];
//        [manger.delegateDictionary removeObjectForKey:@(reqeustId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)uploadHeaderPhoto:(NSString *)fileName finishHandler:(uploadHeaderPhotoFinishHandler)finishHandler {
//
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strFileName = "";
//    if (nil != fileName) {
//        strFileName = [fileName UTF8String];
//    }
//    requestId = mpLSLiveChatRequestProfileController->UploadHeaderPhoto(strFileName);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//#pragma mark - 女士模块
//void onQueryLadyList(long requestId, bool success, list<Lady> ladyList, int totalCount, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::::onQueryLadyList( success : %s )", success ? "true" : "false");
//    RequestManager *manager = [RequestManager manager];
//    onlineListFinishHandler handler = nil;
//    NSMutableArray *itemArray = [NSMutableArray array];
//    if (success) {
//        for (list<Lady>::iterator itr = ladyList.begin(); itr != ladyList.end(); itr++) {
//            Lady item = *itr;
//            QueryLadyListItemObject *obj = [[QueryLadyListItemObject alloc] init];
//            obj.age = item.age;
//            obj.womanid = [NSString stringWithUTF8String:item.womanid.c_str()];
//            obj.firstname = [NSString stringWithUTF8String:item.firstname.c_str()];
//            obj.weight = [NSString stringWithUTF8String:item.weight.c_str()];
//            obj.height = [NSString stringWithUTF8String:item.height.c_str()];
//            obj.country = [NSString stringWithUTF8String:item.country.c_str()];
//            obj.province = [NSString stringWithUTF8String:item.province.c_str()];
//            obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
//            obj.onlineStatus = item.onlineStatus;
//            obj.camStatus = item.camStatus;
//            obj.isFavorite = item.isFavorite;
//            obj.lastTime = 0;
//            [itemArray addObject:obj];
//        }
//    }
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, itemArray, totalCount, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
///**
// *  获取联系人列表接口
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)getQueryLadyListPageIndex:(int)pageIndex
//                              pageSize:(int)pageSize
//                            searchType:(int)searchType
//                               womanId:(NSString *)womanId
//                              isOnline:(int)isOnline
//                          ageRangeFrom:(int)ageRangeFrom
//                            ageRangeTo:(int)ageRangeTo
//                               country:(NSString *)country
//                               orderBy:(int)orderBy
//                            genderType:(LadyGenderType)genderType
//                         finishHandler:(onlineListFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strWomanId = "";
//    if (nil != womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    requestId = mpLSLiveChatRequestLadyController->QueryLadyList(pageIndex, pageSize, searchType, strWomanId, isOnline, ageRangeFrom, ageRangeTo, [country UTF8String], orderBy, [[UIDevice currentDevice].identifierForVendor.UUIDString UTF8String], genderType);
//    @synchronized(self.delegateDictionary) {
//        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//void onQueryLadyDetail(long requestId, bool success, LadyDetail item, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::::onQueryLadyDetail( success : %s )", success ? "true" : "false");
//    LadyDetailItemObject *obj = [[LadyDetailItemObject alloc] init];
//    NSMutableArray *thumbArray = [NSMutableArray array];
//    NSMutableArray *photoArray = [NSMutableArray array];
//    NSMutableArray *videoArray = [NSMutableArray array];
//    if (success) {
//        obj.womanid = [NSString stringWithUTF8String:item.womanid.c_str()];
//        obj.firstname = [NSString stringWithUTF8String:item.firstname.c_str()];
//        obj.country = [NSString stringWithUTF8String:item.country.c_str()];
//        obj.province = [NSString stringWithUTF8String:item.province.c_str()];
//        obj.birthday = [NSString stringWithUTF8String:item.birthday.c_str()];
//        obj.age = item.age;
//        obj.zodiac = [NSString stringWithUTF8String:item.zodiac.c_str()];
//        obj.weight = [NSString stringWithUTF8String:item.weight.c_str()];
//        obj.height = [NSString stringWithUTF8String:item.height.c_str()];
//        obj.smoke = [NSString stringWithUTF8String:item.smoke.c_str()];
//        obj.drink = [NSString stringWithUTF8String:item.drink.c_str()];
//        obj.english = [NSString stringWithUTF8String:item.english.c_str()];
//        obj.religion = [NSString stringWithUTF8String:item.religion.c_str()];
//        obj.education = [NSString stringWithUTF8String:item.education.c_str()];
//        obj.profession = [NSString stringWithUTF8String:item.profession.c_str()];
//        obj.children = [NSString stringWithUTF8String:item.children.c_str()];
//        obj.marry = [NSString stringWithUTF8String:item.marry.c_str()];
//        obj.resume = [NSString stringWithUTF8String:item.resume.c_str()];
//        obj.age1 = item.age1;
//        obj.age2 = item.age2;
//        obj.isonline = item.isonline;
//        obj.isFavorite = item.isfavorite;
//        obj.last_update = [NSString stringWithUTF8String:item.last_update.c_str()];
//        obj.show_lovecall = item.show_lovecall;
//        obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
//        obj.photoMinURL = [NSString stringWithUTF8String:item.photoMinURL.c_str()];
//
//        for (list<string>::iterator itr = item.thumbList.begin(); itr != item.thumbList.end(); itr++) {
//            [thumbArray addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        obj.thumbList = thumbArray;
//
//        for (list<string>::iterator itr = item.photoList.begin(); itr != item.photoList.end(); itr++) {
//            [photoArray addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        obj.photoList = photoArray;
//
//        for (list<VideoItem>::iterator itr = item.videoList.begin(); itr != item.videoList.end(); itr++) {
//            VideoItem item = *itr;
//            VideoItemObject *videoItem = [[VideoItemObject alloc] init];
//            videoItem.id = [NSString stringWithUTF8String:item.id.c_str()];
//            videoItem.thumb = [NSString stringWithUTF8String:item.thumb.c_str()];
//            videoItem.time = [NSString stringWithUTF8String:item.time.c_str()];
//            videoItem.photo = [NSString stringWithUTF8String:item.photo.c_str()];
//            [videoArray addObject:videoItem];
//        }
//        obj.videoList = videoArray;
//
//        obj.photoLockNum = item.photoLockNum;
//
//        obj.camStatus = item.camStatus;
//        //        obj.thumbList = item.thumbList;
//    }
//
//    LadyDetailFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, obj, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
///**
// *  获取指定人物的详情
// *
// *  @param womanId       女士的id
// *
// *
// *  @return 成功:有效Id/失败:无效Id
// */
//- (NSInteger)getLadyDetailWithWomanId:(NSString *)womanId finishHandler:(LadyDetailFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strWomanId = "";
//    if (nil != womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    requestId = mpLSLiveChatRequestLadyController->QueryLadyDetail(strWomanId);
//
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onAddFavouritesLady(long requestId, bool success, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::onAddFavouritesLady( success : %s )", success ? "true" : "false");
//    RequestManager *manger = [RequestManager manager];
//    addFavouritesLadyFinishHandler handler = nil;
//    @synchronized(manger.delegateDictionary) {
//        handler = [manger.delegateDictionary objectForKey:@(requestId)];
//        [manger.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
///**
// *  添加收藏女士
// *
// *  @param womanId       女士id
// *
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)addFavouritesLadyWithWomanId:(NSString *)womanId finishHandler:(addFavouritesLadyFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strWomanId = "";
//    if (nil != womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestLadyController->AddFavouritesLady(strWomanId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//void onRemoveFavouritesLady(long requestId, bool success, string errnum, string errmsg) {
//    RequestManager *manager = [RequestManager manager];
//    removeFavouritesLadyFinishHandler handler = nil;
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
///**
// *  移除收藏女士
// *
// *  @param womanId       女士id
// *
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)removeFavouritesLadyWithWomanId:(NSString *)womanId finishHandler:(removeFavouritesLadyFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strWomanId = "";
//    if (nil != womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    requestId = mpLSLiveChatRequestLadyController->RemoveFavouritesLady(strWomanId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onQueryLadyCall(long requestId, bool success, LadyCall item, string errnum, string errmsg) {
//    RequestManager *manager = [RequestManager manager];
//    QueryLadyCallFinishHandler handler = nil;
//
//    LadyCallItemObject *obj = [[LadyCallItemObject alloc] init];
//    obj.womanId = [NSString stringWithUTF8String:item.womanid.c_str()];
//    obj.lovecallId = [NSString stringWithUTF8String:item.lovecallid.c_str()];
//    obj.lc_centerNumber = [NSString stringWithUTF8String:item.lc_centernumber.c_str()];
//
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//
//- (NSInteger)queryLadyCall:(NSString *)womanId finishHandler:(QueryLadyCallFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    requestId = mpLSLiveChatRequestLadyController->QueryLadyCall(strWomanId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onRecentContact(long requestId, bool success, const string &errnum, const string &errmsg, const list<LadyRecentContact> &items) {
//    FileLog("httprequest", "RequestManager::onRecentContact( success : %s )", success ? "true" : "false");
//
//    NSMutableArray *array = [NSMutableArray array];
//    for (list<LadyRecentContact>::const_iterator itr = items.begin(); itr != items.end(); itr++) {
//        LadyRecentContactObject *obj = [[LadyRecentContactObject alloc] init];
//
//        obj.womanId = [NSString stringWithUTF8String:itr->womanId.c_str()];
//        obj.firstname = [NSString stringWithUTF8String:itr->firstname.c_str()];
//        obj.age = itr->age;
//        obj.photoURL = [NSString stringWithUTF8String:itr->photoURL.c_str()];
//        obj.photoBigURL = [NSString stringWithUTF8String:itr->photoBigURL.c_str()];
//        obj.isFavorite = itr->isFavorite;
//        obj.videoCount = itr->videoCount;
//        obj.lasttime = itr->lasttime;
//
//        [array addObject:obj];
//    }
//
//    RecentContactListFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, array, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
///**
// *  获取最近联系人接口
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)getRecentContactList:(RecentContactListFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//
//    requestId = mpLSLiveChatRequestLadyController->RecentContactList();
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//void onRemoveContactList(long requestId, bool success, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::onRemoveContactList( success : %s )", success ? "true" : "false");
//    RequestManager *manger = [RequestManager manager];
//    removeContactLishFinishHandler handler = nil;
//    @synchronized(manger.delegateDictionary) {
//        handler = [manger.delegateDictionary objectForKey:@(requestId)];
//        [manger.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
///**
// *  移除联系人列表
// *
// *  @param womanIdArray  女士Id数组
// *
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)removeContactListWithWomanId:(NSArray *)womanIdArray finishHandler:(removeContactLishFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//
//    list<string> womanIdList;
//    for (NSString *womanId in womanIdArray) {
//        womanIdList.push_back([womanId UTF8String]);
//    }
//
//    requestId = mpLSLiveChatRequestLadyController->RemoveContactList(womanIdList);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onReportLady(long requestId, bool success, const string &errnum, const string &errmsg) {
//    FileLog("httprequest", "RequestManager::onReportLady( success : %s )", success ? "true" : "false");
//    RequestManager *manger = [RequestManager manager];
//    reportLadyFinishHandler handler = nil;
//    @synchronized(manger.delegateDictionary) {
//        handler = [manger.delegateDictionary objectForKey:@(requestId)];
//        [manger.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
///**
// *  举报女士
// *
// *  @param womanId       女士ID
// *
// *  @return 成功:请求Id/失败:无效Id
// */
//- (NSInteger)reportLady:(NSString *)womanId finishHandler:(reportLadyFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strWomanId = "";
//    if (nil != womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    requestId = mpLSLiveChatRequestLadyController->ReportLady(strWomanId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//
//void onGetFavoriteList(long requestId, bool success, const string& errnum, const string& errmsg, list<FavoriteItem>& favList, int totalCount) {
//    FileLog("httprequest", "RequestManager::::onGetFavoriteList( success : %s )", success ? "true" : "false");
//    RequestManager *manager = [RequestManager manager];
//    GetFavoriteListFinishHandler handler = nil;
//    NSMutableArray *itemArray = [NSMutableArray array];
//    if (success) {
//        for (list<FavoriteItem>::iterator itr = favList.begin(); itr != favList.end(); itr++) {
//            FavoriteItem item = *itr;
//            QueryLadyListItemObject *obj = [[QueryLadyListItemObject alloc] init];
//            obj.age = item.age;
//            obj.womanid = [NSString stringWithUTF8String:item.womanId.c_str()];
//            obj.firstname = [NSString stringWithUTF8String:item.firstName.c_str()];
//            obj.weight = 0;
//            obj.height = 0;
//            obj.country = @"";
//            obj.province = @"";
//            obj.photoURL = [NSString stringWithUTF8String:item.photoUrl.c_str()];
//            LadyOnlineStatus onlineStatus = LADY_OFFLINE;
//            if (item.isOnline) {
//                onlineStatus = LADY_ONLINE;
//            }
//            obj.onlineStatus = onlineStatus;
//            obj.camStatus = item.camStatus;
//            obj.isFavorite = YES;
//            obj.lastTime = item.lastTime;
//            [itemArray addObject:obj];
//        }
//    }
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], itemArray, totalCount);
//    }
//}
//
//- (NSInteger)getFavoriteList:(int)pageIndex
//                    pageSize:(int)pageSize
//                     womanId:(NSString *)womanId
//                  onLineType:(FindLadyOnLineType)onLineType
//               finishHandler:(GetFavoriteListFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strWomanId = "";
//    if (nil != womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestLadyController->GetFavoriteList(pageIndex, pageSize, strWomanId, onLineType);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}

#pragma mark - 其他模块
//void LSLiveChatRequestOtherControllerCallback::OnSynConfig(long requestId, bool success, const string &errnum, const string &errmsg, const OtherSynConfigItem &item) {
//    FileLog("httprequest", "RequestManager::OnSynConfig( success : %s )", success ? "true" : "false");
//
//    SynConfigItemObject *obj = [[SynConfigItemObject alloc] init];
//    if (success) {
//        // 公共配置
//        PublicItemObject *pub = [[PublicItemObject alloc] init];
//        pub.vgVer = item.pub.vgVer;
//        pub.apkVerCode = item.pub.apkVerCode;
//        pub.apkVerName = [NSString stringWithUTF8String:item.pub.apkVerName.c_str()];
//        pub.apkForceUpdate = item.pub.apkForceUpdate;
//        pub.facebook_enable = item.pub.facebook_enable;
//        pub.apkFileVerify = [NSString stringWithUTF8String:item.pub.apkFileVerify.c_str()];
//        pub.apkVerURL = [NSString stringWithUTF8String:item.pub.apkStoreURL.c_str()];
//        pub.apkStoreURL = [NSString stringWithUTF8String:item.pub.apkStoreURL.c_str()];
//        pub.chatVoiceHostUrl = [NSString stringWithUTF8String:item.pub.chatVoiceHostUrl.c_str()];
//        pub.addCreditsUrl = [NSString stringWithUTF8String:item.pub.addCreditsUrl.c_str()];
//        pub.addCredits2Url = [NSString stringWithUTF8String:item.pub.addCredits2Url.c_str()];
//        pub.iOSVerCode = item.pub.iOSVerCode;
//        pub.iOSVerName = [NSString stringWithUTF8String:item.pub.iOSVerName.c_str()];
//        pub.iOSForceUpdate = item.pub.iOSForceUpdate;
//        pub.iOSStoreUrl = [NSString stringWithUTF8String:item.pub.iOSStoreUrl.c_str()];
//        obj.pub = pub;
//
//        NSMutableArray *proxyHostList;
//        NSMutableArray *countryList;
//
//        // CL站点
//        SiteItemObject *cl = [[SiteItemObject alloc] init];
//        cl.host = [NSString stringWithUTF8String:item.cl.host.c_str()];
//        cl.domain = [NSString stringWithUTF8String:item.cl.domain.c_str()];
//        proxyHostList = [NSMutableArray array];
//        for (OtherSynConfigItem::ProxyHostList::const_iterator itr = item.cl.proxyHostList.begin(); itr != item.cl.proxyHostList.end(); itr++) {
//            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        cl.proxyHostList = proxyHostList;
//        cl.port = item.cl.port;
//        cl.camshareHost = [NSString stringWithUTF8String:item.cl.camshareHost.c_str()];
//        cl.minChat = item.cl.minChat;
//        cl.minCamshare = item.cl.minCamshare;
//        cl.minEmf = item.cl.minEmf;
//        countryList = [NSMutableArray array];
//        for (OtherSynConfigItem::ProxyHostList::const_iterator itr = item.cl.countryList.begin(); itr != item.cl.countryList.end(); itr++) {
//            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        cl.countryList = countryList;
//        cl.camshareHeartCycle = item.cl.camshareHeartCycle;
//        cl.liveHost = [NSString stringWithUTF8String:item.cl.liveHost.c_str()];
//        cl.iOSVerCode = item.cl.iOSVerCode;
//        cl.iOSVerName = [NSString stringWithUTF8String:item.cl.iOSVerName.c_str()];
//        cl.iOSForceUpdate = item.cl.iOSForceUpdate;
//        cl.iOSStoreUrl = [NSString stringWithUTF8String:item.cl.iOSStoreUrl.c_str()];
//        obj.cl = cl;
//
//        // IDA站点
//        SiteItemObject *ida = [[SiteItemObject alloc] init];
//        ida.host = [NSString stringWithUTF8String:item.ida.host.c_str()];
//        ida.domain = [NSString stringWithUTF8String:item.ida.domain.c_str()];
//        proxyHostList = [NSMutableArray array];
//        for (OtherSynConfigItem::ProxyHostList::const_iterator itr = item.ida.proxyHostList.begin(); itr != item.ida.proxyHostList.end(); itr++) {
//            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        ida.proxyHostList = proxyHostList;
//        ida.port = item.ida.port;
//        ida.camshareHost = [NSString stringWithUTF8String:item.ida.camshareHost.c_str()];
//        ida.minChat = item.ida.minChat;
//        ida.minCamshare = item.ida.minCamshare;
//        ida.minEmf = item.ida.minEmf;
//        countryList = [NSMutableArray array];
//        for (OtherSynConfigItem::ProxyHostList::const_iterator itr = item.ida.countryList.begin(); itr != item.ida.countryList.end(); itr++) {
//            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        ida.countryList = countryList;
//        ida.camshareHeartCycle = item.ida.camshareHeartCycle;
//        ida.liveHost = [NSString stringWithUTF8String:item.ida.liveHost.c_str()];
//        ida.iOSVerCode = item.ida.iOSVerCode;
//        ida.iOSVerName = [NSString stringWithUTF8String:item.ida.iOSVerName.c_str()];
//        ida.iOSForceUpdate = item.ida.iOSForceUpdate;
//        ida.iOSStoreUrl = [NSString stringWithUTF8String:item.ida.iOSStoreUrl.c_str()];
//        obj.ida = ida;
//
//        // CH站点
//        SiteItemObject *ch = [[SiteItemObject alloc] init];
//        ch.host = [NSString stringWithUTF8String:item.ch.host.c_str()];
//        ch.domain = [NSString stringWithUTF8String:item.ch.domain.c_str()];
//        proxyHostList = [NSMutableArray array];
//        for (OtherSynConfigItem::ProxyHostList::const_iterator itr = item.ch.proxyHostList.begin(); itr != item.ch.proxyHostList.end(); itr++) {
//            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        ch.proxyHostList = proxyHostList;
//        ch.port = item.ch.port;
//        ch.camshareHost = [NSString stringWithUTF8String:item.ch.camshareHost.c_str()];
//        ch.minChat = item.ch.minChat;
//        ch.minCamshare = item.ch.minCamshare;
//        ch.minEmf = item.ch.minEmf;
//        countryList = [NSMutableArray array];
//        for (OtherSynConfigItem::ProxyHostList::const_iterator itr = item.ch.countryList.begin(); itr != item.ch.countryList.end(); itr++) {
//            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        ch.countryList = countryList;
//        ch.camshareHeartCycle = item.ch.camshareHeartCycle;
//        ch.liveHost = [NSString stringWithUTF8String:item.ch.liveHost.c_str()];
//        ch.iOSVerCode = item.ch.iOSVerCode;
//        ch.iOSVerName = [NSString stringWithUTF8String:item.ch.iOSVerName.c_str()];
//        ch.iOSForceUpdate = item.ch.iOSForceUpdate;
//        ch.iOSStoreUrl = [NSString stringWithUTF8String:item.ch.iOSStoreUrl.c_str()];
//        obj.ch = ch;
//
//        // LA站点
//        SiteItemObject *la = [[SiteItemObject alloc] init];
//        la.host = [NSString stringWithUTF8String:item.la.host.c_str()];
//        la.domain = [NSString stringWithUTF8String:item.la.domain.c_str()];
//        proxyHostList = [NSMutableArray array];
//        for (OtherSynConfigItem::ProxyHostList::const_iterator itr = item.la.proxyHostList.begin(); itr != item.la.proxyHostList.end(); itr++) {
//            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        la.proxyHostList = proxyHostList;
//        la.port = item.la.port;
//        la.camshareHost = [NSString stringWithUTF8String:item.la.camshareHost.c_str()];
//        la.minChat = item.la.minChat;
//        la.minCamshare = item.la.minCamshare;
//        la.minEmf = item.la.minEmf;
//        countryList = [NSMutableArray array];
//        for (OtherSynConfigItem::ProxyHostList::const_iterator itr = item.la.countryList.begin(); itr != item.la.countryList.end(); itr++) {
//            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        la.countryList = countryList;
//        la.camshareHeartCycle = item.la.camshareHeartCycle;
//        la.liveHost = [NSString stringWithUTF8String:item.la.liveHost.c_str()];
//        la.iOSVerCode = item.la.iOSVerCode;
//        la.iOSVerName = [NSString stringWithUTF8String:item.la.iOSVerName.c_str()];
//        la.iOSForceUpdate = item.la.iOSForceUpdate;
//        la.iOSStoreUrl = [NSString stringWithUTF8String:item.la.iOSStoreUrl.c_str()];
//        obj.la = la;
//
//        // AD站点
//        SiteItemObject *ad = [[SiteItemObject alloc] init];
//        ad.host = [NSString stringWithUTF8String:item.ad.host.c_str()];
//        ad.domain = [NSString stringWithUTF8String:item.ad.domain.c_str()];
//        proxyHostList = [NSMutableArray array];
//        for (OtherSynConfigItem::ProxyHostList::const_iterator itr = item.ad.proxyHostList.begin(); itr != item.ad.proxyHostList.end(); itr++) {
//            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        ad.proxyHostList = proxyHostList;
//        ad.port = item.ad.port;
//        ad.camshareHost = [NSString stringWithUTF8String:item.ad.camshareHost.c_str()];
//        ad.minChat = item.ad.minChat;
//        ad.minCamshare = item.ad.minCamshare;
//        ad.minEmf = item.ad.minEmf;
//        countryList = [NSMutableArray array];
//        for (OtherSynConfigItem::ProxyHostList::const_iterator itr = item.ad.countryList.begin(); itr != item.ad.countryList.end(); itr++) {
//            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
//        }
//        ad.countryList = countryList;
//        ad.camshareHeartCycle = item.ad.camshareHeartCycle;
//        ad.liveHost = [NSString stringWithUTF8String:item.ad.liveHost.c_str()];
//        ad.iOSVerCode = item.ad.iOSVerCode;
//        ad.iOSVerName = [NSString stringWithUTF8String:item.ad.iOSVerName.c_str()];
//        ad.iOSForceUpdate = item.ad.iOSForceUpdate;
//        ad.iOSStoreUrl = [NSString stringWithUTF8String:item.ad.iOSStoreUrl.c_str()];
//        obj.ad = ad;
//    }
//
//    SynConfigFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, obj, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)synConfig:(SynConfigFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//
//    requestId = mpLSLiveChatRequestOtherController->SynConfig();
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}

void LSLiveChatRequestOtherControllerCallback::OnGetCount(long requestId, bool success, const string &errnum, const string &errmsg, const LSLCOtherGetCountItem &item) {
    FileLog("httprequest", "RequestManager::OnGetCount( success : %s )", success ? "true" : "false");

    LSLCOtherGetCountItemObject *obj = [[LSLCOtherGetCountItemObject alloc] init];
    if (success) {
        obj.money = item.money;
        obj.coupon = item.coupon;
        obj.integral = item.integral;
        obj.regstep = item.regstep;
        obj.allowAlbum = item.allowAlbum;
        obj.admirerUr = item.admirerUr;
    }

    GetCountFinishHandler handler = nil;
    LSLiveChatRequestManager *manager = [LSLiveChatRequestManager manager];
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
    }

    if (handler) {
        handler(success, obj, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
    }
}

- (NSInteger)getCount:(GetCountFinishHandler)finishHandler {
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;

    requestId = mpLSLiveChatRequestOtherController->GetCount(true, true, true, true, true, true);
    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
    }

    return requestId;
}

//void LSLiveChatRequestOtherControllerCallback::OnPhoneInfo(long requestId, bool success, const string &errnum, const string &errmsg) {
//    FileLog("httprequest", "RequestManager::OnPhoneInfo( success : %s )", success ? "true" : "false");
//    PhoneInfoFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)phoneInfo:(PhoneInfoObject *)phoneInfo finishHandler:(PhoneInfoFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//
//    requestId = mpLSLiveChatRequestOtherController->PhoneInfo([phoneInfo.manId UTF8String], phoneInfo.verCode, [phoneInfo.verName UTF8String], phoneInfo.action, phoneInfo.siteId, phoneInfo.density, phoneInfo.width, phoneInfo.height, [phoneInfo.densityDpi UTF8String], [phoneInfo.model UTF8String], [phoneInfo.manufacturer UTF8String], [phoneInfo.osType UTF8String], [phoneInfo.releaseVer UTF8String], [phoneInfo.sdk UTF8String], [phoneInfo.language UTF8String], [phoneInfo.country UTF8String], [phoneInfo.lineNumber UTF8String], [phoneInfo.simOptName UTF8String], [phoneInfo.simOpt UTF8String], [phoneInfo.simCountryIso UTF8String], [phoneInfo.simState UTF8String], phoneInfo.phoneType, phoneInfo.networkType, [phoneInfo.deviceId UTF8String]);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//void LSLiveChatRequestOtherControllerCallback::OnIntegralCheck(long requestId, bool success, const string &errnum, const string &errmsg, const OtherIntegralCheckItem &item) {
//    FileLog("httprequest", "RequestManager::OnGetCount( success : %s )", success ? "true" : "false");
//
//    int integral = 0;
//    if (success) {
//        integral = item.integral;
//    }
//
//    CheckIntegralFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, integral, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)checkIntegral:(NSString *)womanId finishHandler:(CheckIntegralFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strWomanId = "";
//    if (nil != womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    requestId = mpLSLiveChatRequestOtherController->IntegralCheck(strWomanId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//
//void LSLiveChatRequestOtherControllerCallback::OnVersionCheck(long requestId, bool success, const string &errnum, const string &errmsg, const OtherVersionCheckItem &item) {
//    FileLog("httprequest", "RequestManager::OnVersionCheck( success : %s )", success ? "true" : "false");
//
//    VersionItemObject *obj = [[VersionItemObject alloc] init];
//    if (success) {
//        obj.versionCode = item.versionCode;
//        obj.versionName = [NSString stringWithUTF8String:item.versionName.c_str()];
//        obj.versionDesc = [NSString stringWithUTF8String:item.versionDesc.c_str()];
//        obj.isForceUpdate = item.isForceUpdate;
//        obj.url = [NSString stringWithUTF8String:item.url.c_str()];
//        obj.storeUrl = [NSString stringWithUTF8String:item.storeUrl.c_str()];
//        obj.pubTime = [NSString stringWithUTF8String:item.pubTime.c_str()];
//        obj.checkTime = item.checkTime;
//    }
//    VersionCheckFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//
//- (NSInteger)versionCheck:(int)currVersion
//                    appId:(NSString * _Nonnull)appId
//            finishHandler:(VersionCheckFinishHandler _Nullable)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strAppId = "";
//    if (nil != appId) {
//        strAppId = [appId UTF8String];
//    }
//    requestId = mpLSLiveChatRequestOtherController->VersionCheck(currVersion, strAppId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//void LSLiveChatRequestOtherControllerCallback::OnUploadCrashLog(long requestId, bool success, const string &errnum, const string &errmsg) {
//    FileLog("httprequest", "RequestManager::OnUploadCrashLog( success : %s )", success ? "true" : "false");
//    UploadCrashLogFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)uploadCrashLogWithFile:(NSString *)file tmpDirectory:(NSString *)tmpDirectory finishHandler:(UploadCrashLogFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//
//    // create zip
//    KZip zip;
//    NSString *comment = @"";
//    //    NSArray *zipPassword = @[@0x51, @0x70, @0x69, @0x64, @0x5F, @0x44, @0x61, @0x74, @0x69, @0x6E, @0x67, @0x00];
//    //压缩的密码
//    const char password[] = {
//        0x51, 0x70, 0x69, 0x64, 0x5F, 0x44, 0x61, 0x74, 0x69, 0x6E, 0x67, 0x00};
//    char pZipFileName[1024] = {'\0'};
//
//    //压缩文件名称
//    NSDate *curDate = [NSDate date];
//
//    snprintf(pZipFileName, sizeof(pZipFileName), "%s/crash-%s.zip",
//             [tmpDirectory UTF8String], [[curDate toStringCrashZipDate] UTF8String]);
//
//    string strFile = "";
//    if (nil != file) {
//        strFile = [file UTF8String];
//    }
//    string strComment = "";
//    if (nil != comment) {
//        strComment = [comment UTF8String];
//    }
//    //创建压缩文件
//    BOOL bFlag = zip.CreateZipFromDir(strFile, pZipFileName, password, strComment);
//    //压缩成功执行上传压缩文件到服务器
//    if (bFlag) {
//        requestId = mpLSLiveChatRequestOtherController->UploadCrashLog([[self getDeviceId] UTF8String], pZipFileName);
//        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//            @synchronized(self.delegateDictionary) {
//                [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//            }
//        }
//    }
//
//    return requestId;
//}
//
//void LSLiveChatRequestOtherControllerCallback::OnInstallLogs(long requestId, bool success, const string &errnum, const string &errmsg) {
//    FileLog("httprequest", "RequestManager::OnInstallLogs( success : %s )", success ? "true" : "false");
//    InstallLogsFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)installLog:(InstallLogObject *)installLog finishHandler:(InstallLogsFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestOtherController->InstallLogs([installLog.deviceId UTF8String], installLog.installTime, installLog.submitTime, installLog.verCode, [installLog.model UTF8String], [installLog.manufacturer UTF8String], [installLog.osType UTF8String], [installLog.releaseVer UTF8String], [installLog.sdk UTF8String], installLog.width, installLog.height, "", false, "");
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//#pragma mark - 支付
//void onGetPaymentOrder(long requestId, bool success, const string &code, const string &orderNo, const string &productId) {
//    GetPaymentOrderFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:code.c_str()], [NSString stringWithUTF8String:orderNo.c_str()], [NSString stringWithUTF8String:productId.c_str()]);
//    }
//}
//
//- (NSInteger)getPaymentOrder:(NSString *)manId sid:(NSString *)sid number:(NSString *)number finishHandler:(GetPaymentOrderFinishHandler)finishHandler {
//
//    string pManId = "";
//    if (nil != manId) {
//        pManId = [manId UTF8String];
//    }
//
//    string pSid = "";
//    if (nil != sid) {
//        pSid = [sid UTF8String];
//    }
//
//    string pNumber = "";
//    if (nil != number) {
//        pNumber = [number UTF8String];
//    }
//
//    NSInteger requestId = mpLSLiveChatRequestPaidController->GetPaymentOrder(pManId, pSid, pNumber);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//void onCheckPayment(long requestId, bool success, const string &code) {
//    CheckPaymentFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:code.c_str()]);
//    }
//}
//
//- (NSInteger)checkPayment:(NSString *)manId sid:(NSString *)sid receipt:(NSString *)receipt orderNo:(NSString *)orderNo code:(NSInteger)code finishHandler:(CheckPaymentFinishHandler)finishHandler {
//    string pManId = "";
//    if (nil != manId) {
//        pManId = [manId UTF8String];
//    }
//
//    string pSid = "";
//    if (nil != sid) {
//        pSid = [sid UTF8String];
//    }
//
//    string pReceipt = "";
//    if (nil != receipt) {
//        pReceipt = [receipt UTF8String];
//    }
//
//    string pOrderNo = "";
//    if (nil != orderNo) {
//        pOrderNo = [orderNo UTF8String];
//    }
//
//    int iCode = (int)code;
//    NSInteger requestId = mpLSLiveChatRequestPaidController->CheckPayment(pManId, pSid, pReceipt, pOrderNo, iCode);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//#pragma mark - 月费
//void onQueryMemberType(long requestId, bool success, string errnum, string errmsg, int memberType, string mfeeEndDate) {
//    GetQueryMemberTypeFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], memberType);
//    }
//}
//
//- (NSInteger)getQueryMemberType:(GetQueryMemberTypeFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestMonthlyFeeController->QueryMemberType();
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//void onGetMonthlyFeeTips(long requestId, bool success, string errnum, string errmsg, list<MonthlyFeeTip> tipsList) {
//    NSMutableArray *strArray = [NSMutableArray array];
//    NSMutableArray *itemArray = [NSMutableArray array];
//    for (list<MonthlyFeeTip>::const_iterator iter = tipsList.begin();
//         iter != tipsList.end();
//         iter++) {
//        MonthlyFeeTipItemObject *obj = [[MonthlyFeeTipItemObject alloc] init];
//        obj.menberType = iter->memberType;
//        obj.priceTitle = [NSString stringWithUTF8String:iter->priceTilte.c_str()];
//
//        for (list<string>::const_iterator iterStr = iter->tipList.begin();
//             iterStr != iter->tipList.end();
//             iter++) {
//            NSString *str = [NSString stringWithUTF8String:(*iterStr).c_str()];
//            [strArray addObject:str];
//        }
//        obj.tipArray = strArray;
//        [itemArray addObject:obj];
//    }
//
//    GetMonthlyFeeTipsFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], itemArray);
//    }
//}
//
//- (NSInteger)getMonthlyFee:(GetMonthlyFeeTipsFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestMonthlyFeeController->GetMonthlyFeeTips();
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//void onGetPremiumMemberShip(long requestId, bool success, string errnum, string errmsg, MonthlyFeeInstructionItem item) {
//
//    NSMutableArray *itemArray = [NSMutableArray array];
//    PremiumMemberShipItemObject *obj = [[PremiumMemberShipItemObject alloc] init];
//    obj.title = [NSString stringWithUTF8String:item.title.c_str()];
//    obj.subtitle = [NSString stringWithUTF8String:item.subtitle.c_str()];
//    obj.desc = [NSString stringWithUTF8String:item.desc.c_str()];
//    obj.more = [NSString stringWithUTF8String:item.more.c_str()];
//    for (ProductItemList::const_iterator iterStr = item.productList.begin();
//         iterStr != item.productList.end();
//         iterStr++) {
//        ProductItemObject *productItem = [[ProductItemObject alloc] init];
//        productItem.productId = [NSString stringWithUTF8String:(*iterStr).productId.c_str()];
//        productItem.name = [NSString stringWithUTF8String:(*iterStr).productName.c_str()];
//        productItem.price = [NSString stringWithUTF8String:(*iterStr).productPrice.c_str()];
//        [itemArray addObject:productItem];
//    }
//    obj.productList = itemArray;
//
//    GetPremiumMemberShipFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//
//- (NSInteger)getPremiumMemberShip:(GetPremiumMemberShipFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestMonthlyFeeController->GetPremiumMemberShip();
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//#pragma mark - EMF回调
//void onRequestEMFInboxList(long requestId, bool success, const string &errnum, const string &errmsg, int pageIndex, int pageSize, int dataCount, const EMFInboxList &inboxList) {
//    NSMutableArray *itemArray = [NSMutableArray array];
//    EMFInboxListItemObject *obj = [[EMFInboxListItemObject alloc] init];
//    obj.pageIndex = pageIndex;
//    obj.pageSize = pageSize;
//    obj.dataCount = dataCount;
//    for (EMFInboxList::const_iterator iterStr = inboxList.begin();
//         iterStr != inboxList.end();
//         iterStr++) {
//        EMFInboxItemObject *emfMailItem = [[EMFInboxItemObject alloc] init];
//        emfMailItem.mailId = [NSString stringWithUTF8String:(*iterStr).id.c_str()];
//        emfMailItem.attachNum = (*iterStr).attachnum;
//        emfMailItem.shortVideo = (*iterStr).shortVideo;
//        emfMailItem.virtual_gifts = (*iterStr).virtual_gifts;
//        emfMailItem.womanId = [NSString stringWithUTF8String:(*iterStr).womanid.c_str()];
//        emfMailItem.readFlag = (*iterStr).readflag;
//        emfMailItem.rFlag = (*iterStr).rflag;
//        emfMailItem.fFlag = (*iterStr).fflag;
//        emfMailItem.pFlag = (*iterStr).pflag;
//        emfMailItem.firstName = [NSString stringWithUTF8String:(*iterStr).firstname.c_str()];
//        emfMailItem.lastName = [NSString stringWithUTF8String:(*iterStr).lastname.c_str()];
//        emfMailItem.weight = [NSString stringWithUTF8String:(*iterStr).weight.c_str()];
//        emfMailItem.height = [NSString stringWithUTF8String:(*iterStr).height.c_str()];
//        emfMailItem.country = [NSString stringWithUTF8String:(*iterStr).country.c_str()];
//        emfMailItem.province = [NSString stringWithUTF8String:(*iterStr).province.c_str()];
//        emfMailItem.age = (*iterStr).age;
//        emfMailItem.isOnlineStatus = (*iterStr).online_status == 1 ? YES : NO;
//        emfMailItem.isCam = (*iterStr).camStatus == 0 ? NO : YES;
//        emfMailItem.sendTime = [NSString stringWithUTF8String:(*iterStr).sendTime.c_str()];
//        emfMailItem.photoURL = [NSString stringWithUTF8String:(*iterStr).photoURL.c_str()];
//        emfMailItem.intro = [NSString stringWithUTF8String:(*iterStr).intro.c_str()];
//        emfMailItem.vgId = [NSString stringWithUTF8String:(*iterStr).vgId.c_str()];
//        [itemArray addObject:emfMailItem];
//    }
//    obj.datalist = itemArray;
//
//    GetEMFInboxListFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//void onRequestEMFInboxMsg(long requestId, bool success, const string &errnum, const string &errmsg, int memberType, const EMFInboxMsgItem &item) {
//    NSMutableArray *photoRULItemArray = [NSMutableArray array];
//    NSMutableArray *privatePhotoItemArray = [NSMutableArray array];
//    NSMutableArray *shortVideoItemArray = [NSMutableArray array];
//    EMFInboxMsgItemObject *obj = [[EMFInboxMsgItemObject alloc] init];
//    obj.mailId = [NSString stringWithUTF8String:item.id.c_str()];
//    obj.womanId = [NSString stringWithUTF8String:item.womanid.c_str()];
//    obj.firstName = [NSString stringWithUTF8String:item.firstname.c_str()];
//    obj.lastName = [NSString stringWithUTF8String:item.lastname.c_str()];
//    obj.weight = [NSString stringWithUTF8String:item.weight.c_str()];
//    obj.height = [NSString stringWithUTF8String:item.height.c_str()];
//    obj.country = [NSString stringWithUTF8String:item.country.c_str()];
//    obj.province = [NSString stringWithUTF8String:item.province.c_str()];
//    obj.age = item.age;
//    obj.isOnlineStatus = item.online_status == 1 ? YES : NO;
//    obj.isCam = item.camStatus == 0 ? NO : YES;
//    obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
//    obj.body = [NSString stringWithUTF8String:item.body.c_str()];
//    obj.notetoman = [NSString stringWithUTF8String:item.notetoman.c_str()];
//    obj.sendTime = [NSString stringWithUTF8String:item.sendTime.c_str()];
//    obj.vgId = [NSString stringWithUTF8String:item.vgId.c_str()];
//
//    for (EMFPhotoUrlList::const_iterator iterStr = item.photosURL.begin();
//         iterStr != item.photosURL.end();
//         iterStr++) {
//        NSString *photoURLItem = [NSString stringWithUTF8String:(*iterStr).c_str()];
//        [photoRULItemArray addObject:photoURLItem];
//    }
//    obj.photoUrlList = photoRULItemArray;
//
//    for (EMFPrivatePhotoList::const_iterator iterStr = item.privatePhotoList.begin();
//         iterStr != item.privatePhotoList.end();
//         iterStr++) {
//        EMFPrivatePhotoItemObject *privatePhotoItem = [[EMFPrivatePhotoItemObject alloc] init];
//        privatePhotoItem.sendId = [NSString stringWithUTF8String:(*iterStr).sendId.c_str()];
//        privatePhotoItem.photoId = [NSString stringWithUTF8String:(*iterStr).photoId.c_str()];
//        privatePhotoItem.photoFee = (*iterStr).photoFee;
//        privatePhotoItem.photoDesc = [NSString stringWithUTF8String:(*iterStr).photoDesc.c_str()];
//        [privatePhotoItemArray addObject:privatePhotoItem];
//    }
//    obj.privatePhotoList = privatePhotoItemArray;
//
//    for (EMFShortVideoList::const_iterator iterStr = item.shortVideoList.begin();
//         iterStr != item.shortVideoList.end();
//         iterStr++) {
//        EMFShortVideoItemObject *shortVideoItem = [[EMFShortVideoItemObject alloc] init];
//        shortVideoItem.sendId = [NSString stringWithUTF8String:(*iterStr).sendId.c_str()];
//        shortVideoItem.videoId = [NSString stringWithUTF8String:(*iterStr).videoId.c_str()];
//        shortVideoItem.videoFee = (*iterStr).videoFee;
//        shortVideoItem.videoDesc = [NSString stringWithUTF8String:(*iterStr).videoDesc.c_str()];
//
//        [shortVideoItemArray addObject:shortVideoItem];
//    }
//    obj.shortVideoList = shortVideoItemArray;
//
//    GetEMFInboxMsgFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], memberType, obj);
//    }
//}
//void onRequestEMFOutboxList(long requestId, bool success, const string &errnum, const string &errmsg, int pageIndex, int pageSize, int dataCount, const EMFOutboxList &outboxList) {
//    NSMutableArray *itemArray = [NSMutableArray array];
//    EMFOutboxListItemObject *obj = [[EMFOutboxListItemObject alloc] init];
//    obj.pageIndex = pageIndex;
//    obj.pageSize = pageSize;
//    obj.dataCount = dataCount;
//    for (EMFOutboxList::const_iterator iterStr = outboxList.begin();
//         iterStr != outboxList.end();
//         iterStr++) {
//        EMFOutboxItemObject *emfMailItem = [[EMFOutboxItemObject alloc] init];
//        emfMailItem.mailId = [NSString stringWithUTF8String:(*iterStr).id.c_str()];
//        emfMailItem.attachNum = (*iterStr).attachnum;
//        emfMailItem.virtual_gifts = (*iterStr).virtual_gifts;
//        emfMailItem.progress = (*iterStr).progress;
//        emfMailItem.womanId = [NSString stringWithUTF8String:(*iterStr).womanid.c_str()];
//        emfMailItem.firstName = [NSString stringWithUTF8String:(*iterStr).firstname.c_str()];
//        emfMailItem.lastName = [NSString stringWithUTF8String:(*iterStr).lastname.c_str()];
//        emfMailItem.weight = [NSString stringWithUTF8String:(*iterStr).weight.c_str()];
//        emfMailItem.height = [NSString stringWithUTF8String:(*iterStr).height.c_str()];
//        emfMailItem.country = [NSString stringWithUTF8String:(*iterStr).country.c_str()];
//        emfMailItem.province = [NSString stringWithUTF8String:(*iterStr).province.c_str()];
//        emfMailItem.age = (*iterStr).age;
//        emfMailItem.isOnlineStatus = (*iterStr).online_status == 1 ? YES : NO;
//        emfMailItem.isCam = (*iterStr).camStatus == 0 ? NO : YES;
//        emfMailItem.sendTime = [NSString stringWithUTF8String:(*iterStr).sendTime.c_str()];
//        emfMailItem.photoURL = [NSString stringWithUTF8String:(*iterStr).photoURL.c_str()];
//        emfMailItem.intro = [NSString stringWithUTF8String:(*iterStr).intro.c_str()];
//        [itemArray addObject:emfMailItem];
//    }
//    obj.datalist = itemArray;
//
//    GetEMFOutboxListFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//void onRequestEMFOutboxMsg(long requestId, bool success, const string &errnum, const string &errmsg, const EMFOutboxMsgItem &item) {
//    NSMutableArray *photoRULItemArray = [NSMutableArray array];
//    NSMutableArray *privatePhotoItemArray = [NSMutableArray array];
//    EMFOutboxMsgItemObject *obj = [[EMFOutboxMsgItemObject alloc] init];
//    obj.mailId = [NSString stringWithUTF8String:item.id.c_str()];
//    obj.vgId = [NSString stringWithUTF8String:item.vgId.c_str()];
//    obj.content = [NSString stringWithUTF8String:item.content.c_str()];
//    obj.sendTime = [NSString stringWithUTF8String:item.sendTime.c_str()];
//    obj.womanId = [NSString stringWithUTF8String:item.womanid.c_str()];
//    obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
//    obj.firstName = [NSString stringWithUTF8String:item.firstname.c_str()];
//    obj.lastName = [NSString stringWithUTF8String:item.lastname.c_str()];
//    obj.weight = [NSString stringWithUTF8String:item.weight.c_str()];
//    obj.height = [NSString stringWithUTF8String:item.height.c_str()];
//    obj.country = [NSString stringWithUTF8String:item.country.c_str()];
//    obj.province = [NSString stringWithUTF8String:item.province.c_str()];
//    obj.age = item.age;
//    obj.isOnlineStatus = item.online_status == 1 ? YES : NO;
//    obj.isCam = item.camStatus == 0 ? NO : YES;
//
//    for (EMFPhotoUrlList::const_iterator iterStr = item.photosURL.begin();
//         iterStr != item.photosURL.end();
//         iterStr++) {
//        NSString *photoURLItem = [NSString stringWithUTF8String:(*iterStr).c_str()];
//        [photoRULItemArray addObject:photoURLItem];
//    }
//    obj.photoUrlList = photoRULItemArray;
//
//    for (EMFPrivatePhotoList::const_iterator iterStr = item.privatePhotoList.begin();
//         iterStr != item.privatePhotoList.end();
//         iterStr++) {
//        EMFPrivatePhotoItemObject *privatePhotoItem = [[EMFPrivatePhotoItemObject alloc] init];
//        privatePhotoItem.sendId = [NSString stringWithUTF8String:(*iterStr).sendId.c_str()];
//        privatePhotoItem.photoId = [NSString stringWithUTF8String:(*iterStr).photoId.c_str()];
//        privatePhotoItem.photoFee = (*iterStr).photoFee;
//        privatePhotoItem.photoDesc = [NSString stringWithUTF8String:(*iterStr).photoDesc.c_str()];
//        [privatePhotoItemArray addObject:privatePhotoItem];
//    }
//    obj.privatePhotoList = privatePhotoItemArray;
//
//    GetEMFOutboxMsgFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//void onRequestEMFMsgTotal(long requestId, bool success, const string &errnum, const string &errmsg, const EMFMsgTotalItem &item) {
//    GetEMFCountFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, item.msgTotal, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//void onRequestEMFSendMsg(long requestId, bool success, const string &errnum, const string &errmsg, const EMFSendMsgItem &item, const EMFSendMsgErrorItem &errItem) {
//    EMFSendMsgItemObject *obj = [[EMFSendMsgItemObject alloc] init];
//    obj.messageId = [NSString stringWithUTF8String:item.messageId.c_str()];
//    obj.sendTime = item.sendTime;
//
//    EMFSendMsgErrorItemObject *errorObj = [[EMFSendMsgErrorItemObject alloc] init];
//    errorObj.money = [NSString stringWithUTF8String:errItem.money.c_str()];
//    errorObj.memberType = errItem.memberType;
//
//    SendEMFMsgFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj, errorObj);
//    }
//}
//
//void onRequestEMFUploadImage(long requestId, bool success, const string &errnum, const string &errmsg) {
//    UploadEMFImageFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//void onRequestEMFUploadAttach(long requestId, bool success, const string &errnum, const string &errmsg, const string &attachId) {
//    UploadEMFAttachFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:attachId.c_str()]);
//    }
//}
//
//void onRequestEMFDeleteMsg(long requestId, bool success, const string &errnum, const string &errmsg) {
//    DeleteEMFMsgFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//void onRequestEMFAdmirerList(long requestId, bool success, const string &errnum, const string &errmsg, int pageIndex, int pageSize, int dataCount, const EMFAdmirerList &admirerList) {
//    NSMutableArray *admirerItemArray = [NSMutableArray array];
//    EMFAdmirerListItemObject *obj = [[EMFAdmirerListItemObject alloc] init];
//    obj.pageIndex = pageIndex;
//    obj.pageSize = pageSize;
//    obj.dataCount = dataCount;
//
//    for (EMFAdmirerList::const_iterator iterStr = admirerList.begin();
//         iterStr != admirerList.end();
//         iterStr++) {
//        EMFAdmirerItemObject *admirerItem = [[EMFAdmirerItemObject alloc] init];
//        admirerItem.mailId = [NSString stringWithUTF8String:(*iterStr).id.c_str()];
//        admirerItem.idCode = [NSString stringWithUTF8String:(*iterStr).idcode.c_str()];
//        admirerItem.readFlag = (*iterStr).readflag;
//        admirerItem.replyFlag = (*iterStr).replyflag;
//        admirerItem.womanId = [NSString stringWithUTF8String:(*iterStr).womanid.c_str()];
//        admirerItem.firstName = [NSString stringWithUTF8String:(*iterStr).firstname.c_str()];
//        admirerItem.weight = [NSString stringWithUTF8String:(*iterStr).weight.c_str()];
//        admirerItem.height = [NSString stringWithUTF8String:(*iterStr).height.c_str()];
//        admirerItem.country = [NSString stringWithUTF8String:(*iterStr).country.c_str()];
//        admirerItem.province = [NSString stringWithUTF8String:(*iterStr).province.c_str()];
//        admirerItem.mTab = [NSString stringWithUTF8String:(*iterStr).mtab.c_str()];
//        admirerItem.age = (*iterStr).age;
//        admirerItem.isOnlineStatus = (*iterStr).online_status == 1 ? YES : NO;
//        admirerItem.isCam = (*iterStr).camStatus == 0 ? NO : YES;
//        admirerItem.photoURL = [NSString stringWithUTF8String:(*iterStr).photoURL.c_str()];
//        admirerItem.sendTime = [NSString stringWithUTF8String:(*iterStr).sendTime.c_str()];
//        admirerItem.attachNum = (*iterStr).attachnum;
//        admirerItem.template_type = (*iterStr).template_type;
//        [admirerItemArray addObject:admirerItem];
//    }
//    obj.datalist = admirerItemArray;
//
//    GetEMFAdmirerListFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//
//void onRequestEMFAdmirerViewer(long requestId, bool success, const string &errnum, const string &errmsg, const EMFAdmirerViewerItem &item) {
//    NSMutableArray *photoRULItemArray = [NSMutableArray array];
//    EMFAdmirerViewerItemObject *obj = [[EMFAdmirerViewerItemObject alloc] init];
//    obj.mailId = [NSString stringWithUTF8String:item.id.c_str()];
//    obj.body = [NSString stringWithUTF8String:item.body.c_str()];
//    obj.womanId = [NSString stringWithUTF8String:item.womanid.c_str()];
//    obj.firstName = [NSString stringWithUTF8String:item.firstname.c_str()];
//    obj.weight = [NSString stringWithUTF8String:item.weight.c_str()];
//    obj.height = [NSString stringWithUTF8String:item.height.c_str()];
//    obj.country = [NSString stringWithUTF8String:item.country.c_str()];
//    obj.province = [NSString stringWithUTF8String:item.province.c_str()];
//    obj.mTab = [NSString stringWithUTF8String:item.mtab.c_str()];
//    obj.age = item.age;
//    obj.isOnlineStatus = item.online_status == 1 ? YES : NO;
//    obj.isCam = item.camStatus == 0 ? NO : YES;
//    obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
//    obj.sendTime = [NSString stringWithUTF8String:item.sendTime.c_str()];
//    obj.template_type = [NSString stringWithUTF8String:item.template_type.c_str()];
//    obj.vg_id = [NSString stringWithUTF8String:item.vg_id.c_str()];
//    for (EMFPhotoUrlList::const_iterator iterStr = item.photosURL.begin();
//         iterStr != item.photosURL.end();
//         iterStr++) {
//        NSString *photoURLItem = [NSString stringWithUTF8String:(*iterStr).c_str()];
//        [photoRULItemArray addObject:photoURLItem];
//    }
//    obj.photoUrlList = photoRULItemArray;
//
//    GetEMFAdmirerViewerFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//
//void onRequestEMFBlockList(long requestId, bool success, const string &errnum, const string &errmsg, int pageIndex, int pageSize, int dataCount, const EMFBlockList &blockList) {
//    NSMutableArray *admirerItemArray = [NSMutableArray array];
//    EMFBlockListItemObject *obj = [[EMFBlockListItemObject alloc] init];
//    obj.pageIndex = pageIndex;
//    obj.pageSize = pageSize;
//    obj.dataCount = dataCount;
//
//    for (EMFBlockList::const_iterator iterStr = blockList.begin();
//         iterStr != blockList.end();
//         iterStr++) {
//        EMFBlockItemObject *admirerItem = [[EMFBlockItemObject alloc] init];
//        admirerItem.womanId = [NSString stringWithUTF8String:(*iterStr).womanid.c_str()];
//        admirerItem.firstName = [NSString stringWithUTF8String:(*iterStr).firstname.c_str()];
//        admirerItem.age = (*iterStr).age;
//        admirerItem.weight = [NSString stringWithUTF8String:(*iterStr).weight.c_str()];
//        admirerItem.height = [NSString stringWithUTF8String:(*iterStr).height.c_str()];
//        admirerItem.country = [NSString stringWithUTF8String:(*iterStr).country.c_str()];
//        admirerItem.province = [NSString stringWithUTF8String:(*iterStr).province.c_str()];
//        admirerItem.city = [NSString stringWithUTF8String:(*iterStr).city.c_str()];
//        admirerItem.photoURL = [NSString stringWithUTF8String:(*iterStr).photoURL.c_str()];
//        admirerItem.blockReason = (*iterStr).blockreason;
//        [admirerItemArray addObject:admirerItem];
//    }
//    obj.datalist = admirerItemArray;
//
//    GetEMFBlockListFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//
//void onRequestEMFBlock(long requestId, bool success, const string &errnum, const string &errmsg) {
//    AddEMFBlockFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//void onRequestEMFUnblock(long requestId, bool success, const string &errnum, const string &errmsg) {
//    DeleteEMFBlockFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//void onRequestEMFInboxPhotoFee(long requestId, bool success, const string &errnum, const string &errmsg) {
//    GetEMFInboxPhotoFeeFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//void onRequestEMFPrivatePhotoView(long requestId, bool success, const string &errnum, const string &errmsg, const string &filePath) {
//    GetEMFPrivatePhotoViewFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:filePath.c_str()]);
//    }
//}
//void onRequestGetVideoThumbPhoto(long requestId, bool success, const string &errnum, const string &errmsg, const string &filePath) {
//    GetEMFShortVideoPhotoFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:filePath.c_str()]);
//    }
//}
//void onRequestGetVideoUrl(long requestId, bool success, const string &errnum, const string &errmsg, const string &url) {
//    PlayEMFShortVideoUrlFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (nil != handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:url.c_str()]);
//    }
//}
//
//- (NSInteger)getEMFCount:(GetEMFCountFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//
//    requestId = mpLSLiveChatRequestEMFController->MsgTotal(3);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)getEMFInboxList:(int)pageIndex
//                    pageSize:(int)pageSize
//                    sortType:(int)sortType
//                     womanId:(NSString *)womanId
//                      finish:(GetEMFInboxListFinishHandler)finishHandler {
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->InboxList(pageIndex, pageSize, sortType, strWomanId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)getEMFInboxMsg:(NSString *)messageId
//                     finish:(GetEMFInboxMsgFinishHandler)finishHandler {
//    string strMessageId = "";
//    if (messageId) {
//        strMessageId = [messageId UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->InboxMsg(strMessageId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)getEMFOutboxList:(int)pageIndex
//                     pageSize:(int)pageSize
//                 progressType:(int)progressType
//                      womanId:(NSString *)womanId
//                       finish:(GetEMFOutboxListFinishHandler)finishHandler {
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    //string strWomanId = [womanId UTF8String];
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->OutboxList(pageIndex, pageSize, progressType, strWomanId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)getEMFOutboxMsg:(NSString *)messageId
//                      finish:(GetEMFOutboxMsgFinishHandler)finishHandler {
//    string strMessageId = "";
//    if (messageId) {
//        strMessageId = [messageId UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->OutboxMsg(strMessageId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)sendEMFMsg:(NSString *)womanId
//                   body:(NSString *)body
//            useIntegral:(BOOL)useIntegral
//              replyType:(int)replyType
//                   mtab:(NSString *)mtab
//                  gifts:(NSArray<NSString *> *)gifts
//                attachs:(NSArray<NSString *> *)attachs
//             isLovecall:(BOOL)isLovecall
//              messageId:(NSString *)messageId
//                 finish:(SendEMFMsgFinishHandler)finishHandler {
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    string strBody = "";
//    if (nil != body) {
//        strBody = [body UTF8String];
//    }
//    string strMtab = "";
//    if (mtab) {
//        strMtab = [mtab UTF8String];
//    }
//    string strMessageId = "";
//    if (messageId) {
//        strMessageId = [messageId UTF8String];
//    }
//    SendMsgGifts giftItemList;
//    for (NSString *str in gifts) {
//        string pStr = [str UTF8String];
//        giftItemList.push_back(pStr);
//    }
//
//    SendMsgAttachs itemList;
//    for (NSString *str in attachs) {
//        string pStr = [str UTF8String];
//        itemList.push_back(pStr);
//    }
//
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->SendMsg(strWomanId, strBody, useIntegral, replyType, strMtab, giftItemList, itemList, isLovecall, strMessageId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)uploadEMFImage:(NSString *)messageId
//                   fileList:(NSArray<NSString *> *)fileList
//                     finish:(UploadEMFImageFinishHandler)finishHandler {
//    string strMessageId = [messageId UTF8String];
//    EMFFileNameList itemList;
//    for (NSString *str in fileList) {
//        string pStr = [str UTF8String];
//        itemList.push_back(pStr);
//    }
//
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->UploadImage(strMessageId, itemList);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)UploadEMFAttach:(NSString *)filePath
//                  attachType:(int)attachType
//                      finish:(UploadEMFAttachFinishHandler)finishHandler {
//    string strFilePath = "";
//    if (filePath) {
//        strFilePath = [filePath UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->UploadAttach(strFilePath, attachType);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)deleteEMFMsg:(NSString *)messageId
//                 mailType:(int)mailType
//                   finish:(DeleteEMFMsgFinishHandler)finishHandler {
//    string strMessageId = "";
//    if (messageId) {
//        strMessageId = [messageId UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->DeleteMsg(strMessageId, mailType);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)getEMFAdmirerList:(int)pageIndex
//                      pageSize:(int)pageSize
//                      sortType:(int)sortType
//                       womanId:(NSString *)womanId
//                        finish:(GetEMFAdmirerListFinishHandler)finishHandler {
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->AdmirerList(pageIndex, pageSize, sortType, strWomanId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)getEMFAdmirerViewer:(NSString *)messageId
//                          finish:(GetEMFAdmirerViewerFinishHandler)finishHandler {
//    string strMessageId = "";
//    if (messageId) {
//        strMessageId = [messageId UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->AdmirerViewer(strMessageId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)getEMFBlockList:(int)pageIndex
//                    pageSize:(int)pageSize
//                     womanId:(NSString *)womanId
//                      finish:(GetEMFBlockListFinishHandler)finishHandler {
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->BlockList(pageIndex, pageSize, strWomanId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)addEMFBlock:(NSString *)womanId
//             blockreason:(int)blockreason
//                  finish:(AddEMFBlockFinishHandler)finishHandler {
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->Block(strWomanId, blockreason);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)deleteEMFBlock:(NSArray<NSString *> *)fileList
//                     finish:(DeleteEMFBlockFinishHandler)finishHandler {
//    EMFWomanidList itemList;
//    for (NSString *str in fileList) {
//        string pStr = [str UTF8String];
//        itemList.push_back(pStr);
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->Unblock(itemList);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)getEMFInboxPhotoFee:(NSString *)womanId
//                         photoId:(NSString *)photoId
//                          sendId:(NSString *)sendId
//                       messageId:(NSString *)messageId
//                          finish:(GetEMFInboxPhotoFeeFinishHandler)finishHandler {
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    string strSendId = "";
//    if (sendId) {
//        strSendId = [sendId UTF8String];
//    }
//    string strPhotoId = "";
//    if (photoId) {
//        strPhotoId = [photoId UTF8String];
//    }
//    string strMessageId = "";
//    if (messageId) {
//        strMessageId = [messageId UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->InboxPhotoFee(strWomanId, strPhotoId, strSendId, strMessageId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)getEMFPrivatePhotoView:(NSString *)womanId
//                             sendId:(NSString *)sendId
//                            photoId:(NSString *)photoId
//                          messageId:(NSString *)messageId
//                           filePath:(NSString *)filePath
//                               type:(int)type
//                               mode:(int)mode
//                             finish:(GetEMFPrivatePhotoViewFinishHandler)finishHandler {
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//
//    string strSendId = "";
//    if (sendId) {
//        strSendId = [sendId UTF8String];
//    }
//
//    string strPhotoId = "";
//    if (photoId) {
//        strPhotoId = [photoId UTF8String];
//    }
//
//    string strMessageId = "";
//    if (messageId) {
//        strMessageId = [messageId UTF8String];
//    }
//
//    string strFilePath = "";
//    if (filePath) {
//        strFilePath = [filePath UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->PrivatePhotoView(strWomanId, strPhotoId, strSendId, strMessageId, strFilePath, type, mode);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)getEMFShortVideoPhoto:(NSString *)womanId
//                            sendId:(NSString *)sendId
//                           videoId:(NSString *)videoId
//                         messageId:(NSString *)messageId
//                              size:(int)size
//                          filePath:(NSString *)filePath
//                            finish:(GetEMFShortVideoPhotoFinishHandler)finishHandler {
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//
//    string strSendId = "";
//    if (sendId) {
//        strSendId = [sendId UTF8String];
//    }
//
//    string strVideoId = "";
//    if (videoId) {
//        strVideoId = [videoId UTF8String];
//    }
//
//    string strMessageId = "";
//    if (messageId) {
//        strMessageId = [messageId UTF8String];
//    }
//
//    string strFilePath = "";
//    if (filePath) {
//        strFilePath = [filePath UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->GetVideoThumbPhoto(strWomanId, strSendId, strVideoId, strMessageId, size, strFilePath);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}
//
//- (NSInteger)playEMFShortVideoUrl:(NSString *)womanId
//                           sendId:(NSString *)sendId
//                          videoId:(NSString *)videoId
//                        messageId:(NSString *)messageId
//                           finish:(PlayEMFShortVideoUrlFinishHandler)finishHandler {
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//
//    string strSendId = "";
//    if (sendId) {
//        strSendId = [sendId UTF8String];
//    }
//
//    string strVideoId = "";
//    if (videoId) {
//        strVideoId = [videoId UTF8String];
//    }
//
//    string strMessageId = "";
//    if (messageId) {
//        strMessageId = [messageId UTF8String];
//    }
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestEMFController->GetVideoUrl(strWomanId, strSendId, strVideoId, strMessageId);
//    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//        @synchronized(self.delegateDictionary) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//
//    return requestId;
//}

#pragma mark - liveChat他模块
void LSLiveChatRequestLiveChatControllerCallback::OnQueryChatVirtualGift(long requestId, bool success, const list<LSLCGift> &giftList, int totalCount, const string &path, const string &version, const string &errnum, const string &errmsg) {
    FileLog("httprequest", "RequestManager::OnQueryChatVirtualGift( success : %s )", success ? "true" : "false");

    NSMutableArray *giftArray = [NSMutableArray array];
    if (success) {

        for (list<LSLCGift>::const_iterator iter = giftList.begin();
             iter != giftList.end();
             iter++) {
            LSLCGiftItemObject *object = [[LSLCGiftItemObject alloc] init];
            object.vgid = [NSString stringWithUTF8String:(*iter).vgid.c_str()];
            object.title = [NSString stringWithUTF8String:(*iter).title.c_str()];
            object.price = [NSString stringWithUTF8String:(*iter).price.c_str()];
            if (nil != object) {
                [giftArray addObject:object];
            }
        }
    }

    QueryChatVirtualGiftFinishHandler handler = nil;
    LSLiveChatRequestManager *manager = [LSLiveChatRequestManager manager];
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
    }

    if (handler) {
        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], giftArray, totalCount, [NSString stringWithUTF8String:path.c_str()], [NSString stringWithUTF8String:version.c_str()]);
    }
}

- (NSInteger)queryChatVirtualGift:(NSString *)userSid
                           userId:(NSString *)userId
                           finish:(QueryChatVirtualGiftFinishHandler)finishHandler {
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;

    string strUserSid = "";
    if (userSid) {
        strUserSid = [userSid UTF8String];
    }

    string strUserId = "";
    if (userId) {
        strUserId = [userId UTF8String];
    }
    requestId = mpLSLiveChatRequestLiveChatController->QueryChatVirtualGift(strUserSid, strUserId);
    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
    }

    return requestId;
}

void LSLiveChatRequestLiveChatControllerCallback::OnSendGift(long requestId, bool success, const string &errnum, const string &errmsg) {
    FileLog("httprequest", "RequestManager::OnSendGift( success : %s )", success ? "true" : "false");

    SendGiftFinishHandler handler = nil;
    LSLiveChatRequestManager *manager = [LSLiveChatRequestManager manager];
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
    }

    if (handler) {
        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
    }
}

- (NSInteger)sendGift:(NSString *)womanId
                vg_id:(NSString *)vg_id
              chat_id:(NSString *)chat_id
             use_type:(int)use_type
             user_sid:(NSString *)user_sid
              user_id:(NSString *)user_id
               finish:(SendGiftFinishHandler)finishHandler {
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    string strWomanId = "";
    if (womanId) {
        strWomanId = [womanId UTF8String];
    }

    string strVgId = "";
    if (vg_id) {
        strVgId = [vg_id UTF8String];
    }

    string strChatId = "";
    if (chat_id) {
        strChatId = [chat_id UTF8String];
    }

    string strUserSid = "";
    if (user_sid) {
        strUserSid = [user_sid UTF8String];
    }

    string strUserId = "";
    if (user_id) {
        strUserId = [user_id UTF8String];
    }
    requestId = mpLSLiveChatRequestLiveChatController->SendGift(strWomanId, strVgId, "" /*[[UIDevice currentDevice].identifierForVendor.UUIDString UTF8String]*/, strChatId, use_type, strUserSid, strUserId);
    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
    }

    return requestId;
}

//#pragma mark - 设置模块
//
//void onChangePassword(long requestId, bool success, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::onChangePassword( success : %s )", success ? "true" : "false");
//    ChangePasswordFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
//    }
//}
//
//- (NSInteger)changePassword:(NSString *)oldPassword
//                newPassword:(NSString *)newPassword
//                     finish:(ChangePasswordFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strOldPassword = "";
//    if (oldPassword) {
//        strOldPassword = [oldPassword UTF8String];
//    }
//    string strNewPassword = "";
//    if (newPassword) {
//        strNewPassword = [newPassword UTF8String];
//    }
//    requestId = mpLSLiveChatRequestSettingController->ChangePassword(strOldPassword, strNewPassword);
//    @synchronized(self.delegateDictionary) {
//        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//#pragma mark - 视频显示模块
//void onRequestVSVideoDetail(long requestId, bool success, const string &errnum, const string &errmsg, const VSVideoDetailList &list) {
//    FileLog("httprequest", "RequestManager::onRequestVSVideoDetail( success : %s )", success ? "true" : "false");
//
//    NSMutableArray *itemArray = [NSMutableArray array];
//    for (VSVideoDetailList::const_iterator iterStr = list.begin();
//         iterStr != list.end();
//         iterStr++) {
//        VSVideoDetailItemObject *obj = [[VSVideoDetailItemObject alloc] init];
//        obj.videoId = [NSString stringWithUTF8String:(*iterStr).id.c_str()];
//        obj.title = [NSString stringWithUTF8String:(*iterStr).title.c_str()];
//        obj.womanId = [NSString stringWithUTF8String:(*iterStr).womanId.c_str()];
//        obj.thumbURL = [NSString stringWithUTF8String:(*iterStr).thumbURL.c_str()];
//        obj.time = [NSString stringWithUTF8String:(*iterStr).time.c_str()];
//        obj.photoURL = [NSString stringWithUTF8String:(*iterStr).photoURL.c_str()];
//        obj.videoFav = (*iterStr).videoFav == 1 ? YES : NO;
//        obj.videoSize = [NSString stringWithUTF8String:(*iterStr).videoSize.c_str()];
//        obj.transcription = [NSString stringWithUTF8String:(*iterStr).transcription.c_str()];
//        obj.viewTime1 = [NSString stringWithUTF8String:(*iterStr).viewTime1.c_str()];
//        obj.viewTime2 = [NSString stringWithUTF8String:(*iterStr).viewTime2.c_str()];
//        [itemArray addObject:obj];
//    }
//
//    VideoDetailFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], itemArray);
//    }
//}
//
//- (NSInteger)videoDetail:(NSString *)womanId
//                  finish:(VideoDetailFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestVideoShowController->VideoDetail(strWomanId);
//    @synchronized(self.delegateDictionary) {
//        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onRequestVSPlayVideo(long requestId, bool success, const string &errnum, const string &errmsg, int memberType, const VSPlayVideoItem &item) {
//    FileLog("httprequest", "RequestManager::onRequestVSPlayVideo( success : %s )", success ? "true" : "false");
//
//    VSPlayVideoItemObject *obj = [[VSPlayVideoItemObject alloc] init];
//    obj.videoURL = [NSString stringWithUTF8String:item.videoURL.c_str()];
//    obj.transcription = [NSString stringWithUTF8String:item.transcription.c_str()];
//    obj.viewTime1 = [NSString stringWithUTF8String:item.viewTime1.c_str()];
//    obj.viewTime2 = [NSString stringWithUTF8String:item.viewTime2.c_str()];
//
//    PlayVideoFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//
//- (NSInteger)playVideo:(NSString *)womanId
//               videoId:(NSString *)videoId
//                finish:(PlayVideoFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strWomanId = "";
//    if (womanId) {
//        strWomanId = [womanId UTF8String];
//    }
//    string strVideoId = "";
//    if (videoId) {
//        strVideoId = [videoId UTF8String];
//    }
//    requestId = mpLSLiveChatRequestVideoShowController->PlayVideo(strWomanId, strVideoId);
//    @synchronized(self.delegateDictionary) {
//        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//#pragma mark - LoveCall模块回调
//
//void onQueryLoveCallList(long requestId, bool success, list<LoveCall> itemList, int totalCount, string errnum, string errmsg) {
//    FileLog("httprequest", "RequestManager::onQueryLoveCallList( success : %s )", success ? "true" : "false");
//    LoveCallListItemObject *item = [[LoveCallListItemObject alloc] init];
//    NSMutableArray *itemArray = [NSMutableArray array];
//    item.dataCount = totalCount;
//    for (list<LoveCall>::const_iterator iterStr = itemList.begin();
//         iterStr != itemList.end();
//         iterStr++) {
//        LoveCallItemObject *loveCallItem = [[LoveCallItemObject alloc] init];
//        loveCallItem.orderId = [NSString stringWithUTF8String:(*iterStr).orderid.c_str()];
//        loveCallItem.womanId = [NSString stringWithUTF8String:(*iterStr).womanid.c_str()];
//        loveCallItem.image = [NSString stringWithUTF8String:(*iterStr).image.c_str()];
//        loveCallItem.firstName = [NSString stringWithUTF8String:(*iterStr).firstname.c_str()];
//        loveCallItem.country = [NSString stringWithUTF8String:(*iterStr).country.c_str()];
//        loveCallItem.age = (*iterStr).age;
//        loveCallItem.beginTime = (*iterStr).begintime;
//        loveCallItem.endTime = (*iterStr).endtime;
//        loveCallItem.needTr = (*iterStr).needtr == 1 ? YES : NO;
//        loveCallItem.isConfirm = (*iterStr).isconfirm == 1 ? YES : NO;
//        loveCallItem.confirmMsg = [NSString stringWithUTF8String:(*iterStr).confirmmsg.c_str()];
//        loveCallItem.callId = [NSString stringWithUTF8String:(*iterStr).callid.c_str()];
//        loveCallItem.centerId = [NSString stringWithUTF8String:(*iterStr).centerid.c_str()];
//        [itemArray addObject:loveCallItem];
//    }
//    item.datalist = itemArray;
//
//    QueryLoveCallListFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], item);
//    }
//}
//
//- (NSInteger)queryLoveCallList:(int)pageIndex
//                      pageSize:(int)pageSize
//                          Type:(int)type
//                        finish:(QueryLoveCallListFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//
//    requestId = mpLSLiveChatRequestLoveCallController->QueryLoveCallList(pageIndex, pageSize, type);
//    @synchronized(self.delegateDictionary) {
//        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onConfirmLoveCall(long requestId, bool success, string errnum, string errmsg, int memberType) {
//    FileLog("httprequest", "RequestManager::onConfirmLoveCall( success : %s )", success ? "true" : "false");
//    ConfirmLoveCallFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], memberType);
//    }
//}
//
//- (NSInteger)confirmLoveCall:(NSString *)orderId
//                 confirmType:(int)confirmType
//                      finish:(ConfirmLoveCallFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strOrderId = "";
//    if (orderId) {
//        strOrderId = [orderId UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestLoveCallController->ConfirmLoveCall(strOrderId, confirmType);
//    @synchronized(self.delegateDictionary) {
//        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onQueryLoveCallRequestCount(long requestId, bool success, string errnum, string errmsg, int num) {
//    FileLog("httprequest", "RequestManager::onQueryLoveCallRequestCount( success : %s )", success ? "true" : "false");
//    QueryLoveCallRequestCountFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], num);
//    }
//}
//
//- (NSInteger)queryLoveCallRequestCount:(int)type
//                                finish:(QueryLoveCallRequestCountFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    requestId = mpLSLiveChatRequestLoveCallController->QueryLoveCallRequestCount(type);
//    @synchronized(self.delegateDictionary) {
//        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//#pragma 广告
//void onRequestAdWomanListAdvert(long requestId, bool success, const string &errnum, const string &errmsg, const AdWomanListAdvertItem &item) {
//    FileLog("httprequest", "RequestManager::onRequestAdWomanListAdvert( success : %s, advertId : %s, image : %s, adurl : %s, width: %d, height: %d, openType : %d, advertTitle: %s )", success ? "true" : "false", item.advertId.c_str(), item.image.c_str(), item.adurl.c_str(), item.width, item.height, item.openType, item.advertTitle);
//
//    WomanListAdItemObject *obj = [[WomanListAdItemObject alloc] init];
//    obj.advertId = [NSString stringWithUTF8String:item.advertId.c_str()];
//    obj.image = [NSString stringWithUTF8String:item.image.c_str()];
//    obj.width = item.width;
//    obj.height = item.height;
//    obj.adurl = [NSString stringWithUTF8String:item.adurl.c_str()];
//    obj.openType = item.openType;
//    obj.advertTitle = [NSString stringWithUTF8String:item.advertTitle.c_str()];
//
//    WonmanListAdvertFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//
//- (NSInteger)wonmanListAdvert:(NSString *)advertId
//                    showTimes:(int)showTimes
//                   clickTimes:(int)clickTimes
//                    adspaceId:(AdvertSpaceType)adspaceId
//                       finish:(WonmanListAdvertFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strAdvertId = "";
//    if (advertId) {
//        strAdvertId = [advertId UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestAdvertController->WomanListAdvert([[self getDeviceId] UTF8String], strAdvertId, showTimes, clickTimes, adspaceId);
//    @synchronized(self.delegateDictionary) {
//        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onRequestAdmirerListAd(long requestId, bool success, const string &errnum, const string &errmsg, const string &advertId, const string &htmlCode, const string &advertTitle) {
//    FileLog("httprequest", "RequestManager::onRequestAdmirerListAd( success : %s, advertId : %s, htmlCode : %s, advertTitle : %s )", success ? "true" : "false", advertId.c_str(), htmlCode.c_str(), advertTitle.c_str());
//    AdmirerListAdvertFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], [NSString stringWithUTF8String:advertId.c_str()], [NSString stringWithUTF8String:htmlCode.c_str()], [NSString stringWithUTF8String:advertTitle.c_str()]);
//    }
//}
//
//- (NSInteger)admirerListAdvert:(NSString *)advertId
//                  firstGottime:(long)firstGottime
//                     showTimes:(int)showTimes
//                    clickTimes:(int)clickTimes
//                        finish:(AdmirerListAdvertFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strAdvertId = "";
//    if (advertId) {
//        strAdvertId = [advertId UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestAdvertController->AdmirerListAd([[self getDeviceId] UTF8String], strAdvertId, firstGottime, showTimes, clickTimes);
//    @synchronized(self.delegateDictionary) {
//        if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//
//void onRequestHtml5Ad(long requestId, bool success, const string &errnum, const string &errmsg, const AdHtml5AdvertItem &item) {
//    FileLog("httprequest", "RequestManager::onRequestHtml5Ad( success : %s, advertId : %s, htmlCode : %s, advertTitle : %s, hegit : %d )", success ? "true" : "false", item.advertId.c_str(), item.htmlCode.c_str(), item.advertTitle.c_str(), item.height);
//
//    Html5AdItemObject *obj = [[Html5AdItemObject alloc] init];
//    obj.advertId = [NSString stringWithUTF8String:item.advertId.c_str()];
//    obj.htmlCode = [NSString stringWithUTF8String:item.htmlCode.c_str()];
//    obj.advertTitle = [NSString stringWithUTF8String:item.advertTitle.c_str()];
//    obj.height = item.height;
//    Html5AdvertFinishHandler handler = nil;
//    RequestManager *manager = [RequestManager manager];
//    @synchronized(manager.delegateDictionary) {
//        handler = [manager.delegateDictionary objectForKey:@(requestId)];
//        [manager.delegateDictionary removeObjectForKey:@(requestId)];
//    }
//
//    if (handler) {
//        handler(success, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()], obj);
//    }
//}
//
//- (NSInteger)html5Advert:(NSString *)advertId
//            firstGottime:(long)firstGottime
//               showTimes:(int)showTimes
//              clickTimes:(int)clickTimes
//               adspaceId:(AdvertHtmlSpaceType)adspaceId
//              adOverview:(NSString *)adOverview
//                  finish:(Html5AdvertFinishHandler)finishHandler {
//    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
//    string strAdvertId = "";
//    if (advertId) {
//        strAdvertId = [advertId UTF8String];
//    }
//    string strAdOverview = "";
//    if (adOverview) {
//        strAdOverview = [adOverview UTF8String];
//    }
//
//    requestId = mpLSLiveChatRequestAdvertController->Html5Ad([[self getDeviceId] UTF8String], strAdvertId, firstGottime, showTimes, clickTimes, adspaceId, strAdOverview);
//    @synchronized(self.delegateDictionary) {
//        if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
//            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
//        }
//    }
//    return requestId;
//}
//

@end
