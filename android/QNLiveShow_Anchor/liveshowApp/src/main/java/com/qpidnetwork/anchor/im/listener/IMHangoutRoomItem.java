package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMHangoutRoomItem implements Serializable{

	/**
	 * 互动直播间
	 * @author Hunter Mun
	 *
	 */
	public enum IMAnchorStatus {
		Unknown,				//未知
		Invitation,				//邀请中
		InviteConfirm,			//邀请已确认
		KnockConfirm,			//敲门已确认
		ReciprocalEnter,		//倒数进入中
		Online                  //在线
	}

	private static final long serialVersionUID = -2781675685594191161L;

	public IMHangoutRoomItem(){

	}

	/**
	 * @param roomId			直播间ID
	 * @param roomType			直播间类型（参考《“直播间类型”对照表》）
	 * @param manId				观众ID
	 * @param manNickName		观众昵称ID
	 * @param manPhotoUrl		观众头像url
	 * @param manLevel	 		观众等级
	 * @param manVideoUrl      	观众视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》）
	 * @param pushUrl      	 	视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》）
	 * @param otherAnchorList   其它主播列表
	 * @param buyforList      	已收礼物列表
	 */
	public IMHangoutRoomItem(String roomId,
							 int roomType,
                             String manId,
                             String manNickName,
							 String manPhotoUrl,
                             int manLevel,
                             String[] manVideoUrl,
							 String[] pushUrl,
							 IMOtherAnchorItem[] otherAnchorList,
							 IMRecvGiftItem[] buyforList){
		this.roomId = roomId;
		if( roomType < 0 || roomType >= IMRoomInItem.IMLiveRoomType.values().length ) {
			this.roomType = IMRoomInItem.IMLiveRoomType.Unknown;
		} else {
			this.roomType = IMRoomInItem.IMLiveRoomType.values()[roomType];
		}
		this.manId = manId;
		this.manNickName = manNickName;
		this.manPhotoUrl = manPhotoUrl;
		this.manLevel = manLevel;
		this.manVideoUrl = manVideoUrl;
		this.pushUrl = pushUrl;
		this.otherAnchorList = otherAnchorList;
		this.buyforList = buyforList;
	}
	
	public String roomId;
	public IMRoomInItem.IMLiveRoomType roomType;
	public String manId;
	public String manNickName;
	public String manPhotoUrl;
	public int manLevel;
	public String [] manVideoUrl;
	public String [] pushUrl;
	public IMOtherAnchorItem [] otherAnchorList;
	public IMRecvGiftItem [] buyforList;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMHangoutRoomItem[");
		sb.append("roomId:");
		sb.append(roomId);
		sb.append(" manId:");
		sb.append(manId);
		sb.append(" manNickName:");
		sb.append(manNickName);
		sb.append("]");
		return sb.toString();
	}
}
