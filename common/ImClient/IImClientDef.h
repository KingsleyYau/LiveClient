/*
 * author: Samson.Fan
 *   date: 2017-05-09
 *   file: IImClientDef.h
 *   desc: IM客户端定义
 */

#pragma once

#include <string>
#include <list>
#include <vector>
#include <ProtocolCommon/DeviceTypeDef.h>
#include <common/CommonFunc.h>

using namespace std;

// 处理结果
typedef enum {
	LCC_ERR_SUCCESS					= 0,		// 成功
	LCC_ERR_FAIL					= -10000,	// 服务器返回失败结果

	
	// 服务器返回错误

    
	// 客户端定义的错误
	LCC_ERR_PROTOCOLFAIL        = -10001,	// 协议解析失败（服务器返回的格式不正确）
	LCC_ERR_CONNECTFAIL         = -10002,	// 连接服务器失败/断开连接
	LCC_ERR_CHECKVERFAIL        = -10003,	// 检测版本号失败（可能由于版本过低导致）
	LCC_ERR_LOGINFAIL           = -10004,	// 登录失败
	LCC_ERR_SVRBREAK            = -10005,	// 服务器踢下线
	LCC_ERR_SETOFFLINE          = -10006,	// 不能把在线状态设为"离线"，"离线"请使用Logout()
    LCC_ERR_INVITETIMEOUT       = -10007,   // Camshare邀请已经取消
    LCC_ERR_NOVIDEOTIMEOUT      = -10008,   // Camshare没有收到视频流超时
    LCC_ERR_BACKGROUNDTIMEOUT   = -10009    // Camshare后台超时
    
} LCC_ERR_TYPE;

// 直播间观众结构体
typedef struct _tRoomTopFan {
    _tRoomTopFan() {
        userId = "";
        nickName = "";
        photoUrl = "";
    };
    
    _tRoomTopFan(const _tRoomTopFan& item) {
        userId = item.userId;
        nickName = item.nickName;
        photoUrl = item.photoUrl;
    }
    
    string userId;
    string nickName;
    string photoUrl;
} RoomTopFan;
// 直播间观众列表
typedef list<RoomTopFan> RoomTopFanList;

// 客户端端类型
typedef enum {
    CLIENTTYPE_IOS = 0,                        // IOS 客户端
    CLIENTTYPE_ANDROID = 1,                    // Android 客户端
    CLIENTTYPE_WEB = 2,                        // Web端
    CLIENTTYPE_UNKNOW,                         // 未知
    CLIENTTYPE_BEGIN = CLIENTTYPE_IOS,         // 有效范围起始值
    CLIENTTYPE_END = CLIENTTYPE_UNKNOW        // 有效范围结束值
} ClientType;

// int 转换 CLIENT_TYPE
inline ClientType GetClientType(int value) {
    return CLIENTTYPE_BEGIN <= value && value < CLIENTTYPE_END ? (ClientType)value : CLIENTTYPE_UNKNOW;
}


