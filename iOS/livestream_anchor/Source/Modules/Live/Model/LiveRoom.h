//
//  LiveRoom.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBImHeader.h"

typedef enum LiveRoomType {
    LiveRoomType_Unknow = 0,
    LiveRoomType_Public,
    LiveRoomType_Public_VIP,
    LiveRoomType_Private,
    LiveRoomType_Private_VIP,
} LiveRoomType;

@interface LiveRoom : NSObject

@property (strong) NSString *roomId;
@property (strong) NSString *userId;
@property (strong) NSString *userName;
@property (strong) NSString *photoUrl;
@property (strong, readonly) NSString *roomPhotoUrl;
@property (assign) LiveRoomType roomType;

// 播放url数组
@property (strong, nonatomic) NSArray<NSString *> *playUrlArray;
@property (strong, readonly) NSString *playUrl;

// 推流url数组
@property (strong, nonatomic) NSArray<NSString *> *publishUrlArray;
@property (strong, readonly) NSString *publishUrl;

@property (strong) ZBImLiveRoomObject *imLiveRoom;

@property (nonatomic, weak) UIViewController *superController;
@property (nonatomic, weak) UIView *superView;

@property (nonatomic, assign) int leftSeconds;
@property (nonatomic, assign) int maxFansiNum;
/**
 重置
 */
- (void)reset;

/**
 切换播放Url
 */
- (NSString *)changePlayUrl;

/**
 切换推送Url
 */
- (NSString *)changePublishUrl;

@end
