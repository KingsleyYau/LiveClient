/*
 * LMEnumJniConvert.h
 *
 *  Created on: 2017-5-31
 *      Author: Hunter Mun
 */

#ifndef LMENUMJNICONVERT_H
#define LMENUMJNICONVERT_H

#include <jni.h>
#include <ILiveMessageManManager.h>
#include "LMCallbackItemDef.h"
#include "LMGlobalFunc.h"

/*直播间Http状态转换*/
static const int HTTPErrorTypeArray[] = {
        HTTP_LCC_ERR_SUCCESS,   		// 成功
        HTTP_LCC_ERR_FAIL, 				// 服务器返回失败结果

        // 客户端定义的错误
        HTTP_LCC_ERR_PROTOCOLFAIL,   	// 协议解析失败（服务器返回的格式不正确）
        HTTP_LCC_ERR_CONNECTFAIL,    	// 连接服务器失败/断开连接
        //HTTP_LCC_ERR_CHECKVERFAIL,   	// 检测版本号失败（可能由于版本过低导致）

        //HTTP_LCC_ERR_SVRBREAK,       	// 服务器踢下线
        //HTTP_LCC_ERR_INVITE_TIMEOUT, 	// 邀请超时
        // 服务器返回错误
        HTTP_LCC_ERR_ROOM_FULL,   		// 房间人满
        HTTP_LCC_ERR_NO_CREDIT,   		// 信用点不足
        /* IM公用错误码 */
        HTTP_LCC_ERR_NO_LOGIN,   		// 未登录
        HTTP_LCC_ERR_SYSTEM,     		// 系统错误
        HTTP_LCC_ERR_TOKEN_EXPIRE, 		// Token 过期了
        HTTP_LCC_ERR_NOT_FOUND_ROOM, 	// 进入房间失败 找不到房间信息or房间关闭
        HTTP_LCC_ERR_CREDIT_FAIL, 		// 远程扣费接口调用失败

        HTTP_LCC_ERR_ROOM_CLOSE,  		// 房间已经关闭
        HTTP_LCC_ERR_KICKOFF, 			// 被挤掉线 默认通知内容
        HTTP_LCC_ERR_NO_AUTHORIZED, 	// 不能操作 不是对应的userid
        HTTP_LCC_ERR_LIVEROOM_NO_EXIST, // 直播间不存在
        HTTP_LCC_ERR_LIVEROOM_CLOSED, 	// 直播间已关闭

        HTTP_LCC_ERR_ANCHORID_INCONSISTENT, 	// 主播id与直播场次的主播id不合
        HTTP_LCC_ERR_CLOSELIVE_DATA_FAIL, 		// 关闭直播场次,数据表操作出错
        HTTP_LCC_ERR_CLOSELIVE_LACK_CODITION, 	// 主播立即关闭私密直播间, 不满足关闭条件
        /* 其它错误码*/
        HTTP_LCC_ERR_USED_OUTLOG, 				// 退出登录 (用户主动退出登录)
        HTTP_LCC_ERR_NOTCAN_CANCEL_INVITATION, 	// 取消立即私密邀请失败 状态不是带确认 /*important*/
        HTTP_LCC_ERR_NOT_FIND_ANCHOR, 			// 主播机构信息找不到
        HTTP_LCC_ERR_NOTCAN_REFUND, 			// 立即私密退点失败，已经定时扣费不能退点
        HTTP_LCC_ERR_NOT_FIND_PRICE_INFO, 		// 找不到price_setting表信息

        HTTP_LCC_ERR_ANCHOR_BUSY,			  	// 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/
        HTTP_LCC_ERR_CHOOSE_TIME_ERR, 			// 预约时间错误 /*important*/
        HTTP_LCC_ERR_BOOK_EXIST, 				// 用户预约时间段已经存在预约 /*important*/
        HTTP_LCC_ERR_BIND_PHONE, 				// 手机号码已绑定
        HTTP_LCC_ERR_RETRY_PHONE, 				// 请稍后再重试

        HTTP_LCC_ERR_MORE_TWENTY_PHONE, 		// 60分钟内验证超过20次，请24小时后再试
        HTTP_LCC_ERR_UPDATE_PHONE_FAIL, 		// 更新失败
        HTTP_LCC_ERR_ANCHOR_OFFLIVE,            // 主播不在线，不能操作
        HTTP_LCC_ERR_VIEWER_AGREEED_BOOKING, 	// 观众已同意预约
        HTTP_LCC_ERR_OUTTIME_REJECT_BOOKING, 	// 预约邀请已超时（当观众拒绝时）
        HTTP_LCC_ERR_OUTTIME_AGREE_BOOKING,   	// 预约邀请已超时（当观众同意时）
};

// 底层状态转换JAVA坐标
int HTTPErrorTypeToInt(HTTP_LCC_ERR_TYPE errType);

/*直播间状态转换*/
static const int IMErrorTypeArray[] = {
	LCC_ERR_SUCCESS,   				// 成功
	LCC_ERR_FAIL, 					// 服务器返回失败结果

	LCC_ERR_PROTOCOLFAIL,   		// 协议解析失败（服务器返回的格式不正确）
	LCC_ERR_CONNECTFAIL,    		// 连接服务器失败/断开连接
	LCC_ERR_CHECKVERFAIL,   		// 检测版本号失败（可能由于版本过低导致）
	LCC_ERR_SVRBREAK,       		// 服务器踢下线
	LCC_ERR_INVITE_TIMEOUT, 		// 邀请超时

	LCC_ERR_ROOM_FULL,				// 房间人满
	LCC_ERR_ROOM_CLOSE,             // 房间已经关闭
	LCC_ERR_NO_CREDIT,       		// 信用点不足

	LCC_ERR_NO_LOGIN,				// 未登录
	LCC_ERR_SYSTEM,					// 系统错误
	LCC_ERR_TOKEN_EXPIRE,			// Token 过期了
	LCC_ERR_NOT_FOUND_ROOM,			// 进入房间失败 找不到房间信息or房间关闭
	LCC_ERR_CREDIT_FAIL,			// 远程扣费接口调用失败

	LCC_ERR_KICKOFF,				// 被挤掉线 默认通知内容
	LCC_ERR_NO_AUTHORIZED,			// 不能操作 不是对应的userid
	LCC_ERR_LIVEROOM_NO_EXIST,		// 直播间不存在
	LCC_ERR_LIVEROOM_CLOSED,		// 直播间已关闭
	LCC_ERR_ANCHORID_INCONSISTENT,	// 主播id与直播场次的主播id不合

	LCC_ERR_CLOSELIVE_DATA_FAIL,	// 关闭直播场次,数据表操作出错
	LCC_ERR_CLOSELIVE_LACK_CODITION,	 // 主播立即关闭私密直播间, 不满足关闭条件
	LCC_ERR_ENTER_ROOM_ERR,			// 进入房间失败 数据库操作失败（添加记录or删除扣费记录）
	LCC_ERR_NOT_FIND_ANCHOR,		// 主播机构信息找不到
	LCC_ERR_COUPON_FAIL,			// 扣费信用点失败--扣除优惠券分钟数

	LCC_ERR_ENTER_ROOM_NO_AUTHORIZED,	// 进入私密直播间 不是对应的userid
	LCC_ERR_REPEAT_KICKOFF,			// 被挤掉线 同一userid不通socket_id进入同一房间时
	LCC_ERR_ANCHOR_NO_ON_LIVEROOM,	// 改主播不存在公开直播间
	LCC_ERR_INCONSISTENT_ROOMTYPE, 	// 赠送礼物失败、开始\结束推流失败 房间类型不符合
	LCC_ERR_INCONSISTENT_CREDIT_FAIL,	// 扣费信用点数值的错误，扣费失败

	LCC_ERR_REPEAT_END_STREAM,		// 已结结束推流，不能重复操作
	LCC_ERR_REPEAT_BOOKING_KICKOFF,	// 重复立即预约该主播被挤掉线.
	LCC_ERR_NOT_IN_STUDIO,			// You are not in the studio
	LCC_ERR_INCONSISTENT_LEVEL,		// 赠送礼物失败 用户等级不符合
	LCC_ERR_INCONSISTENT_LOVELEVEL,	// 赠送礼物失败 亲密度不符合

	LCC_ERR_LESS_THAN_GIFT,			// 赠送礼物失败 拥有礼物数量不足
	LCC_ERR_SEND_GIFT_FAIL,			// 发送礼物出错
	LCC_ERR_SEND_GIFT_LESSTHAN_LEVEL,	// 发送礼物,男士级别不够
	LCC_ERR_SEND_GIFT_LESSTHAN_LOVELEVEL,	// 发送礼物,男士主播亲密度不够
	LCC_ERR_SEND_GIFT_NO_EXIST,				// 发送礼物,礼物不存在或已下架

	LCC_ERR_SEND_GIFT_LEVEL_INCONSISTENT_LIVE,	// 发送礼物,礼物级别限制与直播场次级别不符
	LCC_ERR_SEND_GIFT_BACKPACK_NO_EXIST,		// 主播发礼物,背包礼物不存在
	LCC_ERR_SEND_GIFT_BACKPACK_LESSTHAN,	 	// 主播发礼物,背包礼物数量不足
	LCC_ERR_SEND_GIFT_PARAM_ERR, 		// 发礼物,参数错误
	LCC_ERR_SEND_TOAST_NOCAN, 			// 主播不能发送弹幕

	LCC_ERR_ANCHOR_OFFLINE,				// 立即私密邀请失败 主播不在线 /*important*/
	LCC_ERR_ANCHOR_BUSY,				// 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/
	LCC_ERR_ANCHOR_PLAYING, 			// 主播正在私密直播中 /*important*/
	LCC_ERR_NOTCAN_CANCEL_INVITATION, 	// 取消立即私密邀请失败 状态不是带确认 /*important*/
	LCC_ERR_NO_FOUND_CRONJOB, 			// cronjob 里找不到对应的定时器函数

	LCC_ERR_REPEAT_INVITEING_TALENT, 	// 发送才艺点播失败 上一次才艺邀请邀请待确认，不能重复发送 /*important*/
	LCC_ERR_RECV_REGULAR_CLOSE_ROOM,    // 用户接收正常关闭直播间

};

// 底层状态转换JAVA坐标
int IMErrorTypeToInt(LCC_ERR_TYPE errType);

/*主播在线状态*/
static const int LMOnLineStatusArray[] = {
        ONLINE_STATUS_UNKNOWN,          // 未知
        ONLINE_STATUS_OFFLINE,          // 离线
        ONLINE_STATUS_LIVE              // 在线
};

// 底层状态转换JAVA坐标
int LMOnLineStatusToInt(OnLineStatus status);

/*消息类型定义*/
static const int LMMessageTypeArray[] = {
        LMMT_Unknow,            // 未知
        LMMT_Text,              // 私信消息
        LMMT_SystemWarn,        // 系统警告
        LMMT_Time,              // 时间提示
        LMMT_Warning            // 警告提示

};

// 底层状态转换JAVA坐标
int LMMessageTypeToInt(LMMessageType type);

/*消息发送方向 类型*/
static const int LMSendTypeArray[] = {
        LMSendType_Unknow,            // 未知类型
        LMSendType_Send,              // 发出
        LMSendType_Recv               // 接收

};

// 底层状态转换JAVA坐标
int LMSendTypeToInt(LMSendType type);

/*消息发送方向 类型*/
static const int LMStatusTypeArray[] = {
        LMStatusType_Unprocess,         // 未处理
        LMStatusType_Processing,        // 处理中
        LMStatusType_Fail,              // 发送失败
        LMStatusType_Finish             // 发送完成/接收成功

};

// 底层状态转换JAVA坐标
int LMStatusTypeToInt(LMStatusType type);

/*消息发送方向 类型*/
static const int LMWarningTypeArray[] = {
        LMWarningType_Unknow,
        LMWarningType_NoCredit          // 点数不足警告

};

// 底层状态转换JAVA坐标
int LMWarningTypeToInt(LMWarningType type);

/*私信支持类型*/
static const int LMPrivateMsgSupportTypeArray[] = {
		LMPMSType_Unknow,
		LMPMSType_Text,
		LMPMSType_Dynamic
};

//Java层转底层枚举
LMPrivateMsgSupportType IntToLMPrivateMsgSupportType(int value);

/*消息发送方向 类型*/
static const int LMSystemTypeArray[] = {
		LMSystemType_Unknow,
		LMSystemType_NoMore
};

// 底层状态转换JAVA坐标
int LMSystemTypeToInt(LMSystemType type);

jobjectArray getContactListArray(JNIEnv *env, const LMUserList& list);

jobject getLiveMessageItem(JNIEnv *env, LiveMessageItem* item);
jobjectArray getLiveMessageListArray(JNIEnv *evn, const LMMessageList& list);

#endif
