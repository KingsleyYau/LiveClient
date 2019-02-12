package com.qpidnetwork.livemodule.livechathttprequest;


/**
 * LiveChat下载语音文件
 */
public interface OnLCPlayVoiceCallback {
	public void OnLCPlayVoice(long requestId, boolean isSuccess, String errno, String errmsg, String filePath);
}
