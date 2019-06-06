//
//  LSPersonalProfileItemObject.h
//  dating
//
//  Created by test on 16/5/30.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

typedef enum VType {
    VType_None = 0,
    VType_Verifing,
    VType_Fail,
    VType_Yes,
} VType;

typedef enum PhotoStatus {
    None = 0,
    Yes,
    Verifing,
    InstitutionsFail,
    Fail,
} PhotoStatus;

typedef enum ResumeStatus {
    UnVerify = 1,
    Verified = 2,
    NotVerified = 3,
} ResumeStatus;

@interface LSPersonalProfileItemObject : NSObject

/** 男士ID */
@property (nonatomic,strong) NSString *manId;
/** 男士年龄 */
@property (nonatomic,assign) int age;
/** 生日 */
@property (nonatomic,strong) NSString *birthday;
/** 姓 */
@property (nonatomic,strong) NSString *firstname;
/** 名 */
@property (nonatomic,strong) NSString *lastname;
/** email */
@property (nonatomic,strong) NSString *email;
/** 性别 */
@property (nonatomic,assign) int gender;
/** 国家 */
@property (nonatomic,assign) int country;
/** 结婚 */
@property (nonatomic,assign) int marry;
/** 高度 */
@property (nonatomic,assign) int height;
/** 体重 */
@property (nonatomic,assign) int weight;
/** 吸烟 */
@property (nonatomic,assign) int smoke;
/** 喝酒 */
@property (nonatomic,assign) int drink;
/** 语言 */
@property (nonatomic,assign) int language;
/** 宗教 */
@property (nonatomic,assign) int religion;
/** 教育 */
@property (nonatomic,assign) int education;
/** 职业 */
@property (nonatomic,assign) int profession;
/** 人种 */
@property (nonatomic,assign) int ethnicity;
/** 收入 */
@property (nonatomic,assign) int income;
/** 孩纸个数 */
@property (nonatomic,assign) int children;
/** 描述 */
@property (nonatomic,strong) NSString *resume;
/** 审核中的个人描述 */
@property (nonatomic,strong) NSString *resume_content;
/** 描述审核状态 */
@property (nonatomic,assign) int resume_status;
/** 地址1 */
@property (nonatomic,strong) NSString *address1;
/** 地址2 */
@property (nonatomic,strong) NSString *address2;
/** 城市 */
@property (nonatomic,strong) NSString *city;
/** 省会 */
@property (nonatomic,strong) NSString *province;
/** 邮政编码 */
@property (nonatomic,strong) NSString *zipcode;
/** 电话 */
@property (nonatomic,strong) NSString *telephone;
/** fax */
@property (nonatomic,strong) NSString *fax;
/** 备用邮箱 */
@property (nonatomic,strong) NSString *alternate_email;
/** 余额 */
@property (nonatomic,strong) NSString *money;

/** 身份状态 */
@property (nonatomic,assign) int v_id;
/** 相册标识 */
@property (nonatomic,assign) int photoStatus;

/** 男士Url */
@property (nonatomic,strong) NSString *photoUrl;

/** 剩余积分 */
@property (nonatomic,assign) int  integral;
/** 手机号 */
@property (nonatomic,strong) NSString *mobile;
/** 手机号区号 */
@property (nonatomic,assign) int mobileZoom;
/** 手机状态 */
@property (nonatomic,assign) int mobileStatus;
/** 固话号码 */
@property (nonatomic,strong) NSString *landline;

/** 固话区号 */
@property (nonatomic,assign) int landlineZoom;
/** 固话区号 */
@property (nonatomic,strong) NSString *landlineLocation;
/** 固话审核状态 */
@property (nonatomic,assign) int landlineStatus;
/** 兴趣爱好 */
@property (nonatomic,strong) NSArray *interests;
/** 星座 */
@property (nonatomic, assign) int zodiac;

/**
 *  是否允许上传头像
 *
 *  @return <#return value description#>
 */
- (BOOL)canUpdatePhoto;

/**
 *  是否允修改描述
 *
 *  @return <#return value description#>
 */
- (BOOL)canUpdateResume;

@end
