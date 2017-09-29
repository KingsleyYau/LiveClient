/*
 * author: Samson.Fan
 *   date: 2015-03-25
 *   file: TaskDef.h
 *   desc: 记录Task的定义
 */

#pragma once

#include "IImClient.h"

#include <string>

using namespace std;

// ----- 公共协议定义
static const string ROOT_ID = "id";         // 请求ID（请求的唯一标识）
static const string ROOT_CMD = "route";     // 请求命令
static const string ROOT_REQ = "req_data";  // 请求参数
static const string ROOT_RES = "res_data";  // 返回参数

static const string ROOT_ERRNO = "errno";     // 错误码（0： 成功 其它：失败）
static const string ROOT_ERRMSG = "errmsg";   // 错误描述（用于客户端显示（可无， err＝0则无））
static const string ROOT_DATA   = "data";  

// ----- 命令（默认为 Client -> Server）
// -- 登录相关命令
static const string CMD_LOGIN = "imLogin/login";       // 2.1.登录
static const string CMD_HEARTBEAT = "heartbeat";    // 2.3.心跳
static const string CMD_KICKOFF = "kickoff";        // 2.4.用户被挤掉线
// -- 直播间相关命令
static const string CMD_ROOMIN = "imMan/roomIn";               // 3.1.观众进入直播间
static const string CMD_ROOMOUT = "imMan/roomOut";             // 3.2.观众退出直播间
static const string CMD_RECVROOMCLOSENOTICE = "imShare/roomCloseNotice";    // 3.3.接收直播间关闭通知(观众端／主播端)
static const string CMD_RECVENTERROOMNOTICE = "imShare/enterRoomNotice";    // 3.4.接收观众进入直播间通知
static const string CMD_RECVLEAVEROOMNOTICE = "imShare/leaveRoomNotice";    // 3.5.接收观众退出直播间通知
static const string CMD_RECVREBATEINFONOTICE = "imMan/rebateInfoNotice";    // 3.6.接收返点通知
static const string CMD_RECVLEAVINGPUBLICROOMNOTICE = "imShare/leavingCloseRoomNotice";    // 3.7.接收关闭直播间倒数通知
static const string CMD_RECVROOMKICKOFFNOTICE = "imShare/roomKickoffNotice";    // 3.8.接收踢出直播间通知
static const string CMD_RECVLACKOFCREDITNOTICE = "imShare/lackOfCreditNotice";     //3.9.接收充值通知
static const string CMD_RECVCREDITNOTICE = "imShare/creditNotice"; //3.10.接收定时扣费通知
static const string CMD_RECVWAITSTARTOVERNOTICE = "imLady/waitStartOverNotice"; //3.11.直播间开播通知
static const string CMD_RECVCHANGEVIDEOURL = "imShare/changeVideoUrl"; //3.12.接收观众／主播切换视频流通知接口
static const string CMD_PUBLICROOMIN = "imMan/publicRoomIn"; // 3.13.观众进入公开直播间
static const string CMD_CONTROLMANPUSH = "imMan/controlManPush"; // 3.14.观众开始／结束视频互动
static const string CMD_GETINVITEINFO = "imMan/getInviteInfo"; // 3.15.获取指定立即私密邀请信息
// -- 文本消息相关命令
static const string CMD_SENDLIVECHAT = "imShare/sendLiveChat";    // 4.1.发送直播间文本消息
static const string CMD_RECVSENDCHATNOTICE = "imShare/sendChatNotice";    // 4.2.接收直播间文本消息
static const string CMD_RECVSENDSYSTEMNOTICE = "imShare/sendSystemNotice"; // 4.3.接收直播间公告消息
// ------------- 直播间礼物消息 -------------
static const string CMD_SENDGIFT = "imShare/sendGift";       //5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
static const string CMD_RECVSENDGIFTNOTICE = "imShare/sendGiftNotice"; //5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
// ------------- 直播间弹幕消息 -------------
static const string CMD_SENDTOAST = "imShare/sendToast";        //6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
static const string CMD_RECVSENDTOASTNOTICE = "imShare/sendToastNotice"; //6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）

// ------------- 邀请预约私密直播消息 -------------
static const string CMD_SENDPRIVATELIVEINVITE = "imMan/sendPrivateLiveInvite";    // 7.1.观众立即私密邀请
static const string CMD_SENDCANCELPRIVATEINVITE = "imMan/sendCancelPrivateLiveInvite";  // 7.2.观众取消立即私密邀请
static const string CMD_RECVINSTANTINVITEREPLYNOTICE = "imLady/instantInviteReplyNotice"; // 7.3.接收立即私密邀请回复通知
static const string CMD_RECVINSTANTINVITEUSERNOTICE = "imLady/instantInviteUserNotice"; // 7.4.接收主播立即私密邀请通知
static const string CMD_RECVSCHEDULEDINVITEUSERNOTICE = "imLady/scheduledInviteUserNotice"; // 7.5.接收主播预约私密邀请通知
static const string CMD_RECVSENDBOOKINGREPLYNOTICE =   "imLady/scheduledInviteReplyNotice"; // 7.6.接收预约私密邀请回复通知
static const string CMD_RECBOOKINGNOTICE =   "bookingNotice"; // 7.7.接收预约开始倒数通知

// ------------- 直播间才艺点播邀请 -------------
static const string CMD_SENDTALENT = "imMan/sendTalent";    // 8.1.发送直播间才艺点播邀请
static const string CMD_RECVSENDTALENTNOTICE = "imShare/sendTalentNotice"; //8.2.接收直播间才艺点播回复通知

// ------------- 公共 -------------
static const string CMD_RECVLEVELUPNOTICE = "imMan/levelUpNotice";    // 9.1.观众等级升级通知
static const string CMD_RECVLOVELEVELUPNOTICE = "imMan/loveLevelUpNotice";    // 9.2.观众亲密度升级通知
static const string CMD_RECVBACKPACKUPDATENOTICE = "imMan/backpackUpdateNotice";    // 9.3.背包更新通知

// 判断是否客户端主动请求的命令
inline bool IsRequestCmd(const string& cmd)
{
	bool result = false;
	if (
        cmd == CMD_LOGIN                // 2.1.登录
        || cmd == CMD_SENDLIVECHAT      // 4.1.发送直播间文本消息
		|| cmd == CMD_HEARTBEAT		    // 2.3.心跳
        || cmd == CMD_ROOMIN            // 3.1.观众进入直播间
        || cmd == CMD_ROOMOUT           // 3.2.观众退出直播间
        || cmd == CMD_PUBLICROOMIN		// 3.13.观众进入公开直播间
        || cmd == CMD_CONTROLMANPUSH    // 3.14.观众开始／结束视频互动
        || cmd == CMD_GETINVITEINFO     // 3.15.获取指定立即私密邀请信息
        || cmd == CMD_SENDGIFT          //5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
        || cmd == CMD_SENDTOAST         //6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
        || cmd == CMD_SENDPRIVATELIVEINVITE       // 7.1.观众立即私密邀请
        || cmd == CMD_SENDCANCELPRIVATEINVITE     // 7.2.观众取消立即私密邀请
        || cmd == CMD_SENDTALENT                  // 8.1.发送直播间才艺点播邀请
        )
    {
        result = true;
    }
	return result;
}
