package com.qpidnetwork.livemodule.im.listener;

import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;


/**
 * IM Client事件监听器
 * @author Hunter Mun
 * @since 2017-5-31
 */
public abstract class IMClientListener {
	
	// 处理结果
	public enum LCC_ERR_TYPE{
		LCC_ERR_SUCCESS,   				// 成功
		LCC_ERR_FAIL, 					// 服务器返回失败结果
		
		LCC_ERR_PROTOCOLFAIL,   		// 协议解析失败（服务器返回的格式不正确）
		LCC_ERR_CONNECTFAIL,    		// 连接服务器失败/断开连接
		LCC_ERR_CHECKVERFAIL,   		// 检测版本号失败（可能由于版本过低导致）
		LCC_ERR_SVRBREAK,       		// 服务器踢下线
		LCC_ERR_INVITE_TIMEOUT, 		// 邀请超时

		LCC_ERR_AUDIENCE_LIMIT,			// 房间人数过多
		LCC_ERR_ROOM_CLOSE,             // 房间已经关闭
		LCC_ERR_NO_CREDIT,       		// 信用点不足
		
		LCC_ERR_NO_LOGIN,				// 未登录
		LCC_ERR_SYSTEM,					// 系统错误
		LCC_ERR_TOKEN_EXPIRE,			// Token 过期了
		LCC_ERR_NOT_FOUND_ROOM,			// 进入房间失败 找不到房间信息or房间关闭
		LCC_ERR_CREDIT_FAIL,			// 远程扣费接口调用失败
		LCC_ERR_KICKOFF,				// 被挤掉线 默认通知内容
		LCC_ERR_NO_AUTHORIZED,			// 不能操作 不是对应的userid
		LCC_ERR_LIVEROOM_NO_EXIST,		// 直播间不存在
		LCC_ERR_LIVEROOM_CLOSED,		// 直播间已关闭
		LCC_ERR_ANCHORID_INCONSISTENT,	// 主播id与直播场次的主播id不合
		LCC_ERR_CLOSELIVE_DATA_FAIL,	// 关闭直播场次,数据表操作出错
		LCC_ERR_CLOSELIVE_LACK_CODITION,	 // 主播立即关闭私密直播间, 不满足关闭条件
		LCC_ERR_ENTER_ROOM_ERR,			// 进入房间失败 数据库操作失败（添加记录or删除扣费记录）
		LCC_ERR_NOT_FIND_ANCHOR,		// 主播机构信息找不到
		LCC_ERR_COUPON_FAIL,			// 扣费信用点失败--扣除优惠券分钟数
		LCC_ERR_ENTER_ROOM_NO_AUTHORIZED,	// 进入私密直播间 不是对应的userid
		LCC_ERR_REPEAT_KICKOFF,			// 被挤掉线 同一userid不通socket_id进入同一房间时
		LCC_ERR_ANCHOR_NO_ON_LIVEROOM,	// 改主播不存在公开直播间
		LCC_ERR_INCONSISTENT_ROOMTYPE, 	// 赠送礼物失败、开始\结束推流失败 房间类型不符合
		LCC_ERR_INCONSISTENT_CREDIT_FAIL,	// 扣费信用点数值的错误，扣费失败
		LCC_ERR_REPEAT_END_STREAM,		// 已结结束推流，不能重复操作
		LCC_ERR_REPEAT_BOOKING_KICKOFF,	// 重复立即预约该主播被挤掉线.
		LCC_ERR_NOT_IN_STUDIO,			// You are not in the studio
		LCC_ERR_INCONSISTENT_LEVEL,		// 赠送礼物失败 用户等级不符合
		LCC_ERR_INCONSISTENT_LOVELEVEL,	// 赠送礼物失败 亲密度不符合
		LCC_ERR_LESS_THAN_GIFT,			// 赠送礼物失败 拥有礼物数量不足
		LCC_ERR_SEND_GIFT_FAIL,			// 发送礼物出错
		LCC_ERR_SEND_GIFT_LESSTHAN_LEVEL,	// 发送礼物,男士级别不够
		LCC_ERR_SEND_GIFT_LESSTHAN_LOVELEVEL,	// 发送礼物,男士主播亲密度不够
		LCC_ERR_SEND_GIFT_NO_EXIST,				// 发送礼物,礼物不存在或已下架
		LCC_ERR_SEND_GIFT_LEVEL_INCONSISTENT_LIVE,	// 发送礼物,礼物级别限制与直播场次级别不符
		LCC_ERR_SEND_GIFT_BACKPACK_NO_EXIST,		// 主播发礼物,背包礼物不存在
		LCC_ERR_SEND_GIFT_BACKPACK_LESSTHAN,	 	// 主播发礼物,背包礼物数量不足
		LCC_ERR_SEND_GIFT_PARAM_ERR, 		// 发礼物,参数错误
		LCC_ERR_SEND_TOAST_NOCAN, 			// 主播不能发送弹幕
		LCC_ERR_ANCHOR_OFFLINE,				// 立即私密邀请失败 主播不在线 /*important*/
		LCC_ERR_ANCHOR_BUSY,				// 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/
		LCC_ERR_ANCHOR_PLAYING, 			// 主播正在私密直播中 /*important*/
		LCC_ERR_NOTCAN_CANCEL_INVITATION, 	// 取消立即私密邀请失败 状态不是带确认 /*important*/
		LCC_ERR_NO_FOUND_CRONJOB, 			// cronjob 里找不到对应的定时器函数
		LCC_ERR_REPEAT_INVITEING_TALENT 	// 发送才艺点播失败 上一次才艺邀请邀请待确认，不能重复发送 /*important*/

	}

	//邀请答复类型
	public enum InviteReplyType{
		Unknown,
		Defined,
		Accepted
	}
	
	//预约邀请答复类型
	public enum BookInviteReplyType{
		Unknown,
		Rejested,		//拒绝
		Accepted,		//同意
		OverTime		//超时
	}
	
	public enum TalentInviteStatus{
		Unknown,
		Accepted,
		Rejested
	}
	
	/**
	 * 邀请答复类型
	 * @param replyType
	 * @return
	 */
	private InviteReplyType intToInviteReplyType(int replyType){
		InviteReplyType type = InviteReplyType.Unknown;
		if( replyType < 0 || replyType >= InviteReplyType.values().length ) {
			type = InviteReplyType.Unknown;
		} else {
			type = InviteReplyType.values()[replyType];
		}
		return type;
	}
	
	/**
	 * 直播房间类型
	 * @param roomType
	 * @return
	 */
	private LiveRoomType intToLiveRoomType(int roomType){
		LiveRoomType type = LiveRoomType.Unknown;
		if( roomType < 0 || roomType >= LiveRoomType.values().length ) {
			type = LiveRoomType.Unknown;
		} else {
			type = LiveRoomType.values()[roomType];
		}
		return type;
	}
	
	/**
	 * 预约私密邀请回复类型
	 * @param replyType
	 * @return
	 */
	private BookInviteReplyType intToBookInviteReplyType(int replyType){
		BookInviteReplyType type = BookInviteReplyType.Unknown;
		if( replyType < 0 || replyType >= BookInviteReplyType.values().length ) {
			type = BookInviteReplyType.Unknown;
		} else {
			type = BookInviteReplyType.values()[replyType];
		}
		return type;
	}
	
	/**
	 * 才艺邀请处理状态
	 * @param talentInviteStatus
	 * @return
	 */
	private TalentInviteStatus intToTalentInviteStatus(int talentInviteStatus){
		TalentInviteStatus status = TalentInviteStatus.Unknown;
		if( talentInviteStatus < 0 || talentInviteStatus >= TalentInviteStatus.values().length ) {
			status = TalentInviteStatus.Unknown;
		} else {
			status = TalentInviteStatus.values()[talentInviteStatus];
		}
		return status;
	}
	
	/**
	 * Jni层返回转Java层错误码
	 * @param errIndex
	 * @return
	 */
	private LCC_ERR_TYPE intToErrType(int errIndex){
		return LCC_ERR_TYPE.values()[errIndex];
	}
	
	/**
	 * 2.1.登录回调
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnLogin(LCC_ERR_TYPE errType, String errMsg, IMLoginItem loginItem);
	public void OnLogin(int errType, String errMsg, IMLoginItem loginItem){
		OnLogin(intToErrType(errType), errMsg, loginItem);
	}
	
	/**
	 * 2.2.注销回调
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnLogout(LCC_ERR_TYPE errType, String errMsg);
	public void OnLogout(int errType, String errMsg){
		OnLogout(intToErrType(errType), errMsg);
	}
	
	/**
	 * 3.1.观众进入直播间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param roomInfo
	 */
	public abstract void OnRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo);
	public void OnRoomIn(int reqId, boolean success, int errType, String errMsg, IMRoomInItem roomInfo){
		OnRoomIn(reqId, success, intToErrType(errType), errMsg, roomInfo);
	}
	
	/**
	 * 3.2.观众退出直播间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnRoomOut(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnRoomOut(int reqId, boolean success, int errType, String errMsg){
		OnRoomOut(reqId, success, intToErrType(errType), errMsg);
	}
	
	/**
	 * 3.13.观众进入公开直播间回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param roomInfo
	 */
	public abstract void OnPublicRoomIn(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo);
	public void OnPublicRoomIn(int reqId, boolean success, int errType, String errMsg, IMRoomInItem roomInfo){
		OnPublicRoomIn(reqId, success, intToErrType(errType), errMsg, roomInfo);
	}
	
    /**
     *  3.14.观众开始／结束视频互动接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errType
     *  @param errMsg           结果描述
     *  @param manPushUrl       观众视频流url
     *
     */
	public abstract void OnControlManPush(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String[] manPushUrl);
	public void OnControlManPush(int reqId, boolean success, int errType, String errMsg, String[] manPushUrl){
		OnControlManPush(reqId, success, intToErrType(errType), errMsg, manPushUrl);
	}
	
    /**
     *  3.15.获取指定立即私密邀请信息接口 回调
     *
     *  @param success          操作是否成功
     *  @param reqId            请求序列号
     *  @param errMsg           结果描述
     *  @param inviteItem       立即私密邀请
     *
     */
	public abstract void OnGetInviteInfo(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMInviteListItem inviteItem);
	public void OnGetInviteInfo(int reqId, boolean success, int errType, String errMsg, IMInviteListItem inviteItem){
		OnGetInviteInfo(reqId, success, intToErrType(errType), errMsg, inviteItem);
	}
	
	/**
	 * 4.1.发送消息回调
	 * @param reqId
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnSendRoomMsg(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnSendRoomMsg(int reqId, boolean success, int errType, String errMsg){
		OnSendRoomMsg(reqId, success, intToErrType(errType), errMsg);
	}
	
	/**
	 * 5.1.发送直播间礼物消息（观众端发送直播间礼物消息，包括连击礼物）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param credit
	 * @param rebateCredit
	 */
	public abstract void OnSendGift(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, double credit, double rebateCredit);
	public void OnSendGift(int reqId, boolean success, int errType, String errMsg, double credit, double rebateCredit){
		OnSendGift(reqId, success, intToErrType(errType), errMsg, credit, rebateCredit);
	}
	
	/**
	 * 6.1.发送直播间弹幕消息（观众端发送直播间弹幕消息）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param credit
	 * @param rebateCredit
	 */
	public abstract void OnSendBarrage(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, double credit, double rebateCredit);
	public void OnSendBarrage(int reqId, boolean success, int errType, String errMsg, double credit, double rebateCredit){
		OnSendBarrage(reqId, success, intToErrType(errType), errMsg, credit, rebateCredit);
	}

	/**
	 * 7.1.观众立即私密邀请
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param invitationId
	 * @param timeout
	 * @param roomId
	 */
	public abstract void OnSendImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String invitationId, int timeout, String roomId);
	public void OnSendImmediatePrivateInvite(int reqId, boolean success, int errType, String errMsg, String invitationId, int timeout, String roomId){
		OnSendImmediatePrivateInvite(reqId, success, intToErrType(errType), errMsg, invitationId, timeout, roomId);
	}
	
	/**
	 * 7.2.观众取消立即私密邀请
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param roomId
	 */
	public abstract void OnCancelImmediatePrivateInvite(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String roomId);
	public void OnCancelImmediatePrivateInvite(int reqId, boolean success, int errType, String errMsg, String roomId){
		OnCancelImmediatePrivateInvite(reqId, success, intToErrType(errType), errMsg, roomId);
	}
	
	/**
	 * 8.1.发送直播间才艺点播邀请回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param talentInviteId
	 */
	public abstract void OnSendTalent(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String talentInviteId);
	public void OnSendTalent(int reqId, boolean success, int errType, String errMsg, String talentInviteId){
		OnSendTalent(reqId, success, intToErrType(errType), errMsg, talentInviteId);
	}
	
	/************************************   服务器推送相关        **********************************************/

	/**
	 * 2.4.用户被挤掉线通知
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnKickOff(LCC_ERR_TYPE errType, String errMsg);
	public void OnKickOff(int errType, String errMsg){
		OnKickOff(intToErrType(errType), errMsg);
	}
	
	/**
	 * 3.3.直播间关闭通知（用户）
	 * @param roomId
	 */
	public abstract void OnRecvRoomCloseNotice(String roomId, LCC_ERR_TYPE errType, String errMsg);
	public void OnRecvRoomCloseNotice(String roomId, int errType, String errMsg){
		OnRecvRoomCloseNotice(roomId, intToErrType(errType), errMsg);
	}
	
	
	/**
	 * 3.4.接收观众进入直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param fansNum
	 */
	public abstract void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum);
	
	/**
	 * 3.5.接收观众退出直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param fansNum
	 */
	public abstract void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum);
	
	/**
	 * 3.6.接收返点通知
	 * @param roomId
	 * @param item
	 */
	public abstract void OnRecvRebateInfoNotice(String roomId, IMRebateItem item);
	
	/**
	 * 3.7.接收关闭直播间倒数通知
	 * @param roomId
	 * @param err
	 * @param errMsg
	 */
	public abstract void OnRecvLeavingPublicRoomNotice(String roomId, LCC_ERR_TYPE err, String errMsg);
	public void OnRecvLeavingPublicRoomNotice(String roomId, int errType, String errMsg){
		OnRecvLeavingPublicRoomNotice(roomId, intToErrType(errType), errMsg);
	}
	
	/**
	 * 3.8.接收踢出直播间通知
	 * @param roomId
	 * @param err
	 * @param errMsg
	 * @param credit
	 */
	public abstract void OnRecvRoomKickoffNotice(String roomId, LCC_ERR_TYPE err, String errMsg, double credit);
	public void OnRecvRoomKickoffNotice(String roomId, int errType, String errMsg, double credit){
		OnRecvRoomKickoffNotice(roomId, intToErrType(errType), errMsg, credit);
	}
	
	/**
	 * 3.9.接收充值通知
	 * @param roomId
	 * @param message
	 * @param credit
	 */
	public abstract void OnRecvLackOfCreditNotice(String roomId, String message, double credit);
	
	/**
	 * 3.10.接收定时扣费通知
	 * @param roomId
	 * @param credit
	 */
	public abstract void OnRecvCreditNotice(String roomId, double credit);
	
	/**
	 * 3.11.直播间开播通知
	 * @param roomId            直播间ID
	 * @param anchorId          主播ID
	 * @param nickName          主播昵称
	 * @param avatarImg         主播头像url
	 * @param leftSeconds		开播前的倒数秒数
	 */
	public abstract void OnRecvLiveStart(String roomId, String anchorId, String nickName, String avatarImg, int leftSeconds);
	
	/**
	 * 3.12.接收观众/主播切换视频流通知接口
	 * @param roomId
	 * @param isAnchor
	 * @param playUrl
	 */
	public abstract void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String playUrl);
	
	/**
	 * 4.2.观众端/主播端向直播间发送文本消息
	 * @param roomId
	 * @param level
	 * @param fromId
	 * @param nickName
	 * @param msg
	 */
	public abstract void OnRecvRoomMsg(String roomId, int level, String fromId, String nickName, String msg);
	
	/**
	 * 4.3.接收直播间公告消息
	 * @param roomId
	 * @param message
	 * @param link
	 */
	public abstract void OnRecvSendSystemNotice(String roomId, String message, String link);
	
	/**
	 * 5.2.接收直播间礼物通知（观众端／主播端接收直播间礼物消息，包括连击礼物）
	 * @param roomId
	 * @param fromId
	 * @param nickName
	 * @param giftId
	 * @param giftName
	 * @param giftNum
	 * @param multi_click
	 * @param multi_click_start
	 * @param multi_click_end
	 * @param multiClickId
	 */
	public abstract void OnRecvRoomGiftNotice(String roomId, String fromId, String nickName, String giftId, String giftName, int giftNum, 
			boolean multi_click, int multi_click_start, int multi_click_end, int multiClickId);
	
	/**
	 * 6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
	 * @param roomId
	 * @param fromId
	 * @param nickName
	 * @param msg
	 */
	public abstract void OnRecvRoomToastNotice(String roomId, String fromId, String nickName, String msg);
	
	/**
	 * 7.3.接收立即私密邀请回复通知
	 * @param inviteId
	 * @param replyType
	 * @param roomId
	 * @param roomType
	 * @param anchorId
	 * @param nickName
	 * @param avatarImg
	 * @param message
	 */
	public abstract void OnRecvInviteReply(String inviteId, InviteReplyType replyType, String roomId, LiveRoomType roomType, String anchorId, 
			String nickName, String avatarImg, String message);
	public void OnRecvInviteReply(String inviteId, int replyType, String roomId, int roomType, String anchorId, 
			String nickName, String avatarImg, String message){
		OnRecvInviteReply(inviteId, intToInviteReplyType(replyType), roomId, intToLiveRoomType(roomType), anchorId, nickName, avatarImg, message);
	}
	
	/**
	 * 7.4.接收主播立即私密邀请通知
	 * @param logId
	 * @param anchorId
	 * @param anchorName
	 * @param anchorPhotoUrl
	 * @param message
	 */
	public abstract void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message);
	
	/**
	 * 7.5.接收主播预约私密邀请通知
	 * @param inviteId
	 * @param anchorId
	 * @param anchorName
	 * @param anchorPhotoUrl
	 * @param message
	 */
	public abstract void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message);
	
	/**
	 * 7.6.接收预约私密邀请回复通知
	 */
	public abstract void OnRecvSendBookingReplyNotice(IMBookingReplyItem imBookingReplyItem);
	//public void OnRecvSendBookingReplyNotice(IMBookingReplyItem imBookingReplyItem){
	//	OnRecvSendBookingReplyNotice(IMBookingReplyItem imBookingReplyItem));
	//}
	
	/**
	 * 7.7.接收预约开始倒数通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param leftSeconds
	 */
	public abstract void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds);

	/**
	 * 8.2.接收直播间才艺点播回复通知
	 * @param roomId
	 * @param talentInviteId
	 * @param talentId
	 * @param name
	 * @param credit
	 * @param status
	 */
	public abstract void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name, double credit, TalentInviteStatus status);
	public void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name, double credit, int status){
		OnRecvSendTalentNotice(roomId, talentInviteId, talentId, name, credit, intToTalentInviteStatus(status));
	}
	
	/**
	 * 9.1.观众等级升级通知
	 * @param level
	 */
	public abstract void OnRecvLevelUpNotice(int level);
	
	/**
	 * 9.2.观众亲密度升级通知
	 * @param lovelevel
	 */
	public abstract void OnRecvLoveLevelUpNotice(int lovelevel);
	
	/**
	 * 9.3.背包更新通知
	 * @param item
	 */
	public abstract void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item);
}
