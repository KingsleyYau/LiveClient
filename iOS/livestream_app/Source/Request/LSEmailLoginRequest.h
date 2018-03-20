//
//  LSEmailLoginRequest.h
//  dating
//  2.6.邮箱登录（仅独立）接口
//  Created by Max on 17/12/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSEmailLoginRequest : LSSessionRequest
/*
 * @param email              用户的email或id
 * @param passWord           登录密码
 * @param model              设备型号（格式：设备型号-系统版本号-API版本号-分辨率）
 * @param deviceId           设备唯一标识
 * @param manufacturer       制造厂商
 */
@property (nonatomic, copy) NSString* _Nonnull email;
@property (nonatomic, copy) NSString* _Nonnull passWord;
@property (nonatomic, copy) NSString* _Nonnull versionCode;
@property (nonatomic, copy) NSString* _Nonnull model;
@property (nonatomic, copy) NSString* _Nonnull deviceId;
@property (nonatomic, copy) NSString* _Nonnull manufacturer;
@property (nonatomic, copy) NSString* _Nonnull checkCode;
@property (nonatomic, strong) EmailLoginFinishHandler _Nullable finishHandler;
@end
