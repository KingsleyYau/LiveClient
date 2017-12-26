//
//  ImLoginReturnObject.h
//  dating
//
//  Created by Alex on 17/09/07.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImInviteIdItemObject.h"
#import "ImScheduleRoomObject.h"
#import "ImLoginRoomObject.h"

/**
 * 立即私密邀请结构体
 * roomList                 需要强制进入的直播间数组
 * inviteList               本人邀请中有效的立即私密邀请
 * scheduleRoomList		    预约且未进入过直播
 */

@interface ImLoginReturnObject : NSObject
@property (nonatomic, strong) NSArray<ImLoginRoomObject*> * _Nullable roomList;
@property (nonatomic, strong) NSArray<ImInviteIdItemObject*> * _Nullable inviteList;
@property (nonatomic, strong) NSArray<ImScheduleRoomObject*> * _Nullable scheduleRoomList;

@end
