package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 可发送的礼物列表Item
 * @author Hunter Mun
 *
 */
public class HangoutGiftListItem {

	public HangoutGiftListItem(){

	}

	/**
	 * 可发送的礼物列表Item
	 * @param buyforList			吧台礼物列表
	 * @param normalList			连击礼物及大礼物列表
	 * @param celebrationList		庆祝礼物列表
	 */
	public HangoutGiftListItem(String[] buyforList,
							   String[] normalList,
							   String[] celebrationList){
		this.buyforList = buyforList;
		this.normalList = normalList;
		this.celebrationList = celebrationList;

	}
	
	public String[] buyforList;
	public String[] normalList;
	public String[] celebrationList;

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("HangoutGiftListItem[");
		sb.append(" buyforList:{");
		if (buyforList != null) {
			for (int i = 0; i < buyforList.length; i++) {
				sb.append(" [");
				sb.append(i);
				sb.append(" :");
				sb.append(buyforList[i]);
				sb.append(" ];");
			}
		}
		sb.append(" };");
		sb.append(" normalList:{");
		if (normalList != null) {
			for (int i = 0; i < normalList.length; i++) {
				sb.append(" [");
				sb.append(i);
				sb.append(" :");
				sb.append(normalList[i]);
				sb.append(" ];");
			}
		}
		sb.append(" };");
		sb.append(" celebrationList:{");
		if (normalList != null) {
			for (int i = 0; i < celebrationList.length; i++) {
				sb.append(" [");
				sb.append(i);
				sb.append(" :");
				sb.append(celebrationList[i]);
				sb.append(" ];");
			}
		}
		sb.append(" };");
		sb.append("]");

		return sb.toString();

	}
}
