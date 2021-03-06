//
//  LiveRoom.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImHeader.h"

#import "LiveRoomInfoItemObject.h"

typedef enum LiveRoomType {
    LiveRoomType_Unknow = 0,
    LiveRoomType_Public,
    LiveRoomType_Private,
    LiveRoomType_Hang_Out,
} LiveRoomType;

@interface LiveRoom : NSObject
// 是否可用, 如果退出直播间则标记为不可用
@property (assign) BOOL active;

@property (strong) NSString *roomId;
@property (strong) NSString *showId;
@property (strong) NSString *userId;
@property (strong) NSString *userName;
@property (assign) LiveRoomType roomType;
 //公开直播间类型（IMPUBLICROOMTYPE_COMMON：普通公开，IMPUBLICROOMTYPE_PROGRAM：节目）
@property (nonatomic, assign) IMPublicRoomType liveShowType;
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

// 公开直播间免费提醒
@property (nonatomic, copy) NSString *publicRoomFreeMsg;

@property (nonatomic, weak) UIViewController *superController;
@property (nonatomic, weak) UIView *superView;

// 主播的 接收私密邀请/接收私密预约 权限
@property (nonatomic, strong) ImAuthorityItemObject* priv;

/** 是否允许最小化 */
@property (nonatomic, assign) BOOL canShowMinLiveView;
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
