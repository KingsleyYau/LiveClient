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
	LCC_ERR_SUCCESS,   				// 成功
	LCC_ERR_FAIL, 					// 服务器返回失败结果
	LCC_ERR_PROTOCOLFAIL,   		// 协议解析失败（服务器返回的格式不正确）
	LCC_ERR_CONNECTFAIL,    		// 连接服务器失败/断开连接
	LCC_ERR_CHECKVERFAIL,   		// 检测版本号失败（可能由于版本过低导致）
	LCC_ERR_SVRBREAK,       		// 服务器踢下线
	LCC_ERR_INVITE_TIMEOUT, 		// 邀请超时
	LCC_ERR_NO_CREDIT,       		// 信用点不足
	LCC_ERR_PRI_LIVING,     		// 主播正在私密直播中
};

// 底层状态转换JAVA坐标
int IMErrorTypeToInt(LCC_ERR_TYPE errType);

/*邀请处理状态*/
static const int IMInviteTypeArray[] = {
	IMREPLYTYPE_UNKNOWN,              // 未知
	IMREPLYTYPE_UNCONFIRM,            // 待确定
	IMREPLYTYPE_AGREE,                // 已同意
	IMREPLYTYPE_REJECT,               // 已拒绝
	IMREPLYTYPE_OUTTIME,              // 已超时
	IMREPLYTYPE_CANCEL,               // 观众/主播取消
	IMREPLYTYPE_ANCHORABSENT,         // 主播缺席
	IMREPLYTYPE_FANSABSENT,           // 观众缺席
	IMREPLYTYPE_COMFIRMED             // 已完成
};

// 底层状态转换JAVA坐标
int IMInviteTypeToInt(IMReplyType replyType);

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

/*预约私密邀请类型*/
static const int AnchorReplyTypeArray[] = {
	ANCHORREPLYTYPE_UNKNOW,
	ANCHORREPLYTYPE_REJECT,                  // 拒绝
	ANCHORREPLYTYPE_AGREE,                   // 同意
	ANCHORREPLYTYPE_OUTTIME                 // 超时
};

// 底层状态转换JAVA坐标
int AnchorReplyTypeToInt(AnchorReplyType replyType);

/*才艺邀请处理状态*/
static const int TalentInviteStatusArray[] = {
	TALENTSTATUS_UNKNOW,                  // 未知
	TALENTSTATUS_AGREE,                   // 已接受
	TALENTSTATUS_REJECT                   // 拒绝
};

// 底层状态转换JAVA坐标
int TalentInviteStatusToInt(TalentStatus talentInviteStatus);

jobject getLoginItem(JNIEnv *env, const LoginReturnItem& item);

jobject getRoomInItem(JNIEnv *env, const RoomInfoItem& item);

jobject getRebateItem(JNIEnv *env, const RebateInfoItem& item);

jobject getPackageUpdateItem(JNIEnv *env, const BackpackInfo& item);

#endif
