//
//  LoginItemObject.h
//  dating
//
//  Created by Alex on 17/5/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginItemObject : NSObject
/**
 * 登录成功结构体
 * userId			用户ID
 * token            直播系统不同服务器的统一验证身份标识
 * nickName             昵称
 * levenl			级别
 * experience		经验值
 * photoUrl		    头像url
 */
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* nickName;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int experience;
@property (nonatomic, strong) NSString* photoUrl;
@end
