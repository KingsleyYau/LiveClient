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
        )
    {
        result = true;
    }
	return result;
}
