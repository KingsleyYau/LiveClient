/*
 * IMEnumJniConvert.h
 *
 *  Created on: 2017-5-31
 *      Author: Hunter Mun
 */

#ifndef IMENUMJNICONVERT_H
#define IMENUMJNICONVERT_H

#include <jni.h>
#include <IImClientDef.h>
#include "IMCallbackItemDef.h"
#include "IMGlobalFunc.h"

/*直播间状态转换*/
static const int IMErrorTypeArray[] = {
	LCC_ERR_SUCCESS,
	LCC_ERR_FAIL,
	LCC_ERR_PROTOCOLFAIL,
	LCC_ERR_CONNECTFAIL,
	LCC_ERR_CHECKVERFAIL,
	LCC_ERR_LOGINFAIL,
	LCC_ERR_SVRBREAK,
	LCC_ERR_SETOFFLINE,
	LCC_ERR_INVITETIMEOUT,
	LCC_ERR_NOVIDEOTIMEOUT,
	LCC_ERR_BACKGROUNDTIMEOUT
};

// 底层状态转换JAVA坐标
int IMErrorTypeToInt(LCC_ERR_TYPE errType);

jobject getRoomInfoItem(JNIEnv *env, const string& userId, const string& nickName, const string& photoUrl,
		const string& country, const list<string>& videoUrls, int fansNum, int contribute, const RoomTopFanList& fansList);

jobject getFansItem(const RoomTopFan& topFanItem);

#endif
