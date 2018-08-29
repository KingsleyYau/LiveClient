package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

public class IMRecvHangoutGiftItem implements Serializable{

	/**
	 * 观众端/主播端接收直播间礼物信息
	 * @author Hunter Mun
	 *
	 */

	private static final long serialVersionUID = -2781675685594191161L;

	public IMRecvHangoutGiftItem(){

	}

	/**
	 * @param roomId				直播间ID
	 * @param fromId				发送方的用户ID
	 * @param nickName				发送方的昵称
	 * @param toUid					接收者ID（可无，无则表示发送给所有人）
	 * @param giftId   				礼物ID
	 * @param giftName	 			礼物名称
	 * @param giftNum	 			本次发送礼物的数量
	 * @param isMultiClick			是否连击礼物（1：是，0：否）
	 * @param multiClickStart   	连击起始数（整型）（可无，multi_click=0则无）
	 * @param multiClickEnd	 		连击结束数（整型）（可无，multi_click=0则无）
	 * @param multiClickId	 		连击ID，相同则表示是同一次连击（整型）（可无，multi_click=0则无）
	 * @param isPrivate				是否私密发送（1：是，0：否）
	 */
	public IMRecvHangoutGiftItem(String roomId,
								 String fromId,
                                 String nickName,
                                 String toUid,
                                 String giftId,
								 String giftName,
                                 int giftNum,
                                 boolean isMultiClick,
								 int multiClickStart,
								 int multiClickEnd,
								 int multiClickId,
								 boolean isPrivate){
		this.roomId = roomId;
		this.fromId = fromId;
		this.nickName = nickName;
		this.toUid = toUid;
		this.giftId = giftId;
		this.giftName = giftName;
		this.giftNum = giftNum;
		this.isMultiClick = isMultiClick;
		this.multiClickStart = multiClickStart;
		this.multiClickStart = multiClickStart;
		this.multiClickEnd = multiClickEnd;
		this.multiClickId = multiClickId;
		this.isPrivate = isPrivate;

	}
	
	public String 		roomId;
	public String 		fromId;
	public String 		nickName;
	public String 		toUid;
	public String 		giftId;
	public String 		giftName;
	public int			giftNum;
	public boolean 		isMultiClick;
	public int			multiClickStart;
	public int			multiClickEnd;
	public int			multiClickId;
	public boolean      isPrivate;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMRecvHangoutGiftItem[");
		sb.append("roomId:");
		sb.append(roomId);
		sb.append(" fromId:");
		sb.append(fromId);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" toUid:");
		sb.append(toUid);
		sb.append(" giftId:");
		sb.append(giftId);
		sb.append(" giftName:");
		sb.append(giftName);
		sb.append(" giftNum:");
		sb.append(giftNum);
		sb.append(" isMultiClick:");
		sb.append(isMultiClick);
		sb.append(" multiClickStart:");
		sb.append(multiClickStart);
		sb.append(" multiClickEnd:");
		sb.append(multiClickEnd);
		sb.append(" multiClickId:");
		sb.append(multiClickId);
		sb.append(" isPrivate:");
		sb.append(isPrivate);
		sb.append("]");
		return sb.toString();
	}
}
