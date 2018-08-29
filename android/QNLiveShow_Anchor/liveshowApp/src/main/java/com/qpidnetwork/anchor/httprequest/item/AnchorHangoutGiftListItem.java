package com.qpidnetwork.anchor.httprequest.item;

/**
 * 主播信息Item
 * @author Hunter Mun
 *
 */
public class AnchorHangoutGiftListItem {

	public AnchorHangoutGiftListItem(){

	}

	/**
	 * 多人互动直播间礼物列表
	 * @param buyforList			吧台礼物列表
	 * @param normalList			连击礼物&大礼物列表
	 * @param celebrationList		庆祝礼物列表
	 */
	public AnchorHangoutGiftListItem(GiftLimitNumItem[] buyforList,
									 GiftLimitNumItem[] normalList,
									 GiftLimitNumItem[] celebrationList){
		this.buyforList = buyforList;
		this.normalList = normalList;
		this.celebrationList = celebrationList;
	}

	public GiftLimitNumItem[] buyforList;
	public GiftLimitNumItem[] normalList;
	public GiftLimitNumItem[] celebrationList;


	@Override
	public String toString() {
        StringBuilder sb = new StringBuilder("AnchorHangoutGiftListItem[");
        sb.append("]");
        return sb.toString();
	}
}
