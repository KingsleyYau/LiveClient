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

	@Override
	public String toString() {
        StringBuilder sb = new StringBuilder("TalentInfoItem[");
        sb.append("talentId:");
        sb.append(talentId);
        sb.append(" talentName:");
        sb.append(talentName);
        sb.append(" talentCredit:");
        sb.append(talentCredit);
        sb.append("]");
        return sb.toString();
	}
}
