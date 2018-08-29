package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 主播信息Item
 * @author Hunter Mun
 *
 */
public class BindAnchorItem {

	public BindAnchorItem(){

	}

	/**
	 * 主播信息Item
	 * @param anchorId			主播ID
	 * @param useRoomType		可用的直播间类型（Any：不限，Public：公开，Private：私密）
	 * @param expTime			试用券到期时间（1970年起的秒数）
	 */
	public BindAnchorItem(String anchorId,
                          int useRoomType,
                          int expTime){
		this.anchorId = anchorId;
		if( useRoomType < 0 || useRoomType >= VoucherItem.VoucherUseSchemeType.values().length ) {
			this.useRoomType = VoucherItem.VoucherUseSchemeType.Any;
		} else {
			this.useRoomType = VoucherItem.VoucherUseSchemeType.values()[useRoomType];
		}
		this.expTime = expTime;

	}
	
	public String anchorId;
	public VoucherItem.VoucherUseSchemeType useRoomType;
	public int expTime;


	@Override
	public String toString() {
		return "BindAnchorItem[anchorId:"+anchorId
				+ " useRoomType:"+useRoomType
				+ " expTime:"+expTime
				+ "]";
	}
}
