/*
 * HttpRequestEnum.h
 *
 *  Created on: 2017-5-25
 *      Author: Hunter.Mun
 */

#ifndef REQUESTENUM_H_
#define REQUESTENUM_H_

typedef enum LoginType {
    LoginType_Unknow = -1,
    LoginType_Phone = 0,
    LoginType_Email =1,
} LoginType;

/*直播间状态*/
typedef enum{
	LIVEROOM_STATUS_UNKNOWN = -1,
	LIVEROOM_STATUS_OFFLINE = 0,
	LIVEROOM_STATUS_LIVE = 1
} LiveRoomStatus;

/*头像类型*/
typedef enum{
	PHOTOTYPE_UNKNOWN = -1,
	PHOTOTYPE_THUMB = 0,
	PHOTOTYPE_LARGE = 1
} PhotoType;

/*性别*/
typedef enum{
	GENDER_UNKNOWN = -1,
	GENDER_MALE = 0,
	GENDER_FEMALE = 1
} Gender;

/*图片类型*/
typedef enum{
    IMAGETYPE_UNKNOWN = 0,
    IMAGETYPE_USER = 1,
    IMAGETYPE_COVER = 2
} ImageType;

/*审核状态*/
typedef enum{
    EXAMINE_STATUS_UNKNOWN = 0,
    EXAMINE_STATUS_WAITING = 1,  // 待审核
    EXAMINE_STATUS_PASS    = 2,  // 通过
    EXAMINE_STATUS_REFUSE  = 3   // 否决
}ExamineStatus;

/*礼物类型*/
typedef enum{
    GIFTTYPE_UNKNOWN = 0,
    GIFTTYPE_COMMON = 1,   // 普通礼物
    GIFTTYPE_Heigh = 2  // 高级礼物（动画）
}GiftType;

#endif
