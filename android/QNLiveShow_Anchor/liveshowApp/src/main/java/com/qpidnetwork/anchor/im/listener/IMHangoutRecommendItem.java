package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMHangoutRecommendItem implements Serializable{

	/**
	 * 推荐好友信息
	 * @author Hunter Mun
	 *
	 */

	private static final long serialVersionUID = -2781675685594191161L;

	public IMHangoutRecommendItem(){

	}

	/**
	 * @param roomId			直播间ID
	 * @param anchorId			主播ID
	 * @param nickName			主播昵称
	 * @param photoUrl			主播头像
	 * @param friendId   		主播好友ID
	 * @param friendNickName	主播好友昵称
	 * @param friendPhotoUrl	主播好友头像
	 * @param friendAge	 		年龄
	 * @param friendCountry	 	国家
	 * @param recommendId	 	邀请ID
	 */
	public IMHangoutRecommendItem(String roomId,
                                  String anchorId,
                                  String nickName,
                                  String photoUrl,
								  String friendId,
								  String friendNickName,
								  String friendPhotoUrl,
                                  int friendAge,
								  String friendCountry,
								  String recommendId){
		this.roomId = roomId;
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.friendId = friendId;
		this.friendNickName = friendNickName;
		this.friendPhotoUrl = friendPhotoUrl;
		this.friendAge = friendAge;
		this.friendCountry = friendCountry;
		this.recommendId = recommendId;

	}
	
	public String roomId;
	public String anchorId;
	public String nickName;
	public String photoUrl;
	public String friendId;
	public String friendNickName;
	public String friendPhotoUrl;
	public int friendAge;
	public String friendCountry;
	public String recommendId;
	public String manNickeName;	//男士昵称
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMHangoutRecommendItem[");
		sb.append("roomId:");
		sb.append(roomId);
		sb.append(" anchorId:");
		sb.append(anchorId);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" photoUrl:");
		sb.append(photoUrl);
		sb.append(" firendId:");
		sb.append(friendId);
		sb.append(" friendNickName:");
		sb.append(friendNickName);
		sb.append(" friendPhotoUrl:");
		sb.append(friendPhotoUrl);
		sb.append(" friendAge:");
		sb.append(friendAge);
		sb.append(" friendCountry:");
		sb.append(friendCountry);
		sb.append(" recommendId:");
		sb.append(recommendId);
		sb.append("]");
		return sb.toString();
	}
}
