package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;

public interface LiveChatManagerMagicIconListener {

	// ----------- 小高级表情回调函数(MagicIcon) ----------------
	/**
	 * 获取小高级表情配置回调
	 * @param errno	    处理结果错误代码
	 * @param errmsg	处理结果描述
	 */
	public void OnGetMagicIconConfig(boolean success, String errno, String errmsg, MagicIconConfig item);
	
	
	/**
	 * 发送小高级表情回调
	 * @param errType	处理结果错误代码
	 * @param errmsg	处理结果描述
	 * @param item		消息item
	 * @return
	 */
	public void OnSendMagicIcon(LiveChatErrType errType, String errmsg, LCMessageItem item);
	
	/**
	 * 接收小高级表情消息回调
	 * @param item		消息item
	 */
	public void OnRecvMagicIcon(LCMessageItem item);
	
	/**
	 * 下载小高级表情原图成功回调
	 * @param success
	 * @param magicIconItem
	 */
	public void OnGetMagicIconSrcImage(boolean success, LCMagicIconItem magicIconItem);
	
	/**
	 * 下载小高级表情拇子图成功回调
	 * @param success
	 * @param magicIconItem
	 */
	public void OnGetMagicIconThumbImage(boolean success, LCMagicIconItem magicIconItem);

}
