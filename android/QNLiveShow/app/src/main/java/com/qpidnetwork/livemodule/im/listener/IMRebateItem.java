package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

/**
 * 返点信息
 * @author Hunter Mun
 *
 */
public class IMRebateItem implements Serializable{
	private static final long serialVersionUID = 3372801283619517083L;
	
	public IMRebateItem(){
		
	}
	
	/**
	 * @param cur_credit		已返点数余额（浮点型）
	 * @param cur_time			剩余返点倒数时间（秒）（整型）
	 * @param pre_credit		每期返点数（浮点型）
	 * @param pre_time			返点周期时间（秒）（整型）
	 */
	public IMRebateItem(double cur_credit,
						int cur_time,
						double pre_credit,
						int pre_time){
		this.cur_credit = cur_credit;
		this.cur_time = cur_time;
		this.pre_credit = pre_credit;
		this.pre_time = pre_time;
	}
	
	public double cur_credit;
	public int cur_time;
	public double pre_credit;
	public int pre_time;
}
