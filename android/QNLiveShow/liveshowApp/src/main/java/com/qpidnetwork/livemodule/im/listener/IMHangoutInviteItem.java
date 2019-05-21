package com.qpidnetwork.livemodule.im.listener;

public class IMHangoutInviteItem {

	/**
	 * 0.15.接收主播Hang-out邀请通知
	 * @author Alex
	 *
	 */
	public enum IMAnchorReplyInviteType {
		Unknown,				// 未知
		Agree,					// 接受
		Reject,					// 拒绝
		OutTime,				// 邀请超时
		Cancel,					// 观众取消邀请
		NoCredit,				// 余额不足
		Busy					// 主播繁忙
	}

	/**
	 * 10.15.接收主播Hang-out邀请通知
	 * @author Alex
	 *
	 */

	public IMHangoutInviteItem(){

	}

	/**
	 * @param logId				记录ID
	 * @param isAnto			是否自动邀请
	 * @param anchorId			主播ID
	 * @param nickName	主播昵称
	 * @param anchorCover   	封面图URL
	 * @param inviteMessage	 	邀请内容
	 * @param weights			权重值
	 * @param avatarImg			主播头像
	 */
	public IMHangoutInviteItem(int logId,
							   boolean isAnto,
							   String anchorId,
                               String nickName,
                               String anchorCover,
                               String inviteMessage,
                               int weights,
                               String avatarImg){
		this.logId = logId;
		this.isAnto = isAnto;
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.anchorCover = anchorCover;
		this.inviteMessage = inviteMessage;
		this.weights = weights;
		this.avatarImg = avatarImg;

	}

	public int logId;
	public boolean isAnto;
	public String anchorId;
	public String nickName;
	public String anchorCover;
	public String inviteMessage;
	public int weights;
	public String avatarImg;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMHangoutInviteItem[");
		sb.append("logId:");
		sb.append(logId);
		sb.append(" isAnto:");
		sb.append(isAnto);
		sb.append(" anchorId:");
		sb.append(anchorId);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" anchorCover:");
		sb.append(anchorCover);
		sb.append(" inviteMessage:");
		sb.append(inviteMessage);
		sb.append(" weights:");
		sb.append(weights);
		sb.append(" avatarImg:");
		sb.append(avatarImg);
		sb.append("]");
		return sb.toString();
	}
}
