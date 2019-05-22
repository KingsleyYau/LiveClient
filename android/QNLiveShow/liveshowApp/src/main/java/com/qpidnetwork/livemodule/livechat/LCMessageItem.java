package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.InviteStatusType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat;
import com.qpidnetwork.livemodule.livechathttprequest.item.Record;
import com.qpidnetwork.livemodule.livechathttprequest.item.Record.ToFlag;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.Serializable;
import java.util.Comparator;

/**
 * 一条聊天消息对象
 * @author Samson Fan
 */
public class LCMessageItem implements Serializable{

	private static final long serialVersionUID = -4130453946668041520L;

	/**
	 * 消息类型
	 */
	public enum MessageType {
		Unknow,		// 未知类型
		Text,		// 文本消息 
		Warning,	// 警告消息
		Emotion,	// 高级表情
		Voice,		// 语音
		MagicIcon,  //小高级表情
		Photo,		// 私密照
		Video,		// 微视频
		System,		// 系统消息
		Custom,     //自定义消息
		Notify,     //自定义通知类型
	}
	
	/**
	 * 消息发送方向 类型
	 */
	public enum SendType {
		Unknow,		// 未知类型
		Send,		// 发出
		Recv,		// 接收
		System,		// 系统
	}
	
	/**
	 * 处理状态
	 * @author Samson Fan
	 *
	 */
	public enum StatusType {
		Unprocess,	// 未处理
		Processing,	// 处理中
		Fail,		// 发送失败
		Finish,		// 发送完成/接收成功
	}
	
	/**
	 * 消息ID
	 */
	public int msgId;
	/**
	 * 消息发送方向
	 */
	public SendType sendType;
	/**
	 * 发送者ID 
	 */
	public String fromId;
	/**
	 * 接收者ID
	 */
	public String toId;
	/**
	 * 邀请ID
	 */
	public String inviteId;
	/**
	 * 接收/发送时间
	 */
	public int createTime;
	/**
	 * 处理状态
	 */
	public StatusType statusType;
	/**
	 * 发送失败错误码存储
	 */
	public LCSendMessageErrorItem sendErrorNo;
	/**
	 * 消息类型
	 */
	public MessageType msgType;
	/**
	 * 邀请类型（当消息当做邀请时才有的属性）
	 */
	public InviteStatusType inviteType = InviteStatusType.INVITE_TYPE_CHAT;
	/**
	 * 文本item
	 */
	private LCTextItem textItem;
	/**
	 * 警告item
	 */
	private LCWarningItem warningItem;
	/**
	 * 高级表情ID
	 */
	private LCEmotionItem emotionItem;
	/**
	 * 语音item
	 */
	private LCVoiceItem voiceItem;
	/**
	 * 小高级表情item
	 */
	private LCMagicIconItem magicIconItem;
	/**
	 * 图片item
	 */
	private LCPhotoItem photoItem;
	/**
	 * 微视频item
	 */
	private LCVideoItem videoItem;
	/**
	 * 系统消息item
	 */
	private LCSystemItem systemItem;
	/**
	 * 自动邀请Item
	 */
	private LCAutoInviteItem autoInviteItem;
	/**
	 * 特殊通知类消息Item
	 */
	private LCNotifyItem notifyItem;
	/**
	 * 用户item
	 */
	private LCUserItem userItem;
	/**
	 * 服务器数据库当前时间
	 */
	static private int mDbTime = 0;
	/**
	 * 发送接收错误类型
	 * (本地用 add by Jagger 2018-11-21)
	 */
	private LiveChatClientListener.LiveChatErrType liveChatErrType;

	public LCMessageItem() {
//		clear();
		clearSelf();
	}
	
	/**
	 * 初始化
	 * @param msgId
	 * @param sendType
	 * @param fromId
	 * @param toId
	 * @param statusType
	 * @return
	 */
	public boolean init(
			int msgId
			, SendType sendType
			, String fromId
			, String toId
			, String inviteId
			, StatusType statusType)
	{
		boolean result = false;
		if (!fromId.isEmpty() 
			&& !toId.isEmpty()
			&& sendType != SendType.Unknow)
		{
			this.msgId = msgId;
			this.sendType = sendType;
			this.fromId = fromId;
			this.toId = toId;
			this.inviteId = inviteId;
			this.statusType = statusType;
			
			this.createTime = GetCreateTime();
			result = true;
		}
		return result;
	}
	
	/**
	 * 消息类型（Camshare消息或者Livechat消息），目前仅文本使用
	 * @param inviteType
	 * @return
	 */
	public void setInviteType(InviteStatusType inviteType){
		if(inviteType == InviteStatusType.INVITE_TYPE_UNKNOW){
			this.inviteType = InviteStatusType.INVITE_TYPE_CHAT;
		}else{
			this.inviteType = inviteType;
		}
	}
	
	/**
	 * 作为邀请的消息初始化
	 * @param msgId
	 * @param sendType
	 * @param fromId
	 * @param toId
	 * @param inviteId
	 * @param statusType
	 * @param inviteType
	 * @return
	 */
	public boolean initByInvite(
			int msgId
			, SendType sendType
			, String fromId
			, String toId
			, String inviteId
			, StatusType statusType
			, InviteStatusType inviteType){
		boolean result = false;
		result = init(msgId, sendType, fromId, toId, inviteId, statusType);
		if(result){
			this.inviteType = inviteType;
		}
		return result;
	}
	
	/**
	 * 获取生成时间
	 * @return
	 */
	public static int GetCreateTime()
	{
		return (int)(System.currentTimeMillis() / 1000);
	}
	
	/**
	 * 更新生成时间
	 */
	public void RenewCreateTime()
	{
		this.createTime = GetCreateTime();
	}
	
	/**
	 * 设置服务器当前数据库时间
	 * @param dbTime	数据库当前时间
	 */
	static public void SetDbTime(int dbTime)
	{
		mDbTime = dbTime;
	}
	
	/**
	 * 把服务器时间转换为手机时间
	 * @param serverTime	服务器返回的时间
	 * @return
	 */
	static public int GetLocalTimeWithServerTime(int serverTime)
	{
		int synServerTime = 0;
		if(mDbTime > 0){
			/*同步服务器时间成功*/
			int diffTime = GetCreateTime() - mDbTime;
			synServerTime = serverTime + diffTime;
		}else {
			/*同步服务器时间失败，使用默认时间*/
			synServerTime = serverTime;
		}
		return synServerTime;
	}
	
	/**
	 * 使用Record初始化MessageItem
	 * @param record
	 * @return
	 */
	public boolean InitWithRecord(
			int msgId
			, String selfId
			, String userId
			, String inviteId
			, Record record
			, LCEmotionManager emotionMgr
			, LCVoiceManager voiceMgr
			, LCPhotoManager photoMgr
			, LCVideoManager videoMgr
			, LCMagicIconManager magicIconMgr)
	{
		boolean result = false;
		this.msgId = msgId;
		this.toId = (record.toflag == ToFlag.Receive ? selfId : userId);
		this.fromId = (record.toflag == ToFlag.Receive ? userId : selfId);
		this.inviteId = inviteId;
		this.sendType = (record.toflag == ToFlag.Receive ? SendType.Recv : SendType.Send);
		this.statusType = StatusType.Finish;
		this.createTime = GetLocalTimeWithServerTime(record.adddate);
		
		switch(record.messageType) {
		case Text: {
			if (null != record.textMsg) 
			{
				LCTextItem textItem = new LCTextItem();
				textItem.init(record.textMsg, this.sendType);
				setTextItem(textItem);
				result = true;
			}
		}break;
		case Invite: {
			if (null != record.inviteMsg)
			{
				LCTextItem textItem = new LCTextItem();
				textItem.init(record.inviteMsg, this.sendType);
				setTextItem(textItem);
				result = true;
			}
		}break;
		case Warning: {
			if (null != record.warningMsg)
			{
				LCWarningItem warningItem = new LCWarningItem();
				warningItem.init(record.warningMsg);
				setWarningItem(warningItem);
				result = true;
			}
		}break;
		case Emotion: {
//			if (null != record.emotionId)
//			{
//				LCEmotionItem emotionItem = emotionMgr.getEmotion(record.emotionId);
//				setEmotionItem(emotionItem);
//				result = true;
//			}
		}break;
		case MagicIcon: {
			if (null != record.magicIconId)
			{
				LCMagicIconItem magicIconItem = magicIconMgr.getMagicIcon(record.magicIconId);
				setMagicIconItem(magicIconItem);
				result = true;
			}
		}break;
		case Photo: {
			if (null != record.photoId)
			{
				LCPhotoItem photoItem = new LCPhotoItem();
				// 男士端发送的为已付费
				boolean photoCharge = (this.sendType == SendType.Send ? true : record.photoCharge);
				photoItem.init(
						photoMgr
						, record.photoId
						, ""
						, record.photoDesc
						, photoCharge);
				setPhotoItem(photoItem);
				result = true;
			}
		}break;
		case Voice: {
			if (null != record.voiceId)
			{
				LCVoiceItem voiceItem = new LCVoiceItem();
				voiceItem.init(record.voiceId
						, voiceMgr.getVoicePath(record.voiceId, record.voiceType)
						, record.voiceTime, record.voiceType
						, ""
						, true);
				setVoiceItem(voiceItem);
				result = true;
			}
		}break;
		case Video: {
			if (null != record.videoId)
			{
				LCVideoItem videoItem = new LCVideoItem();
				videoItem.init(
						record.videoId
						, record.videoSendId
						, record.videoDesc
						, videoMgr.getVideoPhotoPath(userId, record.videoId, inviteId, LCRequestJniLiveChat.VideoPhotoType.Big)
						, videoMgr.getVideoPhotoPath(userId, record.videoId, inviteId, LCRequestJniLiveChat.VideoPhotoType.Default)
						, ""
						, videoMgr.getVideoPath(userId, record.videoId, inviteId)
						, record.videoCharge);
				setVideoItem(videoItem);
				result = true;
			}
		}break;
		default: {
			Log.e("livechat", String.format("%s::%s() unknow message type", "LCMessageItem", "InitWithRecord"));
		}break;
		}
		return result;
	}
	
	public void setVoiceItem(LCVoiceItem theVoiceItem) {
		if (msgType == MessageType.Unknow
				&& theVoiceItem != null) 
		{
			voiceItem = theVoiceItem;
			msgType = MessageType.Voice;
		}
	}
	public LCVoiceItem getVoiceItem() {
		return voiceItem;
	}
	
	public void setPhotoItem(LCPhotoItem thePhotoItem) {
		if (msgType == MessageType.Unknow
				&& thePhotoItem != null) 
		{
			photoItem = thePhotoItem;
			msgType = MessageType.Photo;
		}
	}
	public LCPhotoItem getPhotoItem() {
		return photoItem;
	}
	
	public void setVideoItem(LCVideoItem theVideoItem) {
		if (msgType == MessageType.Unknow
				&& theVideoItem != null) 
		{
			videoItem = theVideoItem;
			msgType = MessageType.Video;
		}
	}
	public LCVideoItem getVideoItem() {
		return videoItem;
	}
	
	public void setTextItem(LCTextItem theTextItem) {
		if (msgType == MessageType.Unknow
				&& theTextItem != null) 
		{
			textItem = theTextItem;
			msgType = MessageType.Text;
		}
	}
	public LCTextItem getTextItem() {
		return textItem;
	}
	
	public void setWarningItem(LCWarningItem theWarningItem) {
		if (msgType == MessageType.Unknow
				&& theWarningItem != null) 
		{
			warningItem = theWarningItem;
			msgType = MessageType.Warning;
		}
	}
	public LCWarningItem getWarningItem() {
		return warningItem;
	}
	
	public void setEmotionItem(LCEmotionItem theEmotionItem) {
		if (msgType == MessageType.Unknow
				&& theEmotionItem != null) 
		{
			emotionItem = theEmotionItem;
			msgType = MessageType.Emotion;
		}
	} 
	public LCEmotionItem getEmotionItem() {
		return emotionItem;
	}
	
	public void setMagicIconItem(LCMagicIconItem magicIconItem) {
		if (msgType == MessageType.Unknow
				&& magicIconItem != null) 
		{
			this.magicIconItem = magicIconItem;
			msgType = MessageType.MagicIcon;
		}
	} 
	public LCMagicIconItem getMagicIconItem() {
		return magicIconItem;
	}
	
	public void setAutoInviteItem(LCAutoInviteItem autoInviteItem) {
		this.autoInviteItem = autoInviteItem;
	}
	
	public LCAutoInviteItem getAutoInviteItem() {
		return autoInviteItem;
	}
	
	public void setNotifyItem(LCNotifyItem notifyItem){
		if (msgType == MessageType.Unknow
				&& notifyItem != null) 
		{
			this.notifyItem = notifyItem;
			msgType = MessageType.Notify;
		}
	}
	
	public LCNotifyItem getNotifyItem() {
		return notifyItem;
	}
	
	public void setSystemItem(LCSystemItem theSystemItem) {
		if (msgType == MessageType.Unknow
				&& theSystemItem != null) 
		{
			systemItem = theSystemItem;
			msgType = MessageType.System;
		}
	}
	public LCSystemItem getSystemItem() {
		return systemItem;
	}
	
	public void setUserItem(LCUserItem theUserItem) {
		userItem = theUserItem;
	}
	public LCUserItem getUserItem() {
		return userItem;
	}

	public LiveChatClientListener.LiveChatErrType getLiveChatErrType() {
		return liveChatErrType;
	}

	public void setLiveChatErrType(LiveChatClientListener.LiveChatErrType liveChatErrType) {
		this.liveChatErrType = liveChatErrType;
	}
	
	public void clearSelf()
	{
		msgId = 0;
		sendType = SendType.Unknow;
		fromId = "";
		toId = "";
		inviteId = "";
		createTime = 0;
		statusType = StatusType.Unprocess;
		msgType = MessageType.Unknow;
		inviteType = InviteStatusType.INVITE_TYPE_CHAT;
		textItem = null;
		warningItem = null;
		emotionItem = null;
		magicIconItem = null;
		voiceItem = null;
		photoItem = null;
		videoItem = null;
		systemItem = null;
		autoInviteItem = null;
		notifyItem = null;
		userItem = null;
	}
	
	/**
	 * 重置所有成员变量
	 */
	public void clear() 
	{
//		msgId = 0;
//		sendType = SendType.Unknow;
//		fromId = "";
//		toId = "";
//		inviteId = "";
//		createTime = 0;
//		statusType = StatusType.Unprocess;
//		msgType = MessageType.Unknow;
//		textItem = null;
//		warningItem = null;
//		emotionItem = null;
//		voiceItem = null;
//		photoItem = null;
//		videoItem = null;
//		systemItem = null;
//		userItem = null;
	}
	
	
	static public Comparator<LCMessageItem> getComparator() {
		Comparator<LCMessageItem> comparator = new Comparator<LCMessageItem>() {
			@Override
			public int compare(LCMessageItem lhs, LCMessageItem rhs) {
				// TODO Auto-generated method stub
				int result = -1;
				if (lhs.createTime == rhs.createTime) {
					// 判断msgId
					if (lhs.msgId == rhs.msgId) {
						result = 0;
					}
					else {
						result = lhs.msgId > rhs.msgId ? 1 : -1;
					}
				}
				else {
					result = lhs.createTime > rhs.createTime ? 1 : -1;
				}

				return result;
			}
		};
		return comparator;
	}
	
	private static final int CAMSHARE_VALID_DURATION = 60;
	/**
	 * 是否是有效的CamShare邀请
	 * @return
	 */
	public boolean isValidCamshareInvite(){
		boolean isValidCamInvite = false;
		int duration = (int)System.currentTimeMillis()/1000 - createTime;
		if(inviteType == InviteStatusType.INVITE_TYPE_CAMSHARE
				&& duration < CAMSHARE_VALID_DURATION){
			isValidCamInvite = true;
		}
		return isValidCamInvite;
	}
}
