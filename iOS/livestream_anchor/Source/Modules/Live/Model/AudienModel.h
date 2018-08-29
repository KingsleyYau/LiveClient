//
//  AudienModel.h
//  livestream
//
//  Created by randy on 2017/9/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudienModel : NSObject
/**
 * 观众列表结构体
 * userId			观众ID
 * nickName         观众昵称
 * photoUrl		    观众头像url
 * mountId          坐驾ID
 * mountUrl         坐驾图片url
 * level            用户等级
 * image            头像默认图
 * isHasTicket      是否已购票（NO：否，YES：是）
 */
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* nickName;
@property (nonatomic, copy) NSString* photoUrl;
@property (nonatomic, copy) NSString* mountId;
@property (nonatomic, copy) NSString* mountname;
@property (nonatomic, copy) NSString* mountUrl;
@property (nonatomic, assign) int level;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isHasTicket;
@end
