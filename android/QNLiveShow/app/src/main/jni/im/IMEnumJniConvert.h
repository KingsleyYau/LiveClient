/*
 * IMEnumJniConvert.h
 *
 *  Created on: 2017-5-31
 *      Author: Hunter Mun
 */

#ifndef IMENUMJNICONVERT_H
#define IMENUMJNICONVERT_H

#include <jni.h>
#include <IImClient.h>
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

/*直播间类型*/
static const int RoomTypeArray[] = {
	    ROOMTYPE_NOLIVEROOM,                               // 没有直播间
	    ROOMTYPE_FREEPUBLICLIVEROOM,                       // 免费公开直播间
	    ROOMTYPE_CHARGEPUBLICLIVEROOM,                     // 付费公开直播间
	    ROOMTYPE_COMMONPRIVATELIVEROOM,                    // 普通私密直播间
	    ROOMTYPE_LUXURYPRIVATELIVEROOM                     // 豪华私密直播间
};

// 底层状态转换JAVA坐标
int RoomTypeToInt(RoomType roomType);

/*立即私密邀请回复类型*/
static const int InviteReplyTypeArray[] = {
	REPLYTYPE_UNKNOW,
	REPLYTYPE_REJECT,                  // 拒绝
	REPLYTYPE_AGREE                   // 同意
};

// 底层状态转换JAVA坐标
int InviteReplyTypeToInt(ReplyType replyType);

jobject getRoomInItem(JNIEnv *env, const string& userId, const string& nickName,const string& photoUrl, const list<string>& videoUrls,
		RoomType roomType, double credit, bool usedVoucher, int fansNum, list<int> emoTypeList, int loveLevel, const RebateInfo& item,
		bool favorite, int leftSeconds, bool waitStart, const list<string>& manPushUrls, int manLevel);

jobject getRebateItem(JNIEnv *env, const RebateInfo& item);

#endif
