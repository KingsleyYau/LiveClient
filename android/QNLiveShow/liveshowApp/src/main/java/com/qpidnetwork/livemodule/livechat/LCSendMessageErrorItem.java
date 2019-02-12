package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;

import java.io.Serializable;

/**
 * 发送消息失败错误状态
 * @author Hunter Mun
 * @since 2016.11.21
 */
public class LCSendMessageErrorItem implements Serializable{
	
	private static final long serialVersionUID = 3644421082178195257L;

	//Livechat error
	public LiveChatErrType errType;
	
	public String errno;
	
	public String errMsg;
	
	public LCSendMessageErrorItem(LiveChatErrType errType, String errno, String errMsg){
		this.errType = errType;
		this.errno = errno;
		this.errMsg = errMsg;
	}
}
