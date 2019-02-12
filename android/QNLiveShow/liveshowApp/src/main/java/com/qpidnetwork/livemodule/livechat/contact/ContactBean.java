package com.qpidnetwork.livemodule.livechat.contact;


import android.text.TextUtils;

import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LCUserItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;

import java.util.Comparator;

public class ContactBean {

	/*比较器*/
	static private Comparator<ContactBean> comparator;
	
	public ContactBean(){
		unreadCount = 0;
		msgHint = "";
	}

	public ContactBean(String userId, String userName){
		this.userId = userId;
		this.userName = userName;
		unreadCount = 0;
		msgHint = "";
	}

	public void updateContactByLiveChatUserItem(LiveChatTalkUserListItem item){
		this.userId = item.userId;
		this.userName = item.userName;
		this.age = item.age;
		this.photoURL = item.avatarImg;
		this.videoCount = item.videoCount;
	}

	
	@Override
	public boolean equals(Object o) {
		if((o != null)&&(o instanceof ContactBean)){
			ContactBean object = (ContactBean)o;
			return (object.userId.equals(userId));
		}
		return super.equals(o);
	}
	
	static public Comparator<ContactBean> getComparator() {
		if (null == comparator) {
			comparator = new Comparator<ContactBean>() {
				@Override
				public int compare(ContactBean lhs, ContactBean rhs) {
					int result = -1;
					LCUserItem lhUserItem = LiveChatManager.getInstance().GetUserWithId(lhs.userId);
					LCUserItem rhUserItem = LiveChatManager.getInstance().GetUserWithId(rhs.userId);
					// 1. 比较在线状态
					if (lhUserItem.isOnline() == rhUserItem.isOnline()) {
						// 2. 比较聊天状态是否 in chat
						if (lhUserItem.isInSession() == rhUserItem.isInSession()) {
//							// 3. 比较是否有 LiveChat 消息
//							if (TextUtils.isEmpty(lhs.msgHint) == TextUtils.isEmpty(rhs.msgHint)) {
								// 4. 都有LiveChat消息 或 都没有LiveChat消息且favorite相等，则比较最后联系时间
								if (lhs.lasttime == rhs.lasttime) {
									result = 0;
								}
								else {
									result = (lhs.lasttime > rhs.lasttime ? -1 : 1);
								}
//							}
//							else {
//								result = (!TextUtils.isEmpty(lhs.msgHint) ? -1 : 1);
//							}
						}
						else {
							result = (lhUserItem.isInSession() == true ? -1 : 1);
						}
					}
					else {
						result = (lhUserItem.isOnline() == true ? -1 : 1);
					}

					return result;
				}
			};
		}
		return comparator;
	}

	public String userId;
	public String userName;
	public int age;
	public String photoURL;
	public int videoCount;
	/*最后一条消息内容*/
	public String msgHint;
	/*未读条数*/
	public int unreadCount;
	//最后更新时间用于处理排序问题
	public int lasttime;
}
