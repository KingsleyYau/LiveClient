package com.qpidnetwork.livemodule.im.listener;

public class IMOngoingShowItem {

	public IMOngoingShowItem(){

	}

	/**
	 * 将要开播的节目
	 * @param showInfo             节目
	 * @param type                 通知类型（IMPROGRAMNOTICETYPE_BUYTICKET：已购票的通知，IMPROGRAMNOTICETYPE_FOLLOW：仅关注通知）
	 * @param msg		           消息提示文字
	 */
	public IMOngoingShowItem(IMProgramInfoItem showInfo,
                             int type,
                             String msg){
		this.showInfo = showInfo;
		if( type < 0 || type >= IMClientListener.IMProgramPlayType.values().length ) {
			this.type = IMClientListener.IMProgramPlayType.Unknown;
		} else {
			this.type = IMClientListener.IMProgramPlayType.values()[type];
		}
		this.msg = msg;
	}
	
	public IMProgramInfoItem showInfo;
	public IMClientListener.IMProgramPlayType type;
	public String msg;
}
