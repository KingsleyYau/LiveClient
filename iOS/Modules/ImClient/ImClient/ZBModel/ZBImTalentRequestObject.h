
//
//  ZBImTalentRequestObject.h
//  livestream
//
//  Created by Max on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 才艺点播请求Object
 */
@interface ZBImTalentRequestObject : NSObject

/**
 * 才艺回复通知结构体
 * talentInviteId         才艺邀请ID
 * name                   才艺点播名称
 * userId                 观众ID
 * nickName               观众昵称
 */
@property (nonatomic, copy) NSString *_Nonnull talentInviteId;
@property (nonatomic, copy) NSString *_Nonnull name;
@property (nonatomic, copy) NSString *_Nonnull userId;
@property (nonatomic, copy) NSString *_Nonnull nickName;

@end
