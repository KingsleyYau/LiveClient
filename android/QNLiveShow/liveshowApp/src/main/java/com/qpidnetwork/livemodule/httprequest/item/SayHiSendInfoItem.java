package com.qpidnetwork.livemodule.httprequest.item;

/**
 * SayHi发送信息Item
 * @author Alex
 *
 */
public class SayHiSendInfoItem {

	public SayHiSendInfoItem(){

	}

	/**
	 * SayHi发送信息Item
	 * @param isSendSuccess		发送是否成功（LoiId 和 isFollow 只有失败有）
	 * @param sayHiId			sayHi的ID（成功 或 失败码为HTTP_LCC_ERR_SAYHI_MAN_ALREADY_SEND_SAYHI才有）
	 * @param onlineStatus		是否在线
	 * @param loiId				意向信ID（失败码为HTTP_LCC_ERR_SAYHI_ANCHOR_ALREADY_SEND_LOI才有）
	 * @param isFollow			是否是关注的（发送失败才有）
	 */
	public SayHiSendInfoItem(
						 boolean isSendSuccess,
                         String sayHiId,
						 int onlineStatus,
						 String loiId,
						 boolean isFollow){
		this.isSendSuccess = isSendSuccess;
		this.sayHiId = sayHiId;
		if( onlineStatus < 0 || onlineStatus >= AnchorOnlineStatus.values().length ) {
			this.onlineStatus = AnchorOnlineStatus.Unknown;
		} else {
			this.onlineStatus = AnchorOnlineStatus.values()[onlineStatus];
		}
		this.loiId = loiId;
		this.isFollow = isFollow;
	}

	public boolean isSendSuccess;
	public String sayHiId;
	public AnchorOnlineStatus onlineStatus;
	public String loiId;
	public boolean isFollow;

	@Override
	public String toString() {
		return "SayHiSendInfoItem[isSendSuccess:"+isSendSuccess
				+ " sayHiId:"+sayHiId
				+ " onlineStatus:"+onlineStatus
				+ " loiId:"+loiId
				+ " isFollow:"+isFollow
				+ "]";
	}
}
