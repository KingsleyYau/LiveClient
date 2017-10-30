package com.qpidnetwork.livemodule.httprequest.item;

public class EmotionCategory {
	
	public enum EmotionTag{
		Unknown,
		Standard,
		Advanced
	}

	public EmotionCategory(){
		
	}
	
	/**
	 * 表情分类Item
	 * @param emotionTag
	 * @param emotionTagName
	 * @param emotionErrorMsg		//此种表情不可用时提示（结合IM接口3.1）
	 * @param emotionTagUrl
	 * @param emotionList
	 */
	public EmotionCategory(int emotionTag,
						String emotionTagName,
						String emotionErrorMsg,
						String emotionTagUrl,
						EmotionItem[] emotionList){
		if( emotionTag < 0 || emotionTag >= EmotionTag.values().length ) {
			this.emotionTag = EmotionTag.Unknown;
		} else {
			this.emotionTag = EmotionTag.values()[emotionTag];
		}
		
		this.emotionTagName = emotionTagName;
		this.emotionErrorMsg = emotionErrorMsg;
		this.emotionTagUrl = emotionTagUrl;
		this.emotionList = emotionList;
	}
	
	public EmotionTag emotionTag;
	public String emotionTagName;
	public String emotionErrorMsg;
	public String emotionTagUrl;
	public EmotionItem[] emotionList;
}
