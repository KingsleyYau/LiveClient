//
//  PaymentItem.m
//  dating
//
//  Created by  Samson on 31/05/2018.
//  Copyright © 2018 qpidnetwork. All rights reserved.
//  用于记录AppStore支付成功的订单信息

#import "LSPaymentItem.h"

@interface LSPaymentItem()
// 男士ID
@property (nonatomic, strong) NSString * _Nonnull manId;
// 我司订单号
@property (nonatomic, strong) NSString * _Nonnull orderNo;
// 产品ID
@property (nonatomic, strong) NSString * _Nonnull productId;
// AppStore支付状态
@property (nonatomic, assign) SKPaymentTransactionState transState;
// AppStore支付凭证
@property (nonatomic, strong) NSString * _Nonnull receipt;
@end

#pragma - key
#define ManIdKey        @"manId"
#define OrderNoKey      @"orderNo"
#define ProductIdKey    @"productId"
#define TransStateKey   @"transState"
#define ReceiptKey      @"receipt"

@implementation LSPaymentItem
/**
 *  初始化函数
 *
 *  @param manId    男士ID
 *  @param orderNo  我司订单号
 *  @param receipt  AppStore订单凭证
 */
- (id _Nullable)init:(NSString* _Nonnull)manId orderNo:(NSString* _Nonnull)orderNo productId:(NSString* _Nonnull)productId transState:(SKPaymentTransactionState)transState receipt:(NSString* _Nonnull)receipt
{
    self = [super init];
    if (nil != self) {
        self.manId = manId;
        self.orderNo = orderNo;
        self.productId = productId;
        self.transState = transState;
        self.receipt = receipt;
    }
    return self;
}

/**
 *  解析为Dictionary
 *
 *  return dictionary
 */
- (NSDictionary* _Nonnull)getDictionary
{
    NSDictionary *result = nil;
    if ([self.manId length] > 0
        && [self.orderNo length] > 0)
    {
        result = [NSMutableDictionary dictionary];
        [result setValue:self.manId forKey:ManIdKey];
        [result setValue:self.orderNo forKey:OrderNoKey];
        [result setValue:self.productId forKey:ProductIdKey];
        [result setValue:[NSNumber numberWithInteger:self.transState] forKey:TransStateKey];
        [result setValue:self.receipt forKey:ReceiptKey];
    }
    return result;
}

/**
 *  通过NSDictionary生成PaymentItem
 *
 *  @param dictionary   dictionary协议
 *  return PaymentItem
 */

+ (LSPaymentItem* _Nonnull)paymentItemWithDictionary:(NSDictionary* _Nonnull)dictionary
{
    LSPaymentItem *item = nil;
    if (nil != dictionary) {
        NSString *manId = [dictionary objectForKey:ManIdKey];
        NSString *orderNo = [dictionary objectForKey:OrderNoKey];
        NSString *productId = [dictionary objectForKey:ProductIdKey];
        NSNumber *transState = [dictionary objectForKey:TransStateKey];
        NSString *receipt = [dictionary objectForKey:ReceiptKey];
        
        if (nil != manId && [manId length] > 0
            && nil != orderNo && [orderNo length] > 0
            && nil != productId && [productId length] > 0
            && nil != transState)
        {
            item = [[LSPaymentItem alloc] init];
            item.manId = manId;
            item.orderNo = orderNo;
            item.productId = productId;
            item.transState = (SKPaymentTransactionState)[transState integerValue];
            item.receipt = (nil != receipt ? receipt : @"");
        }
    }
    return item;
}
@end
