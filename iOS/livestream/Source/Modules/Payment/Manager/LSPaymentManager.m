//
//  PaymentManager.m
//  demo
//
//  Created by  Samson on 6/21/16.
//  Copyright © 2016 Samson. All rights reserved.
//  支付管理器(包括获取订单号、请求AppStore支付、验证订单号等业务流程)

#import "LSPaymentManager.h"
#import "LSPaymentHandler.h"
#import "LSDomainSessionRequestManager.h"
#import "LSGetIOSPayRequest.h"
#import "LSAppStorePayHandler.h"
#import "LSAppStoreProductQueryHandler.h"
#import "LSLoginManager.h"
#import "LSPaymentItemManager.h"

@interface LSPaymentManager () <LSPaymentHandlerDelegate, LoginManagerDelegate, LSAppStoreProductQueryHandlerDeleagte>
// delegate
@property (nonatomic, strong) NSMutableArray<NSValue *> *delegates;
// 产品信息查询处理器
@property (nonatomic, strong) LSAppStoreProductQueryHandler *queryHandler;
// 支付处理器 dictionary
@property (nonatomic, strong) NSMutableDictionary<NSString *, LSPaymentHandler *> *handlers;
// 待重支付处理器 array
@property (nonatomic, strong) NSMutableArray<LSPaymentHandler *> *autoRetryHandlers;
// 处理支付的timer（主要用于重试AppStore支付成功，但由于网络原因导致验证订单失败的交易）
@property (nonatomic, strong) NSTimer *handleTimer;
// 男士ID
@property (nonatomic, strong) NSString *manId;
// sid
@property (nonatomic, strong) NSString *sid;
// AppStore支付信息管理器
@property (nonatomic, strong) LSPaymentItemManager *paymentItemMgr;

// 同步待重支付处理队列(通过AppStore支付信息管理器)
- (void)syncWithPaymentItemMgr;
// 启动重支付timer
- (void)startAutoRetryPayTimer;
// 停止重支付timer
- (void)stopAutoRetryPayTimer;
// 重支付timer处理函数
- (void)timerAutoRetryPay:(NSTimer *)timer;
@end

@implementation LSPaymentManager
/**
 *  获取单件
 *
 *  @return this
 */
+ (LSPaymentManager *_Nonnull)manager {
    static LSPaymentManager *manager = nil;
    if (nil == manager) {
        manager = [[LSPaymentManager alloc] init];
    }
    return manager;
}

/**
 *  初始化
 *
 *  @return this
 */
- (id _Nullable)init {
    self = [super init];
    if (nil != self) {
        self.manId = nil;
        self.sid = nil;

        self.delegates = [NSMutableArray array];
        self.handlers = [NSMutableDictionary dictionary];
        self.autoRetryHandlers = [NSMutableArray array];
        self.handleTimer = nil;
        self.paymentItemMgr = [[LSPaymentItemManager alloc] init];

        // 加入AppStore支付回调
        //        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

        // 同步支付信息管理器信息到待重试队列
        [self syncWithPaymentItemMgr];

        // 加入LoginManager回调
        [[LSLoginManager manager] addDelegate:self];
    }
    return self;
}

/**
 *  析构
 */
- (void)dealloc {
    // 退出LoginManager回调
    [[LSLoginManager manager] removeDelegate:self];

    // 退出AppStore支付回调
    //    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];

    // 停止自动重试支付timer
    if (nil != self.handleTimer) {
        [self.handleTimer invalidate];
    }
}

#pragma mark - delegate
/**
 *  添加监听
 *
 *  @param delegate 监听object
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<LSPaymentManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;
    @synchronized(self.delegates) {
        // 查找是否已存在
        for (NSValue *value in self.delegates) {
            id<LSPaymentManagerDelegate> item = (id<LSPaymentManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                NSLog(@"PaymentManager::addDelegate() add again, delegate:<%@>", delegate);
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

/**
 *  移除监听
 *
 *  @param delegate 监听object
 *
 */
- (void)removeDelegate:(id<LSPaymentManagerDelegate> _Nonnull)delegate {
    BOOL result = NO;
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSPaymentManagerDelegate> item = (id<LSPaymentManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                result = YES;
                break;
            }
        }
    }

    // log
    if (!result) {
        NSLog(@"PaymentManagerDelegate::removeDelegate() fail, delegate:<%@>", delegate);
    }
}

#pragma mark - 接口函数
/**
 *  获取产品信息
 *
 *  @param productIds 产品ID数组
 *
 *  @return 是否成功
 */
- (BOOL)getProductsInfo:(NSSet<NSString *> *_Nonnull)productIds {
    BOOL result = NO;
    self.queryHandler = [[LSAppStoreProductQueryHandler alloc] init:self];
    result = [self.queryHandler query:productIds];
    return result;
}

/**
 *  支付
 *
 *  @param number 套餐ID
 *
 *  @return 是否成功
 */
- (BOOL)pay:(NSString *_Nonnull)number {
    BOOL result = NO;

    if ((nil != self.manId && [self.manId length] > 0) && (nil != self.sid && [self.sid length] > 0)) {
        __block NSString *blockManId = self.manId;
        __block NSString *blockSid = self.sid;

        // 获取订单号请求
        LSDomainSessionRequestManager *sessionRequestMgr = [LSDomainSessionRequestManager manager];
        if (nil != sessionRequestMgr) {
            LSGetIOSPayRequest *request = [[LSGetIOSPayRequest alloc] init];
            request.manid = blockManId;
            request.sid = blockSid;
            request.number = number;
            request.finishHandler = ^(BOOL success, NSString *_Nonnull code, NSString *_Nonnull orderNo, NSString *_Nonnull productId) {
                // callback
                @synchronized(self.delegates) {
                    for (NSValue *value in self.delegates) {
                        id<LSPaymentManagerDelegate> delegate = (id<LSPaymentManagerDelegate>)value.nonretainedObjectValue;
                        if ([delegate respondsToSelector:@selector(onGetOrderNo:result:code:orderNo:)]) {
                            [delegate onGetOrderNo:self result:success code:code orderNo:orderNo];
                        }
                    }
                }

                // 成功则生成支付处理器，并添加到dictionary
                if (success && [orderNo length] > 0) {
                    LSPaymentHandler *handler = [[LSPaymentHandler alloc] initWithOrderNo:orderNo productId:productId manId:blockManId delegate:self];
                    @synchronized(self.handlers) {
                        [self.handlers setObject:handler forKey:orderNo];
                    }

                    // 开始AppStore支付
                    [handler start:blockSid];
                }
            };

            result = [sessionRequestMgr sendRequest:request];
        }
    }

    return result;
}

/**
 *  重试支付(仅当订单号已获取成功才能重试)
 *
 *  @param orderNo 订单号
 *
 *  @return 是否可重试
 */
- (BOOL)retry:(NSString *_Nonnull)orderNo {
    BOOL result = NO;

    // 查找支付处理器
    LSPaymentHandler *handler = nil;
    @synchronized(self.handlers) {
        handler = [self.handlers objectForKey:orderNo];
    }

    // 重试支付
    if (nil != handler) {
        result = [handler start:self.sid];
    }
    return result;
}

/**
 *  设为自动重试支付(仅当订单号已获取成功才能重试)
 *
 *  @param orderNo 订单号
 *
 *  @return 是否成功
 */
- (BOOL)autoRetry:(NSString *_Nonnull)orderNo {
    BOOL result = NO;

    // 查找支付处理器
    LSPaymentHandler *handler = nil;
    @synchronized(self.handlers) {
        handler = [self.handlers objectForKey:orderNo];
    }

    if (nil != handler) {
        // 判断是否已在自动重试数组中
        @synchronized(self.autoRetryHandlers) {
            result = [self.autoRetryHandlers containsObject:handler];
        }

        // 若不在，则加入数组
        if (!result) {
            @synchronized(self.autoRetryHandlers) {
                [self.autoRetryHandlers addObject:handler];
            }
        }
    }

    return result;
}

#pragma - AppStoreProductQueryHandler回调
/**
 *  产品查询完成回调(AppStoreProductQueryHandlerDeleagte)
 *
 *  @param handler  查询处理器
 *  @param products 查询结果(查询失败则返回nil)
 *  @param
 */
- (void)getProductFinish:(LSAppStoreProductQueryHandler *_Nonnull)handler products:(NSArray<SKProduct *> *_Nullable)products {
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSPaymentManagerDelegate> delegate = (id<LSPaymentManagerDelegate>)value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(onGetProductsInfo:products:)]) {
                [delegate onGetProductsInfo:self products:products];
            }
        }
    }
}

#pragma mark - SKPaymentTransactionObserver回调
/**
 *  AppStore支付状态更新回调(SKPaymentTransactionObserver)
 *
 *  @param queue        交易处理队列
 *  @param transactions 交易信息
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *tran in transactions) {
        // 查找支付处理器
        LSPaymentHandler *handler = nil;
        NSString *orderNo = [LSAppStorePayHandler getOrderNo:tran];
        if (nil != orderNo && [orderNo length] > 0) {
            @synchronized(self.handlers) {
                handler = [self.handlers objectForKey:orderNo];

                // 若支付处理器不存在
                if (nil == handler) {
                    NSString *manId = [LSAppStorePayHandler getManId:tran];
                    if (nil != manId && [manId length] > 0) {
                        // 当前男士与AppStore支付信息的男士一致
                        handler = [[LSPaymentHandler alloc] initWithOrderNo:orderNo productId:tran.payment.productIdentifier manId:manId delegate:self];
                        [self.handlers setObject:handler forKey:orderNo];
                    }
                }
            }
        }

        if (nil != handler) {
            // 更新支付状态
            [handler updatedTransactions:tran sid:self.sid];
        } else {
            // 状态不为正在支付及已经完成，则标记为已完成
            if (SKPaymentTransactionStatePurchasing != tran.transactionState && SKPaymentTransactionStatePurchased != tran.transactionState) {
                [LSAppStorePayHandler finish:tran];
            }
        }
    }
}

#pragma mark - PaymentHandlerDelegate
/**
 *  支付状态改变回调
 *
 *  @param handler  payment handler
 *  @param state    支付状态
 *  @param success  是否成功
 *  @param code     错误码
 *  @param isNetErr 是否网络错误(连接不成功)
 */
- (void)updatePaymentState:(LSPaymentHandler *_Nonnull)handler state:(PaymentHandleState)state success:(BOOL)success code:(NSString *_Nonnull)code isNetErr:(BOOL)isNetErr {
    // 是否可retry
    BOOL canRetry = success ? NO : isNetErr;

    // 添加到待提交我司后台队列
    if (PaymentHandleStatePayWithStore == state) {
        LSPaymentItem *paymentItem = [handler getPaymentItem];
        if (nil != paymentItem) {
            [self.paymentItemMgr insert:paymentItem];
        }
    }

    // callback
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSPaymentManagerDelegate> delegate = (id<LSPaymentManagerDelegate>)value.nonretainedObjectValue;
            switch (state) {
                case PaymentHandleStatePayWithStore:
                    if ([delegate respondsToSelector:@selector(onAppStorePay:result:orderNo:canRetry:)]) {
                        [delegate onAppStorePay:self result:success orderNo:handler.orderNo canRetry:canRetry];
                    }
                    break;
                case PaymentHandleStateCheckPayment:
                    if ([delegate respondsToSelector:@selector(onCheckOrder:result:code:orderNo:canRetry:)]) {
                        [delegate onCheckOrder:self result:success code:code orderNo:handler.orderNo canRetry:canRetry];
                    }
                    break;
                case PaymentHandleStateFinish:
                    if ([delegate respondsToSelector:@selector(onPaymentFinish:orderNo:)]) {
                        [delegate onPaymentFinish:self orderNo:handler.orderNo];
                    }
                    break;
            }
        }
    }

    // 移除出队列
    if (PaymentHandleStateFinish == state // 已完成
        || (!success && !isNetErr))       // 处理失败且不是网络错误
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 移除自动重试队列
            @synchronized(self.autoRetryHandlers) {
                [self.autoRetryHandlers removeObject:handler];
            }

            // 移除支付处理器 dictionary
            @synchronized(self.handlers) {
                [self.handlers removeObjectForKey:handler.orderNo];
            }

            // 移除出待提交我司后台队列
            [self.paymentItemMgr remove:handler.orderNo];
        });
    }
}

#pragma mark - 公共处理
// 同步待重支付处理队列(通过AppStore支付信息管理器)
- (void)syncWithPaymentItemMgr {
    NSArray<LSPaymentItem *> *paymentItemArray = [self.paymentItemMgr getArray];
    for (LSPaymentItem *item in paymentItemArray) {
        LSPaymentHandler *handler = [[LSPaymentHandler alloc] initWithOrderNo:item.orderNo productId:item.productId manId:item.manId receipt:item.receipt transState:item.transState delegate:self];
        if (nil != handler) {
            // 添加支付处理器
            [handler setCheckPaymentStatus];
            @synchronized(self.handlers) {
                [self.handlers setObject:handler forKey:item.orderNo];
            }

            // 插入待重试队列
            @synchronized(self.autoRetryHandlers) {
                if (![self.autoRetryHandlers containsObject:handler]) {
                    [self.autoRetryHandlers addObject:handler];
                }
            }
        }
    }
}

#pragma mark - 重试支付处理
// 启动重支付timer
- (void)startAutoRetryPayTimer {
    // 先尝试停止已有timer
    [self stopAutoRetryPayTimer];

    // 启动自动重试支付timer
    self.handleTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timerAutoRetryPay:) userInfo:self repeats:YES];
}

// 停止重支付timer
- (void)stopAutoRetryPayTimer {
    // 停止自动重试支付timer
    if (nil != self.handleTimer) {
        [self.handleTimer invalidate];
    }
}

/**
 *  重试支付timer处理函数
 *
 *  @param timer timer
 */
- (void)timerAutoRetryPay:(NSTimer*)timer
{
    // 自动重试支付
    @synchronized (self.autoRetryHandlers)
    {
        for (LSPaymentHandler* handler in self.autoRetryHandlers) {
            [handler start:self.sid];
        }
    }
}

#pragma mark - LoginManagerDelegate
- (void)manager:(LSLoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject * _Nullable)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString * _Nonnull)errmsg{
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.manId = loginItem.userId;
            self.sid = loginItem.token;
            
            // 加入AppStore支付回调
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            
            // 启动自动重试支付timer
            [self startAutoRetryPayTimer];
        });
    }
}

- (void)manager:(LSLoginManager * _Nonnull)manager onLogout:(LogoutType)type msg:(NSString * _Nullable)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.manId = nil;
        self.sid = nil;
        
        // 停止自动重试支付timer
        [self stopAutoRetryPayTimer];
        
        // 退出AppStore支付回调
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    });
}
@end
