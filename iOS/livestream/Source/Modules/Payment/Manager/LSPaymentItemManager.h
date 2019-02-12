//
//  PaymentItemManager.h
//  dating
//
//  Created by  Samson on 31/05/2018.
//  Copyright © 2018 qpidnetwork. All rights reserved.
//  AppStore支付信息管理器，用于管理AppStore支付完成(包括成功和失败)，但提交我司接口未成功的订单，信息将在本地用文件保存

#import <Foundation/Foundation.h>
#import "LSPaymentItem.h"

@interface LSPaymentItemManager : NSObject
/**
 *  初始化
 *
 *  @return this
 */
- (id _Nullable)init;

/**
 *  插入待提交我司订单信息
 *
 *  @param item 订单信息
 *
 *  @return 是否成功(仅当订单号已存在时失败)
 */
- (BOOL)insert:(LSPaymentItem* _Nonnull)item;

/**
 *  移除待提交我司订单信息
 *
 *  @param orderNo  订单号
 */
- (void)remove:(NSString* _Nonnull)orderNo;

/**
 *  获取订单队列
 *
 *  @return 订单队列
 */
- (NSArray<LSPaymentItem*>* _Nonnull)getArray;
@end
