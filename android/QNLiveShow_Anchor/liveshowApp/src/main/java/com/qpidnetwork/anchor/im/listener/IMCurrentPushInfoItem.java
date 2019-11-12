package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMCurrentPushInfoItem implements Serializable{

	/**
	 * 当前推流状态类型
	 * @author Hunter Mun
	 *
	 */
	public enum IMCurrentPushStatus {
		NoPush,				// 未推流
		PcPush,				// PC推流
		AppPush				// APP推流

	}


	private static final long serialVersionUID = -2781675685594191161L;

	public IMCurrentPushInfoItem(){

	}

	/**
	 * @param status			当前推流状态
	 * @param message			推流消息
	 */
	public IMCurrentPushInfoItem(int status,
                                 String message) {
		if( status < 0 || status >= IMCurrentPushStatus.values().length ) {
			this.status = IMCurrentPushStatus.NoPush;
		} else {
			this.status = IMCurrentPushStatus.values()[status];
		}
		this.message = message;
	}

	public IMCurrentPushStatus status;
	public String message;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMCurrentPushInfoItem[");
		sb.append("status:");
		sb.append(status);
		sb.append(" message:");
		sb.append(message);
		sb.append("]");
		return sb.toString();
	}
}
