package com.qpidnetwork.livemodule.httprequest.item;

import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory.EmotionTag;

public class EmotionItem {
	
	public enum EmotionActionTag{
		Unknown,
		Static,             // 静态表情
		DYNAMIC				// 动画表情
	}
	
	public EmotionItem(){
		
	}
	
	/**
	 * 表情Item
	 * @param emoSign
	 * @param emoUrl
	 */
	public EmotionItem(String emotionId,
					String emoSign,
	 				String emoUrl,
	 				int emoType,
	 				String emoIconUrl){
		this.emotionId = emotionId;
		this.emoSign = emoSign;
		this.emoUrl = emoUrl;
		if( emoType < 0 || emoType >= EmotionActionTag.values().length ) {
			this.emoType = EmotionActionTag.Unknown;
		} else {
			this.emoType = EmotionActionTag.values()[emoType + 1];
		}
		this.emoIconUrl = emoIconUrl;
	}

	public String emotionId;
	public String emoSign;
	public String emoUrl;
	EmotionActionTag emoType;
	public String emoIconUrl;
}
