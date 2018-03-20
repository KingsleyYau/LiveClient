/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: TaskDef.h
 *   desc: 记录Task的定义
 */

#pragma once

#include "IZBImClient.h"

#include <string>

using namespace std;

// ----- 公共协议定义
static const string ZB_ROOT_ID = "id";         // 请求ID（请求的唯一标识）
static const string ZB_ROOT_CMD = "route";     // 请求命令
static const string ZB_ROOT_REQ = "req_data";  // 请求参数
static const string ZB_ROOT_RES = "res_data";  // 返回参数

static const string ZB_ROOT_ERRNO = "errno";     // 错误码（0： 成功 其它：失败）
static const string ZB_ROOT_ERRMSG = "errmsg";   // 错误描述（用于客户端显示（可无， err＝0则无））
static const string ZB_ROOT_DATA   = "data";

// ----- 命令（默认为 Client -> Server）
// -- 登录相关命令
static const string ZB_CMD_LOGIN = "imLogin/ladyLogin";       // 2.1.登录
static const string ZB_CMD_HEARTBEAT = "heartbeat";    // 2.3.心跳
static const string ZB_CMD_KICKOFF = "kickoff";        // 2.4.用户被挤掉线
// -- 直播间相关命令
static const string ZB_CMD_PUBLICROOMIN = "imLady/publicRoomIn"; // 3.1.新建/进入公开直播间
static const string ZB_CMD_ROOMIN = "imLady/roomIn";               // 3.2.主播进入指定直播间
static const string ZB_CMD_ROOMOUT = "imLady/roomOut";             // 3.3.主播退出直播间
static const string ZB_CMD_RECVROOMCLOSENOTICE = "imShare/roomCloseNotice";    // 3.4.接收直播间关闭通知(观众端／主播端)
static const string ZB_CMD_RECVROOMKICKOFFNOTICE = "imShare/roomKickoffNotice";    // 3.5.接收踢出直播间通知
static const string ZB_CMD_RECVENTERROOMNOTICE = "imShare/enterRoomNotice";    // 3.6.接收观众进入直播间通知
static const string ZB_CMD_RECVLEAVEROOMNOTICE = "imShare/leaveRoomNotice";    // 3.7.接收观众退出直播间通知
static const string ZB_CMD_RECVLEAVINGPUBLICROOMNOTICE = "imShare/leavingCloseRoomNotice";    // 3.8.接收关闭直播间倒数通知

static const string ZB_CMD_CONTROLMANPUSH = "imMan/controlManPush"; // 3.14.观众开始／结束视频互动

// -- 文本消息相关命令
static const string ZB_CMD_SENDLIVECHAT = "imShare/sendLiveChat";    // 4.1.发送直播间文本消息
static const string ZB_CMD_RECVSENDCHATNOTICE = "imShare/sendChatNotice";    // 4.2.接收直播间文本消息
static const string ZB_CMD_RECVSENDSYSTEMNOTICE = "imShare/sendSystemNotice"; // 4.3.接收直播间公告消息
// ------------- 直播间礼物消息 -------------
static const string ZB_CMD_SENDGIFT = "imShare/sendGift";       //5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
static const string ZB_CMD_RECVSENDGIFTNOTICE = "imShare/sendGiftNotice"; //5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
// ------------- 直播间弹幕消息 -------------
static const string ZB_CMD_SENDTOAST = "imShare/sendToast";        //6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
static const string ZB_CMD_RECVSENDTOASTNOTICE = "imShare/sendToastNotice"; //6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）

// ------------- 直播间才艺点播邀请 -------------
static const string ZB_CMD_RECVTALENTREQUESTNOTICE = "imShare/receiveTalentRequestNotice"; //7.1.接收直播间才艺点播邀请通知

// ------------- 直播间才艺点播邀请 -------------
static const string ZB_CMD_RECVCONTROLMANPUSHNOTICE = "imShare/controlManPushNotice"; //8.1.接收观众启动/关闭视频互动通知


// ------------- 邀请预约私密直播消息 -------------
static const string ZB_CMD_SENDPRIVATELIVEINVITE = "imLady/instantInviteUser";    // 9.1.主播发送立即私密邀请
static const string ZB_CMD_RECVINSTANTINVITEREPLYNOTICE = "imLady/receiveInstantInviteReplyNotice"; // 9.2.接收立即私密邀请回复通知
static const string ZB_CMD_RECVINSTANTINVITEUSERNOTICE = "imMan/receiveInvitationInstantNotice";    // 9.3.接收立即私密邀请通知
static const string ZB_CMD_RECBOOKINGNOTICE =   "bookingNotice"; // 9.4.接收预约开始倒数通知
static const string ZB_CMD_GETINVITEINFO = "imLady/getInviteInfo"; // 9.5.获取指定立即私密邀请信息
static const string ZB_CMD_RECVINVITATIONACCEPTNOTICE = "imMan/receiveInvitationAcceptNotice"; // 9.6.接收观众接受预约通知

// 判断是否客户端主动请求的命令
inline bool ZBIsRequestCmd(const string& cmd)
{
	bool result = false;
	if (
        cmd == ZB_CMD_LOGIN                // 2.1.登录
        || cmd == ZB_CMD_SENDLIVECHAT      // 4.1.发送直播间文本消息
		|| cmd == ZB_CMD_HEARTBEAT		    // 2.3.心跳
        || cmd == ZB_CMD_ROOMIN            // 3.2.主播进入指定直播间
        || cmd == ZB_CMD_ROOMOUT           // 3.2.观众退出直播间
        || cmd == ZB_CMD_PUBLICROOMIN		// 3.1.新建/进入公开直播间
        || cmd == ZB_CMD_CONTROLMANPUSH    // 3.14.观众开始／结束视频互动
        || cmd == ZB_CMD_GETINVITEINFO     // 9.5.获取指定立即私密邀请信息
        || cmd == ZB_CMD_SENDGIFT          //5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
        || cmd == ZB_CMD_SENDTOAST         //6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
        || cmd == ZB_CMD_SENDPRIVATELIVEINVITE       // 9.1.观众立即私密邀请
        )
    {
        result = true;
    }
	return result;
}
