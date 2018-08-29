package com.qpidnetwork.livemodule.httprequest.item;

public class TalentInfoItem {
	
	public TalentInfoItem(){
		
	}
	
	public TalentInfoItem(String talentId,
						  String talentName,
						  double talentCredit,
						  String decription,
						  String giftId,
						  String giftName,
						  int giftNum){
		this.talentId = talentId;
		this.talentName = talentName;
		this.talentCredit = talentCredit;
		this.decription = decription;
		this.giftId = giftId;
		this.giftName = giftName;
		this.giftNum = giftNum;
	}
	
	public String talentId;
	public String talentName;
	public double talentCredit;
	public String decription;
	public String giftId;
	public String giftName;
	public int    giftNum;

	@Override
	public String toString() {
        StringBuilder sb = new StringBuilder("TalentInfoItem[");
        sb.append("talentId:");
        sb.append(talentId);
        sb.append(" talentName:");
        sb.append(talentName);
        sb.append(" talentCredit:");
        sb.append(talentCredit);
		sb.append(" decription:");
		sb.append(decription);
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
