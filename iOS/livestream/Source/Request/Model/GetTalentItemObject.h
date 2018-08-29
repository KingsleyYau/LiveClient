//
//  GetTalentItemObject.h
//  dating
//
//  Created by Alex on 17/8/30.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetTalentItemObject : NSObject
/**
 * 才艺结构体
 * talentId       才艺ID
 * name           才艺名称
 * credit         发送礼物所需的信用点
 * decription       才艺描述
 * giftId           礼物ID
 * giftName         礼物名称
 * giftNum          礼物数量
 */
@property (nonatomic, copy) NSString *_Nonnull talentId;
@property (nonatomic, copy) NSString *_Nonnull name;
@property (nonatomic, assign) double credit;
@property (nonatomic, copy) NSString *_Nonnull decription;
@property (nonatomic, copy) NSString *_Nonnull giftId;
@property (nonatomic, copy) NSString *_Nonnull giftName;
@property (nonatomic, assign) int giftNum;

@end
