package com.qpidnetwork.livemodule.httprequest;

/**
 * 预约私密 
 * @author Hunter Mun
 * @since 2017.8.17
 */
public class RequstJniSchedule {
	
	public enum ScheduleInviteType{
		AudiencePending,		//等待观众处理
		AnchorPending,			//等待主播处理
		Confirmed,				//已确认
		History					//历史
	}
	
	/**
	 * 4.1.获取预约邀请列表
	 * @param type
	 * @param start
	 * @param step
	 * @param callback
	 * @return
	 */
	static public long GetScheduleInviteList(ScheduleInviteType type, int start, int step, OnGetScheduleInviteListCallback callback){
		return GetScheduleInviteList(type.ordinal(), start, step, callback);
	}
	static private native long GetScheduleInviteList(int type, int start, int step, OnGetScheduleInviteListCallback callback);
	
	/**
	 * 4.2.观众处理预约邀请
	 * @param invitationId
	 * @param isConfirmed
	 * @param callback
	 * @return
	 */
	static public native long HandleScheduledInvite(String invitationId, boolean isConfirmed, OnRequestCallback callback);
	
	/**
	 * 4.3.取消预约邀请
	 * @param invitationId
	 * @param callback
	 * @return
	 */
	static public native long CancelScheduledInvite(String invitationId, OnRequestCallback callback);
	
	/**
	 * 4.4.获取预约邀请未读或待处理数量
	 * @param callback
	 * @return
	 */
	static public native long GetCountOfUnreadAndPendingInvite(OnGetCountOfUnreadAndPendingInviteCallback callback);
	
	/**
	 * 4.5.获取新建预约邀请信息
	 * @param anchorId
	 * @return
	 */
	static public native long GetScheduleInviteCreateConfig(String anchorId, OnGetScheduleInviteCreateConfigCallback callback);
	
	/**
	 * 4.6.新建预约邀请
	 * @param userId
	 * @param timeId
	 * @param bookTime
	 * @param giftId
	 * @param giftNum
	 * @param callback
	 * @param needSms       是否需要短信通知
	 * @return
	 */
	static public native long CreateScheduleInvite(String userId, String timeId, int bookTime, String giftId, int giftNum, boolean needSms, OnRequestCallback callback);
	
	/**
	 * 4.7.观众处理立即私密邀请
	 * @param inviteId              // 邀请ID
	 * @param isConfirmed           // 是否同意（0: 否， 1: 是）
	 * @param callback
	 * @return
	 */
	static public native long AcceptInstanceInvite(String inviteId, boolean isConfirmed, OnAcceptInstanceInviteCallback callback);
}
