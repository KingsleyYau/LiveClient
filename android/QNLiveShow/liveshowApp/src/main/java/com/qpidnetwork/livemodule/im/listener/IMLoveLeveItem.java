package com.qpidnetwork.livemodule.im.listener;


public class IMLoveLeveItem {

	public IMLoveLeveItem(){

	}

	public IMLoveLeveItem(int loveLevel,
                          String anchorId,
                          String anchorName
			){
		this.loveLevel = loveLevel;
		this.anchorId = anchorId;
		this.anchorName = anchorName;
	}

	public int loveLevel;
	public String anchorId;
	public String anchorName;

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMLoveLeveItem[");
		sb.append("loveLevel:");
		sb.append(loveLevel);
		sb.append("anchorId:");
		sb.append(anchorId);
		sb.append("anchorName:");
		sb.append(anchorName);
		sb.append("]");
		return super.toString();
	}
}
