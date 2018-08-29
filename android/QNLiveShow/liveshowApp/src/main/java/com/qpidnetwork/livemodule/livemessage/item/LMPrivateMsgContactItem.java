package com.qpidnetwork.livemodule.livemessage.item;
import java.io.Serializable;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;

public class LMPrivateMsgContactItem {
	
	public LMPrivateMsgContactItem(){
		
	}
	
	public LMPrivateMsgContactItem(String userId,
								   String nickName,
								   String avatarImg,
								   int onlineStatus,
								   String lastMsg,
								   int updateTime,
								   int unreadNum,
								   boolean isAnchor
			){
		this.userId = userId;
		this.nickName = nickName;
		this.avatarImg = avatarImg;
		if( onlineStatus < 0 || onlineStatus >= AnchorOnlineStatus.values().length ) {
			this.onlineStatus = AnchorOnlineStatus.Unknown;
		} else {
			this.onlineStatus = AnchorOnlineStatus.values()[onlineStatus];
		}
		this.lastMsg = lastMsg;
		this.updateTime = updateTime;
		this.unreadNum = unreadNum;
		this.isAnchor = isAnchor;
	}
	
	public String userId;
	public String nickName;
	public String avatarImg;
	public AnchorOnlineStatus onlineStatus;
	public String lastMsg;
	public int updateTime;
	public int unreadNum;
	public boolean isAnchor;

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("LMPrivateMsgContactItem[");
		sb.append("userId:");
		sb.append(userId);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" avatarImg:");
		sb.append(avatarImg);
		sb.append(" onlineStatus:");
		sb.append(onlineStatus);
		sb.append(" lastMsg:");
		sb.append(lastMsg);
		sb.append(" updateTime:");
		sb.append(updateTime);
		sb.append(" unreadNum:");
		sb.append(unreadNum);
		sb.append(" isAnchor:");
		sb.append(isAnchor);
		sb.append("]");
		return sb.toString();
	}

}
