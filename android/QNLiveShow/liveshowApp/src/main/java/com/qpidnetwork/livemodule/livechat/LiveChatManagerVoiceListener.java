package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;

/**
 * LiveChat管理回调接口类
 * @author Samson Fan
 *
 */
public interface LiveChatManagerVoiceListener {
	// ---------------- 语音回调函数(Voice) ----------------
	/**
	 * 发送语音（包括获取语音验证码(livechat)、上传语音文件(livechat)、发送语音(livechat)）回调
	 * @param errType	处理结果错误代码
	 * @param errno		上传文件的错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnSendVoice(LiveChatErrType errType, String errno, String errmsg, LCMessageItem item);
	
	/**
	 * 获取语音（包括下载语音(livechat)）回调
	 * @param errType	处理结果错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnGetVoice(LiveChatErrType errType, String errmsg, LCMessageItem item);
	
	/**
	 * 接收语音消息回调
	 * @param item		消息item
	 */
	public void OnRecvVoice(LCMessageItem item) ;
}
