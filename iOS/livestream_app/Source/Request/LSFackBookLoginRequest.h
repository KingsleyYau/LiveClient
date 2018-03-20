//
//  LSFackBookLoginRequest.h
//  dating
//  2.4.Facebook注册及登录（仅独立) 接口
//  Created by Max on 17/12/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSFackBookLoginRequest : LSSessionRequest
/*
* @param fToken;                              Facebook登录返回的accessToken
* @param nickName;                            昵称
* @param utmReferrer;                         APP推广参数（google play返回的referrer，格式：UrlEncode(referrer)）
* @param model;                               设备型号
* @param deviceId;                            设备唯一标识
* @param manufacturer;                        制造厂商
* @param inviteCode;                          推荐码（可无）
* @param email;                               用户注册的邮箱（可无）
* @param passWord;                            登录密码（可无）
* @param birthDay;                            出生日期（可无，但未绑定时必须提交，格式为：2015-02-20）
* @param gender;                              性别（GENDERTYPE_MAN：男，GENDERTYPE_LADY：女）
*/
@property (nonatomic, copy) NSString* _Nonnull fToken;
@property (nonatomic, copy) NSString* _Nonnull nickName;
@property (nonatomic, copy) NSString* _Nonnull utmReferrer;
@property (nonatomic, copy) NSString* _Nonnull model;
@property (nonatomic, copy) NSString* _Nonnull deviceId;
@property (nonatomic, copy) NSString* _Nonnull manufacturer;
@property (nonatomic, copy) NSString* _Nonnull inviteCode;
@property (nonatomic, copy) NSString* _Nonnull email;
@property (nonatomic, copy) NSString* _Nonnull passWord;
@property (nonatomic, copy) NSString* _Nonnull birthDay;
@property (nonatomic, assign) GenderType gender;
@property (nonatomic, strong) FackBookLoginFinishHandler _Nullable finishHandler;
@end
