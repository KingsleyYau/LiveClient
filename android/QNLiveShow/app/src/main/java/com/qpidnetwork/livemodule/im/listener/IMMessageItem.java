package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

/**
 * IM聊天基本信息存储
 * @author Hunter Mun
 * @since 2017-6-1
 */
public class IMMessageItem implements Serializable{

	private static final int INVALID_MESSAGE_ID = -1;
	private static final int INVALID_LEVEL_ID = -1;

	/**
	 * 消息类型，用于界面显示
	 */
	public enum MessageType{
		Unknown,
		Normal,			//普通文本聊天
		Gift,			//礼物或大礼物
		Barrage,		//弹幕
		FollowHost,			//关注
		RoomIn			//fans进入房间
	}

	public MessageType msgType;	//消息类型
	public int msgId;				//消息本地Id(用于消息本地唯一性)
	public String roomId;			//消息所属房间Id;
	public String userId;			//消息发送人Id
	public String nickName;       	//消息发送人名字
	public int level;				//消息发送人等级

	/* 普通文本、弹幕消息体 */
	public IMTextMessageContent textMsgContent;

	/* 礼物、大礼物消息体 */
	public IMGiftMessageContent giftMsgContent;
	
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
		level = INVALID_LEVEL_ID;
		textMsgContent = null;
		giftMsgContent = null;
	}

	/**
	 * 消息构建
	 * @param roomId
	 * @param msgId
	 * @param userId
	 * @param nickName
	 * @param level
	 * @param msgType
	 * @param textContent
	 * @param giftContent
	 */
	public IMMessageItem(String roomId,
						 int msgId,
						 String userId,
						 String nickName,
						 int level,
						 MessageType msgType,
						 IMTextMessageContent textContent,
						 IMGiftMessageContent giftContent){
		this.roomId = roomId;
		this.msgId = msgId;
		this.userId = userId;
		this.nickName = nickName;
		this.level = level;
		this.msgType = msgType;
		this.textMsgContent = textContent;
		this.giftMsgContent = giftContent;
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
		this.level = msgItem.level;
		this.textMsgContent = msgItem.textMsgContent;
		this.giftMsgContent = msgItem.giftMsgContent;
	}

}
