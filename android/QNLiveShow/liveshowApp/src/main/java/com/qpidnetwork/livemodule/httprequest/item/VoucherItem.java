package com.qpidnetwork.livemodule.httprequest.item;

import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory.EmotionTag;

public class VoucherItem {
	
	public enum VoucherUseSchemeType{
		Any,			//不限
		Public,			//公开
		Private			//私密
	}
	
	public enum VoucherUseRoleType{	
		Any,				//不限
		SpecialAnchor,		//指定主播
		NeverLive			//没看过直播的主播
	}

	public enum VoucherType {
		Broadcast,			// 直播间试聊劵
		Livechat			// livechat试聊劵
	}
	
	public VoucherItem(){
		
	}
	
	/**
	 * @param voucherId					//试用券ID
	 * @param voucherPhotoUrl			//试用券图标url
	 * @param voucherPhotoUrlMobile     //试用券图标url（移动端使用）
	 * @param voucherDesc				//试用券描述
	 * @param useScheme					//可用的直播间类型（0：不限，1：公开，2：私密）
	 * @param useRole					//主播类型（0：不限，1：没看过直播的主播，2：指定主播）
	 * @param anchorId					//主播ID
	 * @param anchorNickname			//主播昵称
	 * @param anchorPhotoUrl			//主播头像url
	 * @param grantedDate				//获取时间（1970年起的秒数）
	 * @param startValidDate            //有效开始时间
	 * @param expDate					//过期时间（1970年起的秒数）
	 * @param isRead					//已读状态（0：未读，1：已读）
	 */
	public VoucherItem(String voucherId,
					String voucherPhotoUrl,
					String voucherPhotoUrlMobile,
					String voucherDesc,
					int useScheme,
					int useRole,
					String anchorId,
					String anchorNickname,
					String anchorPhotoUrl,
					long grantedDate,
					long startValidDate,
					long expDate,
					boolean isRead,
					int offsetMin,
					int voucherType){
		this.voucherId = voucherId;
		this.voucherPhotoUrl = voucherPhotoUrl;
		this.voucherPhotoUrlMobile = voucherPhotoUrlMobile;
		this.voucherDesc = voucherDesc;
		
		if( useScheme < 0 || useScheme >= VoucherUseSchemeType.values().length ) {
			this.useScheme = VoucherUseSchemeType.Any;
		} else {
			this.useScheme = VoucherUseSchemeType.values()[useScheme];
		}
		
		if( useRole < 0 || useRole >= VoucherUseRoleType.values().length ) {
			this.useRole = VoucherUseRoleType.Any;
		} else {
			this.useRole = VoucherUseRoleType.values()[useRole];
		}
		
		this.anchorId = anchorId;
		this.anchorNickname = anchorNickname;
		this.anchorPhotoUrl = anchorPhotoUrl;
		this.grantedDate = grantedDate;
		this.startValidDate = startValidDate;
		this.expDate = expDate;
		this.isRead = isRead;
		this.offsetMin = offsetMin;

		if( voucherType < 0 || voucherType >= VoucherType.values().length ) {
			this.voucherType = VoucherType.Broadcast;
		} else {
			this.voucherType = VoucherType.values()[voucherType];
		}

	}

	public VoucherType voucherType;
	public String voucherId;
	public String voucherPhotoUrl;
	public String voucherPhotoUrlMobile;
	public String voucherDesc;
	public VoucherUseSchemeType useScheme;
	public VoucherUseRoleType useRole;
	public String anchorId;
	public String anchorNickname;
	public String anchorPhotoUrl;
	public long grantedDate;
	public long startValidDate;
	public long expDate;
	public boolean isRead;
	public int offsetMin;
}
