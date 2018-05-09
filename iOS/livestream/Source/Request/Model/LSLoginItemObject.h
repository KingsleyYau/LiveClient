//
//  LSLoginItemObject.h
//  dating
//
//  Created by Alex on 17/5/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSSvrItemObject.h"
#import <httpcontroller/HttpRequestEnum.h>

@interface LSLoginItemObject : NSObject
/**
 * 登录成功结构体
 * userId			用户ID
 * token            直播系统不同服务器的统一验证身份标识
 * nickName         昵称
 * level			级别
 * experience		经验值
 * photoUrl		    头像url
 * isPushAd         是否打开广告（0:否 1:是）
 * svrList          流媒体服务器列表
 * userType         观众用户类型（1:A1类型 2:A2类型）（A1类型：仅可看付费公开及豪华私密直播间，A2类型：可看所有直播间）
 * qnMainAdUrl      QN主界面广告浮层的URL（可无，无则表示不弹广告）
 * qnMainAdTitle    QN主界面广告浮层的标题（可无）
 * qnMainAdId       QN主界面广告浮层的ID（可无，无则表示不弹广告）
 */
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSString* nickName;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int experience;
@property (nonatomic, strong) NSString* photoUrl;
@property (nonatomic, assign) BOOL isPushAd;
@property (nonatomic, strong) NSArray<LSSvrItemObject *>* svrList;
@property (nonatomic, assign) UserType userType;
@property (nonatomic, strong) NSString* qnMainAdUrl;
@property (nonatomic, strong) NSString* qnMainAdTitle;
@property (nonatomic, strong) NSString* qnMainAdId;

@end
