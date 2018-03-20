//
//  ZBImLoginReturnObject.h
//  dating
//
//  Created by Alex on 17/09/07.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBImInviteIdItemObject.h"
#import "ZBImScheduleRoomObject.h"
#import "ZBImLoginRoomObject.h"

/**
 * 立即私密邀请结构体
 * roomList                 需要强制进入的直播间数组
 * inviteList               本人邀请中有效的立即私密邀请
 * scheduleRoomList		    预约且未进入过直播
 */

@interface ZBImLoginReturnObject : NSObject
@property (nonatomic, strong) NSArray<ZBImLoginRoomObject*> * _Nullable roomList;
@property (nonatomic, strong) NSArray<ZBImInviteIdItemObject*> * _Nullable inviteList;
@property (nonatomic, strong) NSArray<ZBImScheduleRoomObject*> * _Nullable scheduleRoomList;

@end
