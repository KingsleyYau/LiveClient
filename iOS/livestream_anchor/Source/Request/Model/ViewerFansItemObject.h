//
//  ViewerFansItemObject.h
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewerFansItemObject : NSObject
/**
 * 观众列表结构体
 * userId			观众ID
 * nickName         观众昵称
 * photoUrl		    观众头像url
 * mountId          坐驾ID
 * mountUrl         坐驾图片url
 * level            用户等级
 */
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* nickName;
@property (nonatomic, copy) NSString* photoUrl;
@property (nonatomic, copy) NSString* mountId;
@property (nonatomic, copy) NSString* mountUrl;
@property (nonatomic, assign) int level;
@end
