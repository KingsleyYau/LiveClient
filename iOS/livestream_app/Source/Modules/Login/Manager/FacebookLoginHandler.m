//
//  FacebookLoginHandler.m
//  livestream
//
//  Created by Calvin on 2017/12/21.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "FacebookLoginHandler.h"
#import "LSFackBookLoginRequest.h"
#import "LSCheckMailRequest.h"
#import "LSEmailRegisterRequest.h"
#import "LSSessionRequestManager.h"
#import "LSRequestManager.h"
#import "LSLoginManager.h"
#define TOKENOUTOFMSG @"Facebook token is out of date"
#define TOKENOUTOFNUM -10000
#define FACEBOOKLOGOUTNUM 666
#define FACEBOOKLOGOUTMSG @"Facebook token Has been cleared"

@interface FacebookLoginHandler()

typedef void (^facebookLoginHandler)(BOOL success, NSError *error, NSString* token);
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (nonatomic, strong) UIViewController *presentVC;
@property (nonatomic, copy) NSString *token;
@end


@implementation FacebookLoginHandler

- (instancetype)initWithPresentVC:(UIViewController *)vc
{
    self = [super init];
    if (self) {
        self.presentVC = vc;
        self.sessionManager = [LSSessionRequestManager manager];
        [AccountSDKManager shareInstance].type = AccountSDKType_Facebook;
    }
    return self;
}

- (BOOL)login:(LoginHandler _Nullable)loginHandler
{
    // 获取本地token 有就自动登录
    [self loadLoginParam];
    if (self.token) {
        [self fackBookLoginRequest:self.token finshHandler:loginHandler];
    } else {
        
        [[AccountSDKManager shareInstance] logout];
        WeakObject(self, weakSelf);
        [self facebookLogin:^(BOOL success, NSError *error, NSString* token) {
            if (success) {
                [weakSelf fackBookLoginRequest:token finshHandler:loginHandler];
            } else {
                [LSLoginManager manager].status = NONE;
            }
        }];
    }
    return [super login:loginHandler];
}

- (BOOL)logout:(LogoutHandler)logoutHandler
{
    self.token = nil;
    [[AccountSDKManager shareInstance] logout];
    
    
    return [super logout:logoutHandler];
}

- (BOOL)bingdingHandler:(LoginHandler)bingdingHandler {
    __block BOOL bFlag = NO;
    LSFackBookLoginRequest *request = [[LSFackBookLoginRequest alloc] init];
    request.fToken = self.loginInfo.token;
    request.email = self.loginInfo.email;
    request.passWord = self.loginInfo.password;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull sessionId) {
        if (success) {
            bFlag = YES;
        } else {
            bFlag = NO;
        }
        bingdingHandler(success, errnum, errmsg, sessionId);
    };
    [self.sessionManager sendRequest:request];
    
    return bFlag;
}

- (BOOL)registerHandler:(LoginHandler)registerHandler {
    __block BOOL bFlag = NO;
    LSFackBookLoginRequest *request = [[LSFackBookLoginRequest alloc] init];
    request.fToken = self.loginInfo.token;
    request.email = self.loginInfo.email;
    request.passWord = self.loginInfo.password;
    request.birthDay = self.loginInfo.birthday;
    request.inviteCode = self.loginInfo.inviteCode;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull sessionId) {
        if (success) {
            bFlag = YES;
        } else {
            bFlag = NO;
        }
        registerHandler(success, errnum, errmsg, sessionId);
    };
    [self.sessionManager sendRequest:request];
    return bFlag;
}

#pragma mark - 调用Facebook第三方弹框登录

- (void)facebookLogin:(facebookLoginHandler _Nullable)facebookLoginHandler{
    
    WeakObject(self, weakSelf);
    [[AccountSDKManager shareInstance] login:AccountSDKType_Facebook vc:self.presentVC handler:^(BOOL success, NSError *error) {
        NSLog(@"FacebookLoginHandler::facebookLogin( [Facebook SDK登录] success:%d, error:%@ )  ",success, error);
        
        if ([weakSelf.delegate respondsToSelector:@selector(facebookSDKLogin:error:)]) {
            [weakSelf.delegate facebookSDKLogin:success error:error];
        }
        
        if (success) {
            // Facebook第三方登录成功,获取个人资料
            weakSelf.token = [AccountSDKManager shareInstance].token;
            [weakSelf accountSDKGetProfile:facebookLoginHandler];
        } else {
            facebookLoginHandler(NO, error, nil);
        }
    }];
}

#pragma mark - 获取Facebook第三方个人资料

- (void)accountSDKGetProfile:(facebookLoginHandler _Nullable)getProfileHandler {
    WeakObject(self, weakSelf);
    [[AccountSDKManager shareInstance] getProfile:^(BOOL success, NSError *error, AccountSDKProfile *profile) {
        NSLog(@"FacebookLoginHandler::accountSDKGetProfile( [获取Facebook个人信息] success:%d, error:%@, profile:%@ )",success, error, profile);
        if (success) {
            // 更新数据
            LiveLoginInfo *info = [[LiveLoginInfo alloc] init];
            info.token = weakSelf.token;
            info.nickName = profile.name;
            if ([profile.gender isEqualToString:@"male"]) {
                info.gender = GENDERTYPE_MAN;
            } else {
                info.gender = GENDERTYPE_LADY;
            }
            info.photoUrl = profile.photoUrl;
            weakSelf.loginInfo = info;
        }
        getProfileHandler(YES, error, weakSelf.token);
    }];
}

#pragma mark - 请求Facebook登录接口

- (void)fackBookLoginRequest:(NSString *)fToken finshHandler:(LoginHandler)finshHandler {
    WeakObject(self, weakSelf);
    LSFackBookLoginRequest *request = [[LSFackBookLoginRequest alloc] init];
    request.fToken = fToken;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull sessionId) {
        NSLog(@"FacebookLoginHandler::fackBookLoginRequest( [请求Facebook登录接口]  success:%d, errnum:%d, errmsg:%@, sessionId:%@ )",success, errnum, errmsg, sessionId);
        
        if ([weakSelf.delegate respondsToSelector:@selector(facebookUserLogin:sessionId:errnum:errMsg:)]) {
            [weakSelf.delegate facebookUserLogin:success sessionId:sessionId errnum:errnum errMsg:errmsg];
        }
        
        if (success) {
            [self saveLoginParam];
        }
        finshHandler(success, errnum, errmsg, sessionId);
    };
    [self.sessionManager sendRequest:request];
}

- (void)saveLoginParam {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dic = @{@"Token":self.token,
                           @"Type":@"Facebook"
                           };
    [userDefaults setObject:dic forKey:@"LoginInfo"];
    [userDefaults synchronize];
}

- (void)loadLoginParam {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * loginDic = [userDefaults dictionaryForKey:@"LoginInfo"];
    
    if (loginDic.allKeys.count > 0) {
        if ([[loginDic objectForKey:@"Type"] isEqualToString:@"Facebook"]) {
           self.token = [loginDic objectForKey:@"Token"];
        }
    }
}

@end
