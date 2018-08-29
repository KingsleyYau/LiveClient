package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMUserInfoItem implements Serializable{

	/**
	 * 观众信息信息
	 * @author Hunter Mun
	 *
	 */

	private static final long serialVersionUID = -2781675685594191161L;

	public IMUserInfoItem(){

	}

	/**
	 * @param riderId			座驾ID
	 * @param riderName			座驾名称
	 * @param riderUrl			座驾图片url
	 * @param honorImg			勋章图片url
	 */
	public IMUserInfoItem(String riderId,
                          String riderName,
                          String riderUrl,
						  String honorImg){
		this.riderId = riderId;
		this.riderName = riderName;
		this.riderUrl = riderUrl;
		this.honorImg = honorImg;
	}
	
	public String riderId;
	public String riderName;
	public String riderUrl;
	public String honorImg;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMAnchorItem[");
		sb.append("riderId:");
		sb.append(riderId);
		sb.append(" riderName:");
		sb.append(riderName);
		sb.append(" riderUrl:");
		sb.append(riderUrl);
		sb.append(" honorImg:");
		sb.append(honorImg);
		sb.append("]");
		return sb.toString();
	}
}
