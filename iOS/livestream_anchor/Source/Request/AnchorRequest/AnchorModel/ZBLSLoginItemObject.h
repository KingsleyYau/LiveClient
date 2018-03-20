//
//  ZBLSLoginItemObject.h
//  dating
//
//  Created by Alex on 18/2/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBLSLoginItemObject : NSObject
/**
 * 登录成功结构体
 * userId			用户ID
 * token            直播系统不同服务器的统一验证身份标识
 * nickName         昵称
 * photoUrl		    头像url
 */
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* nickName;
@property (nonatomic, strong) NSString* photoUrl;
@end
