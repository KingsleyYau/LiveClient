//
//  PaymentHandler.h
//  demo
//
//  Created by  Samson on 6/22/16.
//  Copyright © 2016 Samson. All rights reserved.
//  支付处理器(包括AppStore支付处理和接口请求验证订单处理)

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "LSPaymentItem.h"

typedef NS_ENUM(NSInteger, PaymentHandleState)
{
    PaymentHandleStatePayWithStore,     // 向AppStore支付
    PaymentHandleStateCheckPayment,     // 正在验证订单
    PaymentHandleStateFinish,           // 交易完成
};

@protocol LSPaymentHandlerDelegate;
@interface LSPaymentHandler : NSObject
// 订单号
@property (nonatomic, readonly) NSString* _Nonnull orderNo;
// 支付状态
@property (nonatomic, readonly) PaymentHandleState state;

/**
 *  初始化
 *
 *  @param orderNo   订单号
 *  @param productId 产品ID
 *  @param manId     男士ID
 *  @param delegate  回调
 *
 *  @return this
 */
- (id _Nullable)initWithOrderNo:(NSString* _Nonnull)orderNo productId:(NSString* _Nonnull)productId manId:(NSString* _Nonnull)manId delegate:(id<LSPaymentHandlerDelegate> _Nonnull)delegate;

/**
 *  初始化
 *
 *  @param orderNo      订单号
 *  @param productId    产品ID
 *  @param manId        男士ID
 *  @param receipt      AppStore凭证
 *  @param transState   AppStore交易状态
 *  @param delegate     回调
 *
 *  @return this
 */
- (id _Nullable)initWithOrderNo:(NSString* _Nonnull)orderNo productId:(NSString* _Nonnull)productId manId:(NSString* _Nonnull)manId receipt:(NSString* _Nonnull)receipt transState:(SKPaymentTransactionState)transState delegate:(id<LSPaymentHandlerDelegate> _Nonnull)delegate;

/**
 *  开始支付(或重试)
 *
 *  @param sid      唯一身份标识
 *
 *  @return 是否成功
 */
- (BOOL)start:(NSString* _Nonnull)sid;

/**
 *  更新AppStore支付信息
 */
- (void)updatedTransactions:(SKPaymentTransaction* _Nonnull)transaction sid:(NSString* _Nonnull)sid;

/**
 *  设置为"正在验证订单"状态
 */
- (void)setCheckPaymentStatus;

/**
 *  获取订单信息
 */
- (LSPaymentItem* _Nullable)getPaymentItem;
@end

@protocol LSPaymentHandlerDelegate <NSObject>
/**
 *  支付状态改变回调
 *
 *  @param payment  payment
 *  @param state    支付状态
 *  @param success  是否成功
 *  @param code     错误码
 *  @param isNetErr 是否网络错误(连接不成功)
 */
- (void)updatePaymentState:(LSPaymentHandler* _Nonnull)handler state:(PaymentHandleState)state success:(BOOL)success code:(NSString* _Nonnull)code isNetErr:(BOOL)isNetErr;
@end
