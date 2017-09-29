//
//  LiveRoomCreditRebateManager.m
//  livestream
//
//  Created by alex shum on 17/9/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoomCreditRebateManager.h"
#import "LoginManager.h"
#import "IMManager.h"
#import "GetLeftCreditRequest.h"

@interface LiveRoomCreditRebateManager ()<LoginManagerDelegate, IMLiveRoomManagerDelegate>

@property (nonatomic, strong) SessionRequestManager *sessionManager;

@property (nonatomic, strong) LoginManager *loginManager;

@end

@implementation LiveRoomCreditRebateManager

+ (instancetype)creditRebateManager {
    static LiveRoomCreditRebateManager *liveRoomCreditRebateManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        liveRoomCreditRebateManager = [[LiveRoomCreditRebateManager alloc] init];
    });
    
    return liveRoomCreditRebateManager;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        self.loginManager = [LoginManager manager];
        self.sessionManager = [SessionRequestManager manager];
        [self.loginManager addDelegate:self];
        self.mCredit = 0.0;
        self.imRebateItem = [[IMRebateItem alloc] init];
        self.imRebateItem.curCredit = 0.0;
        self.imRebateItem.curTime = 0;
        self.imRebateItem.preCredit = 0.0;
        self.imRebateItem.preTime = 0;
    }
    
    return self;
}

// 监听HTTP登录
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSInteger)errnum errmsg:(NSString *)errmsg{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            // 请求账号余额
            [self getLeftCreditRequest];
        }
    });
}

#pragma mark - 请求账号余额
- (void)getLeftCreditRequest {
    
    GetLeftCreditRequest *request = [[GetLeftCreditRequest alloc] init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, double credit) {
        
        NSLog(@"LiveRoomCreditRebateManager::getLeftCreditRequest[获取账号余额请求结果] success:%d"
              " ErrNum:%ld ErrMsg:%@ credit:%f",success,(long)errnum, errmsg, credit);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                self.mCredit = credit;
            } else {

            }
        });
    };
    [self.sessionManager sendRequest:request];
}

// 设置信用点
- (void)setCredit:(double)credit {
    @synchronized (self) {
        self.mCredit = credit;
    }
}

// 获取信用点
- (double)getCredit {
    return self.mCredit;
}

// 设置返点信息
- (void)setReBateItem:(IMRebateItem*)rebateItem {
    @synchronized (self) {
        self.imRebateItem.curCredit = rebateItem.curCredit;
        self.imRebateItem.curTime = rebateItem.curTime;
        self.imRebateItem.preCredit = rebateItem.preCredit;
        self.imRebateItem.preTime = rebateItem.preTime;
    }
}

// 获取返点信息
- (IMRebateItem *)getReBateItem {
    IMRebateItem* rebateItem = [[IMRebateItem alloc] init];
    @synchronized (self) {
        rebateItem.curCredit = self.imRebateItem.curCredit;
        rebateItem.curTime = self.imRebateItem.curTime;
        rebateItem.preCredit = self.imRebateItem.preCredit;
        rebateItem.preTime = self.imRebateItem.preTime;
    }
    return rebateItem;
}

// 更新返点总数
- (void)updateRebateCredit:(double)rebateCredit {
    @synchronized (self) {
        self.imRebateItem.curCredit = rebateCredit;
    }
}

@end
