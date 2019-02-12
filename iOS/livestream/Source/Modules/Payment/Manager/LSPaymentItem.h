//
//  PaymentItem.h
//  dating
//
//  Created by  Samson on 31/05/2018.
//  Copyright © 2018 qpidnetwork. All rights reserved.
//  用于记录AppStore支付成功的订单信息

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface LSPaymentItem : NSObject
// 男士ID
@property (nonatomic, readonly) NSString * _Nonnull manId;
// 我司订单号
@property (nonatomic, readonly) NSString * _Nonnull orderNo;
// 产品ID
@property (nonatomic, readonly) NSString * _Nonnull productId;
// AppStore支付状态
@property (nonatomic, readonly) SKPaymentTransactionState transState;
// AppStore支付凭证
@property (nonatomic, readonly) NSString * _Nonnull receipt;

// 初始化
- (id _Nullable)init:(NSString* _Nonnull)manId orderNo:(NSString* _Nonnull)orderNo productId:(NSString* _Nonnull)productId transState:(SKPaymentTransactionState)transState receipt:(NSString* _Nonnull)receipt;
// 解析为NSDictionary
- (NSDictionary* _Nonnull)getDictionary;
// 通过NSDictionary生成PaymentItem
+ (LSPaymentItem* _Nonnull)paymentItemWithDictionary:(NSDictionary* _Nonnull)dictionary;
@end
