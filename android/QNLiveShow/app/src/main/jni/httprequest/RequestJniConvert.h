/*
 * RequestJniConvert.h
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 *  Description Jni中间转换层
 */

#ifndef REQUESTJNICONVERT_H_
#define REQUESTJNICONVERT_H_

#include <httpcontroller/HttpRequestEnum.h>

/*直播间状态转换*/
static const int LiveRoomStatusArray[] = {
	LIVEROOM_STATUS_UNKNOWN,
	LIVEROOM_STATUS_OFFLINE,
	LIVEROOM_STATUS_LIVE
};

// 底层状态转换JAVA坐标
int ReviewStatusToInt(LiveRoomStatus liveRoomStatus);

/*图片类型转换*/
static const int PhotoTypeArray[] = {
	PHOTOTYPE_UNKNOWN,
	PHOTOTYPE_THUMB,
	PHOTOTYPE_LARGE
};

//Java层转底层枚举
PhotoType IntToPhotoType(int value);

/*用户性别*/
static const int GenderArray[] = {
	GENDER_UNKNOWN,
	GENDER_MALE,
	GENDER_FEMALE
};

// 底层状态转换JAVA坐标
int GenderToInt(Gender gender);
//Java层转底层枚举
Gender IntToGender(int value);

/* 礼物类型  */
static const int GiftTypeArray[]{
	GIFTTYPE_UNKNOWN,
	GIFTTYPE_COMMON,   // 普通礼物
	GIFTTYPE_Heigh  // 高级礼物（动画）
};

// 底层状态转换JAVA坐标
int GiftTypeToInt(GiftType giftType);

/* 封面图处理状态    */
static const int CoverPhotoStatusArray[]{
	EXAMINE_STATUS_UNKNOWN,
	EXAMINE_STATUS_WAITING,  	// 待审核
	EXAMINE_STATUS_PASS,  		// 通过
	EXAMINE_STATUS_REFUSE   	// 否决
};

// 底层状态转换JAVA坐标
int CoverPhotoStatusToInt(ExamineStatus status);

/* 上传图片类型   */
static const int uploadPhotoTypeArray[]{
	IMAGETYPE_UNKNOWN,
	IMAGETYPE_USER,
	IMAGETYPE_COVER
};

//Java层转底层枚举
ImageType IntToUploadPhotoType(int value);

#endif
