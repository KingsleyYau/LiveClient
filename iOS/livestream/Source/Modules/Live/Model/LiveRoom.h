//
//  LiveRoom.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LiveRoomInfoItemObject.h"

#import "ImHeader.h"

typedef enum LiveRoomType {
    LiveRoomType_Unknow = 0,
    LiveRoomType_Public,
    LiveRoomType_Public_VIP,
    LiveRoomType_Private,
    LiveRoomType_Private_VIP,
} LiveRoomType;

@interface LiveRoom : NSObject

@property (strong) NSString* roomId;
@property (assign) LiveRoomType roomType;

@property (strong, readonly) NSString* userId;
@property (strong, readonly) NSString* userName;

@property (strong) LiveRoomInfoItemObject *httpLiveRoom;
@property (strong) ImLiveRoomObject *imLiveRoom;

@end
