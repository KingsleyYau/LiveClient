//
//  UnreadNumManager.h
//  livestream
//
//  Created by Randy_Fan on 2018/7/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TotalUnreadNumObject.h"

typedef enum UnreadType {
    UnreadType_Private_Message = 0,
    UnreadType_EMF = 1,
    UnreadType_Loi = 2,
    UnreadType_Ticket = 3,
    UnreadType_Booking = 4,
    UnreadType_Backpack = 5,
} UnreadType;

@class UnreadNumManagerDelegate;
@protocol UnreadNumManagerDelegate <NSObject>
@optional
- (void)reloadUnreadView:(TotalUnreadNumObject *)model;
@end

typedef void (^GetTotalNoreadNumHandler)(BOOL success, TotalUnreadNumObject *unreadModel);

@interface UnreadNumManager : NSObject

+ (instancetype)manager;

/**
 增加监听器

 @param delegate 监听对象
 */
- (void)addDelegate:(id<UnreadNumManagerDelegate>)delegate;

/**
 移除监听器
 
 @param delegate 监听对象
 */
- (void)removeDelegate:(id<UnreadNumManagerDelegate>)delegate;

/**
 请求未读消息

 @param finshHandler 回调
 */
- (void)getTotalUnreadNum:(GetTotalNoreadNumHandler)finshHandler;

/**
 获取未读消息

 @param type 未读消息类型
 @return 返回未读数
 */
- (int)getUnreadNum:(UnreadType)type;



@end
