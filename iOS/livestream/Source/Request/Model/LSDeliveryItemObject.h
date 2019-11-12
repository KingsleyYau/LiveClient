//
//  LSDeliveryItemObject.h
//  dating
//
//  Created by Alex on 19/9/29.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSFlowerGiftBaseInfoItemObject.h"

@interface LSDeliveryItemObject : NSObject
{

}
/**
 * Delivery结构体
 * orderNumber                  订单号
 * orderDate                    订单时间戳（1970年起的秒数）
 * anchorId                     主播ID
 * anchorNickName               主播昵称
 * anchorAvatar                 主播头像
 * deliveryStatus               状态（LSDELIVERYSTATUS_UNKNOW：--，LSDELIVERYSTATUS_PENDING：Pending，LSDELIVERYSTATUS_SHIPPED：Shipped，LSDELIVERYSTATUS_DELIVERED：Delivered，LSDELIVERYSTATUS_CANCELLED：Cancelled
 * deliveryStatusVal            状态文字
 * giftList                     产品列表
 * greetingMessage              文本信息
 * specialDeliveryRequest       文本请求
 */
@property (nonatomic, copy) NSString* orderNumber;
@property (nonatomic, assign) NSInteger  orderDate;
@property (nonatomic, copy) NSString* anchorId;
@property (nonatomic, copy) NSString* anchorNickName;
@property (nonatomic, copy) NSString* anchorAvatar;
@property (nonatomic, assign) LSDeliveryStatus deliveryStatus;
@property (nonatomic, copy) NSString* deliveryStatusVal;
@property (nonatomic, strong) NSMutableArray<LSFlowerGiftBaseInfoItemObject *>* giftList;
@property (nonatomic, copy) NSString* greetingMessage;
@property (nonatomic, copy) NSString* specialDeliveryRequest;
@end
