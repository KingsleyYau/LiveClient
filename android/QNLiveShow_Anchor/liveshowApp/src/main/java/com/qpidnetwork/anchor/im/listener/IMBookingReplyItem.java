package com.qpidnetwork.anchor.im.listener;

import com.qpidnetwork.anchor.im.listener.IMClientListener.BookInviteReplyType;

public class IMBookingReplyItem {
	
	public IMBookingReplyItem(){
		
	}
	
	public IMBookingReplyItem(String inviteId,
			int replyType,
			String roomId,
			String anchorId,
			String nickName,
			String avatarImg,
			String msg
			){
		this.inviteId = inviteId;
		if( replyType < 0 || replyType >= BookInviteReplyType.values().length ) {
			this.replyType = BookInviteReplyType.Unknown;
		} else {
			this.replyType = BookInviteReplyType.values()[replyType];
		}
		this.roomId = roomId;
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.avatarImg = avatarImg;
		this.msg = msg;
	}
	
	public String inviteId;
	public BookInviteReplyType replyType;
	public String roomId;
	public String anchorId;
	public String nickName;
	public String avatarImg;
	public String msg;
}
