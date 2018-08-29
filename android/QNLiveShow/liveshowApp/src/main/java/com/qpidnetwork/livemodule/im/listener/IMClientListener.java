package com.qpidnetwork.livemodule.im.listener;

import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;

import java.nio.charset.Charset;


/**
 * IM Client事件监听器
 * @author Hunter Mun
 * @since 2017-5-31
 */
public abstract class IMClientListener {
	
	// 处理结果
	public enum LCC_ERR_TYPE{
		LCC_ERR_SUCCESS,   				// 成功(0)
		LCC_ERR_FAIL, 					// 服务器返回失败结果(-10000)
		
		LCC_ERR_PROTOCOLFAIL,   		// 协议解析失败（服务器返回的格式不正确）(-10001)
		LCC_ERR_CONNECTFAIL,    		// 连接服务器失败/断开连接 (-10002)
		LCC_ERR_CHECKVERFAIL,   		// 检测版本号失败（可能由于版本过低导致）(-10003)
		LCC_ERR_SVRBREAK,       		// 服务器踢下线 (-10004)
		LCC_ERR_INVITE_TIMEOUT, 		// 邀请超时 (-10005)

		LCC_ERR_AUDIENCE_LIMIT,			// 房间人数过多 (10023)
		LCC_ERR_ROOM_CLOSE,             // 房间已经关闭 (10029)
		LCC_ERR_NO_CREDIT,       		// 信用点不足   (10025)
		
		LCC_ERR_NO_LOGIN,				// 未登录 (10002)
		LCC_ERR_SYSTEM,					// 系统错误(10003)
		LCC_ERR_TOKEN_EXPIRE,			// Token 过期了(10004)
		LCC_ERR_NOT_FOUND_ROOM,			// 进入房间失败 找不到房间信息or房间关闭(10021)
		LCC_ERR_CREDIT_FAIL,			// 远程扣费接口调用失败(10027)

		LCC_ERR_KICKOFF,				// 被挤掉线 默认通知内容(10037)
		LCC_ERR_NO_AUTHORIZED,			// 不能操作 不是对应的userid(10039)
		LCC_ERR_LIVEROOM_NO_EXIST,		// 直播间不存在(16104)
		LCC_ERR_LIVEROOM_CLOSED,		// 直播间已关闭(16106)
		LCC_ERR_ANCHORID_INCONSISTENT,	// 主播id与直播场次的主播id不合(16108)

		LCC_ERR_CLOSELIVE_DATA_FAIL,	// 关闭直播场次,数据表操作出错(16110)
		LCC_ERR_CLOSELIVE_LACK_CODITION,	 // 主播立即关闭私密直播间, 不满足关闭条件(16122)
		LCC_ERR_ENTER_ROOM_ERR,			// 进入房间失败 数据库操作失败（添加记录or删除扣费记录）(10022)
		LCC_ERR_NOT_FIND_ANCHOR,		// 主播机构信息找不到(10026)
		LCC_ERR_COUPON_FAIL,			// 扣费信用点失败--扣除优惠券分钟数(10028)

		LCC_ERR_ENTER_ROOM_NO_AUTHORIZED,	// 进入私密直播间 不是对应的userid(10033)
		LCC_ERR_REPEAT_KICKOFF,			// 被挤掉线 同一userid不通socket_id进入同一房间时(10038)
		LCC_ERR_ANCHOR_NO_ON_LIVEROOM,	// 改主播不存在公开直播间(10055)
		LCC_ERR_INCONSISTENT_ROOMTYPE, 	// 赠送礼物失败、开始\结束推流失败 房间类型不符合(10049)
		LCC_ERR_INCONSISTENT_CREDIT_FAIL,	// 扣费信用点数值的错误，扣费失败(10053)

		LCC_ERR_REPEAT_END_STREAM,		// 已结结束推流，不能重复操作(10054)
		LCC_ERR_REPEAT_BOOKING_KICKOFF,	// 重复立即预约该主播被挤掉线.(10046)
		LCC_ERR_NOT_IN_STUDIO,			// You are not in the studio(15002)
		LCC_ERR_INCONSISTENT_LEVEL,		// 赠送礼物失败 用户等级不符合(10047)
		LCC_ERR_INCONSISTENT_LOVELEVEL,	// 赠送礼物失败 亲密度不符合(10048)

		LCC_ERR_LESS_THAN_GIFT,			// 赠送礼物失败 拥有礼物数量不足(10050)
		LCC_ERR_SEND_GIFT_FAIL,			// 发送礼物出错(16144)
		LCC_ERR_SEND_GIFT_LESSTHAN_LEVEL,	// 发送礼物,男士级别不够(16145)
		LCC_ERR_SEND_GIFT_LESSTHAN_LOVELEVEL,	// 发送礼物,男士主播亲密度不够(16146)
		LCC_ERR_SEND_GIFT_NO_EXIST,				// 发送礼物,礼物不存在或已下架(16147)

		LCC_ERR_SEND_GIFT_LEVEL_INCONSISTENT_LIVE,	// 发送礼物,礼物级别限制与直播场次级别不符(16148)
		LCC_ERR_SEND_GIFT_BACKPACK_NO_EXIST,		// 主播发礼物,背包礼物不存在(16151)
		LCC_ERR_SEND_GIFT_BACKPACK_LESSTHAN,	 	// 主播发礼物,背包礼物数量不足(16152)
		LCC_ERR_SEND_GIFT_PARAM_ERR, 		// 发礼物,参数错误(16153)
		LCC_ERR_SEND_TOAST_NOCAN, 			// 主播不能发送弹幕(15001)

		LCC_ERR_ANCHOR_OFFLINE,				// 立即私密邀请失败 主播不在线 /*important*/(10034)
		LCC_ERR_ANCHOR_BUSY,				// 立即私密邀请失败 主播繁忙--存在即将开始的预约 /*important*/(10035)
		LCC_ERR_ANCHOR_PLAYING, 			// 主播正在私密直播中 /*important*/(10056)
		LCC_ERR_NOTCAN_CANCEL_INVITATION, 	// 取消立即私密邀请失败 状态不是带确认 /*important*/(10036)
		LCC_ERR_NO_FOUND_CRONJOB, 			// cronjob 里找不到对应的定时器函数(10040)

		LCC_ERR_REPEAT_INVITEING_TALENT, 	// 发送才艺点播失败 上一次才艺邀请邀请待确认，不能重复发送 /*important*/(10052)
		LCC_ERR_RECV_REGULAR_CLOSE_ROOM,    // 用户接收正常关闭直播间(10088)

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
		Rejested,
		OutTime,
		Cancel
	}

	// 直播间公告类型
	public enum IMSystemType{
		common,			// 普通
		warn			// 警告
	}

	// 节目通知类型
	public enum IMProgramPlayType {
		Unknown,				// 未知
		BuyTicketPlay,			// 已购票的开播通知
		FollowPlay,				// 仅关注的开播通知
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
	 * 直播间公告类型
	 * @param systemType
	 * @return
	 */
	private IMSystemType intToIMSystemType(int systemType){
		return IMSystemType.values()[systemType];
	}

	/**
	 *  节目通知类型
	 * @param status
	 * @return
	 */
	private IMProgramPlayType intToProgramPlayType(int status){
		IMProgramPlayType type = IMProgramPlayType.Unknown;
		if( status < 0 || status >= IMProgramPlayType.values().length ) {
			type = IMProgramPlayType.Unknown;
		} else {
			type = IMProgramPlayType.values()[status];
		}
		return type;
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
	 * 7.8.观众端是否显示主播立即私密邀请
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnInstantInviteUserReport(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnInstantInviteUserReport(int reqId, boolean success, int errType, String errMsg){
		OnInstantInviteUserReport(reqId, success, intToErrType(errType), errMsg);
	}
	
	/**
	 * 8.1.发送直播间才艺点播邀请回调
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param talentInviteId
	 * @param talentId
	 */
	public abstract void OnSendTalent(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String talentInviteId, String talentId);
	public void OnSendTalent(int reqId, boolean success, int errType, String errMsg, String talentInviteId, String talentId){
		OnSendTalent(reqId, success, intToErrType(errType), errMsg, talentInviteId, talentId);
	}

	/**
	 * 10.3.观众新建/进入多人互动直播间
	 * @param item    主播回复观众多人互动邀请信息
	 */
	public abstract void OnEnterHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMHangoutRoomItem item);
	public void OnEnterHangoutRoom(int reqId, boolean success, int errType, String errMsg, IMHangoutRoomItem item){
		OnEnterHangoutRoom(reqId, success, intToErrType(errType), errMsg, item);
	}

	/**
	 * 10.4.退出多人互动直播间
	 */
	public abstract void OnLeaveHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnLeaveHangoutRoom(int reqId, boolean success, int errType, String errMsg){
		OnLeaveHangoutRoom(reqId, success, intToErrType(errType), errMsg);
	}

	/**
	 * 10.7.发送多人互动直播间礼物消息
	 */
	public abstract void OnSendHangoutGift(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, double credit);
	public void OnSendHangoutGift(int reqId, boolean success, int errType, String errMsg, double credit){
		OnSendHangoutGift(reqId, success, intToErrType(errType), errMsg, credit);
	}

	/**
	 * 10.11.多人互动观众开始/结束视频互动
	 */
	public abstract void OnControlManPushHangout(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, String[] manPushUrl);
	public void OnControlManPushHangout(int reqId, boolean success, int errType, String errMsg, String[] manPushUrl){
		OnControlManPushHangout(reqId, success, intToErrType(errType), errMsg, manPushUrl);
	}

	/**
	 * 10.12.发送多人互动直播间文本消息回调
	 * @param reqId
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnSendHangoutRoomMsg(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnSendHangoutRoomMsg(int reqId, boolean success, int errType, String errMsg){
		OnSendHangoutRoomMsg(reqId, success, intToErrType(errType), errMsg);
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
	 * @param honorImg
	 * @param isHasTicket 是否已购票
	 */
	public abstract void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum, String honorImg, boolean isHasTicket);
	
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
	public abstract void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, LCC_ERR_TYPE err, String errMsg);
	public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, int errType, String errMsg){
		OnRecvLeavingPublicRoomNotice(roomId, leftSeconds, intToErrType(errType), errMsg);
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
	 * @param playUrls		           视频播放url
	 */
	public abstract void OnRecvLiveStart(String roomId, String anchorId, String nickName, String avatarImg, int leftSeconds, String[] playUrls);
	
//	/**
//	 * 3.12.接收观众/主播切换视频流通知接口
//	 * @param roomId				房间ID
//	 * @param isAnchor				是否是主播推流（1:是 0:否）
//	 * @param playUrls				播放url
//	 * @param userId				主播/观众ID（可无，仅在多人互动直播间才存在）
//	 */
//	public abstract void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String[] playUrls, String userId);

	/**
	 * 3.12.接收观众/主播切换视频流通知接口
	 * @param roomId				房间ID
	 * @param isAnchor				是否是主播推流（1:是 0:否）
	 * @param playUrls				播放url
	 */
	public abstract void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String[] playUrls);
	
	/**
	 * 4.2.观众端/主播端向直播间发送文本消息
	 * @param roomId
	 * @param level
	 * @param fromId
	 * @param nickName
	 * @param msg
	 * @param honorUrl
	 */
	public abstract void OnRecvRoomMsg(String roomId, int level, String fromId, String nickName, String msg, String honorUrl);
	public void OnRecvRoomMsg(String roomId, int level, String fromId, String nickName, byte[] msg, String honorUrl){
		//解决emoji6.0以下jni使用NewStringUTF越界读（或者crash问题）
		OnRecvRoomMsg(roomId, level, fromId, nickName, new String(msg, Charset.forName("UTF-8")), honorUrl);
	}
	
	/**
	 * 4.3.接收直播间公告消息
	 * @param roomId
	 * @param message
	 * @param link
	 * @param type 公告类型（0：普通，1：警告）
	 */

	public abstract void OnRecvSendSystemNotice(String roomId, String message, String link, IMSystemType type);
	public void OnRecvSendSystemNotice(String roomId, String message, String link, int type){
		OnRecvSendSystemNotice(roomId, message, link, intToIMSystemType(type));
	}
	
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
	 * @param honorUrl
	 */
	public abstract void OnRecvRoomGiftNotice(String roomId, String fromId, String nickName, String giftId, String giftName, int giftNum, 
			boolean multi_click, int multi_click_start, int multi_click_end, int multiClickId, String honorUrl);
	
	/**
	 * 6.2.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
	 * @param roomId
	 * @param fromId
	 * @param nickName
	 * @param msg
	 * @param honorUrl
	 */
	public abstract void OnRecvRoomToastNotice(String roomId, String fromId, String nickName, String msg, String honorUrl);
	public void OnRecvRoomToastNotice(String roomId, String fromId, String nickName, byte[] msg, String honorUrl){
		//解决emoji6.0以下jni使用NewStringUTF越界读（或者crash问题）
		OnRecvRoomToastNotice(roomId, fromId, nickName, new String(msg, Charset.forName("UTF-8")), honorUrl);
	}
	
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
	 * @param giftId		礼物ID
	 * @param giftName		礼物名称
	 * @param giftNum       礼物数量
	 */
	public abstract void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name, double credit, TalentInviteStatus status, double rebateCredit, String giftId, String giftName, int giftNum);
	public void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name, double credit, int status, double rebateCredit, String giftId, String giftName, int giftNum){
		OnRecvSendTalentNotice(roomId, talentInviteId, talentId, name, credit, intToTalentInviteStatus(status), rebateCredit, giftId, giftName, giftNum);
	}

	/**
	 * 8.3.接收直播间才艺点播回复通知
	 * @param roomId				直播间ID
	 * @param introduction			公告描述
	 */
	public  abstract  void OnRecvTalentPromptNotice(String roomId, String introduction);

	/**
	 * 9.1.观众等级升级通知
	 * @param level
	 */
	public abstract void OnRecvLevelUpNotice(int level);
	
	/**
	 * 9.2.观众亲密度升级通知
	 * @param lovelevelItem
	 */
	public abstract void OnRecvLoveLevelUpNotice(IMLoveLeveItem lovelevelItem);
	
	/**
	 * 9.3.背包更新通知
	 * @param item
	 */
	public abstract void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item);
	
	/**
	 * 9.4.观众勋章升级通知
	 * @param honorId
	 * @param honorUrl
	 */
	public abstract void OnRecvGetHonorNotice(String honorId, String honorUrl);

	/**
	 * 10.1.接收主播推荐好友通知
	 * @param item    主播推荐好友信息
	 */
	public abstract void OnRecvRecommendHangoutNotice(IMHangoutRecommendItem item);

	/**
	 * 10.2.接收主播回复观众多人互动邀请通知x
	 * @param item    主播回复观众多人互动邀请信息
	 */
	public abstract void OnRecvDealInvitationHangoutNotice(IMDealInviteItem item);

	/**
	 * 10.5.接收观众/主播进入多人互动直播间通知
	 * @param item    接收观众/主播进入多人互动直播间信息
	 */
	public abstract void OnRecvEnterHangoutRoomNotice(IMRecvEnterRoomItem item);

	/**
	 * 10.6.接收观众/主播退出多人互动直播间通知
	 * @param item    接收观众/主播退出多人互动直播间信息
	 */
	public abstract void OnRecvLeaveHangoutRoomNotice(IMRecvLeaveRoomItem item);

	/**
	 * 10.8.接收多人互动直播间礼物通知
	 * @param item    接收多人互动直播间礼物信息
	 */
	public abstract void OnRecvHangoutGiftNotice(IMRecvHangoutGiftItem item);

	/**
	 * 10.9.接收主播敲门通知
	 * @param item    接收主播敲门信息
	 */
	public abstract void OnRecvKnockRequestNotice(IMRecvKnockRequestItem item);

	/**
	 * 10.10.接收多人互动余额不足导致主播将要离开的通知
	 * @param item    接收多人互动余额不足导致主播将要离开的信息
	 */
	public abstract void OnRecvLackCreditHangoutNotice(IMRecvLeaveRoomItem item);

	/**
	 * 10.13.接收直播间文本消息
	 * @param item
	 */
	public abstract void OnRecvHangoutRoomMsg(IMHangoutMsgItem item);

	/**
	 * 10.14.接收进入多人互动直播间倒数通知
	 * @param item
	 */
	public abstract void OnRecvAnchorCountDownEnterHangoutRoomNotice(IMHangoutCountDownItem item);

	/**
	 * 11.1.节目开播通知
	 * @param showinfo
	 * @param type
	 * @param msg           消息提示文字
	 */

	public abstract void OnRecvProgramPlayNotice(IMProgramInfoItem showinfo, IMProgramPlayType type, String msg);
	public void OnRecvProgramPlayNotice(IMProgramInfoItem showinfo, int type, String msg) {
		OnRecvProgramPlayNotice(showinfo, intToProgramPlayType(type), msg);
	}


	/**
	 * 11.2.节目取消通知
	 * @param showinfo
	 */
	public abstract void OnRecvCancelProgramNotice(IMProgramInfoItem showinfo);

	/**
	 * 11.3.接收节目已退票通知
	 * @param showinfo
	 * @param leftCredit
	 */
	public abstract void OnRecvRetTicketNotice(IMProgramInfoItem showinfo, double leftCredit);

	/**
	 * 13.1.接收意向信通知
	 * @param anchorId		主播ID
	 * @param loiId			意向信ID
	 */
	public abstract void OnRecvLoiNotice(String anchorId, String loiId);

	/**
	 * 13.2.接收意向信通知
	 * @param anchorId		主播ID
	 * @param emfId			信件ID
	 */
	public abstract void OnRecvEMFNotice(String anchorId, String emfId);

}
