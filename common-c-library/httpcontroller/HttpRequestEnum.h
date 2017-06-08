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

#endif
