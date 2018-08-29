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
static const string ZB_ROOT_ERRDATA   = "errdata";  // 请求失败的应答业务参数

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
static const string ZB_CMD_RECVANCHORLEAVEROOMNOTICE = "imShare/anchorLeaveRoomNotice";    // 3.9.接收主播退出直播间通知

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

// ------------- 多人互动直播间 -------------
static const string ZB_CMD_ENTERHANGOUTROOM = "imLady/enterHangoutRoom";    // 10.1.进入多人互动直播间
static const string ZB_CMD_LEAVEHANGOUTROOM = "imLady/leaveHangoutRoom";    // 10.2.退出多人互动直播间
static const string ZB_CMD_RECEIVEINVITATIONHANGOUTNOTICE = "imLady/receiveInvitationHangoutNotice";    // 10.3.接收观众邀请多人互动通知
static const string ZB_CMD_RECEIVERECOMMENDHANGOUTNOTICE = "imMan/receiveRecommendHangoutNotice";       // 10.4.接收推荐好友通知
static const string ZB_CMD_RECEIVEDEALKNOCKREQUESTNOTICE = "imLady/receiveDealKnockRequestNotice";      // 10.5.接收敲门回复通知
static const string ZB_CMD_RECEIVEOTHERINVITHANGOUTNOTICE = "imLady/receiveOtherInvitHangoutNotice";    // 10.6.接收观众邀请其它主播加入多人互动通知
static const string ZB_CMD_RECEIVEDEALINVITATIONHANGOUTNOTICE = "imLady/receiveDealInvitationHangoutNotice";        // 10.7.接收主播回复观众多人互动邀请通知
static const string ZB_CMD_ENTERHANGOUTROOMNOTICE = "imShare/enterHangoutRoomNotice";       // 10.8.接收主播回复观众多人互动邀请通知
static const string ZB_CMD_LEAVEHANGOUTROOMNOTICE = "imShare/leaveHangoutRoomNotice";       // 10.9.接收观众/主播退出多人互动直播间通知
static const string ZB_CMD_CHANGEVIDEOURL = "imShare/changeVideoUrl";       // 10.10.接收观众/主播多人互动直播间视频切换通知
static const string ZB_CMD_SENDHANGOUTGIFT = "imShare/sendHangoutGift";     // 10.11.发送多人互动直播间礼物消息
static const string ZB_CMD_SENDGIFTNOTICE = "imShare/sendHangoutGiftNotice";       // 10.12.接收多人互动直播间礼物通知
static const string ZB_CMD_CONTROLMANPUSHHANGOUTNOTICE = "imShare/controlManPushHangoutNotice";       // 10.13.接收多人互动直播间礼物通知
static const string ZB_CMD_HANGOUTSENDLIVECHAT = "imShare/hangoutSendLiveChat";                       // 10.14.发送多人互动直播间文本消息
static const string ZB_CMD_RECVHANGOUTSENDCHATNOTICE = "imShare/hangoutSendChatNotice";               // 10.15.接收直播间文本消息
static const string ZB_CMD_RECVANCHORCOUNTDOWNENTERROOMNOTICE = "imShare/receiveAnchorCountDownEnterRoomNotice";               // 10.16.接收进入多人互动直播间倒数通知

// ------------- 节目 -------------
static const string ZB_CMD_RECVANCHORPROGRAMPLAYNOTICE = "imLady/showToStartNotice";    // 11.1.接收节目开播通知
static const string ZB_CMD_RECVANCHORSTATUSCHANGENOTICE = "imLady/statusChangeNotice";    // 11.2.接收节目状态改变通知
static const string ZB_CMD_RECVSHOWMSGNOTICE = "imShare/showMsgNotice";    // 11.3.接收无操作的提示通知

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
        || cmd == ZB_CMD_SENDPRIVATELIVEINVITE          // 9.1.观众立即私密邀请
        || cmd == ZB_CMD_ENTERHANGOUTROOM               // 10.1.进入多人互动直播间
        || cmd == ZB_CMD_LEAVEHANGOUTROOM               // 10.2.退出多人互动直播间
        || cmd == ZB_CMD_SENDHANGOUTGIFT                // 10.11.发送多人互动直播间礼物消息
        || cmd == ZB_CMD_HANGOUTSENDLIVECHAT            // 10.14.发送多人互动直播间文本消息
        )
    {
        result = true;
    }
	return result;
}
