//
//  AppDelegate.m
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "AppDelegate.h"

#import <UserNotifications/UserNotifications.h>

#import "RequestManager.h"
#import "FileCacheManager.h"
#import "LoginManager.h"
#import "IMManager.h"

#import "FirebaseCore/FIRApp.h"

@implementation AppDelegate
@synthesize demo = _demo;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 设置公共属性
    _debug = NO;
    
    // 初始化Crash Log捕捉
//    [CrashLogManager manager];
    
//    [FIRApp configure];
    
    // 状态栏白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // 注册推送
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    // 为Document目录增加iTunes不同步属性
    NSURL *url = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    [url addSkipBackupAttribute];
    
    // 设置导航默认返回键
//    KKNavigationController *nvc = (KKNavigationController *)self.window.rootViewController;
//    [nvc.navigationBar setTintColor:[UIColor whiteColor]];
    
    // 设置接口管理类属性
    RequestManager* manager = [RequestManager manager];
    [manager setLogEnable:YES];
    [manager setLogDirectory:[[FileCacheManager manager] requestLogPath]];
    [manager setWebSite:@"http://172.25.32.17:3007"];
    
    // 设置接口请求环境
    // 如果调试模式, 直接进入正式环境
    [self setRequestHost:_debug];
    
    // 初始化登录管理器
    LoginManager* loginManager = [LoginManager manager];
    
    // 初始化IM
    IMManager* imManager = [IMManager manager];
    
    // 初始化跟踪管理器(默认为真实环境)
//    [[AnalyticsManager manager] initGoogleAnalytics:YES];
    
    // 初始化支付管理器
//    [PaymentManager manager];
    
    // 自动登陆
//    [[LoginManager manager] autoLogin];
    
    // 清除webview的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    // 注册推送
    [self registerRemoteNotifications:application];
    
    // 延长启动画面时间
    // usleep(1000 * 1000);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 标记为后台
    self.isBackground = YES;

    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Do the work associated with the task, preferably in chunks.
        
        while(self.isBackground) {
            NSTimeInterval left = [application backgroundTimeRemaining];
            NSLog(@"AppDelegate::applicationDidEnterBackground( left : %f )", left);
            sleep(5);
        }
        
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // 标记为前台
    self.isBackground = NO;
    
    // 清空推送
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    // 前后台切换强制重登录

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"application::didRegisterForRemoteNotificationsWithDeviceToken( deviceToken : %@ )", deviceToken);

    NSString *deviceTokenStr = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *deviceTokenSave = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:deviceTokenSave forKey:deviceTokenStringKEY];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"application::didReceiveRemoteNotification( userInfo : %@ )", userInfo);
    
    NSString* urlString = [userInfo objectForKey:@"jumpurl"];
    if( urlString.length > 0 ) {
//        NSURL* url = [NSURL URLWithString:urlString];
//        [[URLHandler shareInstance] handleOpenURL:url];
    }

}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    NSLog(@"application::handleOpenURL( url : %@ )", url);
//    return [[URLHandler shareInstance] handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    NSLog(@"application::openURL( sourceApplication : %@ )", sourceApplication);
//    return [[URLHandler shareInstance] handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
//    NSLog(@"application::openURL( options : %@ )", options);
//    return [[URLHandler shareInstance] handleOpenURL:url];
    return YES;
}

- (void)setRequestHost:(BOOL)formal {
//    RequestManager* manager = [RequestManager manager];
    if( formal ) {
        // 配置真是环境
        if( _demo ) {
            // Demo环境

        } else {

        }
        
    } else {
        // 配置假服务器路径
        if( _demo ) {

        } else {

        }
    }

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

- (void)registerRemoteNotifications:(UIApplication *)application {
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

@end
