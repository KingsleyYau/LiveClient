//
//  ZBBookingPrivateInviteListObject.h
//  dating
//
//  Created by Alex on 18/2/28.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBBookingPrivateInviteItemObject.h"

@interface ZBBookingPrivateInviteListObject : NSObject
/**
 * 获取预约邀请列表
 * total           预约列表总数
 * noReadCount     未读总数
 * list            预约列表
 */
@property (nonatomic, assign) int total;
@property (nonatomic, assign) int noReadCount;
@property (nonatomic, strong) NSMutableArray<ZBBookingPrivateInviteItemObject *>* list;


@end
