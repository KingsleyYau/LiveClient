package com.qpidnetwork.livemodule.livechathttprequest;


/**
 * LiveChat上传语音文件
 */
public interface OnLCUploadVoiceCallback {
	public void OnLCUploadVoice(long requestId, boolean isSuccess, String errno, String errmsg, String voiceId);
}
