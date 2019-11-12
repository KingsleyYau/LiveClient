//
//  LiveModuleManager.m
//  livestream
//
//  Created by randy on 2017/8/3.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveModule.h"

#pragma mark - 界面
#import "LSMainViewController.h"

#pragma mark - 登录
#import "LSGiftManager.h"
#import "LSChatEmotionManager.h"
#import "LSStreamSpeedManager.h"

#pragma mark - 公共
#import "LSFileCacheManager.h"
#import "LiveRoomCreditRebateManager.h"
#import "LiveBundle.h"
#import "LSImageViewLoader.h"

#pragma mark - HTTP
#import "LSLoginManager.h"
#import "LSRequestManager.h"
#import "LSSessionRequestManager.h"

#pragma mark - IM
#import "LSImManager.h"
#import "LSLiveChatManagerOC.h"
#import "LSIMLoginManager.h"
#import "LSLCSessionRequestManager.h"
#import "LSLiveChatRequestManager.h"

#pragma mark - 私信
#import "LSPrivateMessageManager.h"

#pragma mark - 流媒体
#import "LiveGobalManager.h"
#import "LiveStreamSession.h"

#pragma mark - 广告
#import "GetAnchorListRequest.h"

#pragma mark - URL跳转
#import "LiveUrlHandler.h"

#pragma mark - QN
#import "LiveMutexService.h"
#import "LiveSiteService.h"
#import "LiveAnalyticsManager.h"
#import "LiveNotificationService.h"

#import "LSPaymentManager.h"
#import "QNContactManager.h"

#import "LSSendSayHiViewController.h"

#define HTTP_AUTHOR @"test"
#define HTTP_PASSWORD @"5179"

static LiveModule *gModule = nil;
@interface LiveModule () <LoginManagerDelegate, IMLiveRoomManagerDelegate, IMManagerDelegate, LSLiveChatManagerListenerDelegate> {
    UIViewController *_moduleVC;
}

#pragma mark - 服务
@property (strong, nonatomic) LiveSiteService *liveSiteService;

// 是否在后台
@property (assign, nonatomic) BOOL isBackground;
@property (strong, nonatomic) NSString *manId;
@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) LiveGobalManager *liveGobalManager;
@property (strong, nonatomic) LSSessionRequestManager *sessionManager;
@property (strong, nonatomic) LSLoginManager *loginManager;
@property (strong, nonatomic) LSImManager *imManager;
@property (strong, nonatomic) LSGiftManager *giftDownloadManager;
@property (strong, nonatomic) LSChatEmotionManager *emotionManager;
@property (strong, nonatomic) LSStreamSpeedManager *speedManager;
@property (strong, nonatomic) LSLiveChatManagerOC *liveChatManager;
@property (strong, nonatomic) LSLiveChatRequestManager *liveChatRequestManager;
// 余额及返点信息管理器
@property (strong, nonatomic) LiveRoomCreditRebateManager *creditRebateManager;
// 通知界面
@property (strong, nonatomic) UIViewController *notificationVC;
@end

@implementation LiveModule
#pragma mark - 获取实例
+ (instancetype)module {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!gModule) {
            gModule = [[LiveModule alloc] init];
        }
    });
    return gModule;
}

- (id)init {
    NSLog(@"LiveModule::init()");

    if (self = [super init]) {
        // 模块主界面
        _debug = NO;
        _debugLog = YES;
        _moduleVC = nil;
        _notificationVC = nil;
        _test = NO;
        _appVerCode = @"";

        // 创建直播服务
        [LiveMutexService service];
        // 资源全局管理
        [LiveBundle gobalInit];
        // 初始化图像下载器
        [LSImageViewLoader gobalInit];
        // 初始化内部GA
        [LiveAnalyticsManager manager];

        [LiveNotificationService service];
        
        // 初始化流媒体管理器
        self.liveGobalManager = [LiveGobalManager manager];
        // 初始化测速管理器
        self.speedManager = [[LSStreamSpeedManager alloc] init];
        // 初始化Http登陆管理器
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
        // 初始化IM管理器
        self.imManager = [LSImManager manager];
        [self.imManager addDelegate:self];
        [self.imManager.client addDelegate:self];
        [LSPaymentManager manager];
        // 初始化私信管理器
        [LSPrivateMessageManager manager];
        // 初始化livechat管理器
        self.liveChatManager = [LSLiveChatManagerOC manager];
        [self.liveChatManager addDelegate:self];

        self.liveChatRequestManager = [LSLiveChatRequestManager manager];

        [LSLCSessionRequestManager manager];

        // 初始化礼物下载器
        self.giftDownloadManager = [LSGiftManager manager];
        // 初始化聊天表情管理器
        self.emotionManager = [LSChatEmotionManager emotionManager];
        // 初始session管理器
        self.sessionManager = [LSSessionRequestManager manager];
        // 初始化余额及返点信息管理器
        self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
        // 清除webview的缓存
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        //        // 开启后台播放
        //        [[LiveStreamSession session] activeSession];
        // 设置接口管理类属性
        [LSRequestManager setLogEnable:_debugLog];
        [LSRequestManager setLogDirectory:[[LSFileCacheManager manager] requestLogPath]];
        LSRequestManager *manager = [LSRequestManager manager];
        [manager setWebSite:@""];
        [manager setAuthorization:HTTP_AUTHOR password:HTTP_PASSWORD];
       // [LSRequestManager setProxy:@"http://172.25.32.80:8888"];
        // 初始化联系人管理器
        [QNContactManager manager];
        
        // 创建直播服务
        self.liveSiteService = [[LiveSiteService alloc] init];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"LiveModule::dealloc()");

    if (_serviceManager) {
        [_serviceManager removeService:self.mutexService];
    }

    [self.imManager.client removeDelegate:self];
    [self.imManager removeDelegate:self];
    [self.loginManager removeDelegate:self];
    [self.liveChatManager removeDelegate:self];
}

- (void)setConfigUrl:(NSString *)url {
    NSLog(@"LiveModule::setConfigUrl( url : %@ )", url);

    LSRequestManager *manager = [LSRequestManager manager];
    [manager setConfigWebSite:url];
}

- (void)destroyModuleVC {
    NSLog(@"LiveModule::destroyModuleVC()");
    _moduleVC = nil;
}

- (BOOL)start:(NSString *)manId token:(NSString *)token {
    BOOL bFlag = YES;

    NSLog(@"LiveModule::start( manId : %@, sessionId : %@ )", manId, token);

    @synchronized(self) {
        self.sessionId = token;
        self.manId = manId;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginManager loginWithSession:self.sessionId];
    });

    return bFlag;
}

- (void)stop {
    NSLog(@"LiveModule::stop( manId : %@, sessionId : %@ )", self.manId, self.sessionId);

    @synchronized(self) {
        self.sessionId = nil;
        self.manId = nil;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginManager logout:LogoutTypeActive msg:@""];

        // 停止直播间, 退出到模块入口
        [[LiveMutexService service] stopService];
    });
}

- (void)cleanCache {
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
}

#pragma mark - Get/Set方法
- (void)setDebugLog:(BOOL)debugLog {
    [LSRequestManager setLogEnable:debugLog];
}

- (void)setHttpProxy:(NSString *)httpProxy {
    [LSRequestManager setProxy:httpProxy];
}

- (void)setServiceManager:(id<IMutexServiceManager>)serviceManager {
    _serviceManager = serviceManager;
    if (_serviceManager) {
        [_serviceManager addService:self.mutexService];
    }
}

- (id<IMutexService>)mutexService {
    return (id<IMutexService>)[LiveMutexService service];
}

- (id<ILoginService>)loginService {
    return (id<ILoginService>)[LSIMLoginManager manager];
}

- (id<ISiteService>)siteService {
    return (id<ISiteService>)self.liveSiteService;
}

- (id<INotificationsServiceService>)notificationsServiceService {
    return (id<INotificationsServiceService>)[LiveNotificationService service];
}

- (UIViewController *)notificationVC {
    return _notificationVC;
}

- (UIViewController *)mainVC {
    _moduleVC = [[LSMainViewController alloc] initWithNibName:nil bundle:nil];
//    _moduleVC = [[LSSendSayHiViewController alloc] initWithNibName:nil bundle:nil];
    return _moduleVC;
}

- (UIViewController *)moduleVC {
    return _moduleVC;
}

- (NSBundle *)liveBundle {
    return [LiveBundle mainBundle];
}

#pragma mark - HTTP登录回调
- (void)manager:(LSLoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *_Nullable)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *_Nonnull)errmsg {
    if (success) {
        // Http登陆成功
        // livechat登录
        ConfigItemObject *configItem = [LSLoginManager manager].configItem;
        NSString *cachesDirectory = [[LSFileCacheManager manager] cacheDirectory];
        NSString *appId = [[NSBundle mainBundle] bundleIdentifier];
        BOOL isLiveChatRisk = NO;
        if (loginItem.isLiveChatRisk || !loginItem.userPriv.liveChatPriv.isLiveChatPriv) {
            isLiveChatRisk = YES;
        }
        [[LSLiveChatRequestManager manager] setWebSite:configItem.httpSvrUrl appSite:configItem.httpSvrUrl wapSite:@""];
        [[LSLiveChatRequestManager manager] setAuthorization:@"test" password:@"5179"];
 
        [[LSLiveChatManagerOC manager] loginUser:configItem.socketHostDomain port:configItem.socketPort webSite:configItem.httpSvrUrl appSite:configItem.httpSvrUrl chatVoiceHostUrl:configItem.chatVoiceHostUrl httpUser:@"test" httpPassword:@"5179" versionCode:[LSRequestManager manager].versionCode appId:appId cachesDirectory:cachesDirectory minChat:configItem.minBalanceForChat user:loginItem.userId userName:loginItem.nickName sid:loginItem.sessionId device:[[LSRequestManager manager] getDeviceId] livechatInvite:(NSInteger)loginItem.userPriv.liveChatPriv.liveChatInviteRiskType isLivechat:isLiveChatRisk isSendPhotoPriv:loginItem.userPriv.liveChatPriv.isSendLiveChatPhotoPriv isLiveChatPriv:loginItem.userPriv.liveChatPriv.isLiveChatPriv isSendVoicePriv:loginItem.userPriv.liveChatPriv.isSendLiveChatVoicePriv];
        
        if ([self.delegate respondsToSelector:@selector(moduleOnLogin:)]) {
            [self.delegate moduleOnLogin:self];
        }
    } else {
        // 停止直播间, 退出到模块入口
        [[LiveMutexService service] stopService];
    }
}

- (void)manager:(LSLoginManager *_Nonnull)manager onLogout:(LogoutType)type msg:(NSString *_Nullable)msg {
    NSLog(@"LiveModule::onLogout( [Http注销通知], type : %d, msg : %@ )", type, msg);

    // Http注销
    @synchronized(self) {
        self.sessionId = nil;
        self.manId = nil;
    }

    dispatch_async(dispatch_get_main_queue(), ^{

        if (type == LogoutTypeKick || type == LogoutTypeActive) {
            [_moduleVC.view removeFromSuperview];
            [_moduleVC removeFromParentViewController];
            _moduleVC = nil;
        }
        BOOL kick = (type != LogoutTypeRelogin);
        [[LSLiveChatManagerOC manager] logoutUser:kick];

        [self.imManager resetIMStatus];
        // 通知外部模块停止
        if ([self.delegate respondsToSelector:@selector(moduleOnLogout:type:msg:)]) {
            [self.delegate moduleOnLogout:self type:type msg:msg];
        }
    });
}

#pragma mark - IM通知
- (void)onHandleLoginRoom:(NSString *_Nonnull)roomId userId:(NSString *_Nullable)userId userName:(NSString *_Nullable)userName {
    // TODO:第一次登陆成功, 通知QN强制进入直播间
    NSLog(@"LiveModule::onHandleLoginRoom( [第一次登陆成功, 通知QN强制进入直播间], roomId : %@, userId : %@, userName : %@ )", roomId, userId, userName);

    dispatch_async(dispatch_get_main_queue(), ^{
        // 生成直播间跳转的URL
        NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:roomId anchorId:userId roomType:LiveRoomType_Private];
        [[LiveMutexService service] openUrlByLive:url];
    });
}

- (void)onHandleLoginInvite:(ImInviteIdItemObject *_Nonnull)inviteItem {
    // TODO:第一次登陆成功, 通知QN强制进入有效的立即私密邀请
    NSLog(@"LiveModule::onHandleLoginInvite( [第一次登陆成功, 通知QN强制进入有效的立即私密邀请], invitationId : %@, roomId : %@, userId : %@, replyType : %d )", inviteItem.invitationId, inviteItem.roomId, inviteItem.oppositeId, (int)inviteItem.replyType);

    dispatch_async(dispatch_get_main_queue(), ^{
        // 生成直播间跳转的URL
        NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:inviteItem.roomId anchorId:inviteItem.oppositeId roomType:LiveRoomType_Private];
        [[LiveMutexService service] openUrlByLive:url];
    });
}

- (void)onRecvInstantInviteUserNotice:(NSString *_Nonnull)inviteId anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    // TODO:接收主播立即私密邀请通知
    NSLog(@"LiveModule::onRecvInstantInviteUserNotice( [接收主播立即私密邀请通知], show : %@, inviteId : %@, userId : %@, userName : %@, msg : %@ )", BOOL2YES(_moduleVC.navigationController), inviteId, anchorId, nickName, msg);

    dispatch_async(dispatch_get_main_queue(), ^{
        // 当前在直播模块
        if (_moduleVC.navigationController) {
            // 当前主播私密邀请能否显示
            if ([_liveGobalManager canShowInvite:anchorId] || !_liveGobalManager.isHangouting) {
                // 生成直播间跳转的URL
                NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByInviteId:inviteId anchorId:anchorId anchorName:nickName];
                // 弹出通知
                [self pushMessageToCenter:[url absoluteString] andNickName:nickName];
            } else {
                // 无法显示主播立即私密邀请
                [self.imManager InstantInviteUserReport:inviteId
                                                 isShow:NO
                                          finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg) {
                                              NSLog(@"LiveModule::InstantInviteUserReport( [当前主播私密邀请无法显示], success : %d, errtype : %d, errmsg : %@ )", success, errType, errMsg);
                                          }];
            }
        }
    });
}

- (void)onRecvBookingNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg leftSeconds:(int)leftSeconds {
    // TODO:接收主播预约开始倒数邀请通知
    NSLog(@"LiveModule::onRecvBookingNotice( [接收预约开始倒数通知], roomId : %@, userId : %@, userName : %@, leftSeconds : %d )", roomId, userId, nickName, leftSeconds);
}

- (void)onRecvProgramPlayNotice:(IMProgramItemObject *)item type:(IMProgramNoticeType)type msg:(NSString *_Nonnull)msg {
    // TODO:接收节目开播通知接口
    NSLog(@"LiveModule::onRecvProgramPlayNotice( [接收节目开播通知], showLiveId : %@, anchorId : %@, anchorNickName : %@, type : %d )", item.showLiveId, item.anchorId, item.anchorNickName, type);
}

- (void)onHandleLoginOnGingShowList:(NSArray<IMOngoingShowItemObject *> *)ongoingShowList {
    IMOngoingShowItemObject *item = [ongoingShowList firstObject];
    NSLog(@"LiveModule::onHandleLoginOnGingShowList( [接收节目开播通知], showLiveId : %@, anchorId : %@, anchorNickName : %@, type : %d )", item.showInfo.showLiveId, item.showInfo.anchorId, item.showInfo.anchorNickName, item.type);
    [self onRecvProgramPlayNotice:item.showInfo type:item.type msg:item.msg];
}

#pragma mark - Application
- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"LiveModule::applicationDidEnterBackground()");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"LiveModule::applicationWillEnterForeground()");
    [LiveGobalManager manager].enterRoomBackgroundTime = nil;

    //    if (self.loginManager.status == LOGINED) {
    //      [[LSLiveChatManagerOC manager] relogin];
    //    }
}

#pragma mark - LiveChat
- (void)onRecvKickOffline:(KICK_OFFLINE_TYPE)kickType {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveModule::onRecvKickOffline( [接收LivechatManager被踢下线通知回调], kickType : %d )", kickType);
        if (KOT_OTHER_LOGIN == kickType) {
            // 注销PHP
            [[LSLoginManager manager] logout:LogoutTypeKick msg:NSLocalizedString(@"Tips_You_Have_Been_Kick", nil)];
        }
    });
}

- (void)onLogout:(LSLIVECHAT_LCC_ERR_TYPE)errType errmsg:(NSString *)errmsg isAutoLogin:(BOOL)isAutoLogin {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveModule::onLogout( [接收LivechatManager注销通知回调], errmsg : %@ )", errmsg);
    });
}

- (void)pushMessageToCenter:(NSString *)url andNickName:(NSString *)nickName {
    [[LiveModule module].analyticsManager reportActionEvent:ShowInvitation eventCategory:EventCategoryGobal];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"PUSH_INVITE_TIP", nil),nickName];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = @{@"jumpurl":url};
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
        notification.repeatInterval = NSCalendarUnitDay;
    }else{
        notification.repeatInterval = NSCalendarUnitDay;
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end

