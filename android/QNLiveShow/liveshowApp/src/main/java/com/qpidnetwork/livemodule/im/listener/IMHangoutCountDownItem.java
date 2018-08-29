package com.qpidnetwork.livemodule.im.listener;

public class IMHangoutCountDownItem{

	/**
	 * 进入多人互动直播间倒数通知
	 * @author Hunter Mun
	 *
	 */

	public IMHangoutCountDownItem(){

	}

	/**
	 * @param roomId			待进入的直播间ID
	 * @param anchorId			主播ID
	 * @param leftSecond		进入直播间的剩余秒数
	 */
	public IMHangoutCountDownItem(String roomId,
                                  String anchorId,
                                  int leftSecond){
		this.roomId = roomId;
		this.anchorId = anchorId;
		this.leftSecond = leftSecond;

	}

	public String roomId;
	public String anchorId;
	public int leftSecond;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMHangoutCountDownItem[");
		sb.append("roomId:");
		sb.append(roomId);
		sb.append(" anchorId:");
		sb.append(anchorId);
		sb.append(" leftSecond:");
		sb.append(leftSecond);
		sb.append("]");
		return sb.toString();
	}
}
