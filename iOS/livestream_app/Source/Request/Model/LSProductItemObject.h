//
// LSProductItemObject
//  dating
//
//  Created by Alex on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
@interface LSProductItemObject : NSObject
/**
 * 主播信息结构体
 * 产品结构体
 * productId               产品ID
 * name                    名称
 * price                   价格
 * icon                    图标URL
 */
@property (nonatomic, copy) NSString* _Nonnull productId;
@property (nonatomic, copy) NSString* _Nonnull name;
@property (nonatomic, copy) NSString* _Nonnull price;
@property (nonatomic, copy) NSString* _Nonnull icon;

@end
