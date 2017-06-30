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
static const string CMD_LOGIN = "login";            // 登录
static const string CMD_HEARTBEAT = "heartbeat";    // 心跳
static const string CMD_KICKOFF = "kickoff";        // 2.4.用户被挤掉线
// -- 文本消息相关命令
static const string CMD_SENDROOMMSG = "roomsendmsg";    // 发送文本消息
static const string CMD_RECVROOMMSG = "roompushmsg";    // 接收文本消息
// -- 直播间相关命令
static const string CMD_FANSROOMIN = "roomin";               // 观众进入直播间
static const string CMD_FANSROOMOUT = "roomout";             // 观众退出直播间
static const string CMD_RECVROOMCLOSEFANS = "roomclosev";    // 接收直播间关闭通知
static const string CMD_RECVROOMCLOSEBROAD = "roomcloseb";   // 接收直播间关闭通知
static const string CMD_RECVFANSROOMIN = "roominnotice";     // 接收观众进入直播间通知
static const string CMD_GETROOMINFO = "roominfo";            // 获取直播间信息
static const string CMD_FANSSHUTUP  = "shutup";              //3.7.主播禁言观众（直播端把制定观众禁言）
static const string CMD_RECVSHUTUPNOTICE = "shutupNotice";   //3.8.接收直播间禁言通知（观众端／主播端接收直播间禁言通知）
static const string CMD_FANSKICKOFFROOM = "kickoffRoom";     //3.9.主播踢观众出直播间（主播端把指定观众踢出直播间）
static const string CMD_RECVKICKOFFROOMNOTICE = "kickoffNoticeRoom"; //3.10.接收观众踢出直播间通知（观众端／主播端接收观众踢出直播间通知）
// ------------- 直播间点赞 -------------
static const string CMD_SENDROOMFAV = "roomsendfav";     //5.1.发送直播间点赞消息（观众端向直播间发送点赞消息）
static const string CMD_RECVPUSHROOMFAV = "roompushfav"; //5.2.接收直播间点赞通知（观众端／主播端接收服务器的直播间点赞通知）
// ------------- 直播间礼物消息 -------------
static const string CMD_SENDROOMGIFT = "sendGift";       //6.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
static const string CMD_RECVROOMGIFTNOTICE = "sendGiftNotice"; //6.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
// ------------- 直播间弹幕消息 -------------
static const string CMD_SENDROOMTOAST = "sendToast";        //7.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
static const string CMD_RECVROOMTOASTNOTICE = "sendToastNotice"; //7.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）

// 判断是否客户端主动请求的命令
inline bool IsRequestCmd(const string& cmd)
{
	bool result = false;
	if (
        cmd == CMD_LOGIN                // 登录命令
        || cmd == CMD_SENDROOMMSG       // 发送文本消息
		|| cmd == CMD_HEARTBEAT		    // 心跳
        || cmd == CMD_FANSROOMIN		// 观众进入直播间
        || cmd == CMD_FANSROOMOUT		// 观众退出直播间
        || cmd == CMD_GETROOMINFO		// 获取直播间信息
        || cmd == CMD_FANSSHUTUP        // 3.7.主播禁言观众（直播端把制定观众禁言）
        || cmd == CMD_FANSKICKOFFROOM   // 3.9.主播踢观众出直播间（主播端把指定观众踢出直播间）
        || cmd == CMD_SENDROOMFAV        //5.1.发送直播间点赞消息（观众端向直播间发送点赞消息）
        || cmd == CMD_SENDROOMGIFT       //6.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
        || cmd == CMD_SENDROOMTOAST       //7.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
        )
    {
        result = true;
    }
	return result;
}
