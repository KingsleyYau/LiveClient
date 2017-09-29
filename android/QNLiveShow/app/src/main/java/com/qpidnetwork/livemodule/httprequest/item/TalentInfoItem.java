package com.qpidnetwork.livemodule.httprequest.item;

public class TalentInfoItem {
	
	public TalentInfoItem(){
		
	}
	
	public TalentInfoItem(String talentId,
						  String talentName,
						  double talentCredit){
		this.talentId = talentId;
		this.talentName = talentName;
		this.talentCredit = talentCredit;
	}
	
	public String talentId;
	public String talentName;
	public double talentCredit;
	public boolean canRequest = true;	//能否发送此才艺（本地使用）
}
