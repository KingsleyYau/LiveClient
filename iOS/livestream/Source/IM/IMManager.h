//
//  IMManager.h
//  livestream
//
//  Created by Max on 2017/6/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImClientOC.h"

@interface IMManager : NSObject
@property (strong) ImClientOC* client;

@property (nonatomic, assign) BOOL isIMLogin;
#pragma mark - 获取实例
+ (instancetype)manager;

/** 发送弹幕请求 */
- (void)sendRoomToastWithRoomID:(NSString *)roomId message:(NSString *)msg;

/** 发送直播间聊天请求 */
- (void)sendRoomMsgWithRoomID:(NSString *)roomId message:(NSString *)msg;

/** 发送粉丝进入直播间请求 */
- (void)sendFansRoomInWithRoomId:(NSString *)roomId;

/** 发送粉丝退出直播间请求 */
- (void)sendFansRoomoutWithRoomId:(NSString *)roomId;

/** 发送礼物请求 */
- (void)sendRoomGiftWithRoomId:(NSString *)roomId giftId:(NSString *)giftId giftName:(NSString *)giftName giftNum:(int)giftNum multi_click:(BOOL)multi_click multi_click_start:(int)starNum multi_click_end:(int)endNum multi_click_id:(int)multi_click_id;

/** 发送点赞请求 */
- (void)sendRoomFavWithRoomId:(NSString *)roomId;

@end
