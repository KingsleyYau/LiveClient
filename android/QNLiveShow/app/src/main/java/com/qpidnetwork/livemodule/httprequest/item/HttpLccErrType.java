package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 主播在线状态
 * @author Hunter Mun
 *
 */
public enum HttpLccErrType {
    HTTP_LCC_ERR_SUCCESS,   		// 成功
    HTTP_LCC_ERR_FAIL, 				// 服务器返回失败结果

    // 客户端定义的错误
    HTTP_LCC_ERR_PROTOCOLFAIL,   	// 协议解析失败（服务器返回的格式不正确）
    HTTP_LCC_ERR_CONNECTFAIL,    	// 连接服务器失败/断开连接
    HTTP_LCC_ERR_CHECKVERFAIL,   	// 检测版本号失败（可能由于版本过低导致）

    HTTP_LCC_ERR_SVRBREAK,       	// 服务器踢下线
    HTTP_LCC_ERR_INVITE_TIMEOUT, 	// 邀请超时
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
    HTTP_LCC_ERR_BOOK_EXIST 				// 用户预约时间段已经存在预约 /*important*/
}
