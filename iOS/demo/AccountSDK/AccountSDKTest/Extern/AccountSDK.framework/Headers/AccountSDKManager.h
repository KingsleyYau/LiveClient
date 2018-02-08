//
//  AccountSDKManager.h
//  AccountSDK
//
//  Created by Max on 2017/12/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AccountSDKProfile.h"
#import "ACCountSDKShareItem.h"

@class AccountSDKManager;

typedef enum AccountSDKType {
    AccountSDKType_Unknow,
    AccountSDKType_Facebook,
    AccountSDKType_Twitter,
} AccountSDKType;

typedef void (^AccountLoginHandler)(BOOL success, NSError *error);
typedef void (^AccountProfileHandler)(BOOL success, NSError *error, AccountSDKProfile *profile);
typedef void (^AccountShareHandler)(BOOL success, NSError *error);

@interface AccountSDKManager : NSObject

@property (readonly) AccountSDKType type;
@property (readonly) NSString *token;

/**
 Get gobal instance

 @return instance
 */
+ (instancetype)shareInstance;

/**
 Auto login
 */
- (BOOL)autoLogin:(AccountLoginHandler)handler;

/**
 Login
 
 @param type Thirty type
 @param vc ViewController object
 @param handler Operation finish handler
 @return success/fail
 */
- (BOOL)login:(AccountSDKType)type vc:(UIViewController *)vc handler:(AccountLoginHandler)handler;

/**
 Logout
 */
- (void)logout;

/**
 Get profile

 @param handler Operation finish handler
 */
- (BOOL)getProfile:(AccountProfileHandler)handler;

/**
 Share item

 @param type Thirty type
 @param vc ViewController object
 @param shareItem Share info item
 @param handler Operation finish handler
 @return success/fail
 */
- (BOOL)shareItem:(AccountSDKType)type vc:(UIViewController *)vc shareItem:(ACCountSDKShareItem *)shareItem handler:(AccountShareHandler)handler;

#pragma mark - Thirdparty callback
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
