package com.qpidnetwork.anchor.httprequest;

/**
 * 预约私密 
 * @author Hunter Mun
 * @since 2017.8.17
 */
public class RequstJniSchedule {
	
	public enum ScheduleInviteType{
		AnchorPending,			//等待主播处理
		AudiencePending,		//等待观众处理
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
	 * 4.2.主播接受预约(邀请主播接受观众发起的预约邀请)
	 * @param invitationId
	 * @param callback
	 * @return
	 */
	static public native long AcceptScheduledInvite(String invitationId, OnRequestCallback callback);

	/**
	 * 4.3.主播拒绝预约邀请(主播拒绝观众发起的预约邀请)
	 * @param invitationId
	 * @param callback
	 * @return
	 */
	static public native long RejectScheduledInvite(String invitationId, OnRequestCallback callback);
	
	/**
	 * 4.4.获取预约邀请未读或待处理数量
	 * @param callback
	 * @return
	 */
	static public native long GetCountOfUnreadAndPendingInvite(OnGetCountOfUnreadAndPendingInviteCallback callback);

	/**
	 * 4.5.获取已确认的预约数(用于主播端获取已确认的预约数量)
	 * @param callback
	 * @return
	 */
	static public native long GetScheduledAcceptNum(OnGetScheduledAcceptNumCallback callback);

	
	/**
	 * 4.6.主播接受立即私密邀请(用于主播接受观众发送的立即私密邀请)
	 * @param inviteId              // 邀请ID
	 * @param callback
	 * @return
	 */
	static public native long AcceptInstanceInvite(String inviteId, OnAcceptInstanceInviteCallback callback);

	/**
	 * 4.7.主播拒绝立即私密邀请(用于主播拒绝观众发送的立即私密邀请)
	 * @param inviteId              // 邀请ID
	 * @param rejectReason         // 拒绝理由（可无）
	 * @param callback
	 * @return
	 */
	static public native long RejectInstanceInvite(String inviteId, String rejectReason, OnRequestCallback callback);

	/**
	 * 4.8.主播取消已发的立即私密邀请
	 * @param inviteId              // 邀请ID
	 * @param callback
	 * @return
	 */
	static public native long CancelInstantInvite(String inviteId, OnRequestCallback callback);

	/**
	 * 4.9.设置直播间为开始倒数
	 * @param roomId              // 直播间ID
	 * @param callback
	 * @return
	 */
	static public native long SetRoomCountDown(String roomId, OnRequestCallback callback);


}
