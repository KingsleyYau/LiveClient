//
//  LSEmailRegisterRequest.h
//  dating
//  2.5.邮箱注册（仅独立）接口
//  Created by Max on 17/12/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSEmailRegisterRequest : LSSessionRequest
/*
 * @param email                电子邮箱
 * @param passWord             密码
 * @param gender               性别（M：男，F：女）
 * @param nickName             昵称
 * @param birthDay             出生日期（格式为：2015-02-20）
 * @param inviteCode           推荐码（可无）
 * @param model                设备型号
 * @param deviceId             设备唯一标识
 * @param manufacturer         制造厂商
 * @param utmReferrer          APP推广参数（google play返回的referrer，格式：UrlEncode(referrer)）
 */
@property (nonatomic, copy) NSString* _Nonnull email;
@property (nonatomic, copy) NSString* _Nonnull passWord;
@property (nonatomic, assign) GenderType gender;
@property (nonatomic, copy) NSString* _Nonnull nickName;
@property (nonatomic, copy) NSString* _Nonnull birthDay;
@property (nonatomic, copy) NSString* _Nonnull inviteCode;
@property (nonatomic, copy) NSString* _Nonnull model;
@property (nonatomic, copy) NSString* _Nonnull deviceId;
@property (nonatomic, copy) NSString* _Nonnull manufacturer;
@property (nonatomic, copy) NSString* _Nonnull utmReferrer;
@property (nonatomic, strong) MailRegisterFinishHandler _Nullable finishHandler;
@end
