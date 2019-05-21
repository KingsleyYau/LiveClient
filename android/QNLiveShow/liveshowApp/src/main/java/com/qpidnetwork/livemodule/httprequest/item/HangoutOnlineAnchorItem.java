package com.qpidnetwork.livemodule.httprequest.item;

import java.io.Serializable;

/**
 * 多人互动的在线主播Item
 * @author Alex
 *
 */
public class HangoutOnlineAnchorItem implements Serializable {

	private static final long serialVersionUID = -7795559990983333316L;

	public HangoutOnlineAnchorItem(){

	}

	/**
	 * 多人互动的在线主播Item
	 * @param anchorId		主播ID
	 * @param nickName		主播昵称
	 * @param avatarImg     主播头像url
	 * @param coverImg		直播间封面图url
	 * @param onlineStatus  在线状态（Offline：离线，Online：在线）
	 * @param friendsNum  	好友数量
	 * @param invitationMsg 主播邀请语
	 * @param friendsInfo   好友信息
	 */
	public HangoutOnlineAnchorItem(String anchorId,
                                   String nickName,
                                   String avatarImg,
								   String coverImg,
                                   int onlineStatus,
								   int friendsNum,
                                   String invitationMsg,
								   HangoutAnchorInfoItem[] friendsInfo){
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.avatarImg = avatarImg;
		this.coverImg = coverImg;

		if( onlineStatus < 0 || onlineStatus >= AnchorOnlineStatus.values().length ) {
			this.onlineStatus = AnchorOnlineStatus.Unknown;
		} else {
			this.onlineStatus = AnchorOnlineStatus.values()[onlineStatus];
		}
		this.friendsNum = friendsNum;
		this.invitationMsg = invitationMsg;
		this.friendsInfo = friendsInfo;
	}
	
	public String anchorId;
	public String nickName;
	public String avatarImg;
	public String coverImg;
	public AnchorOnlineStatus onlineStatus;
	public int friendsNum;
	public String invitationMsg;
	public HangoutAnchorInfoItem[] friendsInfo;


	@Override
	public String toString() {
		return "HangoutOnlineAnchorItem[anchorId:"+anchorId
				+ " nickName:"+nickName
				+ " coverImg:"+coverImg
				+ " age:"+friendsNum
				+ " country:"+invitationMsg
				+ " onlineStatus:"+onlineStatus
				+ " avatarImg:"+avatarImg
				+ "]";
	}
}
