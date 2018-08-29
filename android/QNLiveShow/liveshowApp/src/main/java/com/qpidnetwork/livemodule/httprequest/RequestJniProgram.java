package com.qpidnetwork.livemodule.httprequest;


/**
 * 9. 节目接口
 * @author Hunter Mun
 * @since 2017-6-8
 */
public class RequestJniProgram {


	//节目列表类型
	public enum ProgramSortType{
		Unknow,		// 未知
		Start,		// 按节目开始时间排序
		Verify,		// 按节目审核时间排序
		Ad,			// 按广告排序
		Ticket,		// 已购票列表
		History     // 购票历史列表
	}

	//节目推荐列表类型
	public enum ShowRecommendListType{
		Unknow,					// 未知
		EndRecommend,			// 直播结束推荐<包括指定主播及其它主播
		PersonalRecommend,		// 主播个人节目推荐<仅包括指定主播>
		NoHostRecommend			// 不包括指定主播

	}

	/**
	 * 9.1.获取节目未读数(用于观众端向服务器获取节目未读数，已购或已关注的开播中节目数 + 退票未读数)
	 *
	 * @param callback
	 * @return
	 */
	static public native long GetNoReadNumProgram(OnGetNoReadNumProgramCallback callback);

	/**
	 * 9.2.获取节目列表
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
	 * 9.3.购买
	 *
	 * @param liveShowId  节目ID
	 * @param callback
	 * @return
	 */
	static public native long BuyProgram(String liveShowId, OnBuyProgramCallback callback);

	/**
	 * 9.4.关注/取消关注
	 *
	 * @param liveShowId   节目ID
	 * @param isCancel   	是否取消关注节目
	 * @param callback
	 * @return
	 */
	static public native long FollowShow(String liveShowId, boolean isCancel, OnFollowShowCallback callback);

	/**
	 * 9.5.获取可进入的节目信息接口
	 *
	 * @param liveShowId   节目ID
	 * @param callback
	 * @return
	 */
	static public native long GetShowRoomInfo(String liveShowId, OnGetShowRoomInfoCallback callback);

	/**
	 * 9.6.获取节目推荐列表
	 *
	 * @param type			节目推荐列表类型（EndRecommend：直播结束推荐<包括指定主播及其它主播>，PersonalRecommend：主播个人节目推荐<仅包括指定主播>，NoHostRecommend：不包括指定主播）
	 * @param start
	 * @param step
	 * @param anchorId        主播ID
	 * @param callback
	 * @return
	 */
	static public  long ShowListWithAnchorId(ShowRecommendListType type, int start, int step, String anchorId, OnShowListWithAnchorIdCallback callback) {
		return ShowListWithAnchorId(type.ordinal(), start, step, anchorId, callback);
	}
	static protected native long ShowListWithAnchorId(int type, int start, int step, String anchorId, OnShowListWithAnchorIdCallback callback);


}


