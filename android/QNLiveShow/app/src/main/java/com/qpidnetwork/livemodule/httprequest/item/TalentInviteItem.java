package com.qpidnetwork.livemodule.httprequest.item;


public class TalentInviteItem {
	
	public enum TalentInviteStatus{
		NoReplied,
		Accept,
		Denied
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
	 */
	public TalentInviteItem(String talentInviteId,
							String talentId,
							String name,
							double credit,
							int inviteStatus){
		this.talentInviteId = talentInviteId;
		this.talentId = talentId;
		this.name = name;
		this.credit = credit;
		
		if( inviteStatus < 0 || inviteStatus >= TalentInviteStatus.values().length ) {
			this.inviteStatus = TalentInviteStatus.NoReplied;
		} else {
			this.inviteStatus = TalentInviteStatus.values()[inviteStatus];
		}
	}
	
	public String talentInviteId;
	public String talentId;
	public String name;
	public double credit;
	public TalentInviteStatus inviteStatus;
	
}
