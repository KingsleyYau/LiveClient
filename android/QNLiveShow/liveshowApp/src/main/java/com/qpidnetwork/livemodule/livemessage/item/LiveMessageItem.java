package com.qpidnetwork.livemodule.livemessage.item;

import com.qpidnetwork.livemodule.im.listener.IMClientListener;

import java.io.Serializable;

public class LiveMessageItem {

	/**
	 * 直播消息类型
	 */
	public enum LMMessageType {
		Unknow,		// 未知类型
		Text,		// 私信消息
		System,		// 系统警告
		Time,		// 时间提示
		Warning 	// 警告提示

	}

	/**
	 * 直播消息收发方向
	 * @author Hunter Mun
	 *
	 */
	public enum LMSendType {
		Unknow,			// 未知
		Send,			// 发出方向
		Recv			// 接收方向
	}


	/**
	 * 直播消息处理状态
	 * @author Hunter Mun
	 *
	 */
	public enum LMMessageStatus {
		Unprocess,				// 未处理
		Processing,				// 处理中
		Fail,					// 发送失败
		Finish					// 发送完成/接收成功
	}

	public LiveMessageItem(){

	}

	/**
	 * 直播消息item
	 * @author Hunter Mun
	 *
	 * @param sendMsgId 	本地消息ID （用于发送时才有的，当发送成功后，返回有msgId，本地消息ID设置为0）
	 * @param msgId			消息ID
	 * @param sendType		消息发送方向（Unknow：未知类型， Send：发出， Recv：接收）
	 * @param fromId		发送者ID
	 * @param toId			接收者ID
	 * @param createTime	接收/发送时间
	 * @param statusType    直播messageHandle的类型（Unprocess： 未处理， Processing： 处理中， Fail： 发送失败， Finish：// 发送完成/接收成功）
	 * @param msgType		直播messge的类型（Unknow：未知类型，Text：私信类型信息）
	 * @param sendErr       发送的错误码
	 * @param userItem	    联系人信息
	 * @param privateItem	私信文本信息
	 * @param systemItem	私信系统通知
	 * @param warningItem	私信警告
	 *
	 */
	public LiveMessageItem(
							int sendMsgId,
							int msgId,
							int sendType,
							String fromId,
                            String toId,
                            int createTime,
                            int statusType,
                            int msgType,
							int sendErr,
							LMPrivateMsgContactItem userItem,
							LMPrivateMsgItem privateItem,
							LMSystemNoticeItem systemItem,
							LMWarningItem warningItem,
							LMTimeMsgItem timeMsgItem
			){
		this.sendMsgId = sendMsgId;
		this.msgId = msgId;
		if( sendType < 0 || sendType >= LMSendType.values().length ) {
			this.sendType = LMSendType.Unknow;
		} else {
			this.sendType = LMSendType.values()[sendType];
		}
		this.fromId = fromId;
		this.toId = toId;
		this.createTime = createTime;
		if( statusType < 0 || statusType >= LMMessageStatus.values().length ) {
			this.statusType = LMMessageStatus.Unprocess;
		} else {
			this.statusType = LMMessageStatus.values()[statusType];
		}
		if( msgType < 0 || msgType >= LMMessageType.values().length ) {
			this.msgType = LMMessageType.Unknow;
		} else {
			this.msgType = LMMessageType.values()[msgType];
		}
		if( sendErr < 0 || sendErr >= IMClientListener.LCC_ERR_TYPE.values().length ) {
			this.sendErr = IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS;
		} else {
			this.sendErr = IMClientListener.LCC_ERR_TYPE.values()[sendErr];
		}
		this.userItem = userItem;
		this.privateItem = privateItem;
		this.systemItem = systemItem;
		this.warningItem = warningItem;
		this.timeMsgItem = timeMsgItem;
	}

	public int sendMsgId;
	public int msgId;
	public LMSendType sendType;
	public String fromId;
	public String toId;
	public int createTime;
	public LMMessageStatus statusType;
	public LMMessageType msgType;
	public IMClientListener.LCC_ERR_TYPE sendErr;
	public LMPrivateMsgContactItem userItem;
	public LMPrivateMsgItem privateItem;
	public LMSystemNoticeItem systemItem;
	public LMWarningItem warningItem;
	public LMTimeMsgItem timeMsgItem;


	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("LiveMessageItem[");
		sb.append("sendMsgId:");
		sb.append(sendMsgId);
		sb.append(" msgId:");
		sb.append(msgId);
		sb.append(" sendType:");
		sb.append(sendType);
		sb.append(" fromId:");
		sb.append(fromId);
		sb.append(" toId:");
		sb.append(toId);
		sb.append(" createTime:");
		sb.append(createTime);
		sb.append(" statusType:");
		sb.append(statusType);
		sb.append(" msgType:");
		sb.append(msgType);
		sb.append(" sendErr:");
		sb.append(sendErr);
		if (userItem != null) {
			sb.append(" userItem:");
			sb.append(userItem);
		}
		if (privateItem != null) {
			sb.append(" privateItem:");
			sb.append(privateItem);
		}
		if (systemItem != null) {
			sb.append(" systemItem:");
			sb.append(systemItem);
		}
		if (warningItem != null) {
			sb.append(" warningItem:");
			sb.append(warningItem);
		}
		if (timeMsgItem != null) {
			sb.append(" timeMsgItem:");
			sb.append(timeMsgItem);
		}
		sb.append("]");
		return sb.toString();
	}

}
