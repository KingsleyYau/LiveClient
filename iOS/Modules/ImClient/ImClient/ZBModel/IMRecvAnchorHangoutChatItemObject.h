
//
//  IMRecvAnchorHangoutChatItemObject.h
//  livestream
//
//  Created by Max on 2018/5/12.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMRecvAnchorHangoutChatItemObject : NSObject

/**
 * 接收直播间文本消息
 * roomId           直播间ID
 * level            发送方级别
 * fromId           发送方的用户ID
 * nickName         发送方的昵称
 * msg              文本消息内容
 * honorUrl         勋章图片url
 * at               用户ID，用于指定接收者（字符串数组）（可无，无则表示发送给直播间所有人）
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, assign) int level;
@property (nonatomic, copy) NSString *_Nonnull fromId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull msg;
@property (nonatomic, copy) NSString *_Nonnull honorUrl;
@property (nonatomic, copy) NSArray<NSString *> *_Nonnull at;

@end
