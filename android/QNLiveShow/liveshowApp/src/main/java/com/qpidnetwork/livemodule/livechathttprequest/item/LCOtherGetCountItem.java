package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

public class LCOtherGetCountItem implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 4795555457630694176L;
	public LCOtherGetCountItem() {
		
	}

	/**
	 * 
	 * @param money			余额
	 * @param coupon		优惠券数量
	 * @param integral		积分数量
	 * @param regStep		注册步骤
	 * @param allowAlbum	相册权限
	 * @param admirerUr		未读意向信数量
	 */
	public LCOtherGetCountItem(
			double money,
			int coupon,
			int integral,
			int regStep,
			boolean allowAlbum,
			int admirerUr
			) {
		this.money = money;
		this.coupon = coupon;
		this.integral = integral;
		this.regStep = regStep;
		this.allowAlbum = allowAlbum;
		this.admirerUr = admirerUr;
	}
	
	public double money;
	public int coupon;
	public int integral;
	public int regStep;
	public boolean allowAlbum;
	public int admirerUr;
}
