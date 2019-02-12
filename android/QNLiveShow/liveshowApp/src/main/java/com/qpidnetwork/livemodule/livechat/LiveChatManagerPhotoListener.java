package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;

/**
 * LiveChat管理回调接口类
 * @author Samson Fan
 *
 */
public interface LiveChatManagerPhotoListener {
	// ---------------- 图片回调函数(Private Album) ----------------
	/**
	 * 发送图片（包括上传图片文件(php)、发送图片(livechat)）回调
	 * @param errType	处理结果错误代码
	 * @param errno		上传文件的错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnSendPhoto(LiveChatErrType errType, String errno, String errmsg, LCMessageItem item);
	
	/**
	 * 购买图片（包括付费购买图片(php)）
	 * @param errno		请求错误代码
	 * @param errmsg	错误描述
	 * @param item		消息item
	 */
	public void OnPhotoFee(boolean success, String errno, String errmsg, LCMessageItem item);
	
	/**
	 * 获取图片（获取对方私密照片(php)、显示图片(livechat)）回调
	 * @param errType	处理结果错误代码
	 * @param errno		购买/下载请求失败的错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnGetPhoto(LiveChatErrType errType, String errno, String errmsg, LCMessageItem item);
	
	/**
	 * 接收图片消息回调
	 * @param item		消息item
	 */
	public void OnRecvPhoto(LCMessageItem item);
}
