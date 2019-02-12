package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.VideoPhotoType;

import java.util.ArrayList;

/**
 * LiveChat管理回调接口类
 * @author Samson Fan
 *
 */
public interface LiveChatManagerVideoListener {
	// ---------------- 微视频回调函数(Video) ----------------
	/**
	 * 获取视频图片文件回调
	 * @param errType	处理结果错误代码
	 * @param errno		下载请求失败的错误代码
	 * @param errmsg	处理结果描述
	 * @param userId	用户ID
	 * @param inviteId	邀请ID
	 * @param videoId	视频ID
	 * @param type		视频图片类型
	 * @param filePath	视频图片文件路径
	 * @param msgList	视频相关的聊天消息列表
	 * @return
	 */
	public void OnGetVideoPhoto(LiveChatErrType errType
            , String errno
            , String errmsg
            , String userId
            , String inviteId
            , String videoId
            , VideoPhotoType type
            , String filePath
            , ArrayList<LCMessageItem> msgList);

	/**
	 * 购买视频（包括付费购买视频(php)）
	 * @param errno		请求错误代码
	 * @param errmsg	错误描述
	 * @param item		消息item
	 */
	public void OnVideoFee(boolean success, String errno, String errmsg, LCMessageItem item);

	/**
	 * 开始获取视频文件回调
	 * @param userId	用户ID
	 * @param videoId	视频ID
	 * @param inviteId	邀请ID
	 * @param videoPath	视频文件路径
	 * @param msgList	视频相关的聊天消息列表
	 */
	public void OnStartGetVideo(String userId
            , String videoId
            , String inviteId
            , String videoPath
            , ArrayList<LCMessageItem> msgList);

	/**
	 * 获取视频文件回调
	 * @param errType	处理结果错误代码
	 * @param userId	用户ID
	 * @param videoId	视频ID
	 * @param inviteId	邀请ID
	 * @param videoPath	视频文件路径
	 * @param msgList	视频相关的聊天消息列表
	 */
	public void OnGetVideo(LiveChatErrType errType
            , String userId
            , String videoId
            , String inviteId
            , String videoPath
            , ArrayList<LCMessageItem> msgList);
	
	/**
	 * 接收图片消息回调
	 * @param item		消息item
	 */
	public void OnRecvVideo(LCMessageItem item);
}
