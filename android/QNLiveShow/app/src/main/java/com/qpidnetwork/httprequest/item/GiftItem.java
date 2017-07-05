package com.qpidnetwork.httprequest.item;


public class GiftItem {
	
	public enum GiftType{
		Unknown,
		Normal, 
		AdvancedAnimation
	}
	
	public GiftItem(){
		giftType = GiftType.Unknown;
	}
	
	/**
	 * 礼物bean
	 * @param id					//礼物ID
	 * @param name					//礼物名称
	 * @param smallimgurl			//礼物小图标（用于文本聊天窗显示）
	 * @param imgUrl				//发送列表显示的图片url
	 * @param srcUrl				//礼物在直播间显示的资源url
	 * @param coins					//发送礼物所需的金币
	 * @param multiClickable		//是否可连击
	 * @param type					//礼物类型
	 * @param updateTime			//礼物最后更新时间戳
	 */
	public GiftItem(String id,
					String name,
					String smallimgurl,
					String imgUrl,
					String srcUrl,
					double coins,
					boolean multiClickable,
					int type,
					int updateTime){
		this.id = id;
		this.name = name;
		this.smallimgurl = smallimgurl;
		this.imgUrl = imgUrl;
		this.srcUrl = srcUrl;
		this.coins = coins;
		this.multiClickable = multiClickable;
		
		if( type < 0 || type >= GiftType.values().length ) {
			this.giftType = GiftType.Normal;
		} else {
			this.giftType = GiftType.values()[type];
		}
		this.updateTime = updateTime;
	}

	public String id; 
	public String name;
	public String smallimgurl;
	public String imgUrl;
	public String srcUrl;
	public double coins;
	public boolean multiClickable;
	public GiftType giftType;
	public int updateTime;
}
