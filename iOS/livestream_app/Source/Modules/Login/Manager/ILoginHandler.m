//
//  ILoginHandler.m
//  livestream
//
//  Created by Calvin on 2017/12/21.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ILoginHandler.h"

@implementation ILoginHandler

- (BOOL)login:(LoginHandler)loginHandler
{
    return YES;
}

- (BOOL)logout:(LogoutHandler)logoutHandler
{
    self.loginInfo = nil;
    // 清除用户信息
    [self closeLoginParam];
    return YES;
}

- (BOOL)autoLogin:(LoginHandler)loginHandler
{
    return YES;
}

- (BOOL)registerHandler:(LoginHandler)registerHandler
{
    return YES;
}

- (void)closeLoginParam
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"LoginInfo"];
    [userDefaults synchronize];
}

@end
