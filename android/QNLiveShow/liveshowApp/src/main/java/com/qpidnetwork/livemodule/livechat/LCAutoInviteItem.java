package com.qpidnetwork.livemodule.livechat;

import java.io.Serializable;

public class LCAutoInviteItem implements Serializable{

	private static final long serialVersionUID = 5780025469210305835L;
	
	/**
	 * 女士Id
	 */
	public String womanId;
	/**
	 * 男士Id
	 */
	public String manId;
	/**
	 * 验证码
	 */
	public String identifyKey;
	
	public LCAutoInviteItem(){
		womanId = "";
		manId = "";
		identifyKey = "";
	}
	
	public LCAutoInviteItem(String womanId, String manId, String key){
		this.womanId = womanId;
		this.manId = manId;
		this.identifyKey = key;
	}
}
