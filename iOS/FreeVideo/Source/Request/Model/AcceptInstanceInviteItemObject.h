//
//  AcceptInstanceInviteItemObject.h
//  dating
//
//  Created by Alex on 17/9/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
/**
 * 观众处理立即私密邀请结构体
 * roomId                 直播间ID
 * roomType               直播间类型
 */
@interface AcceptInstanceInviteItemObject : NSObject
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, assign) HttpRoomType roomType;

@end
