//
//  LiveGobalManager.h
//  livestream
//
//  Created by Max on 2017/10/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LiveRoom.h"
#import "LiveStreamPlayer.h"
#import "LiveStreamPublisher.h"

#define BACKGROUND_TIMEOUT 60

@interface LiveGobalManager : NSObject

@property (strong) LiveRoom * _Nullable liveRoom;
@property (strong) LiveStreamPlayer * _Nullable player;
@property (strong) LiveStreamPublisher * _Nullable publisher;
@property (strong) NSDate * _Nullable enterRoomBackgroundTime;
    
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;
    
@end
