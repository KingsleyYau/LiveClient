//
//  LSDateTool.h
//  livestream
//
//  Created by Randy_Fan on 2018/9/19.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSDateTool : NSObject

/**
 显示联系人列表聊天时间

 @param date 时间数据
 @return 时间字符串
 */
- (NSString *)showMessageListTimeTextOfDate:(NSDate *)date;
/**
 显示聊天列表聊天时间
 
 @param date 时间数据
 @return 时间字符串
 */
- (NSString *)showChatListTimeTextOfDate:(NSDate *)date;

/**
 显示邮件联系人列表聊天时间

 @param date 时间数据
 @return 时间字符串
 */
- (NSString *)showMailListTimeTextOfDate:(NSDate *)date;

/**
 显示信件发送时间
 
 @param date 时间数据
 @return 时间字符串
 */
- (NSString *)showGreetingDetailTimeOfDate:(NSDate *)date;

@end
