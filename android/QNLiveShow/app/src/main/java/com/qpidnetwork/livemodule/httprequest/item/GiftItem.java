package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 礼物基础信息Item
 * @author Hunter Mun
 *
 */
public class GiftItem {
	
	public enum GiftType {
		Unknown,
		Normal,
		Advanced
	}
	
	public GiftItem(){
		
	}
	
	/**
	 * 礼物基础信息Item
	 * @param id			礼物ID
	 * @param name			礼物名称
	 * @param smallImgUrl	礼物小图标（用于文本聊天窗显示）
	 * @param middleImgUrl	发送列表显示的图片url
	 * @param bigImageUrl	礼物在直播间显示的资源url(大礼物播放使用)
	 * @param credit		发送礼物所需的信用点
	 * @param canMultiClick	是否可连击
	 * @param giftType		礼物类型
	 * @param updateTime	礼物最后更新时间戳
	 * @param giftChooser   礼物可选发送数目
	 */
	public GiftItem(String id,
						String name,
						String smallImgUrl,
						String middleImgUrl,
						String bigImageUrl,
						String srcFlashUrl,
						String srcWebpUrl,
						double credit,
						boolean canMultiClick,
						int giftType,
						int levelLimit,
						int lovelevelLimit,
						int updateTime,
						int[] giftChooser){
		this.id = id;
		this.name = name;
		this.smallImgUrl = smallImgUrl;
		this.middleImgUrl = middleImgUrl;
		this.bigImageUrl = bigImageUrl;
		this.srcFlashUrl = srcFlashUrl;
		this.srcWebpUrl = srcWebpUrl;
		this.credit = credit;
		this.canMultiClick = canMultiClick;
		
		if( giftType < 0 || giftType >= GiftType.values().length ) {
			this.giftType = GiftType.Unknown;
		} else {
			this.giftType = GiftType.values()[giftType];
		}
		
		this.levelLimit = levelLimit;
		this.lovelevelLimit = lovelevelLimit;
		this.updateTime = updateTime;
		this.giftChooser = giftChooser;
	}
	
	public String id;
	public String name;
	public String smallImgUrl;
	public String middleImgUrl;
	public String bigImageUrl;
	public String srcFlashUrl;
	public String srcWebpUrl;
	public double credit;
	public boolean canMultiClick;
	public GiftType giftType;
	public int levelLimit;
	public int lovelevelLimit;
	public int updateTime;
	public int[] giftChooser;
}
