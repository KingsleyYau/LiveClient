//
//  RoomItemObject.h
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomItemObject : NSObject
/**
 * 有效直播间结构体
 * roomId			直播间ID
 * roomUrl           直播间流媒体服务url（如rtmp://192.168.88.17/live/samson_1）
 */
@property (nonatomic, copy) NSString* roomId;
@property (nonatomic, copy) NSString* roomUrl;


@end
