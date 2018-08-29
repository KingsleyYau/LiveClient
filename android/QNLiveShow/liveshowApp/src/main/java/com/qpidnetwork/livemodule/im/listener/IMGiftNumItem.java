package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

public class IMGiftNumItem implements Serializable{

	/**
	 * 礼物数量列表
	 * @author Hunter Mun
	 *
	 */
	private static final long serialVersionUID = -2781675685594191161L;

	public IMGiftNumItem(){

	}

	/**
	 * @param giftId			礼物ID
	 * @param giftNum			已收礼物数量
	 */
	public IMGiftNumItem(String giftId,
                         int giftNum){
		this.giftId = giftId;
		this.giftNum = giftNum;
	}
	
	public String giftId;
	public int giftNum;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMGiftNumItem[");
		sb.append("giftId:");
		sb.append(giftId);
		sb.append(" giftNum:");
		sb.append(giftNum);
		sb.append("]");
		return sb.toString();
	}
}
