package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMRecvGiftItem implements Serializable {

	/**
	 * 已收礼物列表
	 * @author Hunter Mun
	 *
	 */
	public IMRecvGiftItem(){

	}

	/**
	 * @param userId			用户ID，包括观众及主播
	 * @param buyforList		已收吧台礼物列表
	 */
	public IMRecvGiftItem(String userId,
						  IMGiftNumItem[] buyforList){
		this.userId = userId;
		this.buyforList = buyforList;
	}
	
	public String userId;
	public IMGiftNumItem[] buyforList;
}
