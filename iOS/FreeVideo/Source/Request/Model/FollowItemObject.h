//
//  FollowItemObject.h
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>
#import "LSProgramItemObject.h"
#import "LSHttpAuthorityItemObject.h"

@interface FollowItemObject : NSObject
/**
 * Follow结构体
 * userId			 主播ID
 * nickName          主播昵称
 * photoUrl		     主播头像url
 * onlineStatus		 主播在线状态
 * loveLevel         亲密度等级
 * roomPhotoUrl		 直播间封面图url
 * roomType          直播间类型
 * addDate           添加收藏时间（1970年起的秒数）
 * interest          爱好ID列表
 * anchorType        主播类型（1:白银 2:黄金）
 * showInfo          节目信息
 * isHasOneONOneAuth 是否有私密直播权限
 * isHasBookingAuth  是否有预约私密直播权限
 * isFollow         关注状态（NO:未关注，YES:已关注）
 */
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* nickName;
@property (nonatomic, strong) NSString* photoUrl;
// 直播间状态（0:离线（Offline） 正在直播（Live））
@property (nonatomic, assign) OnLineStatus onlineStatus;
@property (nonatomic, strong) NSString* roomPhotoUrl;
// 直播间类型（0:（没有直播间） 1:（免费公开直播间） 2:（付费公开直播间） 3:（普通私密直播间） 4:（豪华私密直播间））
@property (nonatomic, assign) HttpRoomType roomType;
@property (nonatomic, assign) int loveLevel;
@property (nonatomic, assign) NSInteger addDate;
// 爱好ID列表
@property (nonatomic, strong) NSMutableArray<NSNumber*>* interest;
// 主播类型（1:白银 2:黄金）
@property (nonatomic, assign) AnchorLevelType anchorType;

// 节目信息
@property (nonatomic, strong) LSProgramItemObject* showInfo;

@property (nonatomic, strong) LSHttpAuthorityItemObject* priv;

@property (nonatomic, assign) IMChatOnlineStatus chatOnlineStatus;

@property (nonatomic, assign) BOOL isFollow;


@end
