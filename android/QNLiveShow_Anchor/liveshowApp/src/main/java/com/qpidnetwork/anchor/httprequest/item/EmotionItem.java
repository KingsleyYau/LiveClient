package com.qpidnetwork.anchor.httprequest.item;

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
	 * @param emotionId         表情ID
	 * @param emoSign			表情文本标记
	 * @param emoUrl			表情图片url
	 * @param emoType			表情类型
	 * @param emoIconUrl		表情icon图片url，用于移动端在表情列表显示
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
