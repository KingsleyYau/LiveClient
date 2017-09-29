//
//  RoomTypeIsFirstManager.h
//  livestream
//
//  Created by randy on 2017/9/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveRoom.h"

@interface RoomTypeIsFirstManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *firstInDic;

+ (instancetype)manager;

- (void)comeinLiveRoomWithType:(LiveRoomType)type HaveComein:(BOOL)haveComein;

- (BOOL)getThisTypeHaveCome:(LiveRoomType)type;

@end


@interface RoomTypeFirst : NSObject

@property (nonatomic, assign) LiveRoomType type;

@property (nonatomic, assign) BOOL haveComein;

@end
