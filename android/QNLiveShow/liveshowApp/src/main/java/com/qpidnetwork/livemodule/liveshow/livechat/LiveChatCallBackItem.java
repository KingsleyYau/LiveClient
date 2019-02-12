package com.qpidnetwork.livemodule.liveshow.livechat;

public class LiveChatCallBackItem {
	
	public int errType;
	public String errNo;
	public String errMsg;
	public Object body;
	
	public LiveChatCallBackItem(){
		
	}
	
	public LiveChatCallBackItem(int errType, String errNo, String errMsg, Object body){
		this.errType = errType;
		this.errNo = errNo;
		this.errMsg = errMsg;
		this.body = body;
	}
}
