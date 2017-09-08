package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 礼物基础信息Item
 * @author Hunter Mun
 *
 */
public class GiftItem {
	
	public enum GiftType{
		Unknown,
		Normal,
		Advanced
	}
	
	public GiftItem(){
		
	}
	
	/**
	 * 礼物基础信息Item
	 * @param id				礼物ID
	 * @param name				礼物名称
	 * @param smallImgUrl		礼物小图url（一般用于文本聊天窗显示）
	 * @param middleImgUrl		礼物中图url（一般用于发送列表显示）
	 * @param bigImageUrl		礼物大图url（一般用于播放连击显示）
	 * @param srcFlashUrl		礼物在直播间显示/播放的flash资源url
	 * @param srcWebpUrl		礼物在直播间显示/播放的webp资源url
	 * @param credit			发送礼物所需的信用点
	 * @param canMultiClick		是否可连击
	 * @param giftType			礼物类型
	 * @param levelLimit		发送礼物的用户限制等级，发送者等级>=礼物等级才能发送
	 * @param lovelevelLimit 	发送礼物的亲密度限制，发送者亲密度>=礼物亲密度才能发送
	 * @param giftChooser   	礼物可选发送数目列表
	 * @param updateTime		礼物最后更新时间戳
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
					int[] giftChooser,
					int updateTime){
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
		this.giftChooser = giftChooser;
		this.updateTime = updateTime;
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
	public int[] giftChooser;
	public int updateTime;
}
