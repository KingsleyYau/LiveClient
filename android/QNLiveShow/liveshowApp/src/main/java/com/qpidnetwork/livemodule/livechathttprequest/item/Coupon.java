package com.qpidnetwork.livemodule.livechathttprequest.item;


public class Coupon {
	public Coupon() {
		
	}

	/**
	 * 5.1.查询是否符合试聊条件回调
	 * @param status			试聊状态
	 */
	public Coupon(
			String userId,
			int status,
			int freetrial,
			boolean refundflag,
			String fersivalid,
			int time,
			String couponId,
			String endTime
			) 
	{
		if( status < 0 || status >= CouponStatus.values().length ) {
			this.status = CouponStatus.values()[0];
		} else {
			this.status = CouponStatus.values()[status];
		}
		this.userId = userId;
		this.lc_freetrial = freetrial;
		this.refundflag = refundflag;
		this.festivalid = fersivalid;
		this.time = time;
		this.couponId = couponId;
		this.endTime = endTime;
	}
	
	public enum CouponStatus {
		Used,		// 已聊过
		None,		// 不能使用
		Yes,		// 可以使用
		Started,	// 已开始使用
		Promotion,	// 促销
	}
	
	public String userId;
	public CouponStatus status;
	public int lc_freetrial;  // 试聊券可用张数
	public boolean refundflag; //是否返点
	public String festivalid;  //节日ID
	public int time; // 时长(分钟)
	public String couponId; // 试聊劵ID
	public String endTime;
}
