//
//  RoomStyleItem.h
//  livestream
//
//  Created by randy on 2017/8/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomStyleItem : NSObject
/**
 聊天列表名字颜色
 */
@property (nonatomic, strong) UIColor *nameColor;
/**
 聊天列表接收文本颜色
 */
@property (nonatomic, strong) UIColor *chatStrColor;
/**
 聊天列表发送文本颜色
 */
@property (nonatomic, strong) UIColor *sendStrColor;
/**
 聊天列表关注提示颜色
 */
@property (nonatomic, strong) UIColor *followStrColor;

/**
 警告提示颜色
 */
@property (nonatomic, strong) UIColor *warningStrColor;
/**
 公告提示颜色
 */
@property (nonatomic, strong) UIColor *announceStrColor;

/**
 座驾入场提示颜色
 */
@property (nonatomic, strong) UIColor *riderStrColor;
/**
 连击礼物背景
 */
@property (nonatomic, strong) UIImage *comboViewBgImage;
/**
 弹幕背景颜色
 */
@property (nonatomic, strong) UIColor *barrageBgColor;
@end
