//
//  LSManBaseInfoItemObject
//  dating
//
//  Created by Alex on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSProductItemObject.h"
@interface LSManBaseInfoItemObject : NSObject
/**
 * 个人信息
 * userId               观众ID
 * nickName             昵称
 * nickNameStatus       昵称审核状态（0：审核完成，1：审核中）
 * photoUrl             头像url
 * photoStatus          头像审核状态（0：没有头像及审核成功，1：审核中，2：不合格）
 * birthday             生日
 * userlevel            观众等级（整型）
 * gender               性别（GENDERTYPE_MAN：男，GENDERTYPE_LADY：女）
 * userType             观众用户类型（1:A1类型 2:A2类型）（A1类型：仅可看付费公开及豪华私密直播间，A2类型：可看所有直播间）
 * gauid                Google Analytics UserID参数
 */
@property (nonatomic, copy) NSString* _Nonnull userId;
@property (nonatomic, copy) NSString* _Nonnull nickName;
@property (nonatomic, assign) NickNameVerifyStatus nickNameStatus;
@property (nonatomic, copy) NSString* _Nonnull photoUrl;
@property (nonatomic, assign) PhotoVerifyStatus photoStatus;
@property (nonatomic, copy) NSString* _Nonnull birthday;
@property (nonatomic, assign) int userlevel;
@property (nonatomic,assign) GenderType gender;
@property (nonatomic, assign) UserType userType;
@property (nonatomic, copy) NSString* _Nonnull gaUid;
@end
