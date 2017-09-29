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
	ROOMTYPE_COMMONPRIVATELIVEROOM,                    // 普通私密直播间
	ROOMTYPE_CHARGEPUBLICLIVEROOM,                     // 付费公开直播间
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

/*视频操作状态*/
static const int IMControlTypeArray[] = {
	IMCONTROLTYPE_START,                  // 开始
	IMCONTROLTYPE_CLOSE                   // 关闭
};

//Java层转底层枚举
IMControlType IntToIMControlType(int value);

jobject getLoginItem(JNIEnv *env, const LoginReturnItem& item);

jobject getRoomInItem(JNIEnv *env, const RoomInfoItem& item);

jobject getRebateItem(JNIEnv *env, const RebateInfoItem& item);

jobject getPackageUpdateItem(JNIEnv *env, const BackpackInfo& item);

jobjectArray getJavaStringArray(JNIEnv *env, const list<string>& sourceList);

jobject getInviteItem(JNIEnv *env, const PrivateInviteItem& item);

#endif
