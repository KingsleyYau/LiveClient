package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;

import java.util.ArrayList;

/**
 * LiveChat管理回调接口类
 * @author Samson Fan
 *
 */
public interface LiveChatManagerMessageListener {
	// ---------------- 文字聊天回调函数(message) ----------------
	/**
	 * 发送文本聊天消息回调
	 * @param errType	错误代码
	 * @param errmsg	错误描述
	 * @param item		消息item
	 * @return
	 */
	public void OnSendMessage(LiveChatErrType errType, String errmsg, LCMessageItem item);
	
	/**
	 * 接收聊天文本消息回调
	 * @param item		消息item
	 */
	public void OnRecvMessage(LCMessageItem item);
	
	/**
	 * 接收警告消息回调
	 * @param item		消息item
	 */
	public void OnRecvWarning(LCMessageItem item);
	
	/**
	 * 接收用户正在编辑消息回调 
	 * @param fromId	用户ID
	 */
	public void OnRecvEditMsg(String fromId);
	
	/**
	 * 接收系统消息回调
	 * @param item		消息item
	 */
	public void OnRecvSystemMsg(LCMessageItem item);
	
	/**
	 * 接收发送待发列表不成功消息
	 * @param errType	不成功原因
	 * @param msgList	待发列表
	 */
	public void OnSendMessageListFail(LiveChatErrType errType, ArrayList<LCMessageItem> msgList);
}
