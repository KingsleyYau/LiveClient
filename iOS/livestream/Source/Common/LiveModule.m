//
//  LiveModuleManager.m
//  livestream
//
//  Created by randy on 2017/8/3.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveModule.h"

#import "MainViewController.h"

#import "LoginManager.h"
#import "RequestManager.h"
#import "SessionRequestManager.h"
#import "IMManager.h"
#import "LiveGiftDownloadManager.h"
#import "LiveStreamSession.h"
#import "FileCacheManager.h"

static LiveModule *gMmodule = nil;
@interface LiveModule () <LoginManagerDelegate> {
    UIViewController *_moduleViewController;
}

@property (nonatomic, strong) NSString *token;

@property (nonatomic, strong) SessionRequestManager* sessionManager;
@property (nonatomic, strong) LoginManager *loginManager;
@property (nonatomic, strong) IMManager *imManager;
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;

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
    if( self = [super init] ) {
        // 初始化Http登陆管理器
        self.loginManager = [LoginManager manager];
        [self.loginManager addDelegate:self];
        // 初始化IM管理器
        self.imManager = [IMManager manager];
        // 初始化礼物下载器
        self.giftDownloadManager = [LiveGiftDownloadManager giftDownloadManager];
        // 清除webview的缓存
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        // 开启后台播放
        [[LiveStreamSession session] activeSession];
        // 设置接口管理类属性
        [RequestManager setLogEnable:YES];
        [RequestManager setLogDirectory:[[FileCacheManager manager] requestLogPath]];
        RequestManager* manager = [RequestManager manager];
        [manager setWebSite:@"http://172.25.32.17:3107"];
        
        _moduleViewController = nil;
    }
    return self;
}

- (BOOL)start:(NSString *)token {
    BOOL bFlag = YES;
    
    NSLog(@"LiveModule::start( token : %@ )", token);
    
    @synchronized (self) {
        self.token = token;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginManager login:self.token];
    });
    
    return bFlag;
}

- (void)stop {
    NSLog(@"LiveModule::stop( token : %@ )", self.token);
    
    @synchronized (self) {
        self.token = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginManager logout:YES];
    });
}

- (void)setModuleViewController:(UIViewController *)vc {
    _moduleViewController = vc;
}

- (UIViewController *)moduleViewController {
    if( !_moduleViewController ) {
        _moduleViewController = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    }
    return _moduleViewController;
}

#pragma mark - HTTP登录回调
- (void)manager:(LoginManager *_Nonnull)manager onLogin:(BOOL)success loginItem:(LoginItemObject *_Nullable)loginItem errnum:(NSInteger)errnum errmsg:(NSString *_Nonnull)errmsg {
    if (success) {
        // Http登陆成功
        
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 继续登陆
            if( self.token ) {
                [self.loginManager login:self.token];
            }
        });
    }
}

- (void)manager:(LoginManager *_Nonnull)manager onLogout:(BOOL)kick {
    // Http注销
    @synchronized (self) {
        self.token = nil;
    }
    
    if( [self.delegate respondsToSelector:@selector(module:onLogout:)] ) {
        [self.delegate module:self onLogout:kick];
    }
}

@end
