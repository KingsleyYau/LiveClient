
//
//  ImScheduleStartInfoObject.h
//  livestream
//
//  Created by Max on 2020/4/8.
//  Copyright © 2020年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"
#import <httpcontroller/HttpRequestEnum.h>

/**
  私密直播预付费信息
 */
@interface ImScheduleStartInfoObject : NSObject

/**
 * 预付费即将开始信息
 * anchorId            主播id
 * anchorNickName           主播昵称
 * status        主播在线状态 （IMCHATONLINESTATUS_OFF：离线， IMCHATONLINESTATUS_ONLINE：在线）
 * anchorAvatar         主播头像
 * startTime     预付费开始时间（时间戳）
 * endTime      预付费结束时间（时间戳）
 * msg        提示语
 * schNum        数量
 * countdownNum        距离开始时间
 */
@property (nonatomic, copy) NSString* anchorId;
@property (nonatomic, copy) NSString* anchorNickName;
@property (nonatomic, assign) IMChatOnlineStatus status;
@property (nonatomic, copy) NSString* anchorAvatar;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;
@property (nonatomic, copy) NSString* msg;
@property (nonatomic, assign) int schNum;
@property (nonatomic, assign) int countdownNum;

@end
