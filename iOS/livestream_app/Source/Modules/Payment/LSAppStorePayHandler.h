//
//  AppStorePayHandler.h
//  demo
//
//  Created by  Samson on 6/13/16.
//  Copyright © 2016 Samson. All rights reserved.
//  AppStore支付处理器

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol AppStorePayHandlerDeleagte;

@interface LSAppStorePayHandler : NSObject<SKProductsRequestDelegate>
#pragma mark - 初始化
/**
 *  初始化
 *
 *  @param productId 产品ID
 *
 *  @return self
 */
- (id _Nonnull)initWithProductId:(NSString* _Nonnull)productId orderNo:(NSString* _Nonnull)orderNo manId:(NSString* _Nonnull)manId delegate:(id<AppStorePayHandlerDeleagte> _Nonnull)delegate;

#pragma mark - 支付
/**
 *  开始支付
 *
 *  @return 支付调用是否成功
 */
- (void)pay;

#pragma mark - 其它
/**
 *  根据消费记录object获取订单号
 *
 *  @param transaction 消息记录object
 *
 *  @return 订单号
 */
+ (NSString* _Nonnull)getOrderNo:(SKPaymentTransaction* _Nonnull)transaction;

/**
 *  根据消费记录object获取男士ID
 *
 *  @param transaction 消息记录object
 *
 *  @return 男士ID
 */
+ (NSString* _Nonnull)getManId:(SKPaymentTransaction* _Nonnull)transaction;

/**
 *  获取凭证
 *
 *  @return 凭证
 */
+ (NSString* _Nonnull)getReceipt;

/**
 *  完成支付处理
 *
 *  @param transaction 支付结果object
 */
+ (void)finish:(SKPaymentTransaction* _Nonnull)transaction;
@end

@protocol AppStorePayHandlerDeleagte <NSObject>
@required
/**
 *  支付完成回调
 *
 *  @param handler 支付处理器
 *  @param result  是否支付成功
 *  @param
 */
- (void)getProductFinish:(LSAppStorePayHandler* _Nonnull)handler result:(BOOL)result;
@end
