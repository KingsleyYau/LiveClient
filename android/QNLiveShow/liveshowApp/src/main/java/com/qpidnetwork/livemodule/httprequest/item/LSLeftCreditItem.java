package com.qpidnetwork.livemodule.httprequest.item;

public class LSLeftCreditItem {

	public LSLeftCreditItem(){

	}

	/**
	 * @param balance			//信用点
	 * @param coupon			//可用的试用券数量
	 * @param postStamp			//可用的邮票数量
	 * @param liveChatCount		//可用livechat的试用券数量
	 */
	public LSLeftCreditItem(double balance,
                            int coupon,
                            double postStamp,
                            int liveChatCount){
		this.balance = balance;
		this.coupon = coupon;
		this.postStamp = postStamp;
		this.liveChatCount = liveChatCount;
	}
	
	public double balance;
	public int coupon;
	public double postStamp;
	public int liveChatCount;

}
