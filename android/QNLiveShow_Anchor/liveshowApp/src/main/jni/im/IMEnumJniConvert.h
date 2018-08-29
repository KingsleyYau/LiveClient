/*
 * IMEnumJniConvert.h
 *
 *  Created on: 2017-5-31
 *      Author: Hunter Mun
 */

#ifndef IMENUMJNICONVERT_H
#define IMENUMJNICONVERT_H

#include <jni.h>
#include <IZBImClient.h>
#include "IMCallbackItemDef.h"
#include "IMGlobalFunc.h"

/*直播间状态转换*/
static const int IMErrorTypeArray[] = {
        ZBLCC_ERR_SUCCESS,   // 成功
        ZBLCC_ERR_FAIL, // 服务器返回失败结果

        // 客户端定义的错误
        ZBLCC_ERR_PROTOCOLFAIL,   // 协议解析失败（服务器返回的格式不正确）
        ZBLCC_ERR_CONNECTFAIL,    // 连接服务器失败/断开连接
        ZBLCC_ERR_CHECKVERFAIL,   // 检测版本号失败（可能由于版本过低导致）
        ZBLCC_ERR_SVRBREAK,       // 服务器踢下线
        ZBLCC_ERR_INVITE_TIMEOUT, // 邀请超时

        // IM公用错误码
        ZBLCC_ERR_NO_LOGIN,                // 未登录
        ZBLCC_ERR_SYSTEM,                  // 系统错误
        ZBLCC_ERR_TOKEN_EXPIRE,            // Token 过期了
        ZBLCC_ERR_NOT_FOUND_ROOM,          // 进入房间失败 找不到房间信息or房间关闭
        ZBLCC_ERR_CREDIT_FAIL,             // 远程扣费接口调用失败
        ZBLCC_ERR_ROOM_CLOSE, // 房间已经关闭
        ZBLCC_ERR_KICKOFF,                 // 被挤掉线 默认通知内容
        ZBLCC_ERR_NO_AUTHORIZED,           //10021 不能操作 不是对应的userid
        ZBLCC_ERR_LIVEROOM_NO_EXIST,       // 直播间不存在
        ZBLCC_ERR_LIVEROOM_CLOSED,         // 直播间已关闭
        ZBLCC_ERR_ANCHORID_INCONSISTENT,   // 主播id与直播场次的主播id不合
        ZBLCC_ERR_CLOSELIVE_DATA_FAIL,     // 关闭直播场次,数据表操作出错
        ZBLCC_ERR_CLOSELIVE_LACK_CODITION, // 主播立即关闭私密直播间, 不满足关闭条件
        ZBLCC_ERR_NOT_IN_STUDIO,           // You are not in the studio
        ZBLCC_ERR_NOT_FIND_ANCHOR,                   // 主播机构信息找不到
        ZBLCC_ERR_INCONSISTENT_LEVEL,                // 赠送礼物失败 用户等级不符合
        ZBLCC_ERR_INCONSISTENT_LOVELEVEL,            // 赠送礼物失败 亲密度不符合
        ZBLCC_ERR_INCONSISTENT_ROOMTYPE,             // 赠送礼物失败、开始\结束推流失败 房间类型不符合
        ZBLCC_ERR_LESS_THAN_GIFT,                    // 赠送礼物失败 拥有礼物数量不足
        ZBLCC_ERR_SEND_GIFT_FAIL,                    // 发送礼物出错
        ZBLCC_ERR_SEND_GIFT_LESSTHAN_LEVEL,          // 发送礼物,男士级别不够
        ZBLCC_ERR_SEND_GIFT_LESSTHAN_LOVELEVEL,      // 发送礼物,男士主播亲密度不够
        ZBLCC_ERR_SEND_GIFT_NO_EXIST,                // 发送礼物,礼物不存在或已下架
        ZBLCC_ERR_SEND_GIFT_LEVEL_INCONSISTENT_LIVE, // 发送礼物,礼物级别限制与直播场次级别不符
        ZBLCC_ERR_SEND_GIFT_BACKPACK_NO_EXIST,       // 主播发礼物,背包礼物不存在
        ZBLCC_ERR_SEND_GIFT_BACKPACK_LESSTHAN,       // 主播发礼物,背包礼物数量不足
        ZBLCC_ERR_SEND_GIFT_PARAM_ERR,               // 发礼物,参数错误

};

// 底层状态转换JAVA坐标
int IMErrorTypeToInt(ZBLCC_ERR_TYPE errType);

/*邀请处理状态*/
static const int IMInviteTypeArray[] = {
        ZBIMREPLYTYPE_UNKNOWN,              // 未知
        ZBIMREPLYTYPE_UNCONFIRM,            // 待确定
        ZBIMREPLYTYPE_AGREE,                // 已同意
        ZBIMREPLYTYPE_REJECT,               // 已拒绝
        ZBIMREPLYTYPE_OUTTIME,              // 已超时
        ZBIMREPLYTYPE_CANCEL,               // 观众/主播取消
        ZBIMREPLYTYPE_ANCHORABSENT,         // 主播缺席
        ZBIMREPLYTYPE_FANSABSENT,           // 观众缺席
        ZBIMREPLYTYPE_COMFIRMED             // 已完成
};

// 底层状态转换JAVA坐标
int IMInviteTypeToInt(ZBIMReplyType replyType);

/*直播间类型*/
static const int RoomTypeArray[] = {
        ZBROOMTYPE_NOLIVEROOM,                               // 没有直播间
        ZBROOMTYPE_FREEPUBLICLIVEROOM,                       // 免费公开直播间
        ZBROOMTYPE_COMMONPRIVATELIVEROOM,                    // 普通私密直播间
        ZBROOMTYPE_CHARGEPUBLICLIVEROOM,                     // 付费公开直播间
        ZBROOMTYPE_LUXURYPRIVATELIVEROOM,                    // 豪华私密直播间
        ZBROOMTYPE_MULTIPLAYINTERACTIONLIVEROOM              // 多人互动直播间
};

// 底层状态转换JAVA坐标
int RoomTypeToInt(ZBRoomType roomType);

/*直播间类型*/
static const int tLiveStatusArray[] = {
        ZBLIVESTATUS_UNKNOW,                    // 未知
        ZBLIVESTATUS_INIT,                      // 初始
        ZBLIVESTATUSE_RECIPROCALSTART,          // 开始倒数中
        ZBLIVESTATUS_ONLINE,                    // 在线
        ZBLIVESTATUS_ARREARAGE,                 // 欠费中
        ZBLIVESTATUS_RECIPROCALEND,             // 结束倒数中
        ZBLIVESTATUS_CLOSE                      // 关闭
};

// 底层状态转换JAVA坐标
int LiveStatusToInt(ZBLiveStatus status);

/*立即私密邀请回复类型*/
static const int InviteReplyTypeArray[] = {
        ZBREPLYTYPE_UNKNOW,
        ZBREPLYTYPE_REJECT,                  // 拒绝
        ZBREPLYTYPE_AGREE                   // 同意
};

// 底层状态转换JAVA坐标
int InviteReplyTypeToInt(ZBReplyType replyType);

/*预约私密邀请类型*/
static const int AnchorReplyTypeArray[] = {
        ZBANCHORREPLYTYPE_UNKNOW,
        ZBANCHORREPLYTYPE_REJECT,                  // 拒绝
        ZBANCHORREPLYTYPE_AGREE,                   // 同意
        ZBANCHORREPLYTYPE_OUTTIME                 // 超时
};

// 底层状态转换JAVA坐标
int AnchorReplyTypeToInt(ZBAnchorReplyType replyType);

/*才艺邀请处理状态*/
static const int TalentInviteStatusArray[] = {
        ZBTALENTSTATUS_UNKNOW,                  // 未知
        ZBTALENTSTATUS_AGREE,                   // 已接受
        ZBTALENTSTATUS_REJECT                   // 拒绝
};

// 底层状态转换JAVA坐标
int TalentInviteStatusToInt(ZBTalentStatus talentInviteStatus);

/*直播间公告类型*/
static const int IMSystemTypeArray[] = {
        ZBIMSYSTEMTYPE_COMMON,          		// 普通公告
        ZBIMSYSTEMTYPE_WARN					// 警告公告
};

// 底层状态转换JAVA坐标
int IMSystemTypeToInt(ZBIMSystemType type);


/*视频操作状态*/
static const int IMControlTypeArray[] = {
        ZBIMCONTROLTYPE_START,                  // 开始
        ZBIMCONTROLTYPE_CLOSE                   // 关闭
};

//Java层转底层枚举
ZBIMControlType IntToIMControlType(int value);
// 底层状态转换JAVA坐标
int IMControlTypeToInt(ZBIMControlType type);

/*直播间类型*/
static const int AnchorStatusArray[] = {
        ANCHORSTATUS_INVITATION,                            // 邀请中
        ANCHORSTATUS_INVITECONFIRM,                         // 邀请已确认
        ANCHORSTATUS_KNOCKCONFIRM,                          // 敲门已确认
        ANCHORSTATUS_RECIPROCALENTER,                       // 倒数进入中
        ANCHORSTATUS_ONLINE,                                // 在线
        ANCHORSTATUS_UNKNOW                                 // 未知
};

// 底层状态转换JAVA坐标
int AnchorStatusToInt(AnchorStatus roomType);

/*敲门回复类型*/
static const int AnchorKnockTypeArray[] = {
        IMANCHORKNOCKTYPE_UNKNOWN,                      // 未知
        IMANCHORKNOCKTYPE_AGREE,                        // 接受
        IMANCHORKNOCKTYPE_REJECT,                       // 拒绝
        IMANCHORKNOCKTYPE_OUTTIME,                      // 邀请超时
        IMANCHORKNOCKTYPE_CANCEL                        // 主播取消邀请

};

// 底层状态转换JAVA坐标
int AnchorKnockTypeToInt(IMAnchorKnockType type);

/*邀请回复类型*/
static const int AnchorReplyInviteTypeArray[] = {
        IMANCHORREPLYINVITETYPE_UNKNOWN,                      // 未知
        IMANCHORREPLYINVITETYPE_AGREE,                        // 接受
        IMANCHORREPLYINVITETYPE_REJECT,                       // 拒绝
        IMANCHORREPLYINVITETYPEE_OUTTIME,                     // 邀请超时
        IMANCHORREPLYINVITETYPE_CANCEL                        // 观众取消邀请

};

// 底层状态转换JAVA坐标
int AnchorReplyInviteTypeToInt(IMAnchorReplyInviteType type);

/*公开直播间类型*/
static const int IMAnchorPublicRoomTypeArray[] = {
        IMANCHORPUBLICROOMTYPE_UNKNOW,              // 未知
        IMANCHORPUBLICROOMTYPE_COMMON,              // 普通公开
        IMANCHORPUBLICROOMTYPE_PROGRAM              // 节目

};

// 底层状态转换JAVA坐标
int IMAnchorPublicRoomTypeToInt(IMAnchorPublicRoomType type);

/*节目状态*/
static const int IMAnchorProgramStatusArray[] = {
        IMANCHORPROGRAMSTATUS_UNVERIFY,             // 未审核
        IMANCHORPROGRAMSTATUS_VERIFYPASS,           // 审核通过
        IMANCHORPROGRAMSTATUS_VERIFYREJECT,         // 审核被拒
        IMANCHORPROGRAMSTATUS_PROGRAMEND,           // 节目正常结束
        IMANCHORPROGRAMSTATUS_PROGRAMCALCEL,        // 节目已取消
        IMANCHORPROGRAMSTATUS_OUTTIME               // 节目已超时
};

// 底层状态转换JAVA坐标
int IMAnchorProgramStatusToInt(IMAnchorProgramStatus type);


jobject getLoginItem(JNIEnv *env, const ZBLoginReturnItem& item);

jobject getRoomInItem(JNIEnv *env, const ZBRoomInfoItem& item);

jobjectArray getJavaStringArray(JNIEnv *env, const list<string>& sourceList);

jobject getInviteItem(JNIEnv *env, const ZBPrivateInviteItem& item);

jobject getHangoutRoomItem(JNIEnv *env, const AnchorHangoutRoomItem& item);

jobject getHangoutInviteItem(JNIEnv *env, const AnchorHangoutInviteItem& item);

jobject getHangoutCommendItem(JNIEnv *env, const IMAnchorRecommendHangoutItem& item);

jobject getDealKnockRequestItem(JNIEnv *env, const IMAnchorKnockRequestItem& item);

jobject getOtherInviteItem(JNIEnv *env, const IMAnchorRecvOtherInviteItem& item);

jobject getDealInviteItem(JNIEnv *env, const IMAnchorRecvDealInviteItem& item);

jobject getEnterHangoutRoomItem(JNIEnv *env, const IMAnchorRecvEnterRoomItem& item);

jobject getLeaveHangoutRoomItem(JNIEnv *env, const IMAnchorRecvLeaveRoomItem& item);

jobject getHangoutGiftItem(JNIEnv *env, const IMAnchorRecvGiftItem& item);

jobject getIMProgramInfoItem(JNIEnv *env, const IMAnchorProgramInfoItem& item);

#endif
