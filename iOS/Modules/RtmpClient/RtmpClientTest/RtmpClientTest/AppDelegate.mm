

//
//  AppDelegate.m
//  RtmpClientTest
//
//  Created by Max on 2017/4/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AppDelegate.h"
#import "PronViewController.h"
#include <common/KLog.h>

#pragma mark - 跟踪
#import <Firebase.h>

@interface AppDelegate ()
@end

@implementation AppDelegate
- (BOOL)firstTimeActive {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL firstTimeActive = [userDefaults boolForKey:@"firstTimeActive"];

    if (!firstTimeActive) {
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:req
                                                completionHandler:^(NSData *__nullable data, NSURLResponse *__nullable response, NSError *__nullable error) {
                                                    if (!error) {
                                                        NSLog(@"response:%@", response);
                                                    } else {
                                                        NSLog(@"error:%@", error);
                                                    }
                                                }];
        [task resume];
    }
    
    return firstTimeActive;
}

- (void)setFirstTimeActive:(BOOL)firstTimeActive {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:firstTimeActive forKey:@"firstTimeActive"];
    [userDefaults synchronize];
}

- (BOOL)subscribed {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL subscribed = [userDefaults boolForKey:@"subscribed"];
    return subscribed;
}

- (void)setSubscribed:(BOOL)subscribed {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:subscribed forKey:@"subscribed"];
    [userDefaults synchronize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    KLog::SetLogFileEnable(NO);
    KLog::SetLogLevel(KLog::LOG_WARNING);
    
    [FIRApp configure];
    [self firstTimeActive];
    self.firstTimeActive = YES;
    self.subscribed = NO;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    return [self handleOpenURL:url options:options];
}

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    NSLog(@"handleOpenURL(), url: %@, options: %@", url, options);
    BOOL bFlag = NO;
    if (!url) {
        return bFlag;
    }
    
    NSURLComponents *cmp = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSMutableArray *queryItems = [NSMutableArray arrayWithArray:cmp.queryItems];
    for(NSURLQueryItem *item in queryItems) {
        if ([[item.name lowercaseString] isEqualToString:@"baseurl"] && item.value.length > 0) {
            UINavigationController *nvc = (UINavigationController *)self.window.rootViewController;
            [nvc popToRootViewControllerAnimated:NO];
            
            PronViewController *vc = [[PronViewController alloc] init];
            vc.baseUrl = item.value;
            [nvc pushViewController:vc animated:NO];
            break;
        }
    }
    
    return bFlag;
}

@end
