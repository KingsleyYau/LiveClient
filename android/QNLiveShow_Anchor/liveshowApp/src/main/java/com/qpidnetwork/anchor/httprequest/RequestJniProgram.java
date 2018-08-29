package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.HangoutInviteReplyType;

/**
 * 多人互动直播间相关接口
 * @author Hunter Mun
 * @since 2017-5-22
 */
public class RequestJniProgram {

	//节目列表类型
	public enum ProgramSortType{
		Unknow,		// 未知
		UnVerify,	// 待审核
		VerifyPass,	// 已通过审核且未开播
		VerifyReject,	//被拒绝
		History		//直播间结束推荐列表

	}


	/**
	 * 7.1.获取节目列表
	 *
	 * @param type
	 * @param start
	 * @param step
	 * @param callback
	 * @return
	 */
	static public  long GetProgramList(ProgramSortType type, int start, int step, OnGetProgramListCallback callback) {
		return GetProgramList(type.ordinal(), start, step, callback);
	}
	static protected native long GetProgramList(int type, int start, int step, OnGetProgramListCallback callback);

	/**
	 * 7.2.获取节目未读数(用于观众端向服务器获取节目未读数，已购或已关注的开播中节目数 + 退票未读数)
	 *
	 * @param callback
	 * @return
	 */
	static public native long GetNoReadNumProgram(OnGetNoReadNumProgramCallback callback);


	/**
	 * 7.3.获取可进入的节目信息(用于主播端向服务器获取节目未读数，包括节目未读数量<审核通过/取消> + 已开播数量)
	 *
	 * @param callback
	 * @return
	 */
	static public native long GetShowRoomInfo(String liveShowId, OnGetShowRoomInfoCallback callback);

	/**
	 * 7.4.检测公开直播开播类型
	 * @param callback
	 * @return
	 */
	static public native long CheckPublicRoomType(OnCheckPublicRoomTypeCallback callback);

}
