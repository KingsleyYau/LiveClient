package com.qpidnetwork.livemodule.liveshow.livechat.popEmotion;

/**
 * 需要弹出的表情
 * @author Jagger
 * 2017-5-9
 * @param <T>
 */
public class PopEmotionItem<T> {
	
	public enum EmotionType{
		MagicIcon,
		Emotion
	}
	
	/**
	 * 存入表情对象
	 */
	public T emotion;
	
	/**
	 * 表情类型(高表,小高表)
	 */
	public EmotionType type;
	
//	private T tag;
//
//	public T getTag() {
//		return tag;
//	}
//
//	public void setTag(T tag) {
//		this.tag = tag;
//	}
	
}
