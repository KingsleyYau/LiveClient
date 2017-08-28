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
	 * @param inviteId
	 * @param isConfirmed
	 * @param callback
	 * @return
	 */
	static public native long HandleScheduledInvite(String inviteId, boolean isConfirmed, OnRequestCallback callback);
	
	/**
	 * 4.3.取消预约邀请
	 * @param inviteId
	 * @param callback
	 * @return
	 */
	static public native long CancelScheduledInvite(String inviteId, OnRequestCallback callback);
	
	static public native long GetCountOfUnreadAndPendingInvite(OnGetCountOfUnreadAndPendingInviteCallback callback);
}
