//
//  GiftWithIdItemObject.h
//  dating
//
//  Created by Alex on 17/8/28.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftWithIdItemObject : NSObject
/**
 * 礼物显示结构体
 * giftId   礼物ID
 * isShow   是否在礼物列表显示（0:否 1:是） （不包括背包礼物列表）
 * isPromo  是否推荐礼物（0:否 1:是）（不包括背包礼物列表）
 * typeIdList   分类ID组
 * isFree       是否免费
 */
@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL isPromo;
@property (nonatomic, strong) NSMutableArray<NSString *>* typeIdList;
@property (nonatomic, assign) BOOL isFree;
@end
