package com.qpidnetwork.livemodule.httprequest.item;

public class EmotionItem {
	
	public EmotionItem(){
		
	}
	
	/**
	 * 表情Item
	 * @param emoSign
	 * @param emoUrl
	 */
	public EmotionItem(String emotionId,
					String emoSign,
	 				String emoUrl){
		this.emotionId = emotionId;
		this.emoSign = emoSign;
		this.emoUrl = emoUrl;
	}

	public String emotionId;
	public String emoSign;
	public String emoUrl;
}
