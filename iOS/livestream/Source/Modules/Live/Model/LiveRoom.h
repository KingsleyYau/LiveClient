//
//  LiveRoom.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSImManager.h"

#import "ImHeader.h"

typedef enum LiveRoomType {
    LiveRoomType_Unknow = 0,
    LiveRoomType_Public,
    LiveRoomType_Public_VIP,
    LiveRoomType_Private,
    LiveRoomType_Private_VIP,
    LiveRoomType_Hang_Out,
} LiveRoomType;

@interface LiveRoom : NSObject

@property (strong) NSString *roomId;
@property (strong) NSString *showId;
@property (strong) NSString *userId;
@property (strong) NSString *userName;
@property (assign) LiveRoomType roomType;
@property (strong) NSString * showTitle;
@property (strong, nonatomic) NSArray<NSString *> *playUrlArray;
@property (strong, readonly) NSString *playUrl;
@property (strong, nonatomic) NSArray<NSString *> *publishUrlArray;
@property (strong, readonly) NSString *publishUrl;

@property (strong) NSString *photoUrl;
@property (strong, readonly) NSString *roomPhotoUrl;

@property (strong) LiveRoomInfoItemObject *httpLiveRoom;
@property (strong) ImLiveRoomObject *imLiveRoom;
@property (strong) IMHangoutRoomItemObject *hangoutLiveRoom;

@property (nonatomic, weak) UIViewController *superController;
@property (nonatomic, weak) UIView *superView;

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
