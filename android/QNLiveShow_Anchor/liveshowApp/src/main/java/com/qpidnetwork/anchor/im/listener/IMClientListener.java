package com.qpidnetwork.anchor.im.listener;

import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;

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
		
		LCC_ERR_NO_LOGIN,				// 未登录 (10002)
		LCC_ERR_SYSTEM,					// 系统错误(10003)
		LCC_ERR_TOKEN_EXPIRE,			// Token 过期了(10004)
		LCC_ERR_NOT_FOUND_ROOM,			// 进入房间失败 找不到房间信息or房间关闭(10021)
		LCC_ERR_CREDIT_FAIL,			// 远程扣费接口调用失败(10027)
		LCC_ERR_ROOM_CLOSE, 			// 房间已经关闭
		LCC_ERR_KICKOFF,				// 被挤掉线 默认通知内容(10037)
		LCC_ERR_NO_AUTHORIZED,			// 不能操作 不是对应的userid(10039)
		LCC_ERR_LIVEROOM_NO_EXIST,		// 直播间不存在(16104)
		LCC_ERR_LIVEROOM_CLOSED,		// 直播间已关闭(16106)
		LCC_ERR_ANCHORID_INCONSISTENT,	// 主播id与直播场次的主播id不合(16108)
		LCC_ERR_CLOSELIVE_DATA_FAIL,	// 关闭直播场次,数据表操作出错(16110)
		LCC_ERR_CLOSELIVE_LACK_CODITION,	// 主播立即关闭私密直播间, 不满足关闭条件(16122)
		LCC_ERR_NOT_IN_STUDIO,				// You are not in the studio(15002)
		LCC_ERR_NOT_FIND_ANCHOR,			// 主播机构信息找不到(10026)
		LCC_ERR_INCONSISTENT_LEVEL,			// 赠送礼物失败 用户等级不符合(10047)
		LCC_ERR_INCONSISTENT_LOVELEVEL,		// 赠送礼物失败 亲密度不符合(10048)
		LCC_ERR_INCONSISTENT_ROOMTYPE, 		// 赠送礼物失败、开始\结束推流失败 房间类型不符合(10049)
		LCC_ERR_LESS_THAN_GIFT,				// 赠送礼物失败 拥有礼物数量不足(10050)
		LCC_ERR_SEND_GIFT_FAIL,				// 发送礼物出错(16144)
		LCC_ERR_SEND_GIFT_LESSTHAN_LEVEL,		// 发送礼物,男士级别不够(16145)
		LCC_ERR_SEND_GIFT_LESSTHAN_LOVELEVEL,	// 发送礼物,男士主播亲密度不够(16146)
		LCC_ERR_SEND_GIFT_NO_EXIST,					// 发送礼物,礼物不存在或已下架(16147)
		LCC_ERR_SEND_GIFT_LEVEL_INCONSISTENT_LIVE,	// 发送礼物,礼物级别限制与直播场次级别不符(16148)
		LCC_ERR_SEND_GIFT_BACKPACK_NO_EXIST,		// 主播发礼物,背包礼物不存在(16151)
		LCC_ERR_SEND_GIFT_BACKPACK_LESSTHAN,	 	// 主播发礼物,背包礼物数量不足(16152)
		LCC_ERR_SEND_GIFT_PARAM_ERR, 				// 发礼物,参数错误(16153)
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

	// 直播间公告类型
	public enum IMSystemType{
		common,			// 普通
		warn			// 警告
	}

    /**
     * 互动视频请求类型
     */
	public enum IMVideoInteractiveOperateType{
        Start,      //开始
        Close       //关闭
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
     * 互动视频操作类型
     * @param operateType
     * @return
     */
    private IMVideoInteractiveOperateType intToIMVideoInteractiveOperateType(int operateType){
        return IMVideoInteractiveOperateType.values()[operateType];
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
	 * 3.1.主播进入公开直播间回调
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
	 * 3.2.主播进入指定直播间回调
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
	 * 3.3.主播退出直播间回调
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
	 */
	public abstract void OnSendGift(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnSendGift(int reqId, boolean success, int errType, String errMsg){
		OnSendGift(reqId, success, intToErrType(errType), errMsg);
	}

	/**
	 * 9.1.主播立即私密邀请
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
	 *  9.5.获取指定立即私密邀请信息接口 回调
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
	 * 10.1.进入多人互动直播间（主播端进入多人互动直播间）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 * @param hangoutRoomItem		多人互动直播间
	 * @param expire				倒数进入秒数，倒数完成后再调用本接口重新进入
	 */
	public abstract void OnEnterHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg, IMHangoutRoomItem hangoutRoomItem, int expire);
	public void OnEnterHangoutRoom(int reqId, boolean success, int errType, String errMsg, IMHangoutRoomItem hangoutRoomItem, int expire){
		OnEnterHangoutRoom(reqId, success, intToErrType(errType), errMsg, hangoutRoomItem, expire);
	}

	/**
	 * 10.2.退出多人互动直播间（主播端请求退出多人互动直播间）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnLeaveHangoutRoom(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnLeaveHangoutRoom(int reqId, boolean success, int errType, String errMsge){
		OnLeaveHangoutRoom(reqId, success, intToErrType(errType), errMsge);
	}

	/**
	 * 10.11.发送多人互动直播间礼物消息（观众端/主播端发送多人互动直播间礼物消息）
	 * @param reqId
	 * @param success
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnSendHangoutGift(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnSendHangoutGift(int reqId, boolean success, int errType, String errMsge){
		OnSendHangoutGift(reqId, success, intToErrType(errType), errMsge);
	}

	/**
	 * 10.14.发送多人互动直播间文本消息回调
	 * @param reqId
	 * @param errType
	 * @param errMsg
	 */
	public abstract void OnSendHangoutMsg(int reqId, boolean success, LCC_ERR_TYPE errType, String errMsg);
	public void OnSendHangoutMsg(int reqId, boolean success, int errType, String errMsg){
		OnSendHangoutMsg(reqId, success, intToErrType(errType), errMsg);
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
	 * 3.4.直播间关闭通知（用户）
	 * @param roomId
	 */
	public abstract void OnRecvRoomCloseNotice(String roomId, LCC_ERR_TYPE errType, String errMsg);
	public void OnRecvRoomCloseNotice(String roomId, int errType, String errMsg){
		OnRecvRoomCloseNotice(roomId, intToErrType(errType), errMsg);
	}

	/**
	 * 3.5.接收踢出直播间通知
	 * @param roomId
	 * @param err
	 * @param errMsg
	 */
	public abstract void OnRecvRoomKickoffNotice(String roomId, LCC_ERR_TYPE err, String errMsg);
	public void OnRecvRoomKickoffNotice(String roomId, int errType, String errMsg){
		OnRecvRoomKickoffNotice(roomId, intToErrType(errType), errMsg);
	}

	/**
	 * 3.6.接收观众进入直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param fansNum
	 * @param isHasTicket 是否已购票
	 */
	public abstract void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum, boolean isHasTicket);
	
	/**
	 * 3.7.接收观众退出直播间通知
	 * @param roomId
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param fansNum
	 */
	public abstract void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum);
	
	/**
	 * 3.8.接收关闭直播间倒数通知
	 * @param roomId
	 * @param err
	 * @param errMsg
	 */
	public abstract void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, LCC_ERR_TYPE err, String errMsg);
	public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, int errType, String errMsg){
		OnRecvLeavingPublicRoomNotice(roomId, leftSeconds, intToErrType(errType), errMsg);
	}

	/**
	 * 3.9.接收观众退出直播间通知
	 * @param roomId				 直播间ID
	 * @param anchorId				 退出直播间的主播ID
	 */
	public abstract void OnRecvAnchorLeaveRoomNotice(String roomId, String anchorId);
	
	/**
	 * 4.2.接收直播间文本消息通知
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
	 * @param totalCredit
	 */
	public abstract void OnRecvRoomGiftNotice(String roomId, String fromId, String nickName, String giftId, String giftName, int giftNum, 
			boolean multi_click, int multi_click_start, int multi_click_end, int multiClickId, String honorUrl, int totalCredit);
	
	/**
	 * 6.1.接收直播间弹幕通知（观众端／主播端接收直播间弹幕消息）
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
     * 7.1.接收直播间才艺点播邀请通知
     * @param talentInvitationId
     * @param name
     * @param userId
     * @param nickName
     */
	public abstract void OnRecvTalentRequestNotice(String talentInvitationId, String name, String userId, String nickName);

    /**
     * 8.1.接收观众启动/关闭视频互动通知
     * @param roomId
     * @param userId
     * @param nickname
     * @param avatarImg
     * @param operateType
     * @param pushUrls
     */
    public abstract void OnRecvInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg, IMVideoInteractiveOperateType operateType, String[] pushUrls);
    public void OnRecvInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg, int operateType, String[] pushUrls){
        OnRecvInteractiveVideoNotice(roomId, userId, nickname, avatarImg, intToIMVideoInteractiveOperateType(operateType), pushUrls);
    }
	
	/**
	 * 9.2.接收立即私密邀请回复通知
	 * @param inviteId
	 * @param replyType
	 * @param roomId
	 * @param roomType
	 * @param userId
	 * @param nickName
	 * @param avatarImg
	 */
	public abstract void OnRecvInviteReply(String inviteId, InviteReplyType replyType, String roomId, LiveRoomType roomType, String userId,
			String nickName, String avatarImg);
	public void OnRecvInviteReply(String inviteId, int replyType, String roomId, int roomType, String anchorId, 
			String nickName, String avatarImg){
		OnRecvInviteReply(inviteId, intToInviteReplyType(replyType), roomId, intToLiveRoomType(roomType), anchorId, nickName, avatarImg);
	}
	
	/**
	 * 9.3.接收用户立即私密邀请通知
	 * @param userId
	 * @param nickname
	 * @param photoUrl
	 * @param invitationId
	 */
	public abstract void OnRecvAnchoeInviteNotify(String userId, String nickname, String photoUrl, String invitationId);

	/**
	 * 9.4.接收预约开始倒数通知
	 * @param roomId            直播间ID
	 * @param userId          主播ID
	 * @param nickName          主播昵称
	 * @param avatarImg         主播头像url
	 * @param leftSeconds		开播前的倒数秒数
	 */
	public abstract void OnRecvBookingNotice(String roomId, String userId, String nickName, String avatarImg, int leftSeconds);

	/**
	 * 9.6.接收观众接受预约通知
	 * @param userId          观众ID
	 * @param nickName        观众昵称
	 * @param photoUrl        观众头像url
	 * @param invitationId	  预约ID
	 * @param bookTime		  预约时间（1970年起的秒数）
	 */
	public abstract void OnRecvInvitationAcceptNotice(String userId, String nickName, String photoUrl, String invitationId, int bookTime);

	/**
	 * 10.3.接收观众邀请多人互动通知（主播端接收观众邀请主播进入多人互动通知）
	 * @param item		观众邀请多人互动信息
	 */
	public abstract void OnRecvInvitationHangoutNotice(IMHangoutInviteItem item);

	/**
	 * 10.4.接收推荐好友通知
	 * @param item		 主播端接收自己推荐好友给观众的信息
	 */
	public abstract void OnRecvAnchorRecommendHangoutNotice(IMHangoutRecommendItem item);

	/**
	 * 10.5.接收敲门回复通知
	 * @param item		 接收敲门回复信息
	 */
	public abstract void OnRecvAnchorDealKnockRequestNotice(IMKnockRequestItem item);

	/**
	 * 10.6.接收观众邀请其它主播加入多人互动通知
	 * @param item		接收观众邀请其它主播加入多人互动信息
	 */
	public abstract void OnRecvAnchorOtherInviteNotice(IMOtherInviteItem item);

	/**
	 * 10.7.接收主播回复观众多人互动邀请通知
	 * @param item		接收主播回复观众多人互动邀请信息
	 */
	public abstract void OnRecvAnchorDealInviteNotice(IMDealInviteItem item);

	/**
	 * 10.8.观众端/主播端接收观众/主播进入多人互动直播间通知
	 * @param item		接收主播回复观众多人互动邀请信息
	 */
	public abstract void OnRecvAnchorEnterRoomNotice(IMRecvEnterRoomItem item);

	/**
	 * 10.9.接收观众/主播退出多人互动直播间通知
	 * @param item		接收观众/主播退出多人互动直播间信息
	 */
	public abstract void OnRecvAnchorLeaveRoomNotice(IMRecvLeaveRoomItem item);

	/**
	 * 10.10.接收观众/主播多人互动直播间视频切换通知
	 * @param roomId		直播间ID
	 * @param isAnchor		是否主播（0：否，1：是）
	 * @param userId		观众/主播ID
	 * @param playUrl		视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
	 */
	public abstract void OnRecvAnchorChangeVideoUrl(String roomId, boolean isAnchor, String userId, String[] playUrl);

	/**
	 * 10.12.接收多人互动直播间礼物通知
	 * @param item		接收多人互动直播间礼物信息
	 */
	public abstract void OnRecvAnchorGiftNotice(IMRecvHangoutGiftItem item);

	/**
	 * 10.13.接收多人互动直播间观众启动/关闭视频互动通知
	 * @param roomId
	 * @param userId
	 * @param nickname
	 * @param avatarImg
	 * @param operateType
	 * @param pushUrls
	 */
	public abstract void OnRecvHangoutInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg, IMVideoInteractiveOperateType operateType, String[] pushUrls);
	public void OnRecvHangoutInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg, int operateType, String[] pushUrls){
		OnRecvHangoutInteractiveVideoNotice(roomId, userId, nickname, avatarImg, intToIMVideoInteractiveOperateType(operateType), pushUrls);
	}

	/**
	 * 10.15.接收多人直播间文本消息通知
	 * @param roomId
	 * @param level
	 * @param fromId
	 * @param nickName
	 * @param msg
	 * @param honorUrl
	 * @param at
	 */
	public abstract void OnRecvHangoutMsg(String roomId, int level, String fromId, String nickName, String msg, String honorUrl, String[] at);
	public void OnRecvHangoutMsg(String roomId, int level, String fromId, String nickName, byte[] msg, String honorUrl, String[] at){
		//解决emoji6.0以下jni使用NewStringUTF越界读（或者crash问题）
		OnRecvHangoutMsg(roomId, level, fromId, nickName, new String(msg, Charset.forName("UTF-8")), honorUrl, at);
	}

	/**
	 * 10.16.接收进入多人互动直播间倒数通知回调
	 * @param roomId				待进入的直播间ID
	 * @param anchorId				主播ID
	 * @param leftSecond			进入直播间的剩余秒数
	 */
	public abstract void OnRecvAnchorCountDownEnterRoomNotice(String roomId, String anchorId, int leftSecond);

	/**
	 * 11.1.接收节目开播通知
	 * @param item      节目信息
	 * @param msg        消息提示文字
	 */
	public abstract void OnRecvProgramPlayNotice(IMProgramInfoItem item, String msg);

	/**
	 * 11.2.接收节目状态改变通知
	 * @param item			节目信息
	 */
	public abstract void OnRecvChangeStatusNotice(IMProgramInfoItem item);

	/**
	 * 11.3.接收无操作的提示通知
	 * @param backgroundUrl	背景图url
	 * @param msg			描述
	 */
	public abstract void OnRecvShowMsgNotice(String backgroundUrl, String msg);




}
