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
 */
@property (nonatomic, copy) NSString *_Nonnull talentId;
@property (nonatomic, copy) NSString *_Nonnull name;
@property (nonatomic, assign) double credit;

@end
