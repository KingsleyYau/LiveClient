//
//  LiveModuleManager.m
//  livestream
//
//  Created by randy on 2017/8/3.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveModule.h"

#import "MainViewController.h"
#import "LiveChannelAdViewController.h"

#import "LoginManager.h"
#import "RequestManager.h"
#import "SessionRequestManager.h"
#import "IMManager.h"

#import "LiveGiftListManager.h"
#import "LiveGiftDownloadManager.h"
#import "LiveStreamSession.h"
#import "FileCacheManager.h"
#import "BackpackSendGiftManager.h"
#import "UserInfoManager.h"
#import "LiveRoomCreditRebateManager.h"

#import "GetAnchorListRequest.h"
#import "LiveChannelAdView.h"

#import "IQNService.h"
#import "IServiceManager.h"

#import "Dialog.h"

static LiveModule *gMmodule = nil;
@interface LiveModule () <LoginManagerDelegate, IQNService, IMLiveRoomManagerDelegate, IMManagerDelegate> {
    UIViewController *_moduleViewController;
}

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) SessionRequestManager *sessionManager;
@property (nonatomic, strong) LoginManager *loginManager;
@property (nonatomic, strong) IMManager *imManager;
@property (nonatomic, strong) LiveGiftListManager *giftListManager;
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;
@property (nonatomic, strong) BackpackSendGiftManager *backGiftManager;
@property (nonatomic, strong) LiveChannelAdViewController *liveChannel;
#pragma mark - 余额及返点信息管理器
@property (nonatomic, strong) LiveRoomCreditRebateManager *creditRebateManager;

@end

@implementation LiveModule
#pragma mark - 获取实例
+ (instancetype)module {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!gMmodule) {
            gMmodule = [[LiveModule alloc] init];
        }
    });
    return gMmodule;
}

- (id)init {
    if (self = [super init]) {
        // 模块主界面
        _moduleViewController = nil;
        // 初始化Http登陆管理器
        self.loginManager = [LoginManager manager];
        [self.loginManager addDelegate:self];
        // 初始化IM管理器
        self.imManager = [IMManager manager];
        [self.imManager addDelegate:self];
        [self.imManager.client addDelegate:self];
        // 初始化礼物下载器
        self.giftListManager = [LiveGiftListManager manager];
        self.giftDownloadManager = [LiveGiftDownloadManager manager];
        // 初始化背包礼物管理器
        self.backGiftManager = [BackpackSendGiftManager backpackGiftManager];
        // 初始session管理器
        self.sessionManager = [SessionRequestManager manager];
        // 初始化用户信息管理器
        [UserInfoManager manager];
        // 初始化余额及返点信息管理器
        self.creditRebateManager = [LiveRoomCreditRebateManager creditRebateManager];
        // 清除webview的缓存
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        // 开启后台播放
        [[LiveStreamSession session] activeSession];
        // 设置接口管理类属性
        [RequestManager setLogEnable:YES];
        [RequestManager setLogDirectory:[[FileCacheManager manager] requestLogPath]];
        RequestManager *manager = [RequestManager manager];
        [manager setWebSite:@"http://172.25.32.17:3107"];
        //[manager setWebSite:@"http://192.168.88.17:3107"];

        // QNService
        _serviceManager = nil;
    }
    return self;
}

- (void)dealloc {
    if (_serviceManager) {
        [_serviceManager removeService:self];
    }
    [self.imManager.client removeDelegate:self];
    [self.imManager removeDelegate:self];
    [self.loginManager removeDelegate:self];
}

- (void)setServiceManager:(IServiceManager *)serviceManager {
    _serviceManager = serviceManager;
    [_serviceManager addService:self];
}

- (BOOL)start:(NSString *)token {
    BOOL bFlag = YES;

    NSLog(@"LiveModule::start( token : %@ )", token);

    @synchronized(self) {
        self.token = token;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginManager login:self.token];
    });

    return bFlag;
}

- (void)stop {
    NSLog(@"LiveModule::stop( token : %@ )", self.token);

    @synchronized(self) {
        self.token = nil;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginManager logout:YES msg:@""];
        [self.imManager logout];
    });
}

- (void)setModuleViewController:(UIViewController *)vc {
    _moduleViewController = vc;
}

- (UIViewController *)moduleViewController {
    if (!_moduleViewController) {
        _moduleViewController = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    }
    return _moduleViewController;
}

#pragma mark - HTTP登录回调
- (void)manager:(LoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject *_Nullable)loginItem errnum:(NSInteger)errnum errmsg:(NSString *_Nonnull)errmsg {
    if (success) {
        // Http登陆成功
        if( [self.delegate respondsToSelector:@selector(moduleOnLogin:)] ) {
            [self.delegate moduleOnLogin:self];
        }
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 继续登陆
            if (self.token) {
                [self.loginManager login:self.token];
            }
        });
    }
}

- (void)manager:(LoginManager *_Nonnull)manager onLogout:(BOOL)kick msg:(NSString *)msg {
    // Http注销
    @synchronized(self) {
        self.token = nil;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        // 停止直播间, 退出到模块入口
        [self stopService];
        
        // 通知外部模块停止
        if ([self.delegate respondsToSelector:@selector(module:onLogout:msg:)]) {
            [self.delegate module:self onLogout:kick msg:msg];
        }
    });
}

#pragma mark - IM通知
- (void)onHandleLoginRoom:(NSString * _Nonnull)roomId {
    // TODO:第一次登陆成功, 通知QN强制进入直播间
    NSLog(@"LiveModule::onHandleLoginRoom( roomId : %@ )", roomId);
    
    if( self.serviceManager ) {
        NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&roomid=%@", roomId];
        [self.serviceManager openSpecifyService:[NSURL URLWithString:urlString] fromVC:nil];
    }
}

- (void)onHandleLoginInvite:(ImInviteIdItemObject * _Nonnull)inviteItem {
    // TODO:第一次登陆成功, 通知QN强制进入有效的立即私密邀请
    NSLog(@"LiveModule::onHandleLoginInvite( roomId : %@, userId : %@, replyType : %d )", inviteItem.roomId, inviteItem.oppositeId, (int)inviteItem.replyType);
    
    if( self.serviceManager ) {
        NSString *urlString = [NSString stringWithFormat:@"qpidnetwork://app/open?service=live&module=liveroom&roomid=%@anchorid=%@&roomtype=1", inviteItem.roomId, inviteItem.oppositeId];
        [self.serviceManager openSpecifyService:[NSURL URLWithString:urlString] fromVC:nil];
    }
}

#pragma mark - 广告
- (void)getAdView {
    GetAnchorListRequest *request = [[GetAnchorListRequest alloc] init];

    int start = 1;

    // 每页最大纪录数
    request.start = start;
    request.step = 4;
    request.hasWatch = NO;

    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            NSLog(@"HotViewController::getListRequest( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            NSMutableArray *dataArray = [NSMutableArray array];
            if (success) {
                dataArray = (NSMutableArray *)array;
            }

            LiveChannelAdViewController *liveChannel = [[LiveChannelAdViewController alloc] initWithNibName:nil bundle:nil];
            LiveChannelAdView *adView = [LiveChannelAdView initWithLiveChannelAdViewXib:liveChannel];
            adView.contentView.items = dataArray;
            [adView.contentView reloadData];
            self.liveChannel = liveChannel;

            adView.contentView.liveChannelDelegate = self.liveChannel;
            ;
            adView.adViewDelegate = self.liveChannel;
            ;
            if ([self.delegate respondsToSelector:@selector(module:onGetAdView:)]) {
                [self.delegate module:self onGetAdView:adView];
            }

        });

    };

    [self.sessionManager sendRequest:request];
}

#pragma mark - QN交互
- (NSString *)getServiceName {
    return @"live";
}

- (NSString *)getServiceConflict {
    return @"live module tips";
}

- (void)openUrl:(NSURL *)url fromVC:(UIViewController *)vc {
    // 跳转到指定界面
    NSLog(@"LiveModule::openUrl( url : %@, vc : %@ )", url, vc);
    
    self.fromVC = vc;
}

- (BOOL)isStopService:(NSURL *)url {
    return NO;
}

- (void)stopService {
    // 停止服务
    NSLog(@"LiveModule::stopService()");
    
    // 强制关闭过渡和直播间界面
    if( _moduleViewController ) {
        UIViewController *vc = _moduleViewController.navigationController.topViewController;
        [vc dismissViewControllerAnimated:YES completion:nil];
        
        // 退出其他导航栏界面
        if( self.fromVC ) {
            // 从其他界面推进
            [_moduleViewController.navigationController popToViewController:self.fromVC animated:YES];
        } else {
            // 直接显示
            [_moduleViewController.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
    @synchronized(self) {
        self.fromVC = nil;
    }
}

@end
