//
//  PaymentManager.h
//  demo
//
//  Created by  Samson on 6/21/16.
//  Copyright © 2016 Samson. All rights reserved.
//  支付管理器(包括获取订单号、请求AppStore支付、验证订单号等业务流程)

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol PaymentManagerDelegate;

@interface LSPaymentManager : NSObject<SKPaymentTransactionObserver>

/**
 *  获取单件
 *
 *  @return this
 */
+ (LSPaymentManager* _Nonnull)manager;

/**
 *  初始化
 *
 *  @return this
 */
- (id _Nullable)init;

/**
 *  添加监听
 *
 *  @param delegate 监听object
 *
 */
- (BOOL)addDelegate:(id<PaymentManagerDelegate> _Nonnull)delegate;

/**
 *  移除监听
 *
 *  @param delegate 监听object
 *
 */
- (void)removeDelegate:(id<PaymentManagerDelegate> _Nonnull)delegate;

/**
 *  支付
 *
 *  @param number 套餐ID
 *
 *  @return 是否成功
 */
- (BOOL)pay:(NSString* _Nonnull)number;

/**
 *  重试支付(仅当订单号已获取成功才能重试)
 *
 *  @param orderNo 订单号
 *
 *  @return 是否可重试支付
 */
- (BOOL)retry:(NSString* _Nonnull)orderNo;

/**
 *  设为自动重试支付(仅当订单号已获取成功才能重试)
 *
 *  @param orderNo 订单号
 *
 *  @return 是否成功
 */
- (BOOL)autoRetry:(NSString* _Nonnull)orderNo;
@end

@protocol PaymentManagerDelegate <NSObject>
@optional
/**
 *  获取订单回调（若失败则无法retry）
 *
 *  @param mgr     manager
 *  @param result  处理是否成功
 *  @param code    错误号
 *  @param orderNo 订单号
 */
- (void)onGetOrderNo:(LSPaymentManager* _Nonnull)mgr result:(BOOL)result code:(NSString* _Nonnull)code orderNo:(NSString* _Nonnull)orderNo;

/**
 *  AppStore支付回调（可调retry重试支付）
 *
 *  @param mgr      manager
 *  @param result   处理是否成功
 *  @param orderNo  订单号
 *  @param canRetry 是否可重试支付
 */
- (void)onAppStorePay:(LSPaymentManager* _Nonnull)mgr result:(BOOL)result orderNo:(NSString* _Nonnull)orderNo canRetry:(BOOL)canRetry;

/**
 *  验证订单回调（可调retry重试支付）
 *
 *  @param mgr      manager
 *  @param result   处理是否成功
 *  @param code     错误码
 *  @param orderNo  订单号
 *  @param canRetry 是否可重试支付
 */
- (void)onCheckOrder:(LSPaymentManager* _Nonnull)mgr result:(BOOL)result code:(NSString* _Nonnull)code orderNo:(NSString* _Nonnull)orderNo canRetry:(BOOL)canRetry;

/**
 *  支付完成
 *
 *  @param mgr      manager
 *  @param orderNo  订单号
 */
- (void)onPaymentFinish:(LSPaymentManager* _Nonnull)mgr orderNo:(NSString* _Nonnull)orderNo;
@end
