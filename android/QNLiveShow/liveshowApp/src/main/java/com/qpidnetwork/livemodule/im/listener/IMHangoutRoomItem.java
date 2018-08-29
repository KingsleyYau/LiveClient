package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

public class IMHangoutRoomItem{

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


	public IMHangoutRoomItem(){

	}

	/**
	 * @param roomId				直播间ID
	 * @param roomType				直播间类型（参考《“直播间类型”对照表》）
	 * @param manLevel				观众等级
	 * @param manPushPrice			视频资费
	 * @param pushUrl				观众视频流url
	 * @param livingAnchorList	 	直播间中的主播列表
	 * @param buyforList      		已收礼物列表
	 */
	public IMHangoutRoomItem(String roomId,
							 int roomType,
							 int manLevel,
                             double manPushPrice,
							 String[] pushUrl,
							 IMHangoutAnchorItem[] livingAnchorList,
							 IMRecvBuyforGiftItem[] buyforList,
							 double credit){
		this.roomId = roomId;
		if( roomType < 0 || roomType >= IMRoomInItem.IMLiveRoomType.values().length ) {
			this.roomType = IMRoomInItem.IMLiveRoomType.Unknown;
		} else {
			this.roomType = IMRoomInItem.IMLiveRoomType.values()[roomType];
		}
		this.manLevel = manLevel;
		this.manPushPrice = manPushPrice;
		this.pushUrl = pushUrl;
		this.livingAnchorList = livingAnchorList;
		this.buyforList = buyforList;
		this.credit = credit;
	}
	
	public String roomId;
	public IMRoomInItem.IMLiveRoomType roomType;
	public int manLevel;
	public double manPushPrice;
	public String [] pushUrl;
	public IMHangoutAnchorItem [] livingAnchorList;
	public IMRecvBuyforGiftItem [] buyforList;
	public double credit;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMHangoutRoomItem[");
		sb.append("roomId:");
		sb.append(roomId);
		sb.append("roomType:");
		sb.append(roomType);
		sb.append(" manLevel:");
		sb.append(manLevel);
		sb.append(" manPushPrice:");
		sb.append(manPushPrice);
		sb.append(" credit:");
		sb.append(credit);
		sb.append(" pushUrl {");
		if (pushUrl != null) {
			for (int i = 0; i < pushUrl.length; i++) {
				sb.append(" [");
				sb.append(i);
				sb.append("]: {");
				sb.append(pushUrl[i]);
				sb.append(" }; ");
			}
		}
		sb.append(" }");
		sb.append("]");
		sb.append(" livingAnchorList {");
		if (livingAnchorList != null) {
			for (int i = 0; i < livingAnchorList.length; i++) {
				sb.append(" [");
				sb.append(i);
				sb.append("]: {");
				sb.append(livingAnchorList[i]);
				sb.append(" }; ");
			}
		}
		sb.append(" }");
		sb.append("]");
		sb.append(" buyforList {");
		if (buyforList != null) {
			for (int i = 0; i < buyforList.length; i++) {
				sb.append(" [");
				sb.append(i);
				sb.append("]: {");
				sb.append(buyforList[i]);
				sb.append(" }; ");
			}
		}
		sb.append(" }");
		sb.append("]");


		return sb.toString();
	}
}
