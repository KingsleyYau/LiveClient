package com.qpidnetwork.anchor.httprequest.item;

/**
 * 获取主播直播间礼物Item
 * @author Hunter Mun
 *
 */
public class GiftLimitNumItem {



	public GiftLimitNumItem(){

	}

	/**
	 * 获取主播直播间礼物Item
	 * @param giftId			礼物ID
	 * @param giftNum			礼物数量
	 */
	public GiftLimitNumItem(String giftId,
                            int giftNum){
		this.giftId = giftId;
		this.giftNum = giftNum;
	}
	
	public String giftId;
	public int giftNum;

	@Override
	public String toString() {
        StringBuilder sb = new StringBuilder("GiftLimitNumItem[");
        sb.append("giftId:");
        sb.append(giftId);
        sb.append(" giftNum:");
        sb.append(giftNum);
        sb.append("]");
        return sb.toString();
	}
}
