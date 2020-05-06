
//
//  ImScheduleRoomInfoObject.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImScheduleMsgObject.h"
#include "IImClientDef.h"

/**
  私密直播预付费信息
 */
@interface ImScheduleRoomInfoObject : NSObject

/**
 * 私密直播预付费信息
 * roomId            直播间id （http的refId）
 * nickName       名称
 * toId                 接收者id
 * privScheId      预付费id
 * msg                 发送内容
 */
@property (nonatomic, copy) NSString* roomId;
@property (nonatomic, copy) NSString* nickName;
@property (nonatomic, copy) NSString* toId;
@property (nonatomic, copy) NSString* privScheId;
@property (nonatomic, strong) ImScheduleMsgObject* msg;

@end
