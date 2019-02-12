/*
 * LSLiveChatRequestProfileDefine.h
 *
 *  Created on: 2015-3-5
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTPROFILEDEFINE_H_
#define LSLIVECHATREQUESTPROFILEDEFINE_H_


/* ########################	个人相关 模块  ######################## */

/* 字段 */

/* 个人信息 */
#define PROFILE_MANID			"manid"
#define PROFILE_FIRSTNAME 		"firstname"
#define PROFILE_LASTNAME 		"lastname"
#define PROFILE_BIRTHDAY		"birthday"
#define PROFILE_AGE				"age"
#define PROFILE_GENDER			"gender"
#define PROFILE_EMAIL			"email"
#define PROFILE_COUNTRY			"country"
#define PROFILE_MARRY			"marry"
#define PROFILE_WEIGHT 			"weight"
#define PROFILE_WEIGHT_BEGINVALUE	5
#define PROFILE_HEIGHT			"height"
#define PROFILE_HEIGHT_BEGINVALUE	12
#define PROFILE_SMOKE			"smoke"
#define PROFILE_DRINK			"drink"
#define PROFILE_LANGUAGE		"language"
#define PROFILE_RELIGION		"religion"
#define PROFILE_EDUCATION		"education"
#define PROFILE_PROFESSION		"profession"
#define PROFILE_ETHNICITY		"ethnicity"
#define PROFILE_ETHNICITY_BEGINVALUE	1
#define PROFILE_INCOME			"income"
#define PROFILE_CHILDREN		"children"
#define	PROFILE_JJ				"jj"
#define PROFILE_RS_STATUS		"rs_status"
#define PROFILE_RS_CONTENT		"rs_content"
#define PROFILE_ADDRESS1		"address1"
#define PROFILE_ADDRESS2		"address2"
#define PROFILE_CITY			"city"
#define PROFILE_PROVINCE		"province"
#define PROFILE_ZIPCODE			"zipcode"
#define PROFILE_TELEPHONE		"telephone"
#define PROFILE_TELEPHONE_CC	"telephone_cc"
#define PROFILE_FAX				"fax"
#define PROFILE_ALTERNATE_EMAIL	"alternate_email"
#define PROFILE_MONEY			"money"
#define PROFILE_V_ID			"v_id"
#define PROFILE_PHOTO			"photo"
#define PROFILE_PHOTOURL		"photoURL"
#define PROFILE_INTEGRAL		"integral"
#define PROFILE_MOBILE			"mobile"
#define PROFILE_MOBILE_CC		"mobile_cc"
#define PROFILE_MOBILE_STATUS	"mobile_status"
#define PROFILE_LANDLINE		"landline"
#define PROFILE_LANDLINE_CC		"landline_cc"
#define PROFILE_LANDLINE_AC		"landline_ac"
#define PROFILE_LANDLINE_STATUS	"landline_status"
#define PROFILE_INTERESTS		"interests"
#define PROFILE_ZODIAC          "zodiac"

// 体重转code/code转体重
inline int WeightToCode(int value) {
	return value > 0 ? value - PROFILE_WEIGHT_BEGINVALUE : value;
}
inline int CodeToWeight(int code) {
	return code > 0 ? code + PROFILE_WEIGHT_BEGINVALUE : code;
}
// 身高转code/code转身高
inline int HeightToCode(int value) {
	return value > 0 ? value - PROFILE_HEIGHT_BEGINVALUE : value;
}
inline int CodeToHeight(int code) {
	return code > 0 ? code + PROFILE_HEIGHT_BEGINVALUE : code;
}
// 人种转code/code转人种
inline int EthnicityToCode(int value) {
	return value > 0 ? value - PROFILE_ETHNICITY_BEGINVALUE : value;
}
inline int CodeToEthnicity(int code) {
	return code > 0 ? code + PROFILE_ETHNICITY_BEGINVALUE : code;
}

/* 修改个人信息  */
#define PROFILE_JJ_RESULT		"jj_result"

/* 上传头像*/
#define PROFILE_PHOTONAME		"photoname"

/* 字段  end */

/* 接口路径定义 */

/**
 * 2.1.查询个人信息
 */
#define GetMyProfilePath "/member/myprofile"

/**
 * 2.2.修改个人信息
 */
#define UpdateMyProfilePath "/member/updatepro"

/**
 * 2.3.开始编辑简介触发计时
 */
#define StartEditMyProfilePath "/member/intro_edit"

/**
 * 2.4.保存联系电话
 */
#define SaveContactPath "/member/contact_save"

/**
 * 2.5.上传头像
 */
#define UploadPhotoPath "/member/uploadphoto"

/* 接口路径定义 */

/**
 * 3.6.邮箱验证
 */
#define ActivateEmailPath "/member/activate_email"

/* 字段 */
#define ACTIVATEEMAIL_DO          "do"
#define ACTIVATEEMAIL_NEW_EMAIL   "new_email"

/* 接口路径定义 */

#endif /* REQUESTPROFILEDEFINE_H_ */
