//
//  PaymentManager.m
//  demo
//
//  Created by  Samson on 6/21/16.
//  Copyright © 2016 Samson. All rights reserved.
//  支付管理器(包括获取订单号、请求AppStore支付、验证订单号等业务流程)

#import "LSPaymentManager.h"
#import "LSPaymentHandler.h"
#import "LSSessionRequestManager.h"
#import "LSGetIOSPayRequest.h"
#import "LSAppStorePayHandler.h"
#import "LSLoginManager.h"

@interface LSPaymentManager () <PaymentHandlerDelegate, LoginManagerDelegate>
// delegate
@property (nonatomic, strong) NSMutableArray<NSValue*>* delegates;
// 支付处理器 dictionary
@property (nonatomic, strong) NSMutableDictionary<NSString*, LSPaymentHandler*>* handlers;
// 待重支付处理器 array
@property (nonatomic, strong) NSMutableArray<LSPaymentHandler*>* autoRetryHandlers;
// 处理支付的timer（主要用于重试AppStore支付成功，但由于网络原因导致验证订单失败的交易）
@property (nonatomic, strong) NSTimer* handleTimer;
// 男士ID
@property (nonatomic, strong) NSString* manId;
// sid
@property (nonatomic, strong) NSString* sid;

// 重支付timer处理函数
- (void)timerAutoRetryPay:(NSTimer*)timer;
@end

@implementation LSPaymentManager
/**
 *  获取单件
 *
 *  @return this
 */
+ (LSPaymentManager* _Nonnull)manager
{
    static LSPaymentManager* manager = nil;
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
- (id _Nullable)init
{
    self = [super init];
    if (nil != self) {
        self.manId = nil;
        self.sid = nil;
        
        self.delegates = [NSMutableArray array];
        self.handlers = [NSMutableDictionary dictionary];
        self.autoRetryHandlers = [NSMutableArray array];
        self.handleTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timerAutoRetryPay:) userInfo:self repeats:YES];
    
        // 加入AppStore支付回调
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        // 加入LoginManager回调
//        [[LSLoginManager manager] addDelegate:self];
    }
    return self;
}

/**
 *  析构
 */
- (void)dealloc
{
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
- (BOOL)addDelegate:(id<PaymentManagerDelegate> _Nonnull)delegate
{
    BOOL result = NO;
    @synchronized(self.delegates)
    {
        // 查找是否已存在
        for(NSValue* value in self.delegates) {
            id<PaymentManagerDelegate> item = (id<PaymentManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
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
- (void)removeDelegate:(id<PaymentManagerDelegate> _Nonnull)delegate
{
    BOOL result = NO;
    @synchronized(self.delegates)
    {
        for(NSValue* value in self.delegates) {
            id<PaymentManagerDelegate> item = (id<PaymentManagerDelegate>)value.nonretainedObjectValue;
            if( item == delegate ) {
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

#pragma mark - 公共函数
/**
 *  支付
 *
 *  @param number 套餐ID
 *
 *  @return 是否成功
 */
- (BOOL)pay:(NSString* _Nonnull)number
{
    BOOL result = NO;

//    if ((nil != self.manId && [self.manId length] > 0)
//        && (nil != self.sid && [self.sid length] > 0))
//    {
//        __block NSString* blockManId = self.manId;
//        __block NSString* blockSid = self.sid;
    __block NSString* blockManId = [LSLoginManager manager].loginItem.userId;
    __block NSString* blockSid = [LSLoginManager manager].token;

    
        // 获取订单号请求
        LSSessionRequestManager* sessionRequestMgr = [LSSessionRequestManager manager];
        if (nil != sessionRequestMgr) {
            LSGetIOSPayRequest* request = [[LSGetIOSPayRequest alloc] init];
            request.manid = blockManId;
            request.sid = blockSid;
            request.number = number;
            request.siteid = @"5";
            request.finishHandler = ^(BOOL success, NSString * _Nonnull code, NSString * _Nonnull orderNo, NSString * _Nonnull productId)
            {
                // callback
                @synchronized(self.delegates) {
                    for (NSValue* value in self.delegates)
                    {
                        id<PaymentManagerDelegate> delegate = (id<PaymentManagerDelegate>)value.nonretainedObjectValue;
                        if ([delegate respondsToSelector:@selector(onGetOrderNo:result:code:orderNo:)]) {
                            [delegate onGetOrderNo:self result:success code:code orderNo:orderNo];
                        }
                    }
                }

                // 成功则生成支付处理器，并添加到dictionary
                if (success && [orderNo length] > 0) {
                    LSPaymentHandler* handler = [[LSPaymentHandler alloc] initWithOrderNo:orderNo productId:@"SP2003" manId:blockManId sid:blockSid delegate:self];
                    @synchronized(self.handlers) {
                        [self.handlers setObject:handler forKey:orderNo];
                    }
                    
                    // 开始AppStore支付
                    [handler start];
                }

            };

            result = [sessionRequestMgr sendRequest:request];
        }
//    }

    return result;
}

/**
 *  重试支付(仅当订单号已获取成功才能重试)
 *
 *  @param orderNo 订单号
 *
 *  @return 是否可重试
 */
- (BOOL)retry:(NSString* _Nonnull)orderNo
{
    BOOL result = NO;
    
    // 查找支付处理器
    LSPaymentHandler* handler = nil;
    @synchronized (self.handlers) {
        handler = [self.handlers objectForKey:orderNo];
    }
    
    // 重试支付
    if (nil != handler) {
        result = [handler start];
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
- (BOOL)autoRetry:(NSString* _Nonnull)orderNo
{
    BOOL result = NO;
    
    // 查找支付处理器
    LSPaymentHandler* handler = nil;
    @synchronized (self.handlers) {
        handler = [self.handlers objectForKey:orderNo];
    }
    
    if (nil != handler) {
        // 判断是否已在自动重试数组中
        @synchronized (self.autoRetryHandlers) {
            result = [self.autoRetryHandlers containsObject:handler];
        }
        
        // 若不在，则加入数组
        if (!result) {
            @synchronized (self.autoRetryHandlers) {
                [self.autoRetryHandlers addObject:handler];
            }
        }
    }
    
    return result;
}

#pragma mark - SKPaymentTransactionObserver回调
/**
 *  AppStore支付状态更新回调(SKPaymentTransactionObserver)
 *
 *  @param queue        交易处理队列
 *  @param transactions 交易信息
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction* tran in transactions)
    {
        // 查找支付处理器
        LSPaymentHandler* handler = nil;
        NSString* orderNo = [LSAppStorePayHandler getOrderNo:tran];
        if (nil != orderNo && [orderNo length] > 0) {
            @synchronized (self.handlers) {
                handler = [self.handlers objectForKey:orderNo];
                
                // 若支付处理器不存在
                if (nil == handler) {
                    NSString* manId = [LSAppStorePayHandler getManId:tran];
//                    if (nil != manId && [self.manId isEqualToString:manId]) {
                        // 当前男士与AppStore支付信息的男士一致
                        handler = [[LSPaymentHandler alloc] initWithOrderNo:orderNo productId:tran.payment.productIdentifier manId:manId sid:self.sid delegate:self];
                        [self.handlers setObject:handler forKey:orderNo];
//                    }
                }
            }
        }

        if (nil != handler) {
            // 更新支付状态
            [handler updatedTransactions:tran];
        }
        else {
            // 状态不为正在支付及已经完成，则标记为已完成
            if (SKPaymentTransactionStatePurchasing != tran.transactionState
                && SKPaymentTransactionStatePurchased != tran.transactionState)
            {
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
- (void)updatePaymentState:(LSPaymentHandler* _Nonnull)handler state:(PaymentHandleState)state success:(BOOL)success code:(NSString* _Nonnull)code isNetErr:(BOOL)isNetErr
{
    // 是否可retry
    BOOL canRetry = success ? NO : isNetErr;
    
    // callback
    @synchronized(self.delegates) {
        for (NSValue* value in self.delegates)
        {
            id<PaymentManagerDelegate> delegate = (id<PaymentManagerDelegate>)value.nonretainedObjectValue;
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
    
    // 从自动重试数组移除不能处理的支付处理器
    BOOL isAutoRetry = NO;
    if (canRetry) {
        @synchronized (self.autoRetryHandlers) {
            isAutoRetry = [self.autoRetryHandlers containsObject:handler];
            if (isAutoRetry) {
                [self.autoRetryHandlers removeObject:handler];
            }
        }
    }
    
    // 移除已完成或不能继续处理并是自动重试的支付处理器
    if (PaymentHandleStateFinish == state
        || (isAutoRetry && !canRetry))
    {
        @synchronized (self.handlers) {
            [self.handlers removeObjectForKey:handler.orderNo];
        }
    }
}

#pragma mark - 重试支付处理
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
            [handler start];
        }
    }
}

#pragma mark - LoginManagerDelegate
//- (void)manager:(LSLoginManager * _Nonnull)manager onLogin:(BOOL)success loginItem:(LSManBaseInfoItemObject * _Nullable)loginItem errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg serverId:(int)serverId
//{
//    if (success) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.manId = loginItem.manid;
//            self.sid = loginItem.sessionid;
//
//            // 加入AppStore支付回调
//            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//        });
//    }
//}
//
//- (void)manager:(LoginManager *)manager onLogout:(BOOL)kick
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.manId = nil;
//        self.sid = nil;
//
//        // 退出AppStore支付回调
//        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
//    });
//}
@end
