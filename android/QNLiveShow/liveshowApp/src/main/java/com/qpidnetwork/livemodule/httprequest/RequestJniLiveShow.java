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
	 * 推荐场景类型
	 */
	public enum PromotionCategoryType{
		Unknown,
		LiveRoom,
		AnchorPersonal
	}

	/**
	 * 场次礼物类型
	 */
	public enum GiftRoomType{
		Unknown,
		Public,
		Private
	}
	
	/**
	 * 3.1.分页获取热播列表
	 * @param start
	 * @param step
	 * @param hasWatch  是否只获取观众看过的主播（0：否  1： 是   ）
	 * @param isForTest 是否可看到测试主播（0：否，1：是）
	 * @param callback
	 * @return
	 */
	static public native long GetHotLiveList(int start, int step, boolean hasWatch, boolean isForTest, OnGetHotListCallback callback);
	
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
	 * @param start
	 * @param step
	 * @param callback
	 * @return
	 */
	static public native long GetAudienceListInRoom(String roomId, int start, int step, OnGetAudienceListCallback callback);
	
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
	 * @param talentInviteId
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
	 * @param type
	 * @param userId
	 * @param callback
	 * @return
	 */
	static public long GetPromoAnchorList(int number, PromotionCategoryType type, String userId, OnGetPromoAnchorListCallback callback){
		return GetPromoAnchorList(number, type.ordinal(), userId, callback);
	}
	static protected native long GetPromoAnchorList(int number, int type, String userId, OnGetPromoAnchorListCallback callback);

	/**
	 * 3.15.获取页面推荐主播列表
	 * @param callback
	 * @return
	 */
//	static public long GetPageRecommendAnchorList(PromotionCategoryType type, OnGetPromoAnchorListCallback callback){
//		return GetPageRecommendAnchorList(callback);
//	}
	static public native long GetPageRecommendAnchorList(OnGetPageRecommendAnchorListCallback callback);

	/**
	 * 3.16.获取为的联系人列表
	 * @param start
	 * @param step
	 * @param callback
	 * @return
	 */
	static public native long GetMyContactList(int start, int step, OnGetMyContactListCallback callback);

	/**
	 * 3.17.获取虚拟礼物分类列表
	 * @param roomType		场次类型
	 * @param callback
	 * @return
	 */
	static public long GetGiftTypeList(GiftRoomType roomType, OnGetGiftTypeListCallback callback){
		return GetGiftTypeList(roomType.ordinal(),  callback);
	}
	static protected native long GetGiftTypeList(int roomType, OnGetGiftTypeListCallback callback);


}
