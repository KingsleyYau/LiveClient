package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

public class IMHangoutAnchorItem implements Serializable{

	private static final long serialVersionUID = 943761240665259647L;

	/**
	 * 其它主播列表
	 * @author Hunter Mun
	 *
	 */
	public enum IMAnchorStatus {
		Invitation,				//邀请中
		InviteConfirm,			//邀请已确认
		KnockConfirm,			//敲门已确认
		ReciprocalEnter,		//倒数进入中
		Online                  //在线
	}

	public IMHangoutAnchorItem(){

	}

	/**
	 * @param anchorId			主播ID
	 * @param nickName			主播昵称
	 * @param photoUrl			主播头像url
	 * @param anchorStatus		主播状态（Invitation：邀请中，InviteConfirm：邀请已确认，KnockConfirm：敲门已确认，ReciprocalEnter：倒数进入中，Online：在线）
	 * @param inviteId			邀请ID（可无，仅当anchor_status=0时存在）
	 * @param leftSeconds		倒数秒数（整型）（可无，仅当anchor_status=3时存在）
	 * @param loveLevel	 		与观众的私密等级
	 * @param videoUrl      	主播视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》
	 */
	public IMHangoutAnchorItem(String anchorId,
                             String nickName,
							 String photoUrl,
                             int anchorStatus,
							 String inviteId,
                             int leftSeconds,
                             int loveLevel,
                             String[] videoUrl){
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		if( anchorStatus < 0 || anchorStatus >= IMAnchorStatus.values().length ) {
			this.anchorStatus = IMAnchorStatus.Invitation;
		} else {
			this.anchorStatus = IMAnchorStatus.values()[anchorStatus];
		}
		this.inviteId = inviteId;
		this.leftSeconds = leftSeconds;
		this.loveLevel = loveLevel;
		this.videoUrl = videoUrl;
	}
	
	public String anchorId;
	public String nickName;
	public String photoUrl;
	public IMAnchorStatus anchorStatus;
	public String inviteId;
	public int leftSeconds;
	public int loveLevel;
	public String [] videoUrl;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMHangoutAnchorItem[");
		sb.append("anchorId:");
		sb.append(anchorId);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" photoUrl:");
		sb.append(photoUrl);
		sb.append(" photoUrl:");
		sb.append(photoUrl);
		sb.append(" inviteId:");
		sb.append(inviteId);
		sb.append(" leftSeconds:");
		sb.append(leftSeconds);
		sb.append(" loveLevel:");
		sb.append(loveLevel);
		sb.append(" videoUrl: {");
		if (videoUrl != null) {
			for (int i = 0; i < videoUrl.length; i++) {
				sb.append(" [");
				sb.append(i);
				sb.append(":");
				sb.append(videoUrl[i]);
				sb.append(" ];");
			}
	}
		sb.append(" };");
		sb.append("]");
		return sb.toString();
	}
}
