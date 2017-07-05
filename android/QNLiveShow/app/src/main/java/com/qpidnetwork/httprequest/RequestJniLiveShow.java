package com.qpidnetwork.httprequest;

/**
 * 直播间相关接口
 * @author Hunter Mun
 * @since 2017-5-22
 */
public class RequestJniLiveShow {
	
	/**
	 * 3.1.主播创建直播室
	 * @param roomName
	 * @param roomPhotoId
	 * @param callback
	 * @return
	 */
	static public native long CreateLiveRoom(String roomName, String roomPhotoId, OnCreateLiveRoomCallback callback);
	
	/**
	 * 3.2.用于主播Crash或异常时，重新启动恢复状态使用
	 * @param callback
	 * @return
	 */
	static public native long GetCreatedLiveRoom(OnCreateLiveRoomCallback callback);
	
	/**
	 * 3.3.主播结束直播，退出房间
	 * @param roomId
	 * @param callback
	 * @return
	 */
	static public native long CloseLiveRoom(String roomId, OnRequestCallback callback);
	
	/**
	 * 3.4.用于获取固定前（20 暂定）观众列表
	 * @param roomId
	 * @param callback
	 * @return
	 */
	static public native long GetLimitAudienceListInRoom(String roomId, OnGetAudienceListCallback callback);
	
	/**
	 * 3.5.根据分页Id及步长获取指定观众列表
	 * @param roomId
	 * @param start
	 * @param step
	 * @param callback
	 * @return
	 */
	static public native long GetPagingAudienceListInRoom(String roomId, int start, int step, OnGetAudienceListCallback callback);
	
	
	/**
	 * 3.6.分页获取热播列表
	 * @param start
	 * @param step
	 * @param callback
	 * @return
	 */
	static public native long GetHotLiveList(int start, int step, OnGetLiveRoomListCallback callback);
	
	/**
	 * 3.7. 获取礼物列表
	 * @param callback
	 * @return
	 */
	static public native long GetAllGiftList(OnGetAllGiftCallback callback);
	
	/**
	 * 3.8. 获取直播间可发送的礼物列表
	 * @param roomId
	 * @param callback
	 * @return
	 */
	static public native long GetSendableGiftList(String roomId, OnGetSendableGiftListCallback callback);
	
	/**
	 * 3.9. 获取指定礼物详情
	 * @param giftId
	 * @param callback
	 * @return
	 */
	static public native long GetGiftDetail(String giftId, OnGetGiftDetailCallback callback);
	
	/**
	 * 3.10. 获取开播封面图列表
	 * @param callback
	 * @return
	 */
	static public native long GetLiveCoverPhotoList(OnGetLiveCoverPhotoListCallback callback);
	
	/**
	 * 3.11. 添加开播封面图
	 * @param photoId
	 * @param callback
	 * @return
	 */
	static public native long AddLiveCoverPhoto(String photoId, OnRequestCallback callback);
	
	/**
	 * 3.12. 设置开播默认使用封面图
	 * @param photoId
	 * @param callback
	 * @return
	 */
	static public native long SetDefaultUsedCoverPhoto(String photoId, OnRequestCallback callback);
	
	/**
	 * 3.13. 删除开播封面图
	 * @param photoId
	 * @param callback
	 * @return
	 */
	static public native long DeleteLiveCoverPhoto(String photoId, OnRequestCallback callback);
}
