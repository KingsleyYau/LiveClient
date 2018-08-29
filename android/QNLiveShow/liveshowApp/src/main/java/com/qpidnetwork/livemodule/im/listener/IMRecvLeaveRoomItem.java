package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

public class IMRecvLeaveRoomItem{

	/**
	 * 观众/主播退出多人互动直播间信息
	 * @author Hunter Mun
	 *
	 */


	public IMRecvLeaveRoomItem(){

	}

	/**
	 * @param roomId			直播间ID
	 * @param isAnchor			是否主播（0：否，1：是）
	 * @param userId			观众/主播ID
	 * @param nickName			观众/主播昵称
	 * @param photoUrl   		观众/主播头像url
	 * @param errNo	 			退出原因错误码
	 * @param errMsg	 		退出原因错误描述
	 */
	public IMRecvLeaveRoomItem(String roomId,
							   boolean isAnchor,
                               String userId,
                               String nickName,
                               String photoUrl,
							   int errNo,
                               String errMsg){
		this.roomId = roomId;
		this.isAnchor = isAnchor;
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		if( errNo < 0 || errNo >= IMClientListener.LCC_ERR_TYPE.values().length ) {
			this.errNo = IMClientListener.LCC_ERR_TYPE.LCC_ERR_FAIL;
		} else {
			this.errNo = IMClientListener.LCC_ERR_TYPE.values()[errNo];
		}

		this.errMsg = errMsg;

	}
	
	public String 		roomId;
	public boolean 		isAnchor;
	public String 		userId;
	public String 		nickName;
	public String 		photoUrl;
	public IMClientListener.LCC_ERR_TYPE			errNo;
	public String 		errMsg;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMRecvLeaveRoomItem[");
		sb.append("roomId:");
		sb.append(roomId);
		sb.append(" isAnchor:");
		sb.append(isAnchor);
		sb.append(" userId:");
		sb.append(userId);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" photoUrl:");
		sb.append(photoUrl);
		sb.append(" errNo:");
		sb.append(errNo);
		sb.append(" errMsg:");
		sb.append(errMsg);
		sb.append("]");
		return sb.toString();
	}
}
