package com.qpidnetwork.livemodule.httprequest.item;


public class TalentInviteItem {
	
	public enum TalentInviteStatus{
		NoReplied,
		Accept,
		Denied,
		OutTime,
		Cancel
	}
	
	public TalentInviteItem(){
		
	}
	
	/**
	 * 才艺邀请Item
	 * @param talentInviteId
	 * @param talentId
	 * @param name
	 * @param credit
	 * @param inviteStatus
	 * @param giftId			礼物ID
	 * @param giftName			礼物名称
	 * @param giftNum			礼物数量
	 */
	public TalentInviteItem(String talentInviteId,
							String talentId,
							String name,
							double credit,
							int inviteStatus,
							String giftId,
							String giftName,
							int giftNum){
		this.talentInviteId = talentInviteId;
		this.talentId = talentId;
		this.name = name;
		this.credit = credit;
		
		if( inviteStatus < 0 || inviteStatus >= TalentInviteStatus.values().length ) {
			this.inviteStatus = TalentInviteStatus.NoReplied;
		} else {
			this.inviteStatus = TalentInviteStatus.values()[inviteStatus];
		}
		this.giftId = giftId;
		this.giftName = giftName;
		this.giftNum = giftNum;
	}
	
	public String talentInviteId;
	public String talentId;
	public String name;
	public double credit;
	public TalentInviteStatus inviteStatus;
	public String giftId;
	public String giftName;
	public int    giftNum;

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("TalentInviteItem[");
		sb.append("talentInviteId:");
		sb.append(talentInviteId);
		sb.append(" talentId:");
		sb.append(talentId);
		sb.append(" name:");
		sb.append(name);
		sb.append(" credit:");
		sb.append(credit);
		sb.append(" inviteStatus:");
		sb.append(inviteStatus);
		sb.append(" giftId:");
		sb.append(giftId);
		sb.append(" giftName:");
		sb.append(giftName);
		sb.append(" giftNum:");
		sb.append(giftNum);
		sb.append("]");
		return sb.toString();
	}
	
}
