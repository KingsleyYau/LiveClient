package com.qpidnetwork.livemodule.httprequest;

/**
 * 直播间相关接口
 * @author Hunter Mun
 * @since 2017-5-22
 */
public class RequestJniLiveShow {
	
	//视频互动操作类型
	public enum VideoInteractiveOperateType{
		Start,		//开始
		Close		//关闭
	}
	
	/**
	 * 3.1.分页获取热播列表
	 * @param start
	 * @param step
	 * @param callback
	 * @return
	 */
	static public native long GetHotLiveList(int start, int step, OnGetHotListCallback callback);
	
	/**
	 * 3.2.分页获取收藏主播当前开播列表
	 * @param start
	 * @param step
	 * @param callback
	 * @return
	 */
	static public native long GetFollowingLiveList(int start, int step, OnGetFollowingListCallback callback);
	
	/**
	 * 3.3.获取本人有效直播间或邀请信息
	 * @param callback
	 * @return
	 */
	static public native long GetLivingRoomAndInvites(OnGetLivingRoomAndInvitesCallback callback);
	
	/**
	 * 3.4.获取直播间观众头像列表
	 * @param roomId
	 * @param page
	 * @param number
	 * @param callback
	 * @return
	 */
	static public native long GetAudienceListInRoom(String roomId, int page, int number, OnGetAudienceListCallback callback);
	
	/**
	 * 3.5. 获取礼物列表
	 * @param callback
	 * @return
	 */
	static public native long GetAllGiftList(OnGetGiftListCallback callback);
	
	/**
	 * 3.6. 获取直播间可发送的礼物列表
	 * @param roomId
	 * @param callback
	 * @return
	 */
	static public native long GetSendableGiftList(String roomId, OnGetSendableGiftListCallback callback);
	
	/**
	 * 3.7. 获取指定礼物详情
	 * @param giftId
	 * @param callback
	 * @return
	 */
	static public native long GetGiftDetail(String giftId, OnGetGiftDetailCallback callback);
	
	/**
	 * 3.8.获取文本表情列表
	 * @param callback
	 * @return
	 */
	static public native long GetEmotionList(OnGetEmotionListCallback callback);
	
	/**
	 * 3.9.获取指定立即私密邀请信息
	 * @param invitationId
	 * @param callback
	 * @return
	 */
	static public native long GetImediateInviteInfo(String invitationId, OnGetImediateInviteInfoCallback callback);
	
	/**
	 * 3.10.获取才艺点播列表
	 * @param roomId
	 * @param callback
	 * @return
	 */
	static public native long GetTalentList(String roomId, OnGetTalentListCallback callback);
	
	/**
	 * 3.11.获取才艺点播邀请状态
	 * @param roomId
	 * @param talentId
	 * @param callback
	 * @return
	 */
	static public native long GetTalentInviteStatus(String roomId, String talentInviteId, OnGetTalentInviteStatusCallback callback);
	
	/**
	 * 3.12.获取指定观众信息
	 * @param userId
	 * @param callback
	 * @return
	 */
	static public native long GetAudienceDetailInfo(String userId, OnGetAudienceDetailInfoCallback callback);
	
	/**
	 * 3.13.观众开始/结束视频互动
	 * @param roomId
	 * @param operateType
	 * @param callback
	 * @return
	 */
	static public long StartOrStopVideoInteractive(String roomId, VideoInteractiveOperateType operateType, OnStartOrStopVideoInteractiveCallback callback){
		return StartOrStopVideoInteractive(roomId, operateType.ordinal(), callback);
	}
	static protected native long StartOrStopVideoInteractive(String roomId, int operateType, OnStartOrStopVideoInteractiveCallback callback);
	
	/**
	 * 3.14.获取推荐主播列表
	 * @param number
	 * @param callback
	 * @return
	 */
	static public native long GetPromoAnchorList(int number, OnGetPromoAnchorListCallback callback);
	
}
