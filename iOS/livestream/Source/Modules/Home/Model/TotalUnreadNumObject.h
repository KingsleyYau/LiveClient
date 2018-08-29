//
//  TotalUnreadNumObject.h
//  livestream
//
//  Created by Randy_Fan on 2018/7/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TotalUnreadNumObject : NSObject
/**
 * 获取主界面未读数量
 * ticketNoreadNum              节目未读数量
 * loiNoreadNum                 意向信未读数量
 * emfNoreadNum                 EMF未读数量
 * messageNoreadNum             私信未读数量
 * bookingNoreadNum             预约未读数量
 * backpackNoreadNum            背包未读数量
 */
@property (nonatomic, assign) int ticketNoreadNum;
@property (nonatomic, assign) int loiNoreadNum;
@property (nonatomic, assign) int emfNoreadNum;
@property (nonatomic, assign) int messageNoreadNum;
@property (nonatomic, assign) int bookingNoreadNum;
@property (nonatomic, assign) int backpackNoreadNum;

@end
