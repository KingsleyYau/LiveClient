package com.qpidnetwork.livemodule.im.listener;

public class IMRecvBuyforGiftItem {

	/**
	 * 已收礼物列表
	 * @author Hunter Mun
	 *
	 */
	public IMRecvBuyforGiftItem(){

	}

	/**
	 * @param userId			用户ID，包括观众及主播
	 * @param buyforList		已收吧台礼物列表
	 */
	public IMRecvBuyforGiftItem(String userId,
						  IMGiftNumItem[] buyforList){
		this.userId = userId;
		this.buyforList = buyforList;
	}
	
	public String userId;
	public IMGiftNumItem[] buyforList;

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMRecvBuyforGiftItem[");
		sb.append("userId:");
		sb.append(userId);
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
