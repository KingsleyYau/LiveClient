//
//  BookingPrivateInviteListObject.h
//  dating
//
//  Created by Alex on 17/8/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookingPrivateInviteItemObject.h"

@interface BookingPrivateInviteListObject : NSObject
/**
 * 获取预约邀请列表
 * total           预约列表总数
 * noReadCount     未读总数
 * list            预约列表
 */
@property (nonatomic, assign) int total;
@property (nonatomic, assign) int noReadCount;
@property (nonatomic, strong) NSMutableArray<BookingPrivateInviteItemObject *>* list;


@end
