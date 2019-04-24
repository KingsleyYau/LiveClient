//
//  LSUserUnreadCountManager.h
//  livestream
//
//  Created by Calvin on 17/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetBackpackUnreadNumRequest.h"
#import "ManBookingUnreadUnhandleNumRequest.h"
#import "TotalUnreadNumObject.h"

typedef enum LSUnreadType {
    LSUnreadType_Private_Chat = 0,
    LSUnreadType_EMF = 1,
    LSUnreadType_Loi = 2,
    LSUnreadType_Hangout = 3,
    LSUnreadType_Ticket = 4,
    LSUnreadType_Booking = 5,
    LSUnreadType_Backpack = 6,
    LSUnreadType_SayHi = 7
} LSUnreadType;

@protocol LSUserUnreadCountManagerDelegate <NSObject>
@optional;
- (void)onGetResevationsUnredCount:(BookingUnreadUnhandleNumItemObject * _Nullable)item;
- (void)onGetBackpackUnreadCount:(GetBackPackUnreadNumItemObject * _Nullable)item;
- (void)reloadUnreadView:(TotalUnreadNumObject * _Nonnull)model;
- (void)onGetChatlistUnreadCount:(int)count;
@end

typedef void (^GetTotalNoreadNumHandler)(BOOL success, TotalUnreadNumObject * _Nonnull unreadModel);

@interface LSUserUnreadCountManager : NSObject

+(instancetype _Nonnull)shareInstance;

/**
 *  增加监听器
 *
 *  @param delegate 监听器
 */
- (void)addDelegate:(id<LSUserUnreadCountManagerDelegate> _Nonnull)delegate;

/**
 *  移除监听器
 *
 *  @param delegate 监听器
 */
- (void)removeDelegate:(id<LSUserUnreadCountManagerDelegate> _Nonnull)delegate;

/**
 请求预约未读数
 */
- (void)getResevationsUnredCount;

/**
 请求我的背包未读数
 */
- (void)getBackpackUnreadCount;

/**
 请求未读消息
 
 @param finshHandler 回调
 */
- (void)getTotalUnreadNum:(GetTotalNoreadNumHandler _Nonnull)finshHandler;

/**
 获取指定类型未读消息
 
 @param type 未读消息类型
 @return 返回未读数
 */
- (int)getUnreadNum:(LSUnreadType)type;


/**
 获取指定的用户的未读聊天消息数量

 @param anchorId 主播id
 @return 未读个数
 */
- (NSInteger)getAssignLadyUnreadCount:(NSString * _Nonnull)anchorId;
@end
