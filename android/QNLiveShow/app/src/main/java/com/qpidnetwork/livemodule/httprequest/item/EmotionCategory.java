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
	 * @param emotionErrorMsg		//此种表情不可用时提示（结合IM接口3.1）
	 * @param emotionList
	 */
	public EmotionCategory(int emotionTag,
						String emotionErrorMsg,
						EmotionItem[] emotionList){
		if( emotionTag < 0 || emotionTag >= EmotionTag.values().length ) {
			this.emotionTag = EmotionTag.Unknown;
		} else {
			this.emotionTag = EmotionTag.values()[emotionTag];
		}
		
		this.emotionErrorMsg = emotionErrorMsg;
		this.emotionList = emotionList;
	}
	
	public EmotionTag emotionTag;
	public String emotionErrorMsg;
	public EmotionItem[] emotionList;
}
