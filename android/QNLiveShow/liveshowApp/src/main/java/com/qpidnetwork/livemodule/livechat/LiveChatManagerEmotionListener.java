package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigItem;

/**
 * LiveChat管理回调接口类
 * @author Samson Fan
 *
 */
public interface LiveChatManagerEmotionListener {
	// ---------------- 高级表情回调函数(Emotion) ----------------
	/**
	 * 获取高级表情配置回调
	 * @param errno	    处理结果错误代码
	 * @param errmsg	处理结果描述
	 */
	public void OnGetEmotionConfig(boolean success, String errno, String errmsg, OtherEmotionConfigItem item);
	
	
	/**
	 * 发送高级表情回调
	 * @param errType	处理结果错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnSendEmotion(LiveChatErrType errType, String errmsg, LCMessageItem item);
	
	/**
	 * 接收高级表情消息回调
	 * @param item		消息item
	 */
	public void OnRecvEmotion(LCMessageItem item);
	
	/**
	 * 下载高级表情图片成功回调
	 * @param emotionItem	高级表情Item
	 */
	public void OnGetEmotionImage(boolean success, LCEmotionItem emotionItem);
	
	/**
	 * 下载高级表情播放图片成功回调
	 * @param emotionItem	高级表情Item
	 */
	public void OnGetEmotionPlayImage(boolean success, LCEmotionItem emotionItem);
	
	/**
	 * 下载高级表情3gp文件成功回调
	 * @param emotionItem	高级表情Item
	 */
	public void OnGetEmotion3gp(boolean success, LCEmotionItem emotionItem);
}
