package com.qpidnetwork.anchor.httprequest.item;

/**
 * 主播在线状态
 * @author Hunter Mun
 *
 */
public enum HttpLccErrType {
    HTTP_LCC_ERR_SUCCESS,   		// 成功(0)
    HTTP_LCC_ERR_FAIL, 				// 服务器返回失败结果(-10000)

    // 客户端定义的错误
    HTTP_LCC_ERR_PROTOCOLFAIL,   	// 协议解析失败（服务器返回的格式不正确）(-10001)
    HTTP_LCC_ERR_CONNECTFAIL,    	// 连接服务器失败/断开连接(-10002)
    HTTP_LCC_ERR_CHECKVERFAIL,   	// 检测版本号失败（可能由于版本过低导致）(-10003)

    HTTP_LCC_ERR_SVRBREAK,       	// 服务器踢下线(-10004)
    HTTP_LCC_ERR_INVITE_TIMEOUT, 	// 邀请超时(-10005)
    // 服务器返回错误
    HTTP_LCC_ERR_INSUFFICIENT_PARAM,    // 未传action参数或action参数不正确(10001)
    HTTP_LCC_ERR_NO_LOGIN,   		// 未登录(10002)
    HTTP_LCC_ERR_SYSTEM,     		// 系统错误(10003)
    HTTP_LCC_ERR_TOKEN_EXPIRE, 		// Token 过期了(10004)
    HTTP_LCC_ERR_NOT_FOUND_ROOM, 	// 进入房间失败 找不到房间信息or房间关闭(10021)
    HTTP_LCC_ERR_CREDIT_FAIL, 		// 远程扣费接口调用失败(10027)
    HTTP_LCC_ERR_ROOM_CLOSE,  		// 房间已经关闭(10029)
    HTTP_LCC_ERR_KICKOFF, 			// 被挤掉线 默认通知内容(10037)
    HTTP_LCC_ERR_NO_AUTHORIZED, 	// 不能操作 不是对应的userid(10039)
    HTTP_LCC_ERR_LIVEROOM_NO_EXIST, // 直播间不存在(16104)
    HTTP_LCC_ERR_LIVEROOM_CLOSED, 	// 直播间已关闭(16106)
    HTTP_LCC_ERR_ANCHORID_INCONSISTENT, 	// 主播id与直播场次的主播id不合(16108)
    HTTP_LCC_ERR_CLOSELIVE_DATA_FAIL, 		// 关闭直播场次,数据表操作出错(16110)
    HTTP_LCC_ERR_CLOSELIVE_LACK_CODITION, 	// 主播立即关闭私密直播间, 不满足关闭条件(16122)
    HTTP_LCC_ERR_VERIFICATIONCODE,          // 验证码错误(1)
    HTTP_LCC_ERR_CANCEL_FAIL_INVITE,        // 取消失败，观众已接受(16205)
    HTTP_ERR_IDENTITY_FAILURE,               // 身份失效(16173)
    HTTP_LCC_ERR_VIEWER_OPEN_KNOCK           // 观众已开门(10137)
}
