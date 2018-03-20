//
//  MailLoginHandler.m
//  livestream
//
//  Created by Calvin on 2017/12/21.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "MailLoginHandler.h"
#import "LSEmailLoginRequest.h"
#import "LSEmailRegisterRequest.h"
@implementation MailLoginHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSDictionary * loginDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginInfo"];
        if (loginDic.allKeys > 0 && [[loginDic objectForKey:@"Type"] isEqualToString:@"Email"])
        {
            self.email = [loginDic objectForKey:@"Email"];
            self.password = [loginDic objectForKey:@"Password"];
        }
    }
    return self;
}

- (instancetype)initWithUserId:(NSString *)userId andPassword:(NSString *)password
{
    self = [super init];
    if (self) {
        self.email = userId;
        self.password = password;
    }
    return self;
}

- (BOOL)login:(LoginHandler)loginHandler
{
    __block BOOL bFlag = NO;
    LSEmailLoginRequest * request = [[LSEmailLoginRequest alloc]init];
    request.email = self.email;
    request.passWord = self.password;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull sessionId) {
        
    NSLog(@"MailLoginHandler::LSEmailLoginRequest success:%d, errnum:%d, error:%@, sessionId:%@",success, errnum, errmsg, sessionId);
        
        if (success) {
            bFlag = YES;
            [self saveLoginParam];
        } else {
            bFlag = NO;
        }
        loginHandler(success, errnum, errmsg, sessionId);
    };
    [[LSSessionRequestManager manager] sendRequest:request];
    
    return bFlag;
}

- (void)saveLoginParam{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dic = @{@"Email":self.email,
                           @"Password":self.password,
                           @"Type":@"Email"
                           };
    [userDefaults setObject:dic forKey:@"LoginInfo"];
    [userDefaults synchronize];
    
    [[NSUserDefaults standardUserDefaults]setObject:self.email forKey:@"LoginEmail"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)logout:(LogoutHandler)logoutHandler
{
    return [super logout:logoutHandler];
}

- (BOOL)autoLogin:(LoginHandler)loginHandler
{
    return [self login:loginHandler];
}

- (BOOL)registerHandler:(LoginHandler)registerHandler
{
    __block BOOL bFlag = NO;
    LSEmailRegisterRequest * request = [[LSEmailRegisterRequest alloc]init];
    request.email = self.loginInfo.email;
    request.passWord = self.loginInfo.password;
    request.gender = self.loginInfo.gender;
    request.birthDay = self.loginInfo.birthday;
    request.nickName = self.loginInfo.nickName;
    request.inviteCode = self.loginInfo.inviteCode;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull sessionId) {
        if (success) {
            bFlag = YES;
        } else {
            bFlag = NO;
        }
        registerHandler(success, errnum, errmsg, sessionId);
    };
    
    [[LSSessionRequestManager manager]sendRequest:request];
    
    return bFlag;
}

@end
