//
//  RoomInfoItemObject.h
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoomItemObject.h"
#import "InviteIdItemObject.h"

@interface RoomInfoItemObject : NSObject
/**
 *
 * roomList		 有效直播间数组
 * inviteList     有效邀请数组
 */
@property (nonatomic, strong) NSMutableArray<RoomItemObject *>* roomList;
@property (nonatomic, strong) NSMutableArray<InviteIdItemObject *>* inviteList;


@end
