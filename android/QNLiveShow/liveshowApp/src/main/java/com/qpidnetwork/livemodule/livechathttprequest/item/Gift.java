package com.qpidnetwork.livemodule.livechathttprequest.item;

import java.io.Serializable;

public class Gift implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = -3119611569685498065L;
	public Gift() {
		
	}

	/**
	 * 5.3.获取虚拟礼物列表回调
	 * @param vgid		id
	 * @param title		标题
	 * @param price		点数
	 */
	public Gift(
			String vgid,
			String title,
			String price
			) {
		this.vgid = vgid;
		this.title = title;
		this.price = price;
	}
	
	public String vgid;
	public String title;
	public String price;
}
