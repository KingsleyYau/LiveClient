package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;
import java.nio.charset.Charset;

public class IMHangoutMsgItem{

	/**
	 * 接收多人直播间文本消息
	 * @author Hunter Mun
	 *
	 */


	public IMHangoutMsgItem(){

	}

	/**
	 * @param roomId			直播间ID
	 * @param level				发送方级别
	 * @param fromId			发送方的用户ID
	 * @param nickName			发送方的昵称
	 * @param msg				文本消息内容
	 * @param honorUrl			勋章图片url
	 * @param at      			用户ID，用于指定接收者（字符串数组）（可无，无则表示发送给直播间所有人）
	 */
	public IMHangoutMsgItem(String roomId,
                            int level,
                            String fromId,
                            String nickName,
							byte[] msg,
                            String honorUrl,
                            String[] at){
		this.roomId = roomId;
		this.level = level;
		this.fromId = fromId;
		this.nickName = nickName;
		//解决emoji6.0以下jni使用NewStringUTF越界读（或者crash问题）
		this.msg = new String(msg, Charset.forName("UTF-8"));
		this.honorUrl = honorUrl;
		this.at = at;

	}

	public String roomId;
	public int level;
	public String fromId;
	public String nickName;
	public String msg;
	public String honorUrl;
	public String [] at;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMHangoutMsgItem[");
		sb.append("roomId:");
		sb.append(roomId);
		sb.append(" level:");
		sb.append(level);
		sb.append(" fromId:");
		sb.append(fromId);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" msg:");
		sb.append(msg);
		sb.append(" honorUrl:");
		sb.append(honorUrl);
		sb.append(" at:{");
		if (at != null) {
			for (int i = 0; i < at.length; i++) {
				sb.append(" [");
				sb.append(i);
				sb.append(" :");
				sb.append(at[i]);
				sb.append(" ];");
			}
		}
		sb.append(" };");
		sb.append("]");
		return sb.toString();
	}
}
