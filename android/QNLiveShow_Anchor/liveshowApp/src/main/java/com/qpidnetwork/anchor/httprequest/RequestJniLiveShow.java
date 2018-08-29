package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.TalentReplyType;
import com.qpidnetwork.anchor.httprequest.item.SetAutoPushType;
/**
 * 直播间相关接口
 * @author Hunter Mun
 * @since 2017-5-22
 */
public class RequestJniLiveShow {

	/**
	 * 3.1.获取直播间观众列表
	 * @param roomId
	 * @param start
	 * @param step
	 * @param callback
	 * @return
	 */
	static public native long GetAudienceListInRoom(String roomId, int start, int step, OnGetAudienceListCallback callback);


	/**
	 * 3.2.获取指定观众信息
	 * @param userId
	 * @param callback
	 * @return
	 */
	static public native long GetAudienceDetailInfo(String userId, OnGetAudienceDetailInfoCallback callback);


	/**
	 * 3.3. 获取礼物列表
	 * @param callback
	 * @return
	 */
	static public native long GetAllGiftList(OnGetGiftListCallback callback);

	/**
	 * 3.4. 获取主播直播间礼物列表
	 * @param roomId           直播间ID
	 * @param callback
	 * @return
	 */
	static public native long GiftLimitNumList(String roomId, OnGiftLimitNumListCallback callback);

	/**
	 * 3.5. 获取指定礼物详情
	 * @param giftId			礼物ID
	 * @param callback
	 * @return
	 */
	static public native long GetGiftDetail(String giftId, OnGetGiftDetailCallback callback);

	/**
	 * 3.6.获取文本表情列表
	 * @param callback
	 * @return
	 */
	static public native long GetEmotionList(OnGetEmotionListCallback callback);


	/**
	 * 3.7.主播回复才艺点播邀请
	 * @param talentInviteId		才艺点播邀请ID
	 * @param status				处理结果（1：同意，2：拒绝）
	 * @param callback
	 * @return
	 */
	static public long DealTalentRequest(String talentInviteId, TalentReplyType status, OnRequestCallback callback){
		return DealTalentRequest(talentInviteId, status.ordinal(), callback);
	}
	static protected native long DealTalentRequest(String talentInviteId, int status, OnRequestCallback callback);

	/**
	 * 3.8.设置主播公开直播间自动邀请状态
	 * @param status				处理结果（0：关闭，1：启动）
	 * @param callback
	 * @return
	 */
	static public long SetAutoPush(SetAutoPushType status, OnRequestCallback callback){
		return SetAutoPush( status.ordinal(), callback);
	}
	static protected native long SetAutoPush(int status, OnRequestCallback callback);
	
}
