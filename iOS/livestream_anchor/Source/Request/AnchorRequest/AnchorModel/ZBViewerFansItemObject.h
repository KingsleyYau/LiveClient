//
//  ZBViewerFansItemObject.h
//  dating
//
//  Created by Alex on 18/2/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBViewerFansItemObject : NSObject
/**
 * 观众列表结构体
 * userId			观众ID
 * nickName         观众昵称
 * photoUrl		    观众头像url
 * mountId          坐驾ID
 * mountName        座驾名称
 * mountUrl         坐驾图片url
 * level            用户等级
 * isHasTicket      是否已购票
 */
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* nickName;
@property (nonatomic, copy) NSString* photoUrl;
@property (nonatomic, copy) NSString* mountId;
@property (nonatomic, copy) NSString* mountName;
@property (nonatomic, copy) NSString* mountUrl;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) BOOL isHasTicket;
@end
