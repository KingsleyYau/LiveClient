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
 聊天列表本人名字颜色
 */
@property (nonatomic, strong) UIColor *myNameColor;

/**
 聊天列表用户名字颜色
 */
@property (nonatomic, strong) UIColor *userNameColor;

/**
 聊天列表主播名字颜色
 */
@property (nonatomic, strong) UIColor *liverNameColor;

/**
 聊天列表主播标签图片
 */
@property (nonatomic, strong) UIImage *liverTypeImage;

/**
 聊天列表接收文本颜色
 */
@property (nonatomic, strong) UIColor *chatStrColor;
/**
 聊天列表发送礼物文本颜色
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
 送礼文本底部背景
 */
@property (nonatomic, strong) UIColor *textBackgroundViewColor;

/**
 座驾入场提示颜色
 */
@property (nonatomic, strong) UIColor *riderStrColor;

/**
 座驾背景颜色
 */
@property (nonatomic, strong) UIColor *riderBgColor;

/**
 座驾文本颜色
 */
@property (nonatomic, strong) UIColor *driverStrColor;

/**
 连击礼物背景
 */
@property (nonatomic, strong) UIImage *comboViewBgImage;
/**
 弹幕背景颜色
 */
@property (nonatomic, strong) UIColor *barrageBgColor;
/**
 购票标志
 */
@property (nonatomic, strong) UIImage * buyTicketImage;
@end
