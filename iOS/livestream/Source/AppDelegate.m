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

#import "LSRequestManager.h"
#import "LSFileCacheManager.h"
#import "LiveStreamSession.h"

#import "LiveUrlHandler.h"
#import "LiveModule.h"

@implementation AppDelegate
@synthesize demo = _demo;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self didFinishLaunchWithApplication:application];
    
    return YES;
}

- (void)didFinishLaunchWithApplication:(UIApplication *)application {
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 设置公共属性
    _debug = NO;
    
    NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]] delegate:nil startImmediately:YES];
    // 初始化Crash Log捕捉
//    [CrashLogManager manager];
    
    // 状态栏白色
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // 注册推送
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    // 为Document目录增加iTunes不同步属性
    NSURL *url = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    [LSURLFileAttribute addSkipBackupAttribute:url];
    
    // 设置导航默认返回键
//    LSNavigationController *nvc = (LSNavigationController *)self.window.rootViewController;
//    [nvc.navigationBar setTintColor:[UIColor whiteColor]];
    
    // 设置接口管理类属性
    [LSRequestManager setLogEnable:YES];
    [LSRequestManager setLogDirectory:[[LSFileCacheManager manager] requestLogPath]];
    
    // 设置接口请求环境
    // 如果调试模式, 直接进入正式环境
    [self setRequestHost:_debug];
    
    // 初始化跟踪管理器(默认为真实环境)
//    [[AnalyticsManager manager] initGoogleAnalytics:YES];
//    [[FIRAnalyticsConfiguration sharedInstance] setAnalyticsCollectionEnabled:NO];
//    [[FIRConfiguration sharedInstance] setLoggerLevel:FIRLoggerLevelMin];
//    [FIRApp configure];
    
    // 初始化支付管理器
//    [PaymentManager manager];
    [LiveUrlHandler shareInstance];
    
    // 清除webview的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    // 注册推送
    [self registerRemoteNotifications:application];

    // 开启后台播放
    [[LiveStreamSession session] activeSession];

    // 延长启动画面时间
    // usleep(1000 * 1000);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"AppDelegate::didRegisterForRemoteNotificationsWithDeviceToken( deviceToken : %@ )", deviceToken);

    [self didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *deviceTokenStr = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *deviceTokenSave = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:deviceTokenSave forKey:deviceTokenStringKEY];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"AppDelegate::didReceiveRemoteNotification( userInfo : %@ )", userInfo);

}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    NSLog(@"application::handleOpenURL( url : %@ )", url);
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    NSLog(@"application::openURL( sourceApplication : %@ )", sourceApplication);
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
//    NSLog(@"application::openURL( options : %@ )", options);
    return YES;
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

- (void)setRequestHost:(BOOL)formal {
//    LSRequestManager* manager = [LSRequestManager manager];
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

@end
