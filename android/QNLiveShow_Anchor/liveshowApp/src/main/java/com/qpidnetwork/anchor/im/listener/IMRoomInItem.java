package com.qpidnetwork.anchor.im.listener;

import java.io.Serializable;

public class IMRoomInItem implements Serializable{
	
	/**
	 * 直播间类型
	 * @author Hunter Mun
	 *
	 */
	public enum IMLiveRoomType {
		Unknown,				//未知
		FreePublicRoom,			//免费公开直播间
		NormalPrivateRoom,		//普通私密直播间
		PaidPublicRoom,			//付费公开直播间
		AdvancedPrivateRoom,	//豪华私密直播间
		HangoutRoom				//多人互动直播间
	}

	public enum IMLiveStatus {
		Unknown,					// 未知
		Init,						// 初始
		ReciprocalStart,			// 开始倒数中
		Online,						// 在线
		Arrearage,					// 欠费中
		ReciprocalEnd,				// 结束倒数中
		Close						// 关闭
	}

	/**
	 * 公开直播间类型
	 * @author Hunter Mun
	 *
	 */
	public enum IMPublicRoomType {
		Unknown,			//未知
		Common,				//普通公开
		Program				//节目
	}
	
	private static final long serialVersionUID = -2781675685594191161L;
	
	public IMRoomInItem(){
		
	}
	
	/**
	 * @param anchorId			主播ID
	 * @param roomId			直播间ID
	 * @param roomType			直播间类型
	 * @param pushRtmpUrls		视频流url（字符串数组）
	 * @param leftSeconds		开播前的倒数秒数
	 * @param audienceLimitNum	最大人数限制
	 * @param pullRtmpUrls      男士视频流url(可无，无或空表示男士没有启动视频互动)
	 * @param isHasOneOnOneAuth 是否有私密直播开播权限
	 * @param isHasBookingAuth 是否有预约私密直播开播权限
	 * @param currentPush		当前推流状态
	 */	
	public IMRoomInItem(String anchorId,
						String roomId,
						int roomType,
						String[] pushRtmpUrls,
						int leftSeconds,
						int audienceLimitNum,
						String[] pullRtmpUrls,
						int status,
						int liveShowType,
						boolean isHasOneOnOneAuth,
						boolean isHasBookingAuth,
						IMCurrentPushInfoItem currentPush){
		this.anchorId = anchorId;
		this.roomId = roomId;
		if( roomType < 0 || roomType >= IMLiveRoomType.values().length ) {
			this.roomType = IMLiveRoomType.Unknown;
		} else {
			this.roomType = IMLiveRoomType.values()[roomType];
		}
		this.pushRtmpUrls = pushRtmpUrls;
		this.leftSeconds = leftSeconds;
		this.audienceLimitNum = audienceLimitNum;
		this.pullRtmpUrls = pullRtmpUrls;
		if( status < 0 || status >= IMLiveStatus.values().length ) {
			this.status = IMLiveStatus.Unknown;
		} else {
			this.status = IMLiveStatus.values()[status];
		}
		if( liveShowType < 0 || liveShowType >= IMPublicRoomType.values().length ) {
			this.liveShowType = IMPublicRoomType.Unknown;
		} else {
			this.liveShowType = IMPublicRoomType.values()[liveShowType];
		}
		this.isHasOneOnOneAuth = isHasOneOnOneAuth;
		this.isHasBookingAuth = isHasBookingAuth;
		this.currentPush = currentPush;
	}

	public String anchorId;
	public String roomId;
	public IMLiveRoomType roomType;
	public String [] pushRtmpUrls;
	public int leftSeconds;
	public int audienceLimitNum;
	public String [] pullRtmpUrls;
	public IMLiveStatus status;
	public IMPublicRoomType liveShowType;
	public boolean isHasOneOnOneAuth;
	public boolean isHasBookingAuth;
	public IMCurrentPushInfoItem currentPush;
	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMRoomInItem[");
		sb.append("anchorId:");
		sb.append(anchorId);
		sb.append(" roomId:");
		sb.append(roomId);
		sb.append(" leftSeconds:");
		sb.append(leftSeconds);
		sb.append(" status:");
		sb.append(status);
		sb.append(" isHasOneOnOneAuth:");
		sb.append(isHasOneOnOneAuth);
		sb.append(" isHasBookingAuth:");
		sb.append(isHasBookingAuth);
		sb.append("]");
		return sb.toString();
	}
}
