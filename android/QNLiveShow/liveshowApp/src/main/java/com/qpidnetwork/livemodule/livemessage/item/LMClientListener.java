package com.qpidnetwork.livemodule.livemessage.item;

import java.nio.charset.Charset;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;


/**
 * LM Client事件监听器
 * @author Hunter Mun
 * @since 2017-5-31
 */
public abstract class LMClientListener {
	
//	// 处理结果
//	public enum LCC_ERR_TYPE{
//		LCC_ERR_SUCCESS,   				// 成功(0)
//		LCC_ERR_FAIL, 					// 服务器返回失败结果(-10000)
//
//		LCC_ERR_PROTOCOLFAIL,   		// 协议解析失败（服务器返回的格式不正确）(-10001)
//		LCC_ERR_CONNECTFAIL,    		// 连接服务器失败/断开连接 (-10002)
//		LCC_ERR_CHECKVERFAIL,   		// 检测版本号失败（可能由于版本过低导致）(-10003)
//		LCC_ERR_SVRBREAK,       		// 服务器踢下线 (-10004)
//		LCC_ERR_INVITE_TIMEOUT, 		// 邀请超时 (-10005)
//
//		LCC_ERR_AUDIENCE_LIMIT,			// 房间人数过多 (10023)
//		LCC_ERR_ROOM_CLOSE,             // 房间已经关闭 (10029)
//		LCC_ERR_NO_CREDIT,       		// 信用点不足   (10025)
//
//		LCC_ERR_NO_LOGIN,				// 未登录 (10002)
//		LCC_ERR_SYSTEM,					// 系统错误(10003)
//		LCC_ERR_TOKEN_EXPIRE,			// Token 过期了(10004)
//		LCC_ERR_NOT_FOUND_ROOM,			// 进入房间失败 找不到房间信息or房间关闭(10021)
//		LCC_ERR_CREDIT_FAIL,			// 远程扣费接口调用失败(10027)
//
//		LCC_ERR_KICKOFF,				// 被挤掉线 默认通知内容(10037)
//		LCC_ERR_NO_AUTHORIZED,			// 不能操作 不是对应的userid(10039)
//		LCC_ERR_LIVEROOM_NO_EXIST,		// 直播间不存在(16104)
//		LCC_ERR_LIVEROOM_CLOSED,		// 直播间已关闭(16106)
//		LCC_ERR_ANCHORID_INCONSISTENT,	// 主播id与直播场次的主播id不合(16108)
//
//		LCC_ERR_CLOSELIVE_DATA_FAIL,	// 关闭直播场次,数据表操作出错(16110)
//		LCC_ERR_CLOSELIVE_LACK_CODITION,	 // 主播立即关闭私密直播间, 不满足关闭条件(16122)
//		LCC_ERR_ENTER_ROOM_ERR,			// 进入房间失败 数据库操作失败（添加记录or删除扣费记录）(10022)
//		LCC_ERR_NOT_FIND_ANCHOR,		// 主播机构信息找不到(10026)
//		LCC_ERR_COUPON_FAIL,			// 扣费信用点失败--扣除优惠券分钟数(10028)
//
//		LCC_ERR_ENTER_ROOM_NO_AUTHORIZED,	// 进入私密直播间 不是对应的userid(10033)
//		LCC_ERR_REPEAT_KICKOFF,			// 被挤掉线 同一userid不通socket_id进入同一房间时(10038)
//		LCC_ERR_ANCHOR_NO_ON_LIVEROOM,	// 改主播不存在公开直播间(10055)
//		LCC_ERR_INCONSISTENT_ROOMTYPE, 	// 赠送礼物失败、开始\结束推流失败 房间类型不符合(10049)
//		LCC_ERR_INCONSISTENT_CREDIT_FAIL,	// 扣费信用点数值的错误，扣费失败(10053)
//
//		LCC_ERR_REPEAT_END_STREAM,		// 已结结束推流，不能重复操作(10054)
//		LCC_ERR_REPEAT_BOOKING_KICKOFF,	// 重复立即预约该主播被挤掉线.(10046)
//		LCC_ERR_NOT_IN_STUDIO,			// You are not in the studio(15002)
//		LCC_ERR_INCONSISTENT_LEVEL,		// 赠送礼物失败 用户等级不符合(10047)
//		LCC_ERR_INCONSISTENT_LOVELEVEL,	// 赠送礼物失败 亲密度不符合(10048)
//
//		LCC_ERR_LESS_THAN_GIFT,			// 赠送礼物失败 拥有礼物数量不足(10050)
//		LCC_ERR_SEND_GIFT_FAIL,			// 发送礼物出错(16144)
//		LCC_ERR_SEND_GIFT_LESSTHAN_LEVEL,	// 发送礼物,男士级别不够(16145)
//		LCC_ERR_SEND_GIFT_LESSTHAN_LOVELEVEL,	// 发送礼物,男士主播亲密度不够(16146)
//		LCC_ERR_SEND_GIFT_NO_EXIST,				// 发送礼物,礼物不存在或已下架(16147)
//
//		LCC_ERR_SEND_GIFT_LEVEL_INCONSISTENT_LIVE,	// 发送礼物,礼物级别限制与直播场次级别不符(16148)
//		LCC_ERR_SEND_GIFT_BACKPACK_NO_EXIST,		// 主播发礼物,背包礼物不存在(16151)
//		LCC_ERR_SEND_GIFT_BACKPACK_LESSTHAN,	 	// 主播发礼物,背包礼物数量不足(16152)
//		LCC_ERR_SEND_GIFT_PARAM_ERR, 		// 发礼物,参数错误(16153)
//		LCC_ERR_SEND_TOAST_NOCAN, 			// 主播不能发送弹幕(15001)
//
//		LCC_ERR_ANCHOR_OFFLINE,				// 立即私密邀请失败 主播不在线 /*important*/(10034)
//		LCC_ERR_ANCHOR_BUSY,				// 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/(10035)
//		LCC_ERR_ANCHOR_PLAYING, 			// 主播正在私密直播中 /*important*/(10056)
//		LCC_ERR_NOTCAN_CANCEL_INVITATION, 	// 取消立即私密邀请失败 状态不是带确认 /*important*/(10036)
//		LCC_ERR_NO_FOUND_CRONJOB, 			// cronjob 里找不到对应的定时器函数(10040)
//
//		LCC_ERR_REPEAT_INVITEING_TALENT, 	// 发送才艺点播失败 上一次才艺邀请邀请待确认，不能重复发送 /*important*/(10052)
//		LCC_ERR_RECV_REGULAR_CLOSE_ROOM,    // 用户接收正常关闭直播间(10088)
//
//	}
//
//	//邀请答复类型
//	public enum InviteReplyType{
//		Unknown,
//		Defined,
//		Accepted
//	}

    /**
     * Jni层返回转Java层错误码
     * @param errIndex
     * @return
     */
    private HttpLccErrType intToHttpErrType(int errIndex){
        return HttpLccErrType.values()[errIndex];
    }

    public IMClientListener.LCC_ERR_TYPE intToErrType(int errIndex){
        return IMClientListener.LCC_ERR_TYPE.values()[errIndex];
    }
//   public abstract void OnGetPrivateMsgFriendList(boolean success, HttpLccErrType errType, String errMsg, LMPrivateMsgContactItem[] contactList);
//    public void OnGetPrivateMsgFriendList(boolean success, int errType, String errMsg, LMPrivateMsgContactItem[] contactList) {
//        OnGetPrivateMsgFriendList(success, intToHttpErrType(errType), errMsg, contactList);
//    }
//
//
//    public abstract void OnGetFollowPrivateMsgFriendList(boolean success, HttpLccErrType errType, String errMsg, LMPrivateMsgContactItem[] contactList);
//    public void OnGetFollowPrivateMsgFriendList(boolean success, int errType, String errMsg, LMPrivateMsgContactItem[] contactList) {
//        OnGetFollowPrivateMsgFriendList(success, intToHttpErrType(errType), errMsg, contactList);
//    }
//

    public abstract void OnRefreshPrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId);
    public void OnRefreshPrivateMsgWithUserId(boolean success, int errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId) {
        OnRefreshPrivateMsgWithUserId(success, intToHttpErrType(errType), errMsg, userId, messageList, reqId);
    }

    public abstract void OnGetMorePrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId, boolean isMuchMore);
    public void OnGetMorePrivateMsgWithUserId(boolean success, int errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId, boolean isMuchMore) {
        OnGetMorePrivateMsgWithUserId(success, intToHttpErrType(errType), errMsg, userId, messageList, reqId, isMuchMore);
    }

	/************************************   服务器推送相关        **********************************************/

    public abstract void OnUpdateFriendListNotice(boolean success, HttpLccErrType errType, String errMsg);
    public void OnUpdateFriendListNotice(boolean success, int errType, String errMsg) {
        OnUpdateFriendListNotice(success, intToHttpErrType(errType), errMsg);
    }


    public abstract void OnUpdatePrivateMsgWithUserId(String userId, LiveMessageItem[] messageList);

    public abstract void OnSendPrivateMessage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String userId, LiveMessageItem messageItem);
    public void OnSendPrivateMessage(boolean success, int errType, String errMsg, String userId, LiveMessageItem messageItem) {
        OnSendPrivateMessage(success, intToErrType(errType), errMsg, userId, messageItem);
    }

    public abstract void OnRecvUnReadPrivateMsg(LiveMessageItem messageItem);

    // 重发通知（上层按了重发，c层删除所有时间item（android不好删除可能有时间item），把所有发送给上层）
    public abstract void OnRepeatSendPrivateMsgNotice(String userId, LiveMessageItem[] messageList);
}
