//
//  GiftNumItemObject.h
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftNumItemObject : NSObject
/**
 * 礼物数量结构体
 * num			可选礼物数量
 * isDefault     是否默认选中（0:否 1:是）
 */
@property (nonatomic, assign) int num;
@property (nonatomic, assign) BOOL isDefault;


@end
