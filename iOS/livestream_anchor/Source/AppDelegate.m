//
//  AppDelegate.m
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "AppDelegate.h"

#import <UserNotifications/UserNotifications.h>
#import <AVFoundation/AVFoundation.h>

#pragma mark - 公共模块
#import "LSAnchorRequestManager.h"
#import "LSFileCacheManager.h"
#import "LiveStreamSession.h"
#import "LiveUrlHandler.h"
#import "LiveModule.h"
#import "CrashLogManager.h"

#pragma mark - Http Server
#import "GCDWebDAVServer.h"
#import "LSUrlParmItem.h"
@interface AppDelegate ()
@property (strong) GCDWebServer *httpServer;
@end

@implementation AppDelegate
@synthesize demo = _demo;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self didFinishLaunchWithApplication:application];
    
    return YES;
}

- (void)didFinishLaunchWithApplication:(UIApplication *)application {
    self.window.backgroundColor = [UIColor whiteColor];
 
    // 为Document目录增加iTunes不同步属性
    NSURL *url = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    [LSURLFileAttribute addSkipBackupAttribute:url];
    
    [CrashLogManager manager];
    
    // 设置接口请求环境
    [self setRequestHost];
    
    [self reachability];
    
    // 真机抓包代理
//    [LSRequestManager setProxy:@"http://172.25.32.80:8888"];
    
    // 清除webview的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    //每次启动app只显示一次更新提示
    [self setUpdateState];
    
    // 注册推送
    [self registerRemoteNotifications:application];

    // 启动Http服务
//    self.httpServer = [[GCDWebServer alloc] init];
//    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    [self.httpServer addGETHandlerForBasePath:@"/" directoryPath:documentsPath indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
//    [self.httpServer start];

}

- (void)setUpdateState
{
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"showUpdateDialog"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"showMandatoryUpdateDialog"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"AppDelegate::applicationWillResignActive()");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"AppDelegate::applicationDidEnterBackground()");
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"AppDelegate::applicationWillEnterForeground()");
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"AppDelegate::applicationDidBecomeActive()");
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"AppDelegate::applicationWillTerminate()");
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"AppDelegate::didRegisterForRemoteNotificationsWithDeviceToken( deviceToken : %@ )", deviceToken);

    [self didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"AppDelegate::didRegisterForRemoteNotificationsWithDeviceToken( deviceToken : %@ )", deviceToken);
    
    NSString *deviceTokenStr = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *deviceTokenSave = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:deviceTokenSave forKey:deviceTokenStringKEY];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"AppDelegate::didReceiveRemoteNotification( userInfo : %@ )", userInfo);

}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"AppDelegate::didRegisterUserNotificationSettings( notificationSettings : %@ )", notificationSettings);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"AppDelegate::handleOpenURL( url : %@ )", url);
    [self handleTestUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"AppDelegate::openURL( url : %@, sourceApplication : %@ )", url, sourceApplication);
    [self handleTestUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    NSLog(@"AppDelegate::openURL( url : %@ , options : %@ )", url, options);
    [self handleTestUrl:url];
    return YES;
}

- (void)registerRemoteNotifications:(UIApplication *)application {
    NSLog(@"AppDelegate::registerRemoteNotifications()");
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // Register for Push Notitications, if running iOS 8
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
        
    }
    
    // 清除图标数字, 清空通知栏
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

- (void)setRequestHost{
    LSAnchorRequestManager* manager = [LSAnchorRequestManager manager];
    NSString* webSite = @"";
    // 配置假服务器路径
    if( self.demo ) {
        webSite = @"https://demo.charmlive.com";
 //       webSite = @"http://192.168.88.17:8817";
//        webSite = @"http://172.25.32.17:8817";
        
    } else {
        // 配置真是环境
        webSite = @"https://www.charmlive.com";
    }
    [manager setConfigWebSite:webSite];
}

- (BOOL)demo {
    // 如果版本号最后一位是字母,则是demo
    NSString *versionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    char lastCode = [versionCode characterAtIndex:versionCode.length - 1];
    if ((lastCode >= 'a' && lastCode <= 'z') || (lastCode >= 'A' && lastCode <= 'Z')) {
        _demo = YES;
    } else {
        _demo = NO;
    }
    return _demo;
}

- (void)reachability
{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                NSLog(@"未知网络");
                self.isNetwork = NO;
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                NSLog(@"没有网络(断网)");
                self.isNetwork = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                NSLog(@"手机自带网络");
                self.isNetwork = YES;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                NSLog(@"WIFI");
                self.isNetwork = YES;
                break;
        }
    }];
    // 3.开始监控
    [mgr startMonitoring];
}

- (void)handleTestUrl:(NSURL *)url {
    // TODO:启动连接是否带有测试标记
    NSString *test = [LSURLQueryParam urlParamForKey:@"test" url:url];
    BOOL bTest = [test boolValue];
    if( bTest ) {
        // 启动Http服务
        if( self.httpServer.running ) {
            [self.httpServer stop];
        }
        [self.httpServer startWithPort:8080 bonjourName:@""];
    }
    
   NSString *proxy = [LSURLQueryParam urlParamForKey:@"httpproxy" url:url];
    if (proxy) {
       [LSAnchorRequestManager setProxy:proxy];
    }
}

@end
