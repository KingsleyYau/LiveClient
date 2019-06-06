//
//  LSDoLoginRequest.h
//  dating
//  2.18.token登录认证
//  Created by Alex on 18/9/21
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

/**
 *  2.18.token登录认证接口
 *
 * tokenId           用于登录其他站点的加密串（调用《2.19.获取认证token》返回的sid参数）
 * memberId          会员id
 * deviceid          设备唯一标识
 * versionCode       客户端内部版本号
 * model             设备型号（格式：设备型号-系统版本号-API版本号-分辨率）
 * manufacturer      制造厂商
 *  finishHandler    接口回调

 */
@interface LSDoLoginRequest : LSSessionRequest
@property (nonatomic, copy) NSString * _Nullable tokenId;
@property (nonatomic, copy) NSString * _Nullable memberId;
@property (nonatomic, copy) NSString * _Nullable versionCode;
@property (nonatomic, copy) NSString * _Nullable deviceid;
@property (nonatomic, copy) NSString * _Nullable model;
@property (nonatomic, copy) NSString * _Nullable manufacturer;
@property (nonatomic, strong) LoginWithTokenAuthFinishHandler _Nullable finishHandler;
@end
