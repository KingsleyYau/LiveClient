package com.qpidnetwork.livemodule.livechat;

import android.text.TextUtils;
import android.util.Log;

import com.qpidnetwork.livemodule.livechat.LCMessageItem.MessageType;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.SendType;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.StatusType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.ClientType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserSexType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserStatusType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TalkEventType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TalkMsgType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatSessionInfoItem;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;

/**
 * LiveChat的 User 对象
 * @author Samson Fan
 */
public class LCUserItem implements Serializable{

	private static final long serialVersionUID = -2059118989300697623L;
	/**
	 * 用户ID
	 */
	public String userId;
	/**
	 * 用户名称
	 */
	public String userName;
	/**
	 * 用户性别
	 */
	public UserSexType sexType;
	/**
	 * 用户使用的客户端类型
	 */
	public ClientType clientType;
	/**
	 * 用户在线状态
	 */
	public UserStatusType statusType;
	/**
	 * 与用户的当前聊天状态
	 */
	public ChatType chatType;
	/**
	 * 当前用户使用服务类型
	 */
	public ChatServiceType serviceType;
	/**
	 * Cam是否打开
	 */
	public boolean isCamOpen;
	/**
	 * 邀请ID（仅InChat状态）
	 */
	public String inviteId;
	/**
	 * 是否正在尝试发送（可能正在检测是否可聊天，包括检测是否有试聊券，是否可使用，是否有足够点数等)
	 */
	public boolean tryingSend;
	/**
	 * 排序分值（用于邀请排序）
	 */
	public int order;
	/**
	 * 待发送消息
	 */
	public ArrayList<LCMessageItem> sendMsgList;
	/**
	 * 聊天记录列表
	 */
	protected ArrayList<LCMessageItem> msgList;
	
	/**
	 * 聊天状态
	 */
	public enum ChatType {
		InChatCharge, 		// 收费(聊天中)
		InChatUseTryTicket, // 试聊券(聊天中)
		InChatPause,        //暂停状态(聊天中)
		Invite, 		// 女邀请男
		ManInvite,		// 男士已经发出邀请 
		Other, 			// 其它
	}
	
	/**
	 * 当前使用服务类型
	 */
	public enum ChatServiceType{
		LiveChat,        //正在使用livechat服务
		Camshare         //当前正在使用Camshare服务
	}

	public LCUserItem() {
		userId = "";
		userName = "";
		sexType = UserSexType.USER_SEX_FEMALE;
		clientType = ClientType.CLIENT_ANDROID;
		statusType = UserStatusType.USTATUS_OFFLINE_OR_HIDDEN;
		chatType = ChatType.Other;
		inviteId = "";
		tryingSend = false;
		order = 0;
		msgList = new ArrayList<LCMessageItem>();
		sendMsgList = new ArrayList<LCMessageItem>();
		isCamOpen = false;
	}

	/**
	 * 获取聊天记录列表（已按时间排序）
	 */
	public final ArrayList<LCMessageItem> getMsgList() {
		return msgList;
	}
	
	/**
	 * 获取当前会话消息列表
	 * @return
	 */
	public ArrayList<LCMessageItem> getCurrentSessionMsgList(){
		ArrayList<LCMessageItem> sessionMsgList = new ArrayList<LCMessageItem>();
		synchronized (msgList) {
			if(msgList.size() > 0){
				for(int i= msgList.size()-1; i >= 0; i--){
					String msgInviteId = msgList.get(i).inviteId;
					if(!TextUtils.isEmpty(msgInviteId)
							&& !msgInviteId.equals(inviteId)){
						break;
					}else{
						sessionMsgList.add(msgList.get(i));
					}
				}
			}
		}
		//按照时间排序
		Collections.sort(sessionMsgList, LCMessageItem.getComparator());
		return sessionMsgList;
	}
	
	/**
	 * 获取指定会话的消息列表
	 * @param inviteId
	 * @return
	 */
	public ArrayList<LCMessageItem> getMsglistByInviteId(String inviteId){
		ArrayList<LCMessageItem> messageList = new ArrayList<LCMessageItem>();
		synchronized (msgList) {
			for(LCMessageItem item : msgList){
				if(item.inviteId.equals(inviteId)){
					messageList.add(item);
				}
			}
		}
		return messageList;
	}
	
	/**
	 * 获取指定CamShare会话的消息列表(过滤掉提示及系统消息等)
	 * @param inviteId
	 * @return
	 */
	public ArrayList<LCMessageItem> getCamShareFilterMsglistByInviteId(String inviteId){
		ArrayList<LCMessageItem> messageList = new ArrayList<LCMessageItem>();
		synchronized (msgList) {
			for(LCMessageItem item : msgList){
				if(item.inviteId.equals(inviteId)
						&&(item.msgType == MessageType.Text
						|| item.msgType == MessageType.MagicIcon
						|| item.msgType == MessageType.Emotion
						|| item.msgType == MessageType.Photo
						|| item.msgType == MessageType.Voice
						|| item.msgType == MessageType.Video)){
					messageList.add(item);
				}
			}
		}
		return messageList;
	}
	
	/**
	 * 跟新Cam是否打开
	 * @param isCamOpen
	 */
	public void updateCamstatus(boolean isCamOpen){
		if(isCamOpen){
			//Cam 打开时用户一定在线
			statusType = UserStatusType.USTATUS_ONLINE;
		}
		this.isCamOpen = isCamOpen;
	}
	
	/**
	 * 女士Cam是否打开
	 * @return
	 */
	public boolean isCamOpen(){
		boolean isOpen = false;
		if(statusType == UserStatusType.USTATUS_ONLINE
				&& isCamOpen){
			isOpen = true;
		}
		return isOpen;
	}

	/**
	 * 排序插入聊天记录
	 * @param item
	 * @return
	 */
	public boolean insertSortMsgList(LCMessageItem item) {
		boolean result = false;
		synchronized (msgList) {
			result = msgList.add(item);
			if (result) {
				Collections.sort(msgList, LCMessageItem.getComparator());
			}
		}
		
		if (result) {
			item.setUserItem(this);
		}
		return result;
	}
	
	/**
	 * 删除聊天记录
	 * @param item	消息item
	 * @return
	 */
	public boolean removeSortMsgList(LCMessageItem item) {
		boolean result = false;
		if (null != item) {
			synchronized (msgList) {
				result = msgList.remove(item);
				if (result) {
					item.setUserItem(null);
					Collections.sort(msgList, LCMessageItem.getComparator());
				}
			}
		}
		return result;
	}
	
	/**
	 * 清除所有聊天记录
	 */
	public void clearMsgList() {
		synchronized (msgList) {
			for (Iterator<LCMessageItem> iter = msgList.iterator(); iter.hasNext(); ) {
				LCMessageItem item = iter.next();
				item.clear();
			}
			msgList.clear();
		}
	}
	
	/**
	 * 清除指定会话的消息列表
	 * @param inviteId
	 */
	public void clearSpecifiedMsgList(String inviteId){
		if(!TextUtils.isEmpty(inviteId)){
			ArrayList<LCMessageItem> tempList = new ArrayList<LCMessageItem>();
			synchronized (msgList) {
				for(LCMessageItem item : msgList){
					if(!TextUtils.isEmpty(item.inviteId)
							&& item.inviteId.equals(inviteId)){
						tempList.add(item);
					}
				}
				msgList.removeAll(tempList);
			}
		}
	}
	
	/**
	 * 清除所有已完成的聊天记录
	 */
	public void clearFinishedMsgList() {
		ArrayList<LCMessageItem> tempList = new ArrayList<LCMessageItem>();
		synchronized (msgList) {
			for (Iterator<LCMessageItem> iter = msgList.iterator(); iter.hasNext(); ) {
				LCMessageItem item = iter.next();
				if (item.statusType == StatusType.Finish) {
					tempList.add(item);
					item.clear();
				}
			}
			msgList.removeAll(tempList);
		}
	}
	
	/**
	 * 根据消息ID获取LCMessageItem
	 * @param msgId	消息ID
	 * @return
	 */
	public LCMessageItem getMsgItemWithId(int msgId) {
		LCMessageItem item = null;
		synchronized (msgList) {
			for (Iterator<LCMessageItem> iter = msgList.iterator(); iter.hasNext(); ) {
				LCMessageItem msgItem = iter.next();
				if (msgItem.msgId == msgId) {
					item = msgItem;
					break;
				}
			}
		}
		return item;
	}
	
	/**
	 * 设置聊天状态
	 * @param eventType		聊天事件	
	 */
	public void setChatTypeWithEventType(TalkEventType eventType) {
		switch (eventType) {
		case EndTalk:
			this.chatType = ChatType.Other;
			break;
		case StartCharge:
			if (this.chatType != ChatType.InChatCharge
				&& this.chatType != ChatType.InChatUseTryTicket)
			{
				this.chatType = ChatType.InChatCharge;
			}
			break;
		case StopCharge:
			this.chatType = ChatType.InChatPause;
			break;
		case NoMoney:
		case VideoNoMoney:
			this.chatType = ChatType.InChatPause;
			break;
		case TargetNotFound:
			this.chatType = ChatType.Other;
			break;
		default:
			break;
		}
	}
	
	/**
	 * 设置聊天状态 
	 * @param msgType	聊天消息类型
	 */
	public void setChatTypeWithTalkMsgType(boolean charge, TalkMsgType msgType) {
		this.chatType = getChatTypeWithTalkMsgType(charge, msgType);
	}
	
	/**
	 * 根据 TalkMsgType 获取聊天状态
	 * @param charge	是否已付费
	 * @param msgType	消息收费类型
	 * @return
	 */
	public static ChatType getChatTypeWithTalkMsgType(boolean charge, TalkMsgType msgType)
	{
		ChatType chatType = ChatType.Other;
		switch(msgType) {
		case TMT_FREE:
			if (!charge) {
				// TMT_FREE 及 charge=false，则为邀请
				chatType = ChatType.Invite;
			}
			else {
				// charge=true，则为InChatCharge
				chatType = ChatType.InChatCharge;
			}
			break;
		case TMT_CHARGE:
			chatType = ChatType.InChatCharge;
			break;
		case TMT_CHARGE_FREE:
			chatType = ChatType.InChatUseTryTicket;
			break;
		default:
			chatType = ChatType.Other;
			break;
		}
		return chatType;
	}
	
	/**
	 * 获取对方发出的最后一条聊天消息
	 * @return
	 */
	public LCMessageItem getTheOtherLastMessage()
	{
		LCMessageItem item = null;
		synchronized(msgList) {
			if (msgList.size() > 0) 
			{
				for (int i = msgList.size() - 1; i >= 0 ; i--) 
				{
					LCMessageItem tempItem = msgList.get(i);
					if (tempItem.sendType == SendType.Recv) {
						item = tempItem;
						break;
					}
				}
			}
		}
		return item;
	}
	
	/**
	 * 获取我发出的最后一条聊天消息
	 * @return
	 */
	public LCMessageItem getTheSendLastMessage()
	{
		LCMessageItem item = null;
		synchronized(msgList) {
			if (msgList.size() > 0) 
			{
				for (int i = msgList.size() - 1; i >= 0 ; i--) 
				{
					LCMessageItem tempItem = msgList.get(i);
					if (tempItem.sendType == SendType.Send) {
						item = tempItem;
						break;
					}
				}
			}
		}
		return item;
	}
	
	/**
	 * 获取消息列表最后一条消息
	 * @return
	 */
	public LCMessageItem getLastMessage(){
		LCMessageItem item = null;
		synchronized(msgList) {
			if (msgList!= null && msgList.size() > 0) 
			{
				item = msgList.get(msgList.size() - 1);
			}
		}
		return item;
	}
	
	/**
	 * 结束聊天处理
	 */
	public void endTalk() {
		inviteId = "";
		chatType = ChatType.Other;
		serviceType = ChatServiceType.LiveChat;
		clearMsgList();
	}
	
	/**
	 * 获取会话信息返回，根据会话信息更新本地会话状态
	 */
	public void updateChatStatusBySession(LiveChatSessionInfoItem item){
		LCMessageItem msgItem = getLastMessage();
		if(item.charget || item.freeChat){
			if(item.chatTime > 0 
					|| (msgItem != null && msgItem.createTime < 5*60*1000)){
				if(item.charget){
					chatType = ChatType.InChatCharge;
				}else{
					chatType = ChatType.InChatUseTryTicket;
				}
			}else{
				chatType = ChatType.InChatPause;
			}
		}else{
			chatType = ChatType.Other;
		}
		inviteId = item.inviteId;
		if(item.serviceType == 1){ 
			serviceType = ChatServiceType.Camshare;
		}else{
			serviceType = ChatServiceType.LiveChat;
		}
	}
	
	/**
	 * 正在扣费会话中
	 * @return
	 */
	public boolean isInCharging(){
		boolean result = false;
		if(chatType == ChatType.InChatCharge
				|| chatType == ChatType.InChatUseTryTicket){
			result = true;
		}
		return result;
	}

	/**
	 * 是否处于男士邀请状态
	 * @return
	 */
	public boolean isInManInvite(){
 		return chatType == ChatType.ManInvite;
	}

	/**
	 * 是否处于女士邀请状态
	 * @return
	 */
	public boolean isInLadyInvite(){
		return chatType == ChatType.Invite;
	}

	/**
	 * 男士邀请可取消状态判断（1.处于男士邀请状态 2.第一条邀请信息据现在已超过1分钟）
	 * @return
	 */
	public boolean isInManInviteCanCancel(){
		boolean result = false;
		if(chatType == ChatType.ManInvite){
			int latestWomanMsgIndex = -1;
			if(msgList != null && msgList.size() > 0){
				for(int i = (msgList.size() - 1); i >= 0; i--){
					if(msgList.get(i).sendType == SendType.Recv){
						latestWomanMsgIndex = i;
						break;
					}
				}
			}
			if(latestWomanMsgIndex < msgList.size() - 1){
				LCMessageItem firstInviteMsgItem = null;
				if(latestWomanMsgIndex < 0 ){
					//没有女士消息，从第一条消息开始查找
					latestWomanMsgIndex = 0;
				}
				for(int j = latestWomanMsgIndex; j < msgList.size(); j++){
					if(msgList.get(j).sendType == SendType.Send){
						firstInviteMsgItem = msgList.get(j);
						break;
					}
				}

				//常量要先转为long
				long timeRange = 2 * 60 * 1000;
				if(firstInviteMsgItem != null && (firstInviteMsgItem.createTime*1000l < System.currentTimeMillis() - timeRange)){
					result = true;
				}
			}
		}
		return result;
	}
	
	/**
	 * 会话中（包含charging and pause）
	 */
	public boolean isInSession(){
		boolean result = false;
		if(isInCharging()
				|| chatType == ChatType.InChatPause){
			result = true;
		}
		return result;
	}
	
	/**
	 * 会话暂停中
	 * @return
	 */
	public boolean isPaused(){
		return chatType == ChatType.InChatPause;
	}
	
	/**
	 * 聊天对象是否在线
	 * @return
	 */
	public boolean isOnline(){
		return statusType == UserStatusType.USTATUS_ONLINE;
	}
	
	/**
	 * 添加到等发送队列
	 */
	public void addToSendMsgList(LCMessageItem message)
	{
		synchronized (sendMsgList)
		{
			sendMsgList.add(message);
		}
	}
	
	/**
	 * 获取比较器
	 * @return
	 */
	static public Comparator<LCUserItem> getComparator() {
		Comparator<LCUserItem> comparator = new Comparator<LCUserItem>() {
			@Override
			public int compare(LCUserItem lhs, LCUserItem rhs) {
				// TODO Auto-generated method stub
				int result = 0;
				if (lhs != rhs) 
				{
					synchronized (lhs.msgList) 
					{
						synchronized (rhs.msgList) 
						{
							if (lhs.msgList.size() == 0 && rhs.msgList.size() == 0) {
								// 两个都没有消息，按名字排序
								int nameCompareValue = lhs.userName.compareTo(rhs.userName);
								if (nameCompareValue > 0) {
									result = 1;
								}
								else if (nameCompareValue < 0) {
									result = -1;
								}
							}
							else if (lhs.msgList.size() > 0 && rhs.msgList.size() > 0) {
								// 两个都有消息
								LCMessageItem lMsgItem = lhs.msgList.get(lhs.msgList.size()-1);
								LCMessageItem rMsgItem = rhs.msgList.get(rhs.msgList.size()-1);
								
								// 以最后一条消息的聊天时间倒序排序
								if (null != lMsgItem && null != rMsgItem) {
									if (lMsgItem.createTime != rMsgItem.createTime) {
										result = (lMsgItem.createTime > rMsgItem.createTime ? -1 : 1);
									}
								}
								else {
									if (null == lMsgItem && null != rMsgItem) {
										result = 1;
									}
									else if (null != lMsgItem && null == rMsgItem) {
										result = -1;
									}
								}
							}
							else {
								// 其中一个有消息
								result = (lhs.msgList.size() > rhs.msgList.size() ? -1 : 1);
							}
						}
					}
				}
				return result;
			}
		};
		return comparator;
	}
}
