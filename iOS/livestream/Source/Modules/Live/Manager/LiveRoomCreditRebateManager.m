//
//  LiveRoomCreditRebateManager.m
//  livestream
//
//  Created by alex shum on 17/9/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoomCreditRebateManager.h"
#import "LSLoginManager.h"
#import "LSImManager.h"


@interface LiveRoomCreditRebateManager () <LoginManagerDelegate, IMLiveRoomManagerDelegate>

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) LSLoginManager *loginManager;
@property (nonatomic, strong) NSMutableArray *delegates;
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

- (instancetype)init {

    self = [super init];

    if (self) {
        self.loginManager = [LSLoginManager manager];
        self.sessionManager = [LSSessionRequestManager manager];
        [self.loginManager addDelegate:self];
        self.mCredit = 0.0;
        self.mPostStamp = 0.0;
        self.imRebateItem = [[IMRebateItem alloc] init];
        self.imRebateItem.curCredit = 0.0;
        self.imRebateItem.curTime = 0;
        self.imRebateItem.preCredit = 0.0;
        self.imRebateItem.preTime = 0;
        self.delegates = [NSMutableArray array];
    }

    return self;
}

// 监听HTTP登录
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            // 请求账号余额
            [self getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {

            }];
        }
    });
}

- (BOOL)addDelegate:(id<LiveRoomCreditRebateManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;

    NSLog(@"LiveRoomCreditRebateManager::addDelegate( delegate : %@ )", delegate);

    @synchronized(self.delegates) {
        // 查找是否已存在
        for (NSValue *value in self.delegates) {
            id<LiveRoomCreditRebateManagerDelegate> item = (id<LiveRoomCreditRebateManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                result = YES;
                break;
            }
        }

        // 未存在则添加
        if (!result) {
            [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
            result = YES;
        }
    }

    return result;
}

- (BOOL)removeDelegate:(id<LiveRoomCreditRebateManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;

    NSLog(@"LiveRoomCreditRebateManager::removeDelegate( delegate : %@ )", delegate);

    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LiveRoomCreditRebateManagerDelegate> item = (id<LiveRoomCreditRebateManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                result = YES;
                break;
            }
        }
    }

    return result;
}

#pragma mark - 请求账号余额
- (void)getLeftCreditRequest:(GetCreditFinshtHandler)handler {

    GetLeftCreditRequest *request = [[GetLeftCreditRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, double credit, int coupon, double postStamp) {

        NSLog(@"LiveRoomCreditRebateManager::getLeftCreditRequest( [获取账号余额请求结果], success:%d, errnum : %ld, errmsg : %@ credit : %f coupon : %d, postStamp : %f)", success, (long)errnum, errmsg, credit, coupon, postStamp);

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(success, credit, coupon, postStamp,errnum,errmsg);

            if (success) {
                [self setCredit:credit];
                self.mCoupon = coupon;
                self.mPostStamp = postStamp;
            } else {
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

// 设置信用点
- (void)setCredit:(double)credit {
    NSLog(@"LiveRoomCreditRebateManager::setCredit credit:%@", @(credit));
    @synchronized(self) {
        self.mCredit = credit;
        for (NSValue *value in self.delegates) {
            id<LiveRoomCreditRebateManagerDelegate> delegate = (id<LiveRoomCreditRebateManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(updataCredit:)]) {
                [delegate updataCredit:credit];
            }
        }
    }
}

// 获取信用点
- (double)getCredit {
    return self.mCredit;
}

// 设置返点信息
- (void)setReBateItem:(IMRebateItem *)rebateItem {
    @synchronized(self) {
        self.imRebateItem.curCredit = rebateItem.curCredit;
        self.imRebateItem.curTime = rebateItem.curTime;
        self.imRebateItem.preCredit = rebateItem.preCredit;
        self.imRebateItem.preTime = rebateItem.preTime;
    }
}

// 获取返点信息
- (IMRebateItem *)getReBateItem {
    IMRebateItem *rebateItem = [[IMRebateItem alloc] init];
    @synchronized(self) {
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
