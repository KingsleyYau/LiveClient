package com.qpidnetwork.livemodule.im.listener;

import android.text.TextUtils;

import java.io.Serializable;

/**
 * IM聊天基本信息存储
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class IMMessageItem implements Serializable{

	private static final int INVALID_MESSAGE_ID = -1;
	private static final int INVALID_LEVEL_ID = -1;
	private static final long serialVersionUID = 4343605830896620012L;

	/**
	 * 消息类型，用于界面显示
	 */
	public enum MessageType{
		Unknown,
		Normal,				//普通文本聊天
		Gift,				//礼物或大礼物
		Barrage,			//弹幕
		FollowHost,			//关注
		RoomIn,				//fans进入房间
		SysNotice,			//系统公告
		TalentRecommand,	//才艺推荐
		AnchorRecommand,	//多人互动主播推荐
		AnchorKnock,		//多人互动，主播敲门
		Voucher         	//试聊卷
	}

	public MessageType msgType;	//消息类型
	public int msgId;				//消息本地Id(用于消息本地唯一性)
	public String roomId;			//消息所属房间Id;
	public String userId;			//消息发送人Id
	public String nickName;       	//消息发送人名字
	public String honorUrl;			//勋章Url
	public int level;				//消息发送人等级
	//多人互动新增
	public boolean isPrivate = false; 		//是否私密发送
	public String[] toUids;					//礼物接收群组

	/* 普通文本、弹幕消息体 */
	public IMTextMessageContent textMsgContent;

	/* 礼物、大礼物消息体 */
	public IMGiftMessageContent giftMsgContent;

	/* 系统公告 */
	public IMSysNoticeMessageContent sysNoticeContent;

	/* 推荐主播信息 */
	public IMHangoutRecommendItem hangoutRecommendItem;

	/* 主播敲门信息 */
	public IMRecvKnockRequestItem hangoutKnockRequestItem;

	/* 试聊卷消息内容 */
	public IMVoucherMessageContent voucherMessageContent;
	
	public IMMessageItem(){
		msgType = MessageType.Unknown;
		msgId = INVALID_MESSAGE_ID;
		level = INVALID_LEVEL_ID;
	}

	public void clear(){
		msgType = MessageType.Unknown;
		msgId = INVALID_MESSAGE_ID;
		roomId = "";
		userId = "";
		nickName = "";
		honorUrl = "";
		level = INVALID_LEVEL_ID;
		textMsgContent = null;
		giftMsgContent = null;
		isPrivate = false;
		toUids = null;
	}

	/**
	 * 消息构建
	 * @param roomId
	 * @param msgId
	 * @param userId
	 * @param nickName
	 * @param honorUrl
	 * @param level
	 * @param msgType
	 * @param textContent
	 * @param giftContent
	 */
	public IMMessageItem(String roomId,
						 int msgId,
						 String userId,
						 String nickName,
						 String honorUrl,
						 int level,
						 MessageType msgType,
						 IMTextMessageContent textContent,
						 IMGiftMessageContent giftContent) {
		this.roomId = roomId;
		this.msgId = msgId;
		this.userId = userId;
		this.nickName = nickName;
		this.honorUrl = honorUrl;
		this.level = level;
		this.msgType = msgType;
		this.textMsgContent = textContent;
		this.giftMsgContent = giftContent;
	}

	/**
	 * 构造多人互动直播消息体
	 * @param roomId
	 * @param msgId
	 * @param userId
	 * @param nickName
	 * @param honorUrl
	 * @param level
	 * @param isPrivate
	 * @param toUids
	 * @param msgType
	 * @param textContent
	 * @param giftContent
	 */
	public IMMessageItem(String roomId,
						 int msgId,
						 String userId,
						 String nickName,
						 String honorUrl,
						 int level,
						 boolean isPrivate,
						 String[] toUids,
						 MessageType msgType,
						 IMTextMessageContent textContent,
						 IMGiftMessageContent giftContent){
		this.roomId = roomId;
		this.msgId = msgId;
		this.userId = userId;
		this.nickName = nickName;
		this.honorUrl = honorUrl;
		this.level = level;
		this.isPrivate = isPrivate;
		this.toUids = toUids;
		this.msgType = msgType;
		this.textMsgContent = textContent;
		this.giftMsgContent = giftContent;
	}

	public IMMessageItem(int msgId, IMRecvHangoutGiftItem item){
		String[] toUids = null;
		if(!TextUtils.isEmpty(item.toUid)){
			toUids = new String[]{item.toUid};
		}
		IMGiftMessageContent msgContent = new IMGiftMessageContent(item.giftId, item.giftName, item.giftNum,
				item.isMultiClick, item.multiClickStart, item.multiClickEnd, item.multiClickId,item.isPrivate);
		this.roomId = item.roomId;
		this.msgId = msgId;
		this.userId = item.fromId;
		this.nickName = item.nickName;
		this.honorUrl = "";
		this.level = -1;
		this.isPrivate = item.isPrivate;
		this.toUids = toUids;
		this.msgType = IMMessageItem.MessageType.Gift;
		this.textMsgContent = null;
		this.giftMsgContent = msgContent;
	}

	public IMMessageItem(int msgId, IMHangoutMsgItem item){
		this.roomId = item.roomId;
		this.msgId = msgId;
		this.userId = item.fromId;
		this.nickName = item.nickName;
		this.honorUrl = "";
		this.level = -1;
		this.isPrivate = false;
		this.toUids = item.at;
		this.msgType = IMMessageItem.MessageType.Normal;
		this.textMsgContent = new IMTextMessageContent(item.msg);
		this.giftMsgContent = null;
	}

	public IMMessageItem(String roomId, int msgId, String honorUrl,MessageType msgType, IMSysNoticeMessageContent sysNoticeContent){
		this.roomId = roomId;
		this.msgId = msgId;
		this.honorUrl = honorUrl;
		this.msgType = msgType;
		this.sysNoticeContent = sysNoticeContent;
	}

	public IMMessageItem(String roomId,
						 int msgId,
						 MessageType msgType,
						 IMHangoutRecommendItem hangoutRecommendItem){
		this.roomId = roomId;
		this.msgId = msgId;
		this.msgType = msgType;
		this.hangoutRecommendItem = hangoutRecommendItem;
	}

	public IMMessageItem(String roomId,
						 int msgId,
						 MessageType msgType,
						 IMRecvKnockRequestItem hangoutKnockRequestItem){
		this.roomId = roomId;
		this.msgId = msgId;
		this.msgType = msgType;
		this.hangoutKnockRequestItem = hangoutKnockRequestItem;
	}

	/**
	 * 试聊卷
	 * @param roomId
	 * @param roomPrice		直播间资费
	 * @param useCoupon  	试聊卷分钟数
	 */
	public IMMessageItem(String roomId,
						 int msgId,
						 double roomPrice,
						 int useCoupon){
		this.roomId = roomId;
		this.msgId = msgId;
		this.msgType = MessageType.Voucher;
		this.voucherMessageContent = new IMVoucherMessageContent(roomPrice, useCoupon);
	}

	/**
	 * 拷贝到本消息体
	 * @param msgItem
	 */
	public void copy(IMMessageItem msgItem){
		this.msgType = msgItem.msgType;
		this.msgId = msgItem.msgId;
		this.roomId = msgItem.roomId;
		this.userId = msgItem.userId;
		this.nickName = msgItem.nickName;
		this.honorUrl = msgItem.honorUrl;
		this.level = msgItem.level;
		this.textMsgContent = msgItem.textMsgContent;
		this.giftMsgContent = msgItem.giftMsgContent;
		this.isPrivate = msgItem.isPrivate;
		this.toUids = msgItem.toUids;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMMessageItem[");
		sb.append("honorUrl:");
		sb.append(honorUrl);
		sb.append("]");
		return super.toString();
	}
}
