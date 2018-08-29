package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMAnchorItem implements Serializable{

	/**
	 * 已在直播间的主播列表
	 * @author Hunter Mun
	 *
	 */

	private static final long serialVersionUID = -2781675685594191161L;

	public IMAnchorItem(){

	}

	/**
	 * @param anchorId					主播ID
	 * @param anchorNickName			主播昵称
	 * @param anchorPhotoUrl			主播头像
	 */
	public IMAnchorItem(String anchorId,
						String anchorNickName,
						String anchorPhotoUrl){
		this.anchorId = anchorId;
		this.anchorNickName = anchorNickName;
		this.anchorPhotoUrl = anchorPhotoUrl;
	}
	
	public String anchorId;
	public String anchorNickName;
	public String anchorPhotoUrl;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMAnchorItem[");
		sb.append("anchorId:");
		sb.append(anchorId);
		sb.append(" anchorNickName:");
		sb.append(anchorNickName);
		sb.append(" anchorPhotoUrl:");
		sb.append(anchorPhotoUrl);
		sb.append("]");
		return sb.toString();
	}
}
